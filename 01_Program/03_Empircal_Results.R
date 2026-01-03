##################### set parameters #################
e = 0.001      ## target return
k = 0.001      ## transaction cost
gamma = 0.005  ## transaction cost limit
u = 0.2        ## upper bound for weights




########################## empirical results US #######################
## load raw data
ind_us_return = c('AAPL','AEP','APO','BA','BIDU','CBSH','DUK','EL','F','FDX','GS','HD','JNJ','JPM','KO','LFC','MCD',
                    'MDLZ','MSFT','NKE','PG','PTR','RIO','SNP','WMT','XOM','ZNH','riskfreerate')
ind_us_div = c(NA,'AEP','APO','BA',NA,'CBSH','DUK','EL',NA,'FDX','GS','HD','JNJ','JPM','KO','LFC','MCD',
                 'MDLZ','MSFT','NKE','PG','PTR','RIO','SNP','WMT','XOM',NA,NA)
ind_us_divt = c(rep(NA,20),'PG',rep(NA,7))
country1 = 'American'

data_raw_us = readInsample(ind_us_return,ind_us_div,country1) ## read for training data
test_data_us = readOutofSample(ind_us_return,ind_us_divt,country1) ## read for testing data

## optimal portfolio
data_us = OptimizeInfo(data_raw_us,ind_us_return,ind_us_div,country1)

MV_simple_us = simple_model(data_us$Sigma,data_us$r_bar,e,data_us$n)        ## mean-variance model, simple
MV_real_us = real_model(data_us$Sigma,data_us$r_bar,e,data_us$n,gamma,k,u)  ## mean-variance model, realistic

MG_simple_us = simple_model(data_us$G,data_us$r_bar,e,data_us$n)            ## mean-greedy model, simple
MG_real_us = real_model(data_us$G,data_us$r_bar,e,data_us$n,gamma,k,u)      ## mean-greedy model, realistic


## an example of evaluate the performance of portfolio on testing data
## leave-10-out-of-sample testing, mean-variance simple model
mu = analys_OS10(MV_simple_us,test_data_us$OS_10)$mu          ## return rate
sd = analys_OS10(MV_simple_us,test_data_us$OS_10)$sd          ## standard deviation
cvar = analys_OS10(MV_simple_us,test_data_us$OS_10)$cvar      ## CVaR
mu_sd = analys_OS10(MV_simple_us,test_data_us$OS_10)$R_sd     ## return/standard deviation
mu_cvar = analys_OS10(MV_simple_us,test_data_us$OS_10)$R_cvar ## return/CVaR
FT_11 = analys_OS10(MV_simple_us,test_data_us$OS_10)$FT_11    ## Farnelli-Tibiletti ratio, left order = 1, right order = 1
FT_13 = analys_OS10(MV_simple_us,test_data_us$OS_10)$FT_13    ## Farnelli-Tibiletti ratio, left order = 1, right order = 3
zn = analys_OS10(MV_simple_us,test_data_us$OS_10)$ZN          ## zero-norm
hi = analys_OS10(MV_simple_us,test_data_us$OS_10)$HI          ## Herfindahl index





########################## empirical results A-share #######################
## load raw data
ind_aShare_return = c('000002.SZ','000063.SZ','000951.SZ','002024.SZ','600011.SS','600019.SS','600028.SS','600030.SS',
                   '600085.SS','600118.SS','600125.SS','600138.SS','600150.SS','600298.SS','600388.SS','600519.SS',
                   '600598.SS','600601.SS','600859.SS','600887.SS','600970.SS','601006.SS','601088.SS','601111.SS',
                   '601318.SS','601398.SS','601600.SS','601857.SS','601919.SS')
ind_aShare_div = c('000002.SZ','000063.SZ','000951.SZ','002024.SZ','600011.SS','600019.SS','600028.SS','600030.SS',
                '600085.SS','600118.SS','600125.SS','600138.SS','600150.SS','600298.SS','600388.SS','600519.SS',
                '600598.SS','600601.SS','600859.SS',NA,'600970.SS','601006.SS','601088.SS','601111.SS',
                '601318.SS','601398.SS',NA,'601857.SS','601919.SS')
ind_aShare_divt = c(NA,'000063.SZ',NA,NA,NA,NA,NA,NA,'600085.SS',NA,NA,'600138.SS','600150.SS',NA,'600388.SS','600519.SS',
                 '600598.SS',NA,'600859.SS',NA,NA,NA,NA,NA,'601318.SS',NA,'601600.SS',NA,NA)
country2= 'Chinese'

data_raw_aShare = readInsample(ind_aShare_return,ind_aShare_div,country2)


## optimal portfolio
data_aShare = OptimizeInfo(data_raw_aShare,ind_aShare_return,ind_aShare_div,country2)

MV_simple_aShare = simple_model(data_aShare$Sigma,data_aShare$r_bar,e,data_aShare$n)
MV_real_aShare = real_model(data_aShare$Sigma,data_aShare$r_bar,e,data_aShare$n,gamma,k,u)

MG_simple_aShare = simple_model(data_aShare$G,data_aShare$r_bar,e,data_aShare$n)
MG_real_aShare = real_model(data_aShare$G,data_aShare$r_bar,e,data_aShare$n,gamma,k,u)