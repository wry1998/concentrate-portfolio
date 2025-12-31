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

As well as an actual investment environment with more assumptions are added:

$$
\begin{aligned}
\min_w & w' G w \\
\text{s.t.} & \sum_{i=1}^N w_i \bar{r_i} = e \\
& \sum_{i=1}^N w_i = 1, \quad w_i \ge 0
\end{aligned}
$$

Note that this is a non-convex process




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


Rockafellar, R. T., & Uryasev, S. (2000). Optimization of conditional value-at-risk. Journal of Risk, 2, 21–41.
