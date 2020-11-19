# 미스코리아 pca

setwd("D:\\포트폴리오\\4학년\\다변량")

library(readxl)
data = read_excel("다변량 분석_라면 종류별 평가.xlsx")
data = na.omit(data[1:4])

# 누적기여율이 80% 이상이면 사용 변수가 여러개 있을 경우 누적기여율이 80%까지인 것까지 사용하면됨 

cor(data_1)

library(psych)
pairs.panels(data_1)


data_pca = prcomp(data_1, center = TRUE, scale. = TRUE)
summary(data_pca)

# scale 한 값들이 어떻게 계산되어서 주성분 분석 값이 나오는지 절차 정도는 알아놓는 게 좋음.

data_pca$x

library(HSAUR)
data(heptathlon)
str(heptathlon)


# 200~800 작을수록 좋은 점수
# 높이뛰기 포환던지기는 클수록 좋은 점수 

# 작은 값일수록 좋은 점수이기 때문에 최대값에서 값을 빼줌,
heptathlon$hurdles <- max(heptathlon$hurdles) - heptathlon$hurdles
heptathlon$run200m <- max(heptathlon$run200m) - heptathlon$run200m
heptathlon$run800m <- max(heptathlon$run800m) - heptathlon$run800m


heptathlon$score = NULL
colSums(is.na(heptathlon))
pairs.panels(heptathlon)

# 주성분 전 상관분석과 후 상관분석 결정
# 주성분 분석을 몇 개로 할 것인지
# scree 어쩌고 biplot을 해석해보기 
# 성분들을 뽑을건데 두개를 보통 많이 뽑으니까 두개의 성분이 의미하는 것을 해석하기 - 주성분에 해당하는 변수를 어떤 변수라고 하는지 어떤 변수에 영향력이 높은지 

heptathlon_pca = prcomp(heptathlon, center = TRUE, scale. = TRUE)
heptathlon_pca
summary(heptathlon_pca)

# 2개의 주성분이 80.8% 값 

screeplot(heptathlon_pca)
screeplot(heptathlon_pca,type='line',pch=19,main='Scree Plot of pca')

# screeplot은 주성분 고유값을 크기 순으로 그린 것으로 고유값이 1보다 큰 주성분ㄴ 값이 2개임을 알 수 있다. 
heptathlon_pca$x
heptathlon_pca$rotation
heptathlon_pca$center
heptathlon_pca$sdev

# 
biplot(heptathlon_pca,cex=0.7,col=c('red','blue'),main='Biplot')

biplot(heptathlon_pca)

cor(heptathlon)
cor(heptathlon_pca$x[,1], heptathlon$score)
pairs.panels(round(heptathlon_pca$x,2))


#국물에 해당하는 계수값이 크다는 것은 좌표를 그렸을 때 해당하는 방향의 영향력이 크게 작용한다. 
# 국물이 중요한 변수로써 작용을 했다라고 할 수 있음. 