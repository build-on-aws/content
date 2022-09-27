---
layout: blog.11ty.js
title: Data processing with Kafka Streams - An overview of stateless operations
description: Learn stateless operations in Kafka Streams with practical examples.
tags:
  - kafka
  - data
  - stream-processing
  - java
authorGithubAlias: abhirockzz
authorName: Abhishek Gupta
date: 2022-07-14
---

[Apache Kafka](https://kafka.apache.org/documentation/) serves as a key component in data architectures. It has a rich ecosystem for building scalable data-intensive services including data pipelines, etc.

- Kafka ([Producer](https://kafka.apache.org/documentation/#producerapi) and [Consumer](https://kafka.apache.org/documentation/#consumerapi)) client APIs allow you to choose from a variety of [programming languages](https://cwiki.apache.org/confluence/display/kafka/clients) to produce and consume data from Kafka topics.
- You can integrate heterogenous data systems using [Kafka Connect](https://kafka.apache.org/documentation/#connect) which has an extensive suite of pre-built connectors and a framework that allows you to build custom integrations.
- You can use [Kafka Streams](https://kafka.apache.org/documentation/streams/) (Java library) to develop streaming applications to process data flowing through Kafka topics.

Common requirements in data processing include filtering data, transforming it from one form to another, applying an action to each data record etc. These are often categorized as **stateless** operations. Kafka Streams is an ideal candidate if you want to apply stateless transformations on streaming data in Kafka. The [KStream](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html) abstraction (part of Kafka Streams DSL API) offers functions such as `filter`, `map`, `groupBy` etc. 

In this blog post, you will get an overview of these stateless operations along with practical examples and code snippets. I have grouped them into the following categories: `map`, `filter`, `group`, `terminal` along with some miscellaneous features.

### First things first ....

To work with Kafka Streams, you need to start by creating an instance of [KafkaStreams](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/KafkaStreams.html) that serves as the entry point of your stream processing application. It needs a [Topology](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/Topology.html) along with a `java.util.Properties` object for additional configuration.

```java
Properties config = new Properties();

config.setProperty(StreamsConfig.APPLICATION_ID_CONFIG, App.APP_ID);
config.setProperty(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
config.setProperty(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
config.setProperty(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass().getName());
```

A `Topology` is what defines your stream processing application - it's an *acyclic graph of sources, processors, and sinks*. Once you have defined the `Topology`, create the `KafkaStreams` instance and start processing.

```java
//details omitted
Topology topology = ....;

KafkaStreams app = new KafkaStreams(topology, config);
app.start();

//block
new CountdownLatch(1).await(); 
```

Let's dive into the specifics of the Kafka Streams APIs which implement these stateless operations.

### Transform data with `map` operations

[map](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#map(org.apache.kafka.streams.kstream.KeyValueMapper)) is a commonly used stateless operation which can be used to transform each record in the input `KStream` by applying a *mapper* function.

It is available in multiple flavors - `map`, `mapValues`, `flatMap`, `flatMapValues`

For example, to convert key *and* value to uppercase, use the `map` method:

```java
stream.map(new KeyValueMapper<String, String, KeyValue<String, String>>() {
    @Override
    public KeyValue<String, String> apply(String k, String v) {
            return new KeyValue<>(k.toUpperCase(), v.toUpperCase());
        }
    });
```

If all you need to alter is the value, use [mapValues](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#mapValues(org.apache.kafka.streams.kstream.ValueMapper)) :

```java
stream.mapValues(value -> value.toUpperCase());
```

[flatMap](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#flatMap(org.apache.kafka.streams.kstream.KeyValueMapper)) is similar to map, but it allows you to return multiple records (`KeyValue`s).

Say you have a stream of records `(foo <-> a,b,c)`, `(bar <-> d,e)` etc., where `foo` and `bar` are keys and `"a,b,c"`, `"d,e"` are CSV string values. You want the resulting stream to be as follows: `(foo,a)`, `(foo,b)`, `(foo,c)`, `(bar,d)`, `(bar,e)`. Here is an example of how this can be achieved:

```java
stream.flatMap(new KeyValueMapper<String, String, Iterable<? extends KeyValue<? extends String, ? extends String>>>() {
    @Override
    public Iterable<? extends KeyValue<? extends String, ? extends String>> apply(String k, String csvRecord) {
        String[] values = csvRecord.split(",");
        return Arrays.asList(values)
                    .stream()
                    .map(value -> new KeyValue<>(k, value))
                    .collect(Collectors.toList());
            }
    })
```

Each record in the stream gets `flatMap`ped such that each CSV (comma separated) value is first split into its constituents and a [KeyValue](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/KeyValue.html) pair is created for each part of the CSV string.

There is also [flatMapValues](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#flatMapValues(org.apache.kafka.streams.kstream.ValueMapper)) in case you only want to accept a value from the stream and return a collection of values.

### Include/Exclude data using `filter`

For example, if values in a topic are words and you want to include the ones which are greater than a specified length. You can use [filter](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#filter(org.apache.kafka.streams.kstream.Predicate)) since it allows you *include* records based on a criteria which can be defined using a [Predicate](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/Predicate.html). The result is a new `KStream` instance with the filtered records:

```java
KStream<String, String> stream = builder.stream("words");
stream.filter(new Predicate<String, String>() {
    @Override
    public boolean test(String k, String v) {
            return v.length() > 5;
        }
    })
```

[filterNot](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#filterNot(org.apache.kafka.streams.kstream.Predicate)) lets you *exclude* records based on a criteria. Here is an example (lambda style):

```java
KStream<String, String> stream = builder.stream("words");
stream.filterNot((key,value) -> value.startsWith("foo"));
```

### Use `group`ing to prepare data for stateful operations

Grouping is often a pre-requisite to [stateful aggregations](https://kafka.apache.org/32/documentation/streams/core-concepts#streams_state) in Kafka Streams. To group records by their key, you can make sure of [groupByKey](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#groupByKey()) as such:

```java
StreamsBuilder builder = new StreamsBuilder();
KStream<String, String> stream = builder.stream(INPUT_TOPIC); 
       
KGroupedStream<String,String> kgs = stream.groupByKey();
```

> `groupByKey` returns a `KGroupedStream` object

[groupBy](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#groupBy(org.apache.kafka.streams.kstream.KeyValueMapper)) is a generic version of `groupByKey` which gives you the ability to group based on a *different* key using a [KeyValueMapper](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KeyValueMapper.html):

```java
stream.groupBy(new KeyValueMapper<String, String, String>() {
    @Override
    public String apply(String k, String v) {
        return k.toUpperCase();
    }
});
```

`groupByKey` and `groupBy` allow you to specify a different [Serde](https://kafka.apache.org/32/javadoc/org/apache/kafka/common/serialization/Serde.html) (`Serializer` and `Deserializer`) instead of the default ones. Just use the [overloaded version](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#groupBy(org.apache.kafka.streams.kstream.KeyValueMapper,org.apache.kafka.streams.kstream.Grouped)) which accepts a [Grouped](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/Grouped.html) object:

```java
stream.groupByKey(Grouped.with(Serdes.Bytes(), Serdes.Long()));
```

### Terminal operations

Not all stateless computations return intermediate results such as a `KStream`, `KTable` etc. They are often called *terminal* operations whose methods return `void`. Let's look at a few examples.

**Save record to a topic**

You may want to write the results of a stateless operation back to Kafka - most likely, in a different topic. You can use the [to](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#to(java.lang.String)) method to store the records of a `KStream` to a topic in Kafka.

```java
KStream<String, String> stream = builder.stream("words");

stream.mapValues(value -> value.toUpperCase())
      .to("uppercase-words");
```

An [overloaded version](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#to(java.lang.String,org.apache.kafka.streams.kstream.Produced)) of `to` allows you to specify a [Produced](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/Produced.html) object to customize the `Serdes` and partitioner:

```java
stream.mapValues(value -> value.toUpperCase())
      .to("output-topic",Produced.with(Serdes.Bytes(), Serdes.Long()));
```

You are not limited to a fixed/static topic name. [TopicNameExtractor](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/processor/TopicNameExtractor.html) allows you to include custom logic to choose a specific topic in a dynamic manner. Here is a simplified example - say you are using a `map` operation to convert each record to its upper case, and need to store it in a topic that has the original name with `_uppercase` appended to it:

```java
stream.mapValues(value -> value.toUpperCase())
    .to(new TopicNameExtractor<String, String>() {
        @Override
        public String extract(String k, String v, RecordContext rc) {
            return rc.topic()+"_uppercase";
        }
    });
```

In this example, we make use of the `RecordContext` (contains record metadata) to get the name of the source topic.

> In all the above cases, the sink/target topic should pre-exist in Kafka

**Debugging records**

[print](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#print(org.apache.kafka.streams.kstream.Printed)) is useful for debugging purposes - you can log each record in the `KStream`. It also accepts an instance of [Printed](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/Printed.html) to configure the behavior. 

```java
StreamsBuilder builder = new StreamsBuilder();
KStream<String, String> stream = builder.stream(INPUT_TOPIC);
stream.mapValues(v -> v.toUpperCase()).print(Printed.toSysOut());
```

This will print out the records e.g. if you pass in `(foo, bar)` and `(john,doe)` to the input topic, they will get converted to uppercase and logged as such:

```
[KSTREAM-MAPVALUES-0000000001]: foo, BAR
[KSTREAM-MAPVALUES-0000000001]: john, DOE
```

> You can also use `Printed.toFile` (instead of `toSysOut`) to target a specific file

**Do something for every record**

[foreach](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#foreach(org.apache.kafka.streams.kstream.ForeachAction)) is yet another terminal operation, but accepts a [ForeachAction](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/ForeachAction.html) using which you can specify *what* you want to do with each record in the the `KStream`.

### Miscellaneous features

Here are some other useful operations offered by the Kafka Streams API.

**peek**

Since `print` is a terminal operation, you no longer have access to the original `KStream`. This where [peek](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#peek(org.apache.kafka.streams.kstream.ForeachAction)) comes in handy because it returns the same `KStream` instance. Just like `foreach`, it accepts a `ForeachAction` which can use to specify what you *want* to do for each record.

Here is an example of the flexibility that peek offers - not only can you log each key-value pair, but you can also materialized them to an output topic (unlike the `print` operation) using the same chain of method calls:


```java
StreamsBuilder builder = new StreamsBuilder();
KStream<String, String> stream = builder.stream(INPUT_TOPIC);

stream.mapValues(v -> v.toUpperCase())
      .peek((k,v) -> System.out.println("key="+k+", value="+v))
      .to(OUTPUT_TOPIC);
```

**through**

While developing your processing pipelines with Kafka Streams DSL, you will find yourself pushing resulting stream records to an output topic using `to` and then creating a new stream from that (output) topic.

Say you want to transform records, store the result in a topic and then continue to process the new (transformed) records, here is how you get this done:


```java
StreamsBuilder builder = new StreamsBuilder();
KStream<String, String> stream1 = builder.stream(INPUT_TOPIC);

stream1.mapValues(v -> v.toUpperCase()).to(OUTPUT_TOPIC);

//output topic now becomes the input source
KStream<String, String> stream2 = builder.stream(OUTPUT_TOPIC);

//continue processing with stream2
stream2.filter((k,v) -> v.length > 5).to(LENGTHY_WORDS_TOPIC);
```

Since `to` is terminal operation, a new `KStream` (`stream2`) had to be created. The [through](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#through(java.lang.String)) method can help simplify this. You can rewrite the above using a single chain of calls:

```java
StreamsBuilder builder = new StreamsBuilder();
KStream<String, String> stream = builder.stream(INPUT_TOPIC);

stream.mapValues(v -> v.toUpperCase())
      .through(OUTPUT_TOPIC)
      .filter((k,v) -> v.length > 5)
      .to(LENGTHY_WORDS_TOPIC);
```

**merge**

Say you have streaming data coming into two different Kafka topics, each of which is represented by a `KStream`. You can [merge](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#merge(org.apache.kafka.streams.kstream.KStream)) the contents of these `KStream`s into a single stream.

```java
StreamsBuilder builder = new StreamsBuilder(); 

KStream<String, String> stream1 = builder.stream("topic1");
KStream<String, String> stream2 = builder.stream("topic2");

stream1.merge(stream2).to("output-topic");
```

> Caveat: The resulting stream may *not* have all the records in order

**selectKey**

With the help of a `KeyValueMapper`, [selectKey](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#selectKey(org.apache.kafka.streams.kstream.KeyValueMapper)) allows you to derive a new key with a different data type.

```java
StreamsBuilder builder = new StreamsBuilder();
KStream<Integer, String> stream = builder.stream(INPUT_TOPIC);

stream.selectKey(new KeyValueMapper<Integer, String, String>() {
            @Override
            public String apply(Integer k, String v) {
                return Integer.toString(k);
            }
        })
```

**branch**

[branch](https://kafka.apache.org/32/javadoc/org/apache/kafka/streams/kstream/KStream.html#branch(org.apache.kafka.streams.kstream.Named,org.apache.kafka.streams.kstream.Predicate...)) seems quite interesting, but something I have not used a lot (to be honest!). You can use it to evaluate every record in a `KStream` against multiple criteria (represented by a `Predicate`) and produce multiple `KStream`s (an array) as output. The key differentiator is that you can use multiple `Predicate`s instead of a single one as is the case with `filter` and `filterNot`.

## Wrap up

This blog post summarized most of the key stateless operations available in Kafka Streams along with code examples. You can combine them to build powerful streaming applications with the flexibility to adopt a functional programming style (using [Java Lambda Expressions](https://docs.oracle.com/javase/tutorial/java/javaOO/lambdaexpressions.html)) or a more traditional, explicit way of defining your data processing logic.

Happy Building!