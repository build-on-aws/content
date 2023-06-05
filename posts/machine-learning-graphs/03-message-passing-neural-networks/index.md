---
title: Needs title
description: Needs description
tags:
  - graphml
  - graph-neural-networks
  - gnn
  - dgl
  - graph
  - graph-theory
  - MPNN
  - message-passing-neural-networks
authorGithubAlias: cyrusmvahid
authorName: Cyrus Vahid
date: 2022-07-08
---

Having fortified our knowledge of graphs in the [previous post](/posts/machine-learning-graphs/02-graph-theory), we are now ready to take a deeper look at the MPNN paradigm.

Let us reconsider RNNs again. We calculate state of a node, $h$, and then pass it on to the next node. We are not restricted to "positive" direction of time. We can go backward. We can also stack up the layers and thus moving upwards, or downwards. Skip connections further muddle the idea of sequential time. If we take step back and consider doing a propagation step in a graph and compute a path in a graph, we have created a sequence and all things RNN can be applied to that path.

- [part 1](/posts/machine-learning-graphs/01-motivation-for-graph-ml) - Motivation for using graphs.
- [Part 2](/posts/machine-learning-graphs/02-graph-theory) - Graph theory, a theoretical minimum.
- [Part 3](/posts/machine-learning-graphs/03-message-passing-neural-networks) - MPNN paradigm.
- [Part 4](/posts/machine-learning-graphs/04-graph-convolutional-networks) - GCN, a brief introduction to the theory.
- [Part 5](/posts/machine-learning-graphs/05-GNN-example-karate-club) - Karate Club example, GNN's HelloWorld using Deep Graph Library.
- [Part 6](/posts/machine-learning-graphs/06-knowledge-graph-embedding) - Introduction to Knowledge Embedding in graphs.
- [Part 7](/posts/machine-learning-graphs/07-dglke-oss-tool-for-KGE) - Under the hood of DGL-KE, a framework for knowledge embedding using DGL.
- [Part 8](/posts/machine-learning-graphs/08-covid-drug-repurposing-with-DGLKE) - DGL-KE in practice, Drug repurposing using DGL-KE

## An Example

We now create a complete graph with 6 nodes (1), drop some edges randomly (2), and assign weights to each edge(3). On the graph we have created, we can create a few path graph using some neighborhood criteria. In this example we are using shortest path between node 4 and node 0 (4). The outcome is that we have created three possible paths that can be used for graph embedding where source is 4 and target is 0 as illustrated in figure 1.

```python
import networkx as nx
import matplotlib.pyplot as plt
import random
random.seed(42)
N = 6
DROP_RATE=.5
G = nx.complete_graph(N) #(1)
G.remove_edges_from(random.sample(G.edges(),k=int(DROP_RATE*G.number_of_edges()))) #(2)
G.add_edges_from([(5,0),(1,0)])
for (u,v,w) in G.edges(data=True):
    w['weight'] = round(random.random(), 2) #(3)
 
pos = nx.spring_layout(G)
plt.figure(3,figsize=(8,6))

nx.draw(G, pos=pos, with_labels=True, node_color='black', font_color='white', font_weight='bold')
nx.draw_networkx_edge_labels(G, pos=pos)
plt.show()
```

![weighted graph](images/img0301.png "Figure 1: A randomly generated weighted graph. We later create walks in this graph that would take us from node 4 to node 0.")

Ignoring the weights for the sake of simplicity, we can then create walks with the shortest path from node 4 to node 0.

```python
a = nx.all_shortest_paths(G, source=4, target=0, weight='weigth') #(4)
len_a = 0
for path in a:
    len_a += 1

fig, ax = plt.subplots(1, len_a+1, figsize=(10,3))
a = nx.all_shortest_paths(G, source=4, target=0, weight='weigth') 
i = 0
for path in a:
    graph = nx.subgraph(G, path)
    nx.draw(graph, with_labels=True, node_color='black', font_color='white', font_weight='bold', ax=ax[i], node_shape='^')
    ax[i].set_axis_off()
    i += 1
AP = nx.DiGraph()
AP.add_edges_from([(0,3), (3,1), (1,5), (5,3), (3,4)])
nx.draw(AP, with_labels=True, font_color='white', font_weight='bold')
plt.show() #(5)
```

![different walks](images/img0302.png "Figure 2: the three graphs on the left are possible walks from node 4 to node 0 on the possible shortest paths. We should keep in mind that we do not necessary want to walk the shortest path. Walks can have different types of paths in order to collect as much information as needed. The walk on the right is created manually based on [(0,3), (3,1), (1,5), (5,3), (3,4)]. It is worth noticing that here we have created a directed graph that is easier to follow the path.")

Now try to imagine on the three graphs on the left we increase the paths to all possible paths, then the graph theoretically has become a series of RNNs. If we consider time-steps $t_1, t_2, t_3$, then we can create some sort of aggregation similar to RNNs. To encode a path, such as [4, 1, 0], we could For instance, do a weighted sum. In this case, of value of 0, 1, and 4 are respectively 5, 6, 7. We already know that weight values for (0, 1), (1, 4) are .74 and .03 respectively. If we are at 0 at timestep 0, 1 at timestep 1, and 4 at timestep 2, then $m_{4}^{2}=M(5 \times .74 + 6 \times .03 = 3.88)$, where $\Phi$ is some function; M can be a simple liner function, concatenation, or even a neural network. We then use a non-liner update function $U$ to update the value of the node state. In this example, $h_{4}^{2}=U_4(h_{1}^{4}, m_{4}^{2})$  

You can observe that in this simple example we have skipped value of the destination node. This results in ignoring correlation between edge and state nodes similar to early version of MPNN [Duevenaud, 2015]

## MPNN Intuition

There are several MPNN frameworks. Here I will explore a few of them. Forward pass of MPNN has two phases, Message Passing phase and readout phase.

Message passing phase consists of message function $M$ over $T$ timesteps and update function $U$ over the same number of timesteps. during message passing state, hidden stats of a node is updated based on an aggregation on stated of neighboring nodes and properties of the edges connecting the target node with its neighbors.

We shall need an encoding mechanism to captures node and edge features. We can, for instance, cerate a one-hot vector of all features and then combine those features through concatenation or other means.

The readout phase, not dissimilarly to encoder in the encoder-decoder architecture, computes a feature vector for the whole graph. The readout phase uses a readout function that can be a neural network.

![world of mary](images/img0303.png "Figure 3: This is the full knowledge graph of \"the world of Mary\". Obviously not all edges are defined. The job of GNN is to predict what is missing.")

Let us try an example. In the world of Marry graph above, if we want to to encode Mary, we can set hyperparameter $T$ to 2 and use message processing to propagate and update Mary's state. The figure below captures the subgraph that is used for MPNN.

![contextualized graph of world of Mary](images/img0304.png)

Figure 4: This is a graph that provided with certain hyperparameters captures Mary's relationship with the rest of the graph. The edges and the nodes are a subset of the knowledgebase. We can now find an embedding mechanism to encode Mary in this context.

We can extract all the features and edges within the premise of T==2

```text
all edge features: ['works', 'likes', 'loves', 'sibling', 'colleagues', 'is', 'contains']
edge featured for marry at T==2: ['sibling', 'works', 'is', 'likes']
```

The image above demonstrates that for instance the edge between Mary and Tom could be presented as: $[1, 0, 0, 0, 0, 0, 0]$. If there has been an edge describing that Mary "likes" her brother, Tom, then the edge feature vector would look like $[1, 1, 0, 0, 0, 0, 0]$. As both Tom and Mary work in amazon, they are colleagues. In the example, this is a missing edge that could be predicted, but if we imagine the "colleague" relationship as a part of our data, then the feature vector would look like: $[1, 1, 0, 1, 0, 0, 0]$. 
We might also have node features such as Tom is a 25-33 male, 180-cm tall and BMI index of 18. This could also be combined and perhaps pass through an embedding layer to create a latent feature vector, which is in agreement with the edge feature vector in terms of shapes of the two vectors. We can then calculate:

$$
m^{mary}_{1 \times 7} = \sum{[(tom,cheese, likes), \\(tom,vegetarian, is), \\(tom, amazon, works), \\(mary,tom, sibling), (mary,cheese, likez), \\(mary, amazon, works), \\(mary, vegetarian, is), \\(tom, mary, sibling)\large ]} $$

Finally, we can build an MLP, $U^{mary}$, that takes $m^{mary}_{1 \times 7}$ and current $h^{mary}$ before the update and assigns Mary a new state:

$$
h^{mary}_{next}=U^{mary}(h^{mary}_{current}, m^{mary}_{1 \times 7}),\text{where U is a neural network}
$$

For the readout phase we can imagine using a neural network

$$
\phi(\sigma (h_{mary}\odot h_{tom} \odot h_{cheese} \odot h_{vegtn} \odot h_{amazon}))
$$

## MPNN formalization

Graph $\mathcal {G} = (V,E)$ is am undirected and simple graph where $v,w \in V\ and\ (v,w)\in V$. $x_v$ is edge feature vector for edge $v$ and $e_{v,w}$ is the feature vector for edge connecting $v$ and $w$.

The forward pass includes, as we have seen, a propagation and an update phase. The propagation phase in general is calculating message for the next timestep based on current state of a vertex $v$, states of all the connected vertices in $v$ 's neighborhood, and edge features of all of $v$ 's neighbors. We then use this message and value of current hidden state of node $v$ to update the node with the new value.

$$
\large \\
m_v^{t+1} = \sum{w} \in \mathcal{N}_(v)}\mathcal{M}_t(h^t_v, h^t_w, e_{vw})
h^{t+1}_v = \mathcal {U}_t(h_v^t, m_v^{t+1})
$$

The readout phase, calculates a feature vector for the whole graph using some readout function $\mathcal {R}$:

$$
\large \\
\hat{y} = \mathcal {R}({h_v^T} \vert v \in \mathcal{G})
$$

$\mathcal{M_t}$, $\mathcal{U_t}$, and $\mathcal{R}$ are learned differentiable functions.

## Invariance

In Mary's world, the result of MPNN process should be independent of the starting point. Mary's node features should be the same if we start the MPNN process from 'vegtrn' node or from 'tom'. If this does not hold and MPNN does not exhibit invariance to graph isomorphism, then depending on starting point, we would need to retrain the model.
we, thus, need MPNN to be invariant to graph isomorphism, meaning relabeling of nodes should not affect messaging process. This is achieved if $\mathcal{R}$ is invariant to permutation of node states while processing graphs' feature vector.

## What's Next?

Graph convolutional networls or GCNs have come to dominate the field. They, therefore, deserve a short introduction. Something the [next post](/posts/machine-learning-graphs/004-graph-convolutional-networks) will take care of.

## Variations of MPNN.

There are several flavours of MPNN, but before going there, let us use a simple implementation using Deep Graph Library.

## references

- Neural Message Passing for Quantum Chemistry Gilmer et. al, arXiv:1704.01212 [cs.LG](https://arxiv.org/pdf/1704.01212.pdf)
