args <- commandArgs()
# define arguments
setwd <- args[6]
fpath <- paste(setwd, "temp/cv_outputs/",sep="")
file.list <- list.files(fpath,".txt")
file.path.list <- paste0(fpath,file.list)

parampath <- paste(setwd, "temp/param.txt",sep="")
paramgrid <- read.table(file=parampath, header=T)
n.sp <- length(unique(paramgrid$sp.arg))
n.folds <- length(unique(paramgrid$fold.arg))
n.lambdas <- length(unique(paramgrid$lambdas))
n.args <- n.sp*n.lambdas

read_cv_func <- function(x){
  temp.obj <- read.table(file=x,header=T)
  return(temp.obj)
}
cv.list <- lapply(file.path.list,read_cv_func)
cv.obj <- do.call(rbind.data.frame,cv.list)
cv.mat <- cv.obj[order(cv.obj$job),]
cv.mat <- cv.mat[,-1]

metric.matrix <- acSPCA::matrix.fill(param.grid=cv.mat,n.args=n.args,n.folds=n.folds)
cv.metric <- apply(metric.matrix,1,mean)
spath <- paste(setwd, "temp/sparg.txt",sep="")
lpath <- paste(setwd, "temp/lambdas.txt",sep="")
sp.arg <- read.table(spath, header=T) |> as.matrix() |> as.vector()
l.arg <- read.table(lpath, header=T) |> as.matrix() |> as.vector()
arg.list.vec <- expand.grid(sp.arg,l.arg)
cv.df <- data.frame(arg.list.vec,cv.metric)
colnames(cv.df) <- c("sparse","lambda","cv.metric")
best.metric <- min(cv.df$cv.metric)
best.sparse <- cv.df$sparse[which(cv.df$cv.metric==best.metric)]
best.lambda <- cv.df$lambda[which(cv.df$cv.metric==best.metric)]

cat("best cv metric: ",best.metric,"\n")
cat("best sparse parameter: ",best.sparse,"\n")
cat("best lambda parameter: ",best.lambda,"\n")