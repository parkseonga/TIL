# peak찾기
# peak: 신호 데이터에서 위로 볼록 올라온 부분
# peak가 얼마만의 간격을 갖고 있고 크기는 어떤지 특질화

# r로 수학계산을 하는 패키지 
# 미분을 이용하는 것 
library(changepoint)
library(pracma)
# findpeak()  함수를 이용하여 찾을 수 있음 

# sample data만들기 
x = seq(0, 1, len = 1024)
pos = c(0.1, 0.13, 0.15, 0.23, 0.25, 0.40, 0.44, 0.65, 0.76, 0.78, 0.81)
hgt = c(4, 5, 3, 4, 5, 4.2, 2.1, 4.3, 3.1, 5.1, 4.2)
wdt = c(0.005, 0.005, 0.006, 0.01, 0.01, 0.03, 0.01, 0.01, 0.005, 0.008, 0.005)
psignal =numeric(length(x))
for (i in seq(along=pos)){
  psignal = psignal+hgt[i]/(1+abs((x-pos[i])/wdt[i]))^4
  
}

plot(psignal,type='l',col="navy")

# peak찾기
# 값이 4이상인 것들을 찾음
# 상위 3개만 도출 
x = findpeaks(psignal,npeaks=3,threshold=4,sortstr=TRUE)  # matrix형태러 결가 반환
# 1번 컬럼 peak의 크기
# 2번 컬럼 peak의 위치 
# peak의 크기 순서대로 나타남-> peak의 간격을 구할 때 순서대로 되어 있지 않다는 부분을 유의해야함.
points(x[,2],x[,1],pch=20,col="maroon")

x= findpeaks(psignal)
points(x[,2],x[,1],pch=20,col="maroon")

d = diff(sort(x[,2]))
hist(d)

## peak간격에 대한 평균
# 대표값 하나로 표현
mean(diff(sort(x[,2])))
# 분포가 한 쪽으로 치우쳐져 있으면
median(diff(sort(x[,2])))
mode(diff(sort(x[,2])))

# 간격의 산포확인      
std(diff(sort(x[,2])))

## peak자체 값에 대한 대표값으로도 특징을 지을 수 있음
mean(x[,1])
# 편차, 최대값, 최소값 등으로도 나타낼 수 있음.

# 파고율: peak가 얼마나 극단적인가를 나타내는 척도
# 가장 큰 peak의 값에 절댓값을 취하고 rms로 나눠줌 
# 신호의 강도를 나타내는 rms: 신호의 크기를 모두 제곱해서 더한 후 전체 개수로 나누어 다음 루트 적용 
c = x[,1]/rms(psignal)
c = max(x[,1]/rms(psignal))  # 주로 사용하는 방법

## 파고율이 주로 사용되는 곳
# 사각 구형파: peak가 존재하지 않으므로 파고율 계산이 필요
# 정현파: 사인파로 이루어져있는 경우

# PAPR은 항상 1보다 크거나 같다 
# 1이면 peak가 없는것 
# 제곱을 하면 비선형, 제곱을 안하면 비선형으로 표현됨 
# peak가 조금이라도 다르면 값의 변화를 진폭시키기 위하여 제곱을 취함 

# 실제 데이터로 실습하기
install.packages("ade4")
library(ade4)

# 심장의 전기자극에 따른 심장 근육의 수축이완데이터 
data(ecg)
plot(ecg)

#  n치원 다항함수로 데이터의 추세 파악
polyfit(x,y,n)   # 인덱스, 데이터, n차원 다항 함수의 n값
a =polyfit(1:length(ecg),ecg,6)

fit_y = polyval(a,1:length(ecg))

library(ggplot2)
ecg_d = as.data.frame(ecg)

ggplot(ecg_d, aes(1:length(ecg)))+geom_line(aes(y=ecg_d),colour="red")+geom_line(aes(y=fit_y),colour="green")
# n을 늘리면 더 잘 나타낼 수 있음.

# 추세가 제거된 값
ECG_data = ecg-fit_y
plot(ECG_data)
plot(1:length(ecg),ECG_data,"l")

# 심전도 신호에서 가장 두드러지게 반복 출현하는 피크인 QRS파 찾기 
R = findpeaks(as.numeric(ECG_data),threshold = 0.5)
par(new=TRUE)
points(R[,2],R[,1],col="red")

S = findpeaks(as.numeric(-ECG_data),threshold = 0.5)
par(new=TRUE)
points(S[,2],-S[,1],col="blue")

# Savitzky-Golay filter: 구불구불한 잔신호들이 있을 때 필터링 하는 방법
# smoothing
# 7차원 21개 윈도우개수 
library(signal)
fit = sgolayfilt(ECG_data,7,21)
plot(1:length(ECG_data),as.vector(ECG_data),"l")
lines(as.vector(fit),col="red")

Q = findpeaks(-as.numeric(fit),minpeakdistance = 40)

plot(1:length(fit),fit,"l")
par(new=TRUE)

points(Q[,2],-Q[,1],col="red")

# 크기가 0.2에서 0.5 사이인 피크만 찾음 
Q = Q[Q[,1]>0.2&Q[,1]<0.5,]
plot(1:length(fit),fit,"l")
par(new=TRUE)

points(Q[,2],-Q[,1],col="red")
