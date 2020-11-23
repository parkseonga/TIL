# 시스템?: 신호를 만들어내는 것
# 신호와시스템은 보편적으로 적용할 수 있는 토대를 만듦
# 전 세계의 온도 데이터
# 연별로 기록해놓은 데이터를 row data로 사용하기 어렵기 때문에 특징을 뽑음
# 특징을 계량화하여 표현한는 방법
# 1. 중심화경향 -> 대표값 (central tendency)
# - 산술평균, 중앙값, 최빈값, 기하평균, 조화평균, 가중평균
# 2.퍼짐 정도(dispersion)
# - 분산, 표준편차, 변이계수, 범위, IQR, 백분위수
# 3. 분표형태와 대칭정도(distribution)
# - 왜도, 첨도, 분위수-분위수
# 3가지의 특성이 모두 다 다른 것을 나타내기 때문에 모두 고려
# 특질 추출 전 summary와 그래프로 나타날 것

library(seewave)
library(signal) # 신호 전반에 관련된 패키지 
library(pracmat) # 신호 전반에 관련된 패키지

which.max(table())  # 최빈값 table로 요약한 후 값이 많이 찍히는 것을 인덱스로 반환
x=c(1,2,3,3,4,5,6)
y=c(1,2,3)
prod(x)^(1/length(x)) # 기하 평균

# 값이 한쪽으로 편향되는 값이면 산술 평균은 이도저도 아닌 값이 나옴
# 역수를 취해서 값의 차이를 줄이고 평균을 구하고 다시 역수를 취하여 데이터들이 실제로 분포했던 값의 중앙으로 들어감    
1/mean(1/x)  # 조화평균 

# 가중평균: 갖고 있는 데이터의 중요도가 다를 때 데이터에 중요도 부여

## 퍼짐정도
# 변이계수: 값의 scale이 크면 절대비교하기가 어렵기 때문에 변이계수를 이용하여 서로 다른 scale을 가진 데이터도 비교할 수 있도록함  
100*sd(x)/mean(x)

# 정규분포 대비 분포가 얼마나 치우쳐져 있는가?
# 왜도
skewness()
# 첨도
kurtosis()
# 분위수 
qqnorm();qqline

# RMS(Root Mean Squre): 신호의 크기를 더 더하여 제곱을 하여 데이터의 개수로 나눔
# 데이터의 수는 고려하지 않고 모든 데이터를 다 더해서 현재 갖고 있는 데이터의 크기를 나타냄
# 신호의 크기를 나타내는 통계량
a = sample(1:10,10)
a
m = cummax(a) # 누적하면서 최댓값을 나타냄(누적된 위치까지의 각 최대값)
# 변화하는 시점의 값을 통해서 데이터를 표현할 수 있음.

library(seewave)
t = seq(0,1,0.01)
x = cos(2*pi*t)

# 정형파: sin,cos로 주기를 가지는 파형
plot(t,x,"l")  # l: line으로 그래프 그리기 
y = rms(x)

# RSS: RMS와 달리 신호의 개수까지 포함하여 신호의 크기를 나타내는 통계량
# 첨도: 분포의 대칭성을 알아보는 척도 중 하나 정규분포 대비 봉우리의 높이 
# 왜도: 분포의 좌우 대칭이 맞는가
# 분포가 왼쪽으로 치우져져 있는 경우 왜도가 0보다 큰 값
# 분포가 오른쪽으로 치우져져 있는 경우는 왜도가 0보다 작은 값 

library(ggplot2)
str(diamonds)

# data의 성질을 그래프로 확인 
# aes:축 옵션
# 히스토그램의 역할: 각 데이터들의 개수를 집계하여 그림
ggplot(diamonds,aes(x=price))+geom_histogram()+facet_grid(color~.)
ggplot(diamonds,aes(x=price))+geom_histogram()+facet_wrap(color~.)

library(fBasics) # 수학 계산
skewness(diamonds$price)

# tapply: table형태로 값을 요약 
with(diamonds,tapply(price, color, skewness))
with(diamonds,tapply(price,color,kurtosis))   # 다이아몬드 색 D의 데이터 분포는 왼쪽으로 치우쳐져 있고 볼록.

# 시계열 데이터로 실습 
Nile

par(mfrow=c(1,2))

plot(Nile)
# 정규분포를 따르는지 확인 
hist(Nile)

## 각각의 특질을 추출하여 비교해보기 
# 통계치로 요약 
mean(Nile)
median(Nile)
which.max(table(Nile))
x = Nile
prod(x)^(1/length(x))
1/mean(1/x)

# 분포 확인
# Q-Q plot
# 실제값과 정규분포를 매칭| 값 하나하나가 정규분포 대비 잘 매칭되어있는가 
# x축: 정규분포를 가정했을때의 사분위수 값
# y축: 실제 사분위수 값 
par(mfrow=c(1,1))
a = qqnorm(x);qqline(x)

# 신호에서의 세가지 변화
# 신호에서 변화를 파악하는 경우: 변화가 발생했을 때 시스템 관리를 다시 해야할 때
library(changepoint)

cpt.mean()  # 평균의 변화량 
cpt.var()    # 분산의 변화량 
cpt.meanvar() # 평균과 분산의 변화량 

