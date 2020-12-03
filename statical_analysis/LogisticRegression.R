# 더미변수가 포함된 데이터를 이용하여 회귀분석을 실습하고 다른 모형들과 비교해보기 

library(caret)
library(ROCR)
library(e1071)

data = read.csv("https://stats.idre.ucla.edu/stat/data/binary.csv")
str(data)

data$rank = factor(data$rank)  # 대학교의 등급, factor 변환 
data$admit = factor(data$admit)  # 종속변수를 factor로 변환 
str(data)
set.seed(123456789)

n = nrow(data)
idx = 1:n
training_idx = sample(idx, n*.60) 
idx = setdiff(idx, training_idx)
validate_idx = sample(idx, n*.20)
test_idx = setdiff(idx, validate_idx)


training = data[training_idx,]
str(training)
validation = data[validate_idx,]
str(validation)
test = data[test_idx,]
str(test)

data_logit_full = glm(admit~., data = training, family = "binomial")
summary(data_logit_full)

y_obs_t = training$admit

pre_logit_t = predict(data_logit_full, newdata = training, type = "response")
pred_logit_t = prediction(pre_logit_t, y_obs_t)

confusionMatrix(factor(ifelse(pre_logit_t>0.5,1,0)),y_obs_t)
performance(pred_logit_t, "auc")@y.values[[1]]

y_obs_v = validation$admit

pre_logit_v = predict(data_logit_full, newdata = validation, type = "response")
pred_logit_v = prediction(pre_logit_v, y_obs_v)

confusionMatrix(factor(ifelse(pre_logit_v>0.5,1,0)), y_obs_v)
performance(pred_logit_v,"auc")@y.values[[1]]

# 나무모형으로 적합값/예측값 확인 
library(rpart)

# 학습 데이터
data_tr = rpart(admit~., data = training)
opar = par(mfrow = c(1,1), xpd = NA)
plot(data_tr)
text(data_tr, use.n = TRUE)

pre_tr_t = predict(data_tr, newdata = training)
pred_tr_t = prediction(pre_tr_t[,"1"], y_obs_t)

confusionMatrix(factor(ifelse(pre_tr_t[,"1"]>0.5,1,0)), y_obs_t)
performance(pred_tr_t, "auc")@y.values[[1]]

# 검증데이터 
pre_tr_v = predict(data_tr, newdata = validation)
pred_tr_v = prediction(pre_tr_v[,"1"], y_obs_v)

confusionMatrix(factor(ifelse(pre_tr_v[,"1"]>0.5, 1, 0)), y_obs_v)
performance(pred_tr_v, "auc")@y.values[[1]]

# 랜덤포레스트
library(randomForest)
set.seed(123456789)
data_rf = randomForest(admit~., data = training)
varImpPlot(data_rf)

pre_rf_t = predict(data_rf, newdata = training, type = "prob")[,'1']
pred_rf_t = prediction(pre_rf_t, y_obs_t)

confusionMatrix(factor(ifelse(pre_rf_t>0.5,1,0)),y_obs_t)
performance(pred_rf_t, "auc")@y.values[[1]]

pre_rf_v = predict(data_rf, newdata = validation, type = "prob")[,"1"]
pred_rf_v = prediction(pre_rf_v, y_obs_v)

confusionMatrix(factor(ifelse(pre_rf_v>0.5,1,0)), y_obs_v)
performance(pred_rf_v, "auc")@y.values[[1]]

# 부스팅
library(gbm)

set.seed(123456789)

# 학습 데이터 
training$admit = as.numeric(ifelse(training$admit=='0',0,1))

data_gbm = gbm(admit ~., data = training, distribution = "bernoulli", n.trees = 500, cv.folds = 5, verbose = TRUE)
best_iter = gbm.perf(data_gbm, method = "cv")

pre_gbm_t = predict(data_gbm, n.trees = best_iter, newdata = training, type = "response")
pred_gbm_t = prediction(pre_gbm_t, y_obs_t)

confusionMatrix(factor(ifelse(pre_gbm_t>0.5,1,0)), y_obs_t)
performance(pred_gbm_t, "auc")@y.values[[1]]

# 검증 데이터
pre_gbm_v = predict(data_gbm, n.trees = best_iter, newdata = validation, type = "response")
pred_gbm_v = prediction(pre_gbm_v, y_obs_v)

confusionMatrix(factor(ifelse(pre_gbm_v>0.5,1,0)), y_obs_v)
performance(pred_gbm_v, "auc")@y.values[[1]]

# rf의 모형의 성능이 가장 좋음. 
# 그래도 모든 테스트 데이터에 대한 성능 확인 
#######################
# 테스트 데이터
########################
# logistic
pre_lm_test = predict(data_logit_full, newdata = test, type = "response")
pred_lm_test = prediction(pre_lm_test, test$admit)

confusionMatrix(factor(ifelse(pre_lm_test>0.5,1,0)), test$admit)
performance(pred_lm_test, "auc")@y.values[[1]]

# rpart
pre_tr_test = predict(data_tr, newdata = test)[,"1"]
pred_tr_test = prediction(pre_tr_test, test$admit)

confusionMatrix(factor(ifelse(pre_tr_test>0.5,1,0)), y_obs_v)
performance(pred_tr_test, "auc")@y.values[[1]]

# randomforest
pre_rf_test = predict(data_rf, newdata = test, type = "prob")[,"1"]
pred_rf_test = prediction(pre_rf_test, test$admit)

confusionMatrix(factor(ifelse(pre_rf_test>0.5,1,0)), test$admit)
performance(pred_rf_test, "auc")@y.values[[1]]

# boosting
pre_gbm_test = predict(data_gbm, n.trees = best_iter, newdata = test, type = "response")
pred_gbm_test = prediction(pre_gbm_test, test$admit)

confusionMatrix(factor(ifelse(pre_gbm_test>0.5,1,0)), test$admit)
performance(pred_gbm_test, "auc")@y.values[[1]]
