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

## Implementation
Below is a sample R code on how to build the simple and realistic models, more information on [R interface](https://www.gurobi.com/documentation/9.5/refman/r_api_overview.html):

```
library(Gurobi)

## build model
model = list()
model$Q = Q                  ## the quadratic objective w'Qw
model$A = A                  ## the linear constraint Aw %sense% b
model$sense = c('=','<','>') ## the linear constraint Aw %sense% b
model$rhs = b                ## the linear constraint Aw %sense% b
model$lb = l                 ## lower bound for w
model$ub = u                 ## upper bound for w

## setup parameters
params = list()
params$method = 2            ## solving algorithm to use
params$NonConvex = 2         ## programming type

## optimal portfolio
weight = gurobi(model, params)$x[1:N]
```

Simple model:

$$Q = G$$

$$
\begin{bmatrix} 
\bar{r_1} & \dots & \bar{r_N} \\ 
1 & \dots & 1
\end{bmatrix}
\begin{bmatrix}
w_1 \\
\dots \\
w_N
\end{bmatrix} 
\begin{bmatrix}
= \\
\=
\end{bmatrix}
\begin{bmatrix}
e \\
1
\end{bmatrix}
$$

Realistic Model:

$$ Q =
\begin{bmatrix}
G & 0 \dots 0 \\
0 \dots 0 & 0 \dots 0
\end{bmatrix}
$$

$$
\begin{bmatrix}
r_1+d_1 & \dots & r_N+d_N & -1 & \dots & -1 \\
1 & \dots & 1 & 0 & \dots & 0 \\
0 & \dots & 0 & 1 & \dots & 1 \\
-k_1 & \dots & 0 & 1 & \dots & 0 \\
\dots & \dots & \dots & \dots & \dots & \dots \\
0 & -k_i & 0 & 0 & 1 & 0 \\
\dots & \dots & \dots & \dots & \dots & \dots \\
0 & \dots & -k_N & 0 & \dots & 1
\end{bmatrix}
\begin{bmatrix}
w_1 \\
\dots \\
w_N \\
c_1 \\
\dots \\
c_N
\end{bmatrix} 
\begin{bmatrix}
= \\
= \\
<= \\
\>= \\
\dots \\
\>=
\end{bmatrix} 
\begin{bmatrix}
1 \\
e \\
\gamma \\
0 \\
\dots \\
0
\end{bmatrix} 
$$


---

## Empirical Findings

Empirical results are applied on American (2011-03-30 to 2011-10-13) and Chinese stock market (2009-01-13 to 2011-07-01), and optimal portfolios are evaluated by their out-of-sample performance. Return, standard deviation, CVaR, and Famelli-Tibiletti ratio are used to evaluate portfolio performance, while zero-norm and Herfindahl index are used to evaluate portfolio diversification. We observed the following:

-	Portfolios selected by concentrate algorithm is much more concentrated than portfolios selected by mean-variance algorithm with much less stocks selected and a higher individual weights, due to the concentrate nature of G
-	Low diversification is not necessarily associated with poor performance, as MG portfolios in general outperform MV portfolios. This is consistent with real world market structure that most indices are highly concentrated in a few dominate stocks
-	To limit the weight of individual stocks has a positive effect on Chinese Market while a negative effect on American Market, as Chinese stock market is more policy driven and regime dependent, and head-stock dominance is less stable
-	A high transaction cost will not affect the performance of MG portfolios, which is another advantage compared to the mean-variance algorithm
-	A “greedy choice” of target return generally doesn’t improve portfolio performance

*Note: Data were downloaded from yahoo finance. The time period and stock contents are slightly different from those in the original paper because of data quality issues.*

---

## Repository Structure
```text
.
├── 01_Program/                     # R implementation of the mean-greedy model
│   ├── 01_Model_Setup.R            # Functions to set up the simple and realistic mean-greedy models
│   ├── 02_Supporting_Functions.R   # Supporting functions such as reading data from csv files, calculate the statistics, etc.
│   └── 03_Empirical_Results.R      # Compute optimal portfolio and evaluate it's performance
│
├── 02_Data/                        # Data folder
│   ├── Testing/                    # Data used for testing
│       ├── American/               # Stocks from American stock market, both stock prices and dividents
│       └── Chinese/                # Stocks Chinese stock market, both stock prices and dividents
│   └── Training/                   # Data used for training
│       ├── American/               # Stocks from American stock market, both stock prices and dividents
│       └── Chinese/                # Stocks Chinese stock market, both stock prices and dividents
│           
├── 04_report/                       
│   └── report.pdf                  # Final report
│ 
└── README.md
```

---

## Retrospective Note on Empirical Results

At the time when this project was originally completed in 2021, the empirical design closely followed the **out-of-sample setup** in [Chen, Li & Wang (2014)](#chen2014): optimal portfolios are estimated on a long in-sample window using the entire sample period except the last 5/10 trading days, and then evaluated out-of-sample over a single short block of 5/10 trading days. In hindsight, this evaluation protocol is **statistically very weak**:

- Using only 5–10 daily observations to compute expected returns and risk measures provides almost no robust information about true model performance.
- Any apparent performance differences across models over such a short horizon could easily be driven by noise or by the specific choice of data, rather than by a genuinely superior strategy.

Thus, if I were to revisit this topic today, I would prefer a **rolling window scheme** over the simple out-of-sample setup, in order to obtain more reliable performance statistics and to reduce sample-selection effects. 

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
