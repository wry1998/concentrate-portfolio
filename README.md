# Concentrated Portfolio Selection with Mean–Greedy–Matrix (MG) Model

This repository implements a concentrated portfolio selection model based on the mean–greedy–matrix (MG) risk measure, and compares it against the classic mean–variance (MV) framework on U.S. and Chinese equity markets. 


The project reproduces and extends the empirical study of Chen, Li, and Wang (2014) on concentrated portfolios, using updated data and a modern non-convex optimizer (Gurobi).

1. Project Overview

Traditional portfolio models such as mean–variance (MV), mean–semivariance (M-SV), and mean–CVaR (M-CVaR) typically select well-diversified portfolios. In practice, however, investors often hold concentrated portfolios due to:

High transaction costs or indivisible positions (e.g., households).

Limited supply of truly “good” stocks and a preference to focus on a few winners.

Strategic reasons (e.g., avoiding benchmark-like diversification).

To meet this need, the mean–greedy–matrix (MG) model introduces a new risk measure that explicitly captures investors’ greedy psychology:

“Upside deviation should be as large as possible, while downside deviation should be as small as possible.”

As a result, MG naturally selects few, strongly performing assets while remaining computationally tractable.

2. Methodology
2.1 Mean–Greedy–Matrix Risk Measure

For a portfolio weight vector 
𝜔
ω, the MG risk measure is

𝜌
(
𝜔
)
=
𝜔
⊤
𝐺
𝜔
,
ρ(ω)=ω
⊤
Gω,

where 
𝐺
G is a greedy matrix constructed similarly to a covariance matrix, with a key difference on the diagonal:

Off-diagonal entries 
𝑔
𝑖
𝑗
g
ij
	​

 are standard sample covariances.

Diagonal entries 
𝑔
𝑖
𝑖
=
𝜎
𝑖
𝑖
−
−
𝜎
𝑖
𝑖
+
g
ii
	​

=σ
ii
−
	​

−σ
ii
+
	​

,
where 
𝜎
𝑖
𝑖
−
σ
ii
−
	​

 and 
𝜎
𝑖
𝑖
+
σ
ii
+
	​

 are downside and upside deviations of asset 
𝑖
i.

Properties:

𝜌
(
𝜔
)
ρ(ω) can be negative, effectively combining:

Minimization of downside deviation, and

Maximization of upside deviation,
into a single objective.

This encourages concentrated portfolios that load heavily on consistently strong assets.

2.2 Simple MG Model

The simple MG model ignores taxes, transaction costs, and dividends, and solves:

min
⁡
𝜔
	
𝜌
(
𝜔
)
=
𝜔
⊤
𝐺
𝜔


s.t.
	
∑
𝑖
=
1
𝑛
𝜔
𝑖
𝑟
𝑖
=
𝑒
(target return)


	
∑
𝑖
=
1
𝑛
𝜔
𝑖
=
1


	
𝜔
𝑖
≥
0
,
𝑖
=
1
,
…
,
𝑛
(no short selling)
.
ω
min
	​

s.t.
	​

ρ(ω)=ω
⊤
Gω
i=1
∑
n
	​

ω
i
	​

r
i
	​

=e(target return)
i=1
∑
n
	​

ω
i
	​

=1
ω
i
	​

≥0,i=1,…,n(no short selling).
	​


Here 
𝑟
𝑖
r
i
	​

 is the mean return of asset 
𝑖
i and 
𝑒
e is the investor-specified target return.

2.3 Realistic MG Model

The realistic MG model incorporates transaction costs, bounds on weights, taxes, and dividends. Let

𝜔
0
ω
0
 be initial holdings,

𝜔
ω be final weights,

𝑐
𝑖
c
i
	​

 be transaction cost of asset 
𝑖
i,

𝑘
𝑖
𝑠
,
𝑘
𝑖
𝑏
k
i
s
	​

,k
i
b
	​

 be unit sell/buy costs,

𝑅
𝑖
R
i
	​

 be after-tax, dividend-adjusted returns.

The model minimizes 
𝜌
(
𝜔
)
ρ(ω) subject to:

Target net return,

Total transaction cost cap 
𝛾
γ,

Linearized buy/sell cost constraints,

Lower and upper bounds 
𝜔
‾
𝑖
≤
𝜔
𝑖
≤
𝜔
‾
𝑖
ω
	​

i
	​

≤ω
i
	​

≤
ω
i
	​

,

Full-investment constraint 
∑
𝑖
𝜔
𝑖
=
1
∑
i
	​

ω
i
	​

=1.

For empirical work here, taxes are set to zero and initial holdings are taken as zero for simplicity, following the original paper’s setup. 

Final Essay

2.4 Performance Metrics

Out-of-sample performance is evaluated using:

Expected return 
𝑅
R,

Standard deviation (Std),

CVaR (e.g., 0.8-CVaR),

Diversification measures:

Zero-norm 
𝑍
𝑁
(
𝜔
)
=
#
{
𝑖
:
𝜔
𝑖
≠
0
}
ZN(ω)=#{i:ω
i
	​


=0},

Herfindahl index 
𝐻
𝐼
(
𝜔
)
=
∑
𝑖
𝜔
𝑖
2
HI(ω)=∑
i
	​

ω
i
2
	​

,

Reward-to-risk ratios:

𝑅
/
Std
R/Std,

𝑅
/
CVaR
R/CVaR,

Farinelli–Tibiletti (FT) ratio with various 
(
𝑝
,
𝑞
)
(p,q) choices.

3. Data

We use equity return data from:

U.S. stock market

Subset of the original Chen–Li–Wang stock pool

Shortened sample (e.g., 2011-03-30 to 2011-10-13) due to missing data.

Chinese stock market

600 daily returns (2009-01-13 to 2011-07-01),

One stock dropped due to missing prices.

Daily returns are computed from adjusted close prices:

return
𝑡
=
price
𝑡
−
price
𝑡
−
1
price
𝑡
−
1
.
return
t
	​

=
price
t−1
	​

price
t
	​

−price
t−1
	​

	​

.

Out-of-sample windows of 5 and 10 trading days are used to test robustness across different trading frequencies. 

Final Essay

4. Software & Tools

Main stack:

R (version ≥ X.X.X)

Gurobi Optimizer (non-convex quadratic programming)

gurobi R package

MG is a non-convex quadratic program, but can be efficiently solved by Gurobi with:

Quadratic objective matrix 
𝑄
=
𝐺
Q=G (or block matrix for realistic MG),

Linear equality/inequality constraints for target return, costs, and bounds,

Bound constraints on decision variables.

See Final Essay.pdf Section 3 “Software and Tools” for example code snippets and matrix formulations. 

Final Essay

5. Repository Structure

⚠️ Adjust this section to match your actual repo layout.

.
├── data/
│   ├── us_returns.csv
│   ├── cn_returns.csv
│   └── ...
├── R/
│   ├── build_greedy_matrix.R
│   ├── simple_MG_US.R
│   ├── simple_MG_CN.R
│   ├── realistic_MG_US.R
│   ├── realistic_MG_CN.R
│   └── utils_plot.R
├── results/
│   ├── tables_simple_MG_US.csv
│   ├── tables_simple_MG_CN.csv
│   ├── plots_realistic_MG_US.png
│   └── plots_realistic_MG_CN.png
├── report/
│   └── Final Essay.pdf
└── README.md

6. Getting Started
6.1 Requirements

R ≥ X.X.X

Gurobi installed and licensed

R package gurobi (and other dependencies, e.g. tidyverse, matrixStats, …)

6.2 Installation

Install Gurobi and activate the license.

Install the R package:

install.packages("gurobi")  # or via Gurobi’s installer instructions


Clone this repository:

git clone https://github.com/<username>/<repo-name>.git
cd <repo-name>

7. Reproducing the Experiments

(Fill in the exact script names / commands you use.)

Example workflow:

Build greedy matrix and basic statistics

source("R/build_greedy_matrix.R")


Run simple MG vs MV on U.S. data

source("R/simple_MG_US.R")


Run simple MG vs MV on Chinese data

source("R/simple_MG_CN.R")


Run realistic MG experiments (bounds, transaction costs, target returns)

source("R/realistic_MG_US.R")
source("R/realistic_MG_CN.R")


Generated tables and plots will be saved under results/ and correspond to the figures and tables in the report.

8. Summary of Key Findings

High-level empirical conclusions (see report for full details): 

Final Essay

MG portfolios are concentrated and competitive

MG tends to select few assets with strong performance.

In many U.S. cases, MG outperforms MV in reward-to-risk terms, especially with longer out-of-sample windows.

Effect of trading frequency

U.S. market: trading less frequently (longer OS window) improves MG performance → market is relatively steady.

Chinese market: trading more frequently is beneficial → prices are more policy-driven and volatile.

Realistic MG robustness

In both markets, MG’s performance is largely insensitive to:

Target return level, and

Unit transaction cost within a reasonable range.

Impact of weight bounds

U.S.: Best MG performance when weights are not capped (true concentration allowed).

China: Performance first deteriorates then improves as the upper bound increases, with the best outcome at an intermediate cap.

Overall, MG demonstrates that efficient, concentrated portfolios can be constructed in a fully data-driven way and solved efficiently with modern non-convex optimization tools.

9. References

Chen, Z., Li, Z., & Wang, L. (2014). Concentrated portfolio selection models based on historical data. Applied Stochastic Models in Business and Industry, 31(5), 649–668.

Markowitz, H. (1952). Portfolio Selection. Journal of Finance, 7(1), 77–91.

Rockafellar, R. T., & Uryasev, S. (2000). Optimization of conditional value-at-risk. Journal of Risk, 2, 21–41.

Additional references as listed in Final Essay.pdf. 

Final Essay
