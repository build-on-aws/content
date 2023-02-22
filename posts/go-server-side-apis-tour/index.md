---
title: 'Go net/http package: A quick tour of the server side APIs'
description: Learn how to use the Go net/http library to build your web apps and services
tags:
  - go
  - programming
  - http
  - apis
authorGithubAlias: abhirockzz
authorName: Abhishek Gupta
date: 2022-09-27
---

The [Go](http://go.dev/) programming language (also sometimes referred to as `Golang`) is known for its comprehensive, robust and well-documented [standard library](https://pkg.go.dev/std). This includes the [net/http](https://golang.org/pkg/net/http/) package, which provides the server and client side APIs for HTTP services. 

Although the `net/http` package is quite rich in terms of functionality, some of it may be confusing for newcomers to the language. Coming from HTTP frameworks in other programming languages, I had trouble grokking some of the concepts, especially with so many occurrences of the term `Handle` - `Handler`, `Handle`, `HandleFunc` etc.

In this blog post, I will provide a break down of the important server-side components in the `net/http` package. The topics covered include:

- HTTP Multiplexer and Handlers
- HTTP Server
- The default multiplexer
- How to use functions to handle HTTP requests

Let's start off with the fundamental building blocks - `ServeMux` and `Server`.

## `ServeMux` - HTTP multiplexer

[ServeMux](https://pkg.go.dev/net/http#ServeMux) is responsible for matching the URL in the HTTP request to an appropriate handler and executing it. You can create one by calling [NewServeMux](https://pkg.go.dev/net/http#NewServeMux).

The way you associate HTTP URLs to their respective handler implementations is by using `Handle` and / or `HandleFunc` methods in `ServeMux` instance.

## Types of HTTP Handlers

### **Handle**

One way is to use the [`Handle` method](https://golang.org/pkg/net/http/#ServeMux.Handle) which accepts a `String` and an [`http.Handler`](https://golang.org/pkg/net/http/#Handler) (which is an `interface`).

```go
func (mux *ServeMux) Handle(pattern string, handler Handler)

type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

Since `http.Handler` is an `interface`, you need to provide an implementation to define how you want to process the incoming HTTP request.

```go
type home struct{}

func (h home) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
	rw.Write([]byte("Welcome to the Just Enough Go! blog series!"))
}
```

Associating the `http.Handler` implementation involves passing an instance of the `struct` to the `Handle` method of `http.ServeMux`:

```go
mux := http.NewServeMux()
mux.Handle("/", home{})
```

In this example, a request to the root URL of the server (e.g. http://locahost:8080/) will map to the implementation in the `ServeHTTP` associated with the `home` struct.

### **HandleFunc**

Let's see an example of how to use [`HandleFunc`](https://golang.org/pkg/net/http/#ServeMux.HandleFunc) to assign a function to a request path without creating an explicit type. Like `Handle`, it is just another method in `http.ServeMux`. But, instead of an `interface`, it accepts a function as the implementation.

This is the type signature:

```go
func (mux *ServeMux) HandleFunc(pattern string, handler func(ResponseWriter, *Request))
```

In this example, the handler associated with `/posts`, will simply return HTTP 200 response with the body - `Visit http://bit.ly/just-enough-go to get started`

```go
mux.HandleFunc("/posts", func(rw http.ResponseWriter, req *http.Request) {
    rw.Write([]byte("Visit http://bit.ly/just-enough-go to get started"))
})
```

## HTTP `Server`

Once you have the `handler` and the `mux` defined, create an instance of a `http.Server` to tie everything together. Here is how you instantiate a server - `Addr` is the address on which the server listens e.g. `http://localhost:8080` and `Handler` is an `http.Handler` instance. Start the server with [`ListenAndServe`](https://golang.org/pkg/net/http/#Server.ListenAndServe) method.

```go
server := http.Server{Addr: ":8080", Handler: mux}
server.ListenAndServe()
```

> At runtime, the request is dispatched to the appropriate handler based on the path (URL) in `http.Request`.

So far, we covered multiple components including `ServeMux` and how to define handlers. Then, we glued everything together using a `Server`. Here is the complete code listing that you can run:

```go
package main

import (
    "log"
    "net/http"
)

func main() {
    mux := http.NewServeMux()

    mux.Handle("/", home{})

    mux.HandleFunc("/posts", func(rw http.ResponseWriter, req *http.Request) {
        rw.Write([]byte("Visit http://bit.ly/just-enough-go to get started"))
    })

    server := http.Server{Addr: ":8080", Handler: mux}
    log.Fatal(server.ListenAndServe())
}

type home struct{}

func (h home) ServeHTTP(rw http.ResponseWriter, r *http.Request) {
    rw.Write([]byte("Welcome to the \"Just Enough Go\" blog series!!"))
}
```

To try this:

- Save the code in a file (e.g. `go-http-1.go`) 
- Run it - `go run go-http-1.go`
- Access the HTTP endpoints - `curl http://localhost:8080/` and `curl http://localhost:8080/posts`

## Default Multiplexer

You don't always need to define a `http.ServeMux` explicitly because the `Handle` and `HandleFunc` methods available in a `http.ServeMux` are also exposed as global functions in `net/http` package!

You can use them as such:

```go
http.Handle("/", home{})

http.HandleFunc("/posts", func(rw http.ResponseWriter, req *http.Request){
    rw.Write([]byte("Visit http://bit.ly/just-enough-go to get started"))
})
```

This is made possible by a ready-to-use multiplexer called [DefaultServeMux](https://pkg.go.dev/net/http#pkg-variables). Similarly, the `ListenAndServe` function on the `http.Server` instance is also defined at a package level. It's commonly used along with the default multiplexer.

```go
func ListenAndServe(addr string, handler Handler) error
```

The `handler` parameter can be `nil` if you have used `http.Handle` and/or `http.HandleFunc` to specify the handler implementations for the respective routes.

## Functions as handlers

[`http.HandlerFunc`](https://golang.org/pkg/net/http/#HandlerFunc) allows you to use ordinary functions as HTTP handlers in case you want to use a standalone function instead of defining a `struct` in order to implement `http.Handler` interface.

```go
type HandlerFunc func(ResponseWriter, *Request)
```

Here is a simplified example:

```go
func welcome(rw http.ResponseWriter, req *http.Request) {
    rw.Write([]byte("Welcome to Just Enough Go"))
}
...
http.ListenAndServe(":8080", http.HandlerFunc(welcome))
```

We defined a standalone function (`welcome`) with the required signature and used it in the `Handle` method that accepts a `http.Handler`.

> `HandlerFunc(f)` is a `Handler` that calls the function `f`

Here is the code listing that you can run:

```go
package main

import "net/http"

func main() {
    http.Handle("/welcome", http.HandlerFunc(welcome))
    http.ListenAndServe(":8080", nil)
}

func welcome(rw http.ResponseWriter, req *http.Request) {
    rw.Write([]byte("Welcome to Just Enough Go"))
}
```

To try this:

- Save the code in a file (e.g. `go-http-2.go`) and 
- To run - `go run go-http-2.go`
- Access the endpoint - `curl http://localhost:8080/welcome`

## Conclusion

If you're starting out building HTTP services using Go, it's good to know the key components and have a high-level mental model of the `net/http` package. Hopefully this blog post can provide a quick intro (or a refresher) and proves useful to you.

Happy Building!
