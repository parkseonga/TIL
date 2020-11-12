library(e1071)
library(ROSE)

data(hacide)

data = rbind(hacide.train,hacide.test)
str(data)
table(data$cls)

# 0인 것만 학습시킴.
data$class[data$cls=="0"] = "TRUE"
data$class[data$cls!="0"] = "FALSE"

# TRUE와 FALSE인 데이터 나눔 
data_True<-subset(data,class=="TRUE")
data_False<-subset(data,class=="FALSE")

# train/test data split
inTrain<-createDataPartition(1:nrow(data_True),p=0.6,list=FALSE)

# train 데이터 생성 
train_x<-data_True[inTrain,2:3]
train_y<-data_True[inTrain,4]

# test 데이터 생성 
test<-rbind(data_True[-inTrain,],data_False)

test_x <-test[,2:3]
test_y <-test[,4]

# 모델 적용 
svm.model<-svm(train_x,y=NULL,
               type='one-classification',
               nu=0.10,
               scale=TRUE,
               kernel="radial")  # 방사 커널 적용 

svm.predtrain<-predict(svm.model,train_x)
svm.predtest<-predict(svm.model,test_x)

confTrain<-table(Predicted=svm.predtrain,Reference=train_y)
confTest<-table(Predicted=svm.predtest,Reference=test_y )

# 결과 확인 
confusionMatrix(confTest,positive='TRUE')

print(confTrain)
print(confTest)
