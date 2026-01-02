# Concentrated Portfolio Selection Model (Mean–Greedy Method)
This repository contains the code and report for a two-person Master’s course project at the University of Waterloo. We replicate and extend the **concentrated portfolio selection** method of [Chen, Li & Wang (2014)](#chen2014), and compare it against the classic **mean–variance (MV)** model on U.S. and Chinese equity markets.

The project implements both the **simple** and the **realistic** versions of the **mean–greedy (MG)** model in R, and evaluates their performance using daily stock returns for U.S. and A-share markets.

> Note: This was a joint project with a teammate. This repo hosts my implementation and the final report we submitted for the course.

---

## Methodology
The classic mean-variance model minimizes the overall exposure to the covariance matrix while specifying a target return:

$$
\begin{aligned}
\min_w & w' \Sigma w \\
\text{s.t.} & \sum_{i=1}^N w_i \bar{r_i} = e \\
& \sum_{i=1}^N w_i = 1 \\
& w_i \ge 0 , \quad i=1,...N
\end{aligned}
$$

It treats all volatility as risk and naturally prefers **well-diversified** portfolios. In practice, however, many investors behave in a more “greedy” way:
- They are happy to tolerate **large upside moves**.
- They are mainly afraid of **downside moves**.
- They often hold **concentrated portfolios** containing a few “star” stocks instead of a well-diversified portfolio.

Thus, [Chen, Li & Wang (2014)](#chen2014) proposed a new risk measure that explicitly distinguishes **upside deviation** from **downside deviation**, leading to an adjusted covariance matrix called the **greedy matrix (G)**:

$$
\begin{aligned}
g_{ij} = 
\begin{cases}
\sigma_{ij} &, \quad \text{if } i \ne j \\
\sigma_{ii}^- - \sigma_{ii}^+ = \frac{1}{T}\sum_{j=1}^T min(r_{ij}-\bar{r_i},0)^2 - \frac{1}{T}\sum_{j=1}^T max(r_{ij}-\bar{r_i},0)^2 &, \quad \text{otherwise}
\end{cases}
\end{aligned}
$$

This modification to diagonal elements of the covariance matrix reflects investors’ greedy psychology of wanting the upside deviation as large as possible and the downside deviation as small as possible, as well as describes the rule of minimizing risk more naturally in practice: the smaller the risk value is, the better the portfolio performs. And it naturally produces concentrated portfolios without explicit cardinality constraints by assigning large weights to the few good stocks with negative “variance” ($\sigma_{ii}^+ > \sigma_{ii}^-$).

The mean-greedy method is then built under a simplified environment that only requires on target return:

$$
\begin{aligned}
\min_w & w' G w \\
\text{s.t.} & \sum_{i=1}^N w_i \bar{r_i} = e \\
& \sum_{i=1}^N w_i = 1 \\
& w_i \ge 0 , \quad i=1,...N
\end{aligned}
$$

As well as an actual investment environment with transaction cost $c_i = k_i w_i$ and divident yield $d_i$. We require a target return and limit on the weights and transaction costs.

$$
\begin{aligned}
\min_w & w' G w \\
\text{s.t.} 
& E[r(w)] = \sum_{i=1}^N (\bar{r_i}+\bar{d_i})w_i - \sum_{i=1}^N c_i= e \\
& c_i \ge k_i w_i \\
& \sum_{i=1}^N c_i \le \gamma \\
& \sum_{i=1}^N w_i = 1 \\
& w_l \le w_i \le w_u, \quad i=1,...,N
\end{aligned}
$$

Note that both models are nonconvex optimization problems, as $G$ is indefinite. But the quadratic objective can be written as the difference of two convex functions, thus a DC algorithm (DCA) can be applied and is guaranteed (under standard assumptions) to converge to a DC-critical point:

$$ w'Gw = w' \Sigma w - 2 w' \Delta w, \quad \Delta = diag(\sigma_{11}^+, \ldots , \sigma_{NN}^+) $$

And for small-scale instances (which is the case in our empirical study), a global optimal portfolio can be efficiently obtained by the CP/DNN-based global QP optimization algorithm introduced in [Chen & Burer (2012)](#chen2012). The authors’ implementation is available at [QuadprogBB](https://github.com/sburer/QuadProgBB).

However, since the public QuadProgBB code is written for older 32-bit Matlab/CPLEX environments and is difficult to run reliably on a modern 64-bit setup, we decided to used the commercial optimizer **Gurobi**, via its [R interface](https://www.gurobi.com/documentation/9.5/refman/r_api_overview.html). It also relies on a spatial branch-and-bound framework similar in spirit to Chen & Burer’s method, but with QP/LP-based convex relaxations instead of CP/DNN, bringing several practical advantages in our setting: 
- It provides an easy-to-use R package and a clear documentation, and is effectively free for many university-affiliated users via an academic license.
- For portfolio selection purposes, cheap computation and short running times are more important than extremely tight optimality gaps. Gurobi allows us to explicitly control the optimality tolerance (e.g., via `MIPGap` and time limits).
- It can handle a wide range of problem classes (e.g., MILP, MIQP, QCP), making it convenient to extend the MG framework to more realistic settings with additional linear or mixed-integer constraints.

---

## Algorithm & Implementation






---

## Empirical Findings



---

## Repository Structure



---

## References
<a id="chen2014"></a>
**Chen, Z., Li, Z., & Wang, L. (2014).**  
Concentrated portfolio selection models based on historical data.  
*Applied Stochastic Models in Business and Industry*, 31(5), 649–668.

<a id="chen2012"></a>
**Chen J. and Burer S. (2012).**  
Globally solving nonconvex quadratic programming problems via completely positive programming. 
*Mathematical programming Computation*, 4(1), 33–52.
