library(xts)
library(PerformanceAnalytics)


############################# read from csv files (in-sample) #########################
readInsample = function(index_return,index_div,country){
  setwd(paste('.../02_Data/Training/',toString(country),sep=''))
  N=length(index_return)
  
  ## read for returns
  data_return = as.list(rep(NA,N))
  for (i in 1:N) {
    tdata = read.csv(paste(toString(index_return[i]),'.csv',sep=''))[,c(1,6)]
    ti = as.Date(tdata[,1])
    tdata = xts(tdata[,2],order.by = ti)
    tdata = as.numeric(tdata)
    
    for (j in 1:length(tdata)){ #deal with NA: take the same value as last period
      if(is.na(tdata[j])){
        tdata[j] = tdata[j-1]
      }
    }
    
    for(k in length(tdata):2){
      tdata[k] = tdata[k]/tdata[k-1]-1
    }
    
    tdata = xts(tdata[-1],order.by = ti[-1])
    #    data_return[[i]] = tdata
    data_return[[i]] = tail(tdata,137)
  }
  
  ## read for dividents
  data_div = as.list(rep(NA,N))
  for (i in 1:N) {
    if (is.na(index_div[i])){
      data_div[[i]] = 0
    }else{
      data_div[[i]] = read.csv(paste(toString(index_div[i]),'_dividend_train.csv',sep=''))[,2]
    }
  }
  
  data = list('return' = data_return,'div' = data_div)
  return(data)
}



############################# read from csv files (out-of-sample) #########################
readOutofSample = function(index_return,index_div,country){
  setwd(paste('.../02_Data/Testing/',toString(country),sep=''))
  N=length(index_return)
  
  ## read for div
  div = as.list(rep(NA,N))
  for (i in 1:N) {
    if (is.na(index_div[i])){
      div[[i]] = 0
    }else{
      div[[i]] = read.csv(paste(toString(index_div[i]),'_dividend_test.csv',sep=''))[,2]
    }
  }
  
  ## read for returns
  OS_5 = as.list(rep(NA,N))
  OS_10 = as.list(rep(NA,N))
  for (i in 1:N) {
    tdata = read.csv(paste(toString(index_return[i]),'.csv',sep=''))[,c(1,6)]
    ti = as.Date(tdata[,1])
    tdata = xts(tdata[,2],order.by = ti)
    tdata = as.numeric(tdata)
    
    for(k in length(tdata):2){
      tdata[k] = tdata[k]/tdata[k-1]-1
    }
    
    tdata = xts(tdata[-1],order.by = ti[-1])
    
    OS_10[[i]] = tdata[1:10] + sum(div[[i]])/length(tdata)
    OS_5[[i]] = tdata[1:5] + sum(div[[i]])/length(tdata)
  }
  
  mylist = list('OS_5' = OS_5, 'OS_10'=OS_10)
  return(mylist)
}




############################## statistics for OS-5 & OS-10 ########################
## leave 10 out-of-sample testing
analys_OS10 = function(w,R){    ## w is the optimal portfolio obtained from training data, R is the daily return of testing data
  N = length(w)
  ## diversification
  ZN = length(which(w != 0))
  HI = sum(w %*% w)
  
  ## return of portfolio
  Rp = c()
  for(i in 1:10){
    Rp[i] = 0
    for(j in 1:N){
      Rp[i] = R[[j]][i]*w[j]+Rp[i]
    }
  }
  
  ## mean, sd, cvar
  mu = mean(Rp)
  sd = sd(Rp)
  cvar = abs(sum(sort(Rp)[c(1,2)])/(0.8*10))
  
  ## reward-to risk
  R_sd = mu/sd
  R_cvar = mu/cvar
  FT_11 = sum(max(0,Rp)*0.1)/sum(abs(min(0,Rp))*0.1)
  FT_13 = sum(max(0,Rp)*0.1)/(sum(abs(min(0,Rp))^3*0.1))^(1/3)
  
  result = c(mu,sd,cvar,R_sd,R_cvar,FT_11,FT_13,ZN,HI)
  return(result)
}


## leave 10 out-of-sample testing
analys_OS5 = function(w,R){    ## w is the optimal portfolio obtained from training data, R is the daily return of testing data
  N = length(w)
  ## diversification
  ZN = length(which(w != 0))
  HI = sum(w %*% w)
  
  ## return of portfolio
  Rp = c()
  for(i in 1:5){
    Rp[i] = 0
    for(j in 1:N){
      Rp[i] = R[[j]][i]*w[j]+Rp[i]
    }
  }
  
  ## mean, sd, cvar
  mu = mean(Rp)
  sd = sd(Rp)
  cvar = abs(min(Rp)/(0.8*5))
  
  ## reward-to risk
  R_sd = mu/sd
  R_cvar = mu/cvar
  FT_11 = sum(max(0,Rp)*0.2)/sum(abs(min(0,Rp))*0.2)
  FT_13 = sum(max(0,Rp)*0.2)/(sum(abs(min(0,Rp))^3*0.2))^(1/3)
  
  result = c(mu,sd,cvar,R_sd,R_cvar,FT_11,FT_13,ZN,HI)
  return(result)
}