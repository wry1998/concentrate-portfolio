library(gurobi)


############################### model inputs  #######################
OptimizeInfo = function(data,index_return,index_div,country){
  N = length(index_return)
  returns = data$return
  div = data$div
  period = length(returns[[1]])
  
  ## compute Sigma
  Sigma = matrix(nrow = N,ncol = N)
  for(i in 1:N){
    for(j in 1:N){
      Sigma[i,j] = cov(returns[[i]],returns[[j]])
    }
  }
  
  
  ## compute G
  G = matrix(nrow = N,ncol = N)
  for(i in 1:N){
    for(j in 1:N){
      if(i == j){
        mu = mean(returns[[i]])
        sigma_min = sum(min(returns[[i]]-mu,0)^2)/period
        sigma_max = sum(max(returns[[i]]-mu,0)^2)/period
        G[i,j] = sigma_min-sigma_max
      }else{
        G[i,j] = cov(returns[[i]],returns[[j]])
      }
    }
  }
  
  ## compute bar_Ri
  R_bar = c()
  for (i in 1:N){
    R_bar[i] = mean(returns[[i]])+sum(div[[i]])/period
  }
  ## compute bar_ri
  r_bar = c()
  for (i in 1:N){
    r_bar[i] = mean(returns[[i]])
  }
  
  my_return = list('R_bar'=R_bar, 'r_bar'=r_bar, 'G'=G, 'n'=N-1,'Sigma'=Sigma)
  return(my_return)
  
}



############################### portfolio optimization ####################
## simple 
simple_model = function(G,r,e,n){
  ## parameters
  params <- list()
  params$method = 2
  params$NonConvex = 2
  params$ResultFile = 'model.sol'
  
  ## model setup
  model = list()
  model$Q = G
  model$A = rbind(r,rep(1,n+1))
  model$rhs = c(e,1)
  model$sense = '='
  model$modelsense = 'min'  
  
  ## optimal weights
  result <- gurobi(model, params)
  w = result$x
  return(w)
}


## realistic
real_model = function(G,R,e,n,gamma,k,u){
  ## parameters
  params <- list()
  params$method = 2
  params$NonConvex = 2
  params$ResultFile = 'model.sol'

  ## model setup
  model = list()  
  model$Q = rbind(cbind(G,matrix(rep(0,n*(n+1)),nrow=n+1,ncol=n)),
                  matrix(rep(0,n*(2*n+1)),nrow=n,ncol=2*n+1))
  cons_c = cbind(diag(-k,n),rep(0,n),diag(1,n))
  model$A = rbind(c(rep(1,n+1),rep(0,n)),c(R,rep(-1,n)),
                  c(rep(0,n+1),rep(1,n)),cons_c)
  model$rhs = c(1,e,gamma,rep(0,n))
  model$sense= c('=','=','<=',rep('>=',n))
  model$ub = c(rep(u,n+1),rep(gamma,n))
  
  ## optimal weights
  result <- gurobi(model, params)
  w = result$x[1:(n+1)]
  return(w)
}