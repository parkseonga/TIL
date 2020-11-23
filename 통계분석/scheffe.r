names(final)
final_math<-readxl::read_excel("C:\\Users\\USER\\Documents\\R\\기말 설문조사\\문항 2개 비교.xlsx",1)
final_2<-readxl::read_excel("C:\\Users\\USER\\Documents\\R\\기말 설문조사\\기말 분석_2.xlsx",1)
math<-readxl::read_excel("C:\\Users\\USER\\Documents\\R\\기말 설문조사\\math.xlsx",2)
com<-read.csv("cor.csv")


math<-readxl::read_excel("D:\\math.xlsx",2)
ggplot(data=subset(math,!is.na(math$게임)),aes(x=c(학습진척도,리더보드,배지,미션)))+geom_boxplot()
boxplot(aaaa,main="관련 문항별 사후 분석 결과")+
  
final_r<-lm(final_2$`개인별 설문조사`~미션+배지+리더보드+학습진척도+카탄+루미큐브+마피아+포켓볼+통계+`수열과 연립방정식`,data=final_2)       
summary(final_r)       

relweights <- function(fit,...){
  R <- cor(fit$model)
  nvar <- ncol(R)
  rxx <- R[2:nvar, 2:nvar]
  rxy <- R[2:nvar, 1]
  svd <- eigen(rxx)
  evec <- svd$vectors
  ev <- svd$values
  delta <- diag(sqrt(ev))
  lambda <- evec %*% delta %*% t(evec)
  lambdasq <- lambda ^ 2
  beta <- solve(lambda) %*% rxy
  rsquare <- colSums(beta ^ 2)
  rawwgt <- lambdasq %*% beta ^ 2
  import <- (rawwgt / rsquare) * 100
  import <- as.data.frame(import)
  row.names(import) <- names(fit$model[2:nvar])
  names(import) <- "Weights"
  import <- import[order(import),1, drop=FALSE]
  dotchart(import$Weights, labels=row.names(import),
           xlab="% of R-Square", pch=19,
           main="상대적인 중요성",   
           sub=paste("Total R-Square=", round(rsquare, digits=3)),
           ...)
  return(import)
}

relweights(final_r)


final_A<-final_after[c(1:2)]
names(final_A)<-c("학과","학번")

a<-final_after[c(3:6)]
final_A$미션<-apply(a,1,mean,na.rm=TRUE)
a<-final_after[c(7:10)]
final_A$배지<-apply(a,1,mean,na.rm=TRUE)
a<-final_after[c(11:13)]
final_A$리더보드<-apply(a,1,mean,na.rm=TRUE)
a<-final_after[c(14:16)]
final_A$학습진척도<-apply(a,1,mean,na.rm=TRUE)
a<-final_after[c(17:18)]
final_A$카탄<-apply(a,1,mean,na.rm=TRUE)
a<-final_after[c(19:20)]
final_A$루미큐브<-apply(a,1,mean,na.rm=TRUE)
a<-final_after[c(21:22)]
final_A$마피아<-apply(a,1,mean,na.rm=TRUE)
a<-final_after[c(23:24)]
final_A$포켓볼<-apply(a,1,mean,na.rm=TRUE) 
a<-final_after[c(25:26)]
final_A$통계<-apply(a,1,mean,na.rm=TRUE)
a<-final_after[c(23:24)]
final_A$포켓볼<-apply(a,1,mean,na.rm=TRUE)
a<-final_after[c(27:28)]
final_A$수열과연립방정식<-apply(a,1,mean,na.rm=TRUE)
a<-final_after[c(29:38)]
final_A$개인별설문조사<-apply(a,1,mean,na.rm=TRUE)


final_all<-inner_join(final_A,final_score,by="학번")
final_all<-finall_all[-15]
final_all<-final_all[,c(1,2,15,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,21,22,23)]
View(final_all)
final_all<-final_all[,c(1,3,2,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23)]
View(final_all)

avc<-final_all_2[c(4:18)]
corrplot(cor(avc),method = "circle")

with(final_all_2, plot (미션,미션점수,col="red",lwd=2,main="미션과 관련된 문항 결과와 미션 개수와의 관계"))
abline(lm(미션점수 ~ 미션, data = final_all_2),lwd=2,col="blue")

ggplot(final_all_2,mapping = aes(x=미션점수,y=미션))+geom_point(shape=1,color="red")+stat_smooth(method='lm')

F_summary<-final_all_2[c(1:3,)]
score_math<-aov(수학과목~등급,data=final_result)
summary(score_math)
result_game<-scheffe.test(score_math,"등급",group = TRUE,console = TRUE)


library(agricolae)

final_result_2<-final_result[-c(1:3,19:22)]
final_r2<-lm(최종성적~.,data=final_result_2)       
summary(final_r2)       

relweights <- function(fit,...){
  R <- cor(fit$model)
  nvar <- ncol(R)
  rxx <- R[2:nvar, 2:nvar]
  rxy <- R[2:nvar, 1]
  svd <- eigen(rxx)
  evec <- svd$vectors
  ev <- svd$values
  delta <- diag(sqrt(ev))
  lambda <- evec %*% delta %*% t(evec)
  lambdasq <- lambda ^ 2
  beta <- solve(lambda) %*% rxy
  rsquare <- colSums(beta ^ 2)
  rawwgt <- lambdasq %*% beta ^ 2
  import <- (rawwgt / rsquare) * 100
  import <- as.data.frame(import)
  row.names(import) <- names(fit$model[2:nvar])
  names(import) <- "Weights"
  import <- import[order(import),1, drop=FALSE]
  dotchart(import$Weights, labels=row.names(import),
           xlab="% of R-Square", pch=19,
           main="상대적인 중요성",   
           sub=paste("Total R-Square=", round(rsquare, digits=3)),
           ...)
  return(import)
}

relweights(final_r2)

final_game1<-final_math[c(1,2,3,5,7,9,11,13)]
final_game2<-final_math[c(1,2,4,6,8,10,12,14)]

final_game1<-as.data.frame(final_game1)
final_melt<-melt(final_game1,id=c("학과","학번"))

final_game2<-as.data.frame(final_game2)
final_melt_2<-melt(final_game2,id=c("학과","학번"))

problem_1<-aov(value~variable,data=final_melt)
summary(problem_1)
result_1<-scheffe.test(problem_1,"variable",group = TRUE,console = TRUE)

math<-as.data.frame(math)
names(math)<-c("학과","학번","게임")
game<-aov(게임~학과,data=math)

summary(game)
result_game<-scheffe.test(game,"학과",group = TRUE,console = TRUE)
