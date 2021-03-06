library(quantreg)

set.seed(793)


#Probability Integral Transform for weight distribution
finv=function(u){
  if(u<=0.5){
    w=-sqrt(25/16-2*u)
  }
  else{
    w=sqrt(2*u-7/16)
  }
  return(w)
}


Beta_hat={}
Length={}
L_Beta={}
U_Beta={}

#Replicate
for (L in 1:1000){
  #Date generate
  n=50
  x0=rep(1,n)
  x1=rlnorm(n,meanlog=0,sdlog=1)
  x2=c(rep(1, n*0.8),rep(0, n*0.2))
  X=cbind(x0,x1,x2)
  epsilon=rt(n, df=3)
  beta=c(1,1,1)
  y=beta[1]+beta[2]*x1+beta[3]*x2+3^(-0.5)*(2+(1+(x1-8)^2+x2)/10)*epsilon
  fit=rq(y~x1+x2, tau=0.5)
  beta_hat=fit$coefficients
  Beta_hat=rbind(Beta_hat,beta_hat)
  ehat=y-X%*%beta_hat
  
  #Wild Bootstrap
  B=1000
  Beta_star={}
  
  for(l in 1:B){
    u=runif(n)
    w=sapply(u,finv)
    estar=w*abs(ehat)
    ystar=X%*%beta_hat+estar
    fit_star=rq(ystar~x1+x2, tau=0.5)
    beta_star=fit_star$coefficients
    Beta_star=rbind(Beta_star, beta_star)
  }
  
  
  sd=apply(Beta_star,2,sd)
  #CI Length
  length=2*qnorm(0.975)*sd
  Length=rbind(Length,length)
  
  #Construct Confidence Interval
  L_beta=beta_hat-0.5*length
  U_beta=beta_hat+0.5*length
  L_Beta=rbind(L_Beta,L_beta)
  U_Beta=rbind(U_Beta,U_beta)
}


#Average Length
apply(Length,2,mean)
#Coverage Probability
length(which((L_Beta[,1]<1)&(U_Beta[,1]>1)))/1000
length(which((L_Beta[,2]<1)&(U_Beta[,2]>1)))/1000
length(which((L_Beta[,3]<1)&(U_Beta[,3]>1)))/1000
