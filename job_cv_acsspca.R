args <- commandArgs()
# define arguments
setwd <- args[6]
index <- as.numeric(args[7])
npc <- as.numeric(args[8])
nfolds <- as.numeric(args[9])
ykernel <- args[10]
akernel <- args[11]
c1 <- as.numeric(args[12])
maxiter <- as.numeric(args[13])
delta <- as.numeric(args[14])
filter <- as.numeric(args[15])
minmaxsep <- as.numeric(args[16])

cat("setwd: ",setwd,"\n")
cat("index: ", index,"\n")
cat("npc: ",npc,"\n")
cat("nfolds: ",nfolds,"\n")
cat("ykernel: ",ykernel,"\n")
cat("akernel: ",akernel,"\n")
cat("c1: ",c1,"\n")
cat("maxiter: ",maxiter,"\n")
cat("delta: ",delta,"\n")
cat("filter: ",filter,"\n")
cat("minmaxsep: ",minmaxsep,"\n")


cat("load libraries \n")
library(tidyverse)
library(acSPCA)

dfpath <- paste(setwd,"temp/df.txt",sep="")
parampath <- paste(setwd, "temp/param.txt",sep="")
df <- read.table(file=dfpath, header=T)
paramgrid <- read.table(file=parampath, header=T)
fpath <- paste(setwd,"temp",sep="")
xnpath <- paste(fpath,"/xnames.txt",sep="")
ynpath <- paste(fpath,"/ynames.txt",sep="")
anpath <- paste(fpath,"/anames.txt",sep="")
xnames <- read.table(file=xnpath) |> as.matrix() |> as.vector()
ynames <- read.table(file=ynpath) |> as.matrix() |> as.vector()
anames <- read.table(file=anpath) |> as.matrix() |> as.vector()

if(is.na(c1)) c1 <- NULL

acsspca.obj <- cv.partition.acSSPCA.lambda(arg.sparse=paramgrid[index,],df.partition=df,npc=npc,n.folds=nfolds,resp.kernel=ykernel,conf.kernel=akernel,bandwidth=bandwidth,c1=c1,maxiter=maxiter,delta=delta,filter=filter,minmaxsep=minmaxsep,x.names=xnames,y.names=ynames,a.names=anames)

fpath <- paste(setwd,"temp/cv_outputs/job_",index,".txt",sep="")
data.obj <- data.frame(job=index,fold=paramgrid[index,1],sparse=paramgrid[index,2],lambda=paramgrid[index,3],cv.metric=acsspca.obj)
write.table(data.obj,file=fpath,quote=F,row.names=F,col.names=T)
