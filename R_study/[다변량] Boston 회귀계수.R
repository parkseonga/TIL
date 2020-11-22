library(lm.beta)
library(MASS)
library(psych)
library(lattice)

data = Boston

set.seed(1606)

data$chas = NULL

n = nrow(data)

idx = 1:n

training_idx = sample(idx, n*.60)
idx = setdiff(idx, n*.20)
validate_idx = sample(idx, n*.20)
test_idx = setdiff(idx, validate_idx)

training = data[training_idx,]
validation = data[validate_idx,]
test = data[test_idx,]

# 표준화하기 전에 단위의 문제가 발생하기 때문에 회귀계수값들을 비교하기 쉽지 않아서 이에 대해 비교.
# 표준화된 것을 이용해서 검증데이터나 test데이터에 적용하기에는 번거로워진다.
# 영향력을 비교할 때 회귀계수값들을 비교하면 되고 기존에 비표준화된 방법들을 가지고 예측에 사용하면 된다.
# 왜? : 표준화를 하게되면 표준화해서 학습데이터에 사용되었던 값들을 다시 가지고 와서 test나 validation에 다시 적용해야하기 때문에.
# 전체 데이터로 표준화 시키는 게 아님. validation과 test데이터는 보지 못한 값으로 가정하기 때문에
# 표준화를 하는 이유는 변수들의 영향력을 파악하기 위함. 
# 모형을 예측하려면 기존에 사용했던 비표준화를 이용해서 분석을 하면됨. 

data_lm_before_sc = lm(medv~., data = training)
summary(data_lm_before_sc)

s_train = as.data.frame(scale(training))
data_lm_after_sc = lm(medv~., data = s_train)
summary(data_lm_after_sc)

lm.beta(data_lm_before_sc)

# 표준화 전 개체를 lm.beta에 적용하였을 때 계수값들이 동일하게 나오는 지 확인.
# 조심해야한다라고 생각하시는 분들도 계심 단순하게 절대값이 크면 영향을 많이 미친다라고 생각해도 크게 문제는 없음. 
# 보통 해야할 것들은 각각의 변수들을 제거해가면서 예측력에 포커스를 두고 그때그때 사용 
# 회귀계수는 해석하기 위해 사용하는 것

# metric 정의 
rmse = function(yi, yhat_i){
  sqrt(mean((yi-yhat_i)^2))
}

y_obs_t = training$medv
y_obs_v = validation$medv


# 선형회귀모형
lm.fit.train = lm(medv~.,data = training)
summary(lm.fit.train)
length(coef(lm.fit.train))


par(mfrow = c(1,3))

hist(lm.fit.train$residuals)

plot(lm.fit.train,which=1)

plot(lm.fit.train,which=2)


rmse(training$medv,predict(lm.fit.train, training))

rmse(validation$medv,predict(lm.fit.train, validation))


# 잔차: 예측값과 실제 값의 차이 
error = as.vector(predict(lm.fit.train, validation)-validation$medv)

par(mfrow = c(1,3))

hist(error)

# 데이터가 특정 모집단에서 나온 것이라 가정했을 때 데이터가 얼마만큼 특정 모집단에 가까운가를 보는 것으로 선이 가장 이상적인 분포를 나타낸다.
qqnorm(error); qqline(error, col = 2)

p2 = xyplot(error ~ as.vector(predict(lm.fit.train, validation)),col = 2,type = c("p", "smooth"),xlab = "predicted values", ylab = "Residuals",main = "Residuals vs. predicted" )
print(p2, position = c(0.66, 0, 0.99, 1),more = TRUE)



# 이차형 선형회귀모형

lm2.fit.train = lm(medv~ .^2, data = training)

summary(lm2.fit.train)

length(coef(lm2.fit.train))



par(mfrow = c(1,3))

hist(lm2.fit.train$residuals)

plot(lm2.fit.train,which=1)

plot(lm2.fit.train,which=2)



rmse(training$medv,predict(lm2.fit.train, training))

rmse(validation$medv,predict(lm2.fit.train, validation))


library(MASS)



data_step_both = stepAIC(lm.fit.train, direction = "both", scope = list(upper = ~.^2, lower = ~1))

summary(data_step_both)

length(coef(data_step_both))

rmse(training$medv, predict(data_step_both, training))

rmse(validation$medv, predict(data_step_both, validation))



data_step_forw = stepAIC(lm.fit, direction = "forward", scope = list(upper = ~.^2, lower = ~1))

summary(data_step_forw)

length(coef(data_step_forw))



data_step_back = stepAIC(lm.fit, direction = "backward", scope = list(upper = ~.^2, lower = ~1))

summary(data_step_back)

length(coef(data_step_back))


# decistion tree
library(rpart)

data_tr = rpart(medv~., data = training)
data_tr 

opar = par(mfrow = c(1,1), xpd= NA)
plot(data_tr)

text(data_tr, use.n = TRUE)

# 학습데이터 적합
yhat_tr_t = predict(data_tr, newdata = training)
rmse(y_obs_t, yhat_tr_t)

error_tr = as.vector(predict(data_tr, newdata = training))-training$medv
par(mfrow = c(1,3))

hist(error_tr)
qqnorm(error_tr); qqline(error_tr, col = 2)

p2 = xyplot(error_tr ~ as.vector(predict(data_tr, training)),col = 2,type = c("p", "smooth"),xlab = "fitted values", ylab = "Residuals",main = "Residuals vs. fitted" )
print(p2, position = c(0.66, 0, 0.99, 1),more = TRUE)

# 검증데이터 예측
yhat_tr_v = predict(data_tr, newdata = validation)
rmse(y_obs_v, yhat_tr_v)

# 잔차: 예측값과 실제 값의 차이 
error = as.vector(predict(data_tr, newdata = validation))-validation$medv
par(mfrow = c(1,3))

# 데이터가 특정 모집단에서 나온 것이라 가정했을 때 데이터가 얼마만큼 특정 모집단에 가까운가를 보는 것으로 선이 가장 이상적인 분포를 나타낸다.
hist(error)
qqnorm(error); qqline(error, col = 2)

p2 = xyplot(error ~ as.vector(predict(data_tr, validation)),col = 2,type = c("p", "smooth"),xlab = "predicted values", ylab = "Residuals",main = "Residuals vs. predicted" )
print(p2, position = c(0.66, 0, 0.99, 1),more = TRUE)

# 데이터가 특정 모집단에서 나온 것이라 가정했을 때 데이터가 얼마만큼 특정 모집단에 가까운가를 보는 것으로 선이 가장 이상적인 분포를 나타낸다.

qqnorm(error)
qqline(error)

# bagging 방법
# randomforest
library(randomForest)

set.seed(1607)

data_rf = randomForest(medv~., training)
data_rf 

# 상관계수랑 비교해서 어떤 것이 영향력이 큰지
varImpPlot(data_rf)
pairs.panels(data[,-4])
# 학습데이터 적합
yhat_tr_t = predict(data_rf, newdata = training)
rmse(y_obs_t, yhat_tr_t)

error_tr = as.vector(predict(data_rf, newdata = training))-training$medv
par(mfrow = c(1,3))

hist(error_tr)
qqnorm(error_tr); qqline(error_tr, col = 2)

p2 = xyplot(error_tr ~ as.vector(predict(data_rf, training)),col = 2,type = c("p", "smooth"),xlab = "fitted values", ylab = "Residuals",main = "Residuals vs. fitted" )
print(p2, position = c(0.66, 0, 0.99, 1),more = TRUE)

# 검증데이터 예측
yhat_tr_v = predict(data_rf, newdata = validation)
rmse(y_obs_v, yhat_tr_v)

# test data
yhat_tr_test = predict(data_rf, newdata = test)
rmse(test$medv, yhat_tr_test)

yhat_tr_test = predict(data_tr, newdata = test)
rmse(test$medv, yhat_tr_test)


# 잔차: 예측값과 실제 값의 차이 
error = as.vector(predict(data_rf, newdata = validation))-validation$medv
par(mfrow = c(1,3))

hist(error)

qqnorm(error); qqline(error, col = 2)

p2 = xyplot(error ~ as.vector(predict(data_rf, validation)),col = 2,type = c("p", "smooth"),xlab = "predicted values", ylab = "Residuals",main = "Residuals vs. predicted" )
print(p2, position = c(0.66, 0, 0.99, 1),more = TRUE)

# 학습데이터와 검증 데이터에 대한 적합 및 예측 후 검증

# boosting 방법 
# boosting

library(gbm)
set.seed(1607)

data_gbm = gbm(medv~., data = training, n.trees = 4000, cv.folds = 3, verbose = TRUE)
best_itr = gbm.perf(data_gbm, method = "cv")

# 학습데이터 적합
yhat_tr_t = predict(data_gbm, newdata = training)
rmse(y_obs_t, yhat_tr_t)

error_tr = as.vector(predict(data_gbm, newdata = training))-training$medv
par(mfrow = c(1,3))

hist(error_tr)
qqnorm(error_tr); qqline(error_tr, col = 2)

p2 = xyplot(error_tr ~ as.vector(predict(data_gbm, training)),col = 2,type = c("p", "smooth"),xlab = "fitted values", ylab = "Residuals",main = "Residuals vs. fitted" )
print(p2, position = c(0.66, 0, 0.99, 1),more = TRUE)

# 검증데이터 예측
yhat_tr_v = predict(data_gbm, newdata = validation)
rmse(y_obs_v, yhat_tr_v)

# 잔차: 예측값과 실제 값의 차이 
error = as.vector(predict(data_gbm, newdata = validation))-validation$medv
par(mfrow = c(1,3))

hist(error)

qqnorm(error); qqline(error, col = 2)

p2 = xyplot(error ~ as.vector(predict(data_gbm, validation)),
            col = 2,type = c("p", "smooth"),xlab = "predicted values",
            ylab = "Residuals",main = "Residuals vs. predicted" )
print(p2, position = c(0.66, 0, 0.99, 1),more = TRUE)

yhat_tr_test = predict(data_gbm, newdata = test)
rmse(test$medv, yhat_tr_test)

# PCA
pca_boston <- prcomp(training[,-14], center = T, scale. = T)
pca_boston
summary(pca_boston)


# Data set 구축 (주성분 점수 만들기)
data_pca_t <- data.frame(predict(pca_boston, training[,-14]))
data_pca_v <- data.frame(predict(pca_boston, validation[,-14]))
data_pca_e <- data.frame(predict(pca_boston, test[, -14]))

data_pca_train <- cbind(data_pca_t, medv = training$medv)
data_pca_validation <- cbind(data_pca_v, medv = validation$medv)
data_pca_test <- cbind(data_pca_e, medv = test$medv)

data_lm_pca <- lm(medv ~ PC1 + PC2 + PC3 + PC4, data = data_pca_train)
summary(data_lm_pca)

yhat_pca_t <- predict(data_lm_pca, newdata = data_pca_train)
yhat_pca_v <- predict(data_lm_pca, newdata = data_pca_validation)
yhat_pca_e <- predict(data_lm_pca, newdata = data_pca_test)

rmse(training$medv, yhat_pca_t)
rmse(validation$medv, yhat_pca_v)
rmse(test$medv, yhat_pca_e)

error_tr = as.vector(predict(pca_boston, newdata = training))-training$medv
par(mfrow = c(1,3))

hist(error_tr)
qqnorm(error_tr); qqline(error_tr, col = 2)

p2 = xyplot(error_tr ~ as.vector(predict(pca_boston, training)),col = 2,type = c("p", "smooth"),xlab = "fitted values", ylab = "Residuals",main = "Residuals vs. fitted" )
print(p2, position = c(0.66, 0, 0.99, 1),more = TRUE)

# 검증데이터 예측
yhat_tr_v = predict(pca_boston, newdata = validation)
rmse(y_obs_v, yhat_tr_v)

# 잔차: 예측값과 실제 값의 차이 
error = as.vector(predict(pca_boston, newdata = validation))-validation$medv
par(mfrow = c(1,3))

# 데이터가 특정 모집단에서 나온 것이라 가정했을 때 데이터가 얼마만큼 특정 모집단에 가까운가를 보는 것으로 선이 가장 이상적인 분포를 나타낸다.
hist(error)
qqnorm(error); qqline(error, col = 2)

p2 = xyplot(error ~ as.vector(predict(pca_boston, validation)),col = 2,type = c("p", "smooth"),xlab = "predicted values", ylab = "Residuals",main = "Residuals vs. predicted" )
print(p2, position = c(0.66, 0, 0.99, 1),more = TRUE)

# 데이터가 특정 모집단에서 나온 것이라 가정했을 때 데이터가 얼마만큼 특정 모집단에 가까운가를 보는 것으로 선이 가장 이상적인 분포를 나타낸다.

qqnorm(error)
qqline(error)

