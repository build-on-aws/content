---
title: Title
description: Description
tags:
  - ai-explainability
  - ai-fairness
  - ai-ml
  - shapley-values
  - shap
authorGithubAlias: cyrusmvahid
authorName: Cyrus Vahid
date: 2022-07-08
additionalAuthors: 
  - authorGithubAlias: kirannsa
    authorName: Sai Kiran Jukanti
---

|ToC|
|---|

|SeriesToC|
|---------|



In the [previous](/posts/ai-explainability/02-lime) segment of this publication, we learned about LIME as a feature attribution method, with the drawback that finding the right hyperparameters for kernel width and model complexity could be rather arbitrary. We are going to use Shapely values to find a unique solution to solving LIME's optimization equation. Before that, we need to understand the theory behind Shapley values and how there are calculated. If you are familiar with the concept, you can skip to the next [post](/posts/ai-explainability/05-shap).
In order to understand SHAP method for explainability, we need to first understand Shapley values. This post gives a quick introductory overview as a theoretical minima into Shapley values in the context of game theory.

## Cooperative n-person games

Fundamentally,  How The problem is to measure what contribution each player makes. Let's think in terms of a football (soccer) team. The aim of the game is to score, perhaps as many as you can if you are a proper team. Imagine a team would like to reward the whole team a certain reward based on the position in the league after the end of a season. team as well as club employees such as kit man, coaching, and medical staff based on their contribution. Obviously no one thinks that only goal scorers should be rewarded. The problem is to computer what impact each player has had in success of the team.
Another example is a sales organization within a IT vendor company. There are account managers, solutions architects, inside sales, technical account managers, and many other in the account team as well as specialist support teams that contribute to a sale. How should the commission be distributed? What is the exact contribution of a solution architect to the success of a transaction? They story goes. What is the direct contribution of marketing to the total revenue?

These are all n-player games in competitive situations. There is a total amount of available commission to be distributed amongst the account team and the team members, although in a tight alliance, compete over having a bigger chunk of the available rewards. Marketing, PR, and other support teams compete over the amount of available budget based on their contribution, even though in the grand scheme of things are tightly allied for the benefit of the company. Lloyd Shapley proposed a solution to this problem. In the next section, I will introduce Shapley values. They are relevant to model explanation as we can use Shapley values to measure how much each feature contributes to the final decision of a model.

### Definitions

#### Coalition Function

Imagine a sales team. if the team has $N$ members and their coalition has a payout. Now if we create permutations of team members by changing the order or removing one or more members from the team, we still would have a payout that is either the same or lower, or perhaps, unlikely as it might be,higher.

Let's imaging we have three players $A, B,$ and $C$. The coalition set in this case is $\{\{\} = \phi, \{A\}, \{B\}, \{C\}, \{A,B\}, \{A,C\}, \{B,C\}, \{A,B,C\}=\Omega \}$. We can see that for a coalition of $3$ we have $2^3$ permutations with each permutation resulting in some payout. For N players, there will be 

The total number of coalitions for $N$ players we have $2^N$ coalitions and each coalition has a payout. A grand coalition is a coalition that includes all the player. In this example $\{A,B,C\}$ is the grand coalition. We define characteristic or coalition function as a function that projects each of the coalitions to a payout. More formally:

Let $N=\{p_1, p_2, \dots, p_n\}$ be all the players in a game $G$ with $|N|=[N]$. Each non empty $S \subseteq N$ is called a coalition. A grand coalition is a coalition of all players in the game and is denoted by $\Omega$.

***Definition:*** *A characteristic function game $G$* is given by $(N,v)$ where $v:2^{[N]} \rightarrow \mathbb{R}$ is a coalition function that maps every $S_i \in S$ (all coalitions + empty subset to a payout.

Let us consider the sales example where A is the account manager, B the solutions architect, and C the technical account manager. The below table is the coalition function with the hypothetical payout values:

| Coalition | Payout |
|-----------|--------|
| $\phi$    | 0      |
| A         | 100K   |
| B         | 80K    |
| C         | 65K    |
| A,B       | 160K   |
| A,C       | 140K   |
| B,C       | 100K   |
| A,B,C     | 250K   |

Let us contemplate as what the payout function is telling us.

![venn diagram for player contribution](images/venngame.png)

- A has the highest impact on this specific sale, followed by B, and then C.
- A and B together can make a sale with a total value of 180. C adds 70 to the total.
- B individually makes a total revenue of 80 and C adds only a contribution of 20, a far cry form individual contribution of 65. This does not seem to be a good coalition. It even makes causal sense as the two technical resources have many areas of overlap in terms of skillset.
- C makes a total contribution of 40 when paired with A. It is a much better contribution, but the maximum effectiveness comes where all members of the coalition are working together.

We can conclude C is most successful when A is in the coalition.

#### Superadditive

We all have heard of teams whose total is more that total sum of its members. This is basically intuition for the superadditive characteristic function game. More accurately we have for each combination of distinct coalitions, if the total payout of the combined coalition is more than or equal the total sum of its coalition members. The distinctness does make sense. Let us consider the case of $\{C_A=\{A\}, C_{AB=}\{A,B\}\}$. There is a hidden double counting of contribution of $A$ so we should account for it. In the case of our example $v(C_A)=100,v(C_B)=80,\ v(C_{AB})=160;\ 160=v(C_{A,B}) < v(C_A) + v(C_B) = 180$ does not contradict super additiveness. How about $v(C_{AB})$ and $v(C_C)$ where the two coalitions are distinct? $v(C_{AB}) = 160,\ v(C_C) = 65, and  v_{ABC}=250;\ 225 = v(C_{AB}) + v(C_B) \leq v(C_{ABC}) = 250$ does not contradict superadditiveness.

***Definition*** A characteristic function game $G=(N,v)$ is called *super additive* when:

$$
\large{\forall\ C_i\subseteq S,\ where\ \cap_{i=1}^{[N]}C_i =\phi :\   v(\cup_{i=1}^{[N]}C_i) \geq \sum_{i=1}^{[N]}v(c_i)}
$$

***Question:*** *Is the sale example a super additive characteristic game function?*

***Answer:*** We need to try an example that breaks superadditiveness. The case of $\{A, C\}$ results in $165 = v(C_A) + v(C_C) > v(C_{AC}) = 140$, therefore the sales example is not a superadditive game. Altering payouts to $v(C_{AC} \geq 165$ will make the game to be an example of a superadditive game.

A solution to a coalition function game is a payoff vector that divides payouts amongst players in the grand coalition. More formally Shapley value is the vector $\lambda \in \mathbb{R}_{\geq 0}^{[N]}$ that satisfies:

$$
\large{ \sum_{i=1}^{[N]} \lambda_i = v(\Omega) }
$$

One obvious solution to the problem is of course equal payout, but this is unfair to the high performing players. A possible solution to our example is to choose $\lambda = [\frac{100}{250}, \frac{80}{250}, \frac{65}{250}]$. This means we consider impact only on the basis of individual performance. This is perhaps unfair to $C$ as he seems to excel in team settings where $A$ is present.

The goal of Shapley values is to find the fair distribution in relation to impact. This requires us to define Shapley axioms, which define a system in which Shapley values can be defined.

### Symmetry

Symmetry axiom represents interchangeability of two members, meaning that either of the members would always have the same marginal contribution no matter what coalition they are added to. Coalitions $C_i$ and $C_j$ with respect to coalition function $v \in G$ if adding it to a coalition that does not already include them results in the same payout. For instance if we have two additional players in the sale example,--e.g. inside sales and marketing-- with individual contribution of $v(C_D)=15$ and $v(C_E)=20$. $C_D$ and $C_E$ are symmetrical in respect the payout function if $v(C_{ABD}) = v(C_{ABE}) = 150$.
More formally:

$$
\forall K \subset S;\ where\ C_i \notin K\ and\ C_j \notin K\ and\ \forall v \in G:\\
\large{
v(K \cup C_i) = v(K \cup C_j)
}
$$

***Symmetry Axiom:*** Interchangeable members should receive the same share or:. $\large{\lambda_{C_i}(N,v) = \lambda_{C_j}(N,v)}$ for interchangeable players $C_i$ and  $C_j$.

### Null player

We all have had coworkers where we though what would happen if one day they did not show up. Would it affect anything? If the data supports your suspicion, then we have a null player. Basically a null player is a player that if added to a coalition, the payout value does not change. More formally:
A player $C_k$ is a null player in if:

$$
\forall v\in G\ and\ \forall K \subset S:\\
\large{
v(K) = v(K \cup C_k)
}
$$

***Null player axiom:*** Null(dummy) players should receive nothing or:. $\large {\lambda_{C_k}(N,v) = 0}$ for null player $C_k$.

### Additivity

Consider two independent games $G_!$ and $G_2$. For instance the same sales team from the previous example would be working on more than one sales initiative or sometimes more than one customer account at a given time. Let's say in January they maker a sales of a total value of 250K as given in the example and in the month of February, they close another sale at the different customer for 300K. These two games are independent of one another. There are two ways of looking at this. Either we are looking at a single game of total sales in a quarter, or we can break that game to individual games based on each sales. The quarterly games of selling services for this sales team can be split into independent games. It is often done very regularly by splitting annual sales to quarterly sales and rewarding sales them on the basis of their quarterly performance. Games that can be split into independent parts are additive. More precisely, *if a game can be separated into parts, we should be able to decompose the payments.*
***Additivity axiom:*** let $v_i$ and $v_j$ be two arbitrary payout functions and $C \subseteq S $ be an arbitrary non-empty coalition. The solution function $\lambda$ follows the additivity axiom if:

$$
\large{\lambda_C (v_i + v_j) = \lambda_C(v_i) = \lambda_C(v_j)}
$$.

### Shapely theorem

Given a coalitional game $(N,v)$, there is a unique payoff division $x(v) = \lambda(N, v)$ that divides the full payoff of of the grand coalition and satisfies Symmetry, Null player, and additivity axiom.

### Shapely Value

the Shapley value is calculation of the unique payoff division based on removing members and measuring what difference removal of a member has made. Then doing it for all members and in all possible ways and averaging over the possible ways we can constructed the society.

More formally:

$$
\large{
\lambda_i(N,v) = \frac{1}{N!}\sum_{S\subseteq N \setminus \{i\}}|S!|(|N|-|S|-1)! \left[ v(S \cup \{i\})-v(S)    \right]
}
$$

Let us dissect this a little bit: $\left[ v(S \cup \{i\})-v(S) \right ]$ is play $i$'s marginal contribution that is acquired through removing the player and looking at the total payout. We then weight the marginal contribution by $|S!|$, the number of ways set $S$ could be created before adding player $i$ and (|N|-|S|-1)!, the number of ways the rest of the players could have been added. Then all these possible ways of contributions by members is added up using $\sum_{S\subseteq N \setminus \{i\}}|S!|(|N|-|S|-1)! \left[ v(S \cup \{i\})-v(S)    \right]$. As we have summed up all the possible contributions, we average the total over the total of orderings we could have had by dividing the sum by $|N!|$.  

#### Example

Let us restrict our example only to an account manager and a solutions architect. We know that we have a following payout table (I have changed $v(B)$ to 40 to have a superadditive game:

| Coalition | Payout |
|-----------|--------|
| A         | 100K   |
| B         | 40K    |
| A,B       | 160K   |

Let us calculate Shapley Value.

Let us focus on player $A$. We can add $A$ first. in this case $\lambda_A = v(C_A) = 100$. A could be added second in a sequence of B first and A second, thus resulting in the $B \rightarrow A$ sequence. Marginal contribution is now calculated as $v(C_{AB}) - v({C_B}) = 120$. The total sums up to 220 and as we are averaging over two possibilities $|N|! = 2$, so each variation is divided by 2 and payout for A comes to: $50+60 = 110$. We can then repeat the process focusing on B. $v(C_B) = 40$ and $v(C_{AB}) - v(C_A)=60$. By the same token, both values are divided by 2 and thus contribution of $B=20+30=50$. We can see that the total for the grand coalition is 110+50 = 160, which is equal to $v(C_{AB})$.

$$\large{ \lambda (N=\{A,B\}, v) = \{110, 50}\}$$  

## What is next?

in the next [part](/posts/ai-explainability/05-shap) we apply Shapley theorem to find a unique solution to LIME's equation.

## References

Below are a set of references I have looked up and used for this post. There are very good references to learn more about AI Exlainability. If you are interested to learn more, I strongly suggest taking a look at these resources.

1. [LIME's original paper](https://arxiv.org/pdf/1602.04938v1.pdf)
2. [Survey paper for explainability methods](https://arxiv.org/pdf/2011.07876.pdf)
3. [Oreily blog for intuitive understanding of LIME](https://www.oreilly.com/content/introduction-to-local-interpretable-model-agnostic-explanations-lime/)
4. [LIME Open Source Library [docs]](https://github.com/marcotcr/lime/tree/master/doc/notebooks)
5. [Kernel SHAP paper](https://arxiv.org/pdf/1705.07874.pdf)
6. [Cooporative games in Game theory](https://vknight.org/Year_3_game_theory_course/Content/Chapter_16_Cooperative_games/)
7. [Original Shapley paper](https://www.rand.org/content/dam/rand/pubs/papers/2021/P295.pdf)
8. [Cooporative Game Theory](https://www.wifa.uni-leipzig.de/fileadmin/Fakultät_Wifa/Institut_für_Theoretische_Volkswirtschaftslehre/Professur_Mikroökonomik/Cooperative_game_theory/B1_gl.pdf)
9. [UBC course on Shapley Values](https://www.youtube.com/watch?v=9OFMRiAVH-w)
10. [A Unified Approach to Interpreting Model Predictions](https://arxiv.org/pdf/1705.07874.pdf)
