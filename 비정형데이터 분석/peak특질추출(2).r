# 패키지 설치 
library(ggplot2)
library(seewave)
library(signal)
library(pracma)

# 심장의 전기자극에 따른 심장 근육의 수축이완데이터
# 데이터 불러오기
library(ade4)
data(ecg)

# 시각화 
plot(ecg)

# n차원 다항함수로 데이터의 추세 파악
# polyfit(x,y,n) # 인덱스, 데이터, n차원 다항 함수의 n값
a = polyfit(1:length(ecg),ecg,6)        # n을 늘리면 더 잘 나타낼 수 있음.
fit_y = polyval(a,1:length(ecg))

# 추세가 제거된 값
ECG_data = ecg-fit_y
plot(1:length(ecg),ECG_data,"l")

# 심전도 신호에서 가장 두드러지게 반복 출현하는 피크인 QRS파 찾기
R = findpeaks(as.numeric(ECG_data),threshold = 0.5,minpeakdistance = 100)
S = findpeaks(as.numeric(-ECG_data),threshold = 0.5, minpeakdistance = 100)

# Q파는 잔시호들 사이에서 잘못 찾아질 수 있기 때문에 필터링 필요 
# Savitzky-Golay filter: 구불구불한 잔신호들이 있을 때 필터링 하는 방법
# 7차원 21개 윈도우개수
fit = sgolayfilt(ECG_data,7,21)

Q = findpeaks(-as.numeric(fit),minpeakdistance = 50)

# R파 전의 위치한 Q값 중 가장 가까운 값 추출하기 
Q2 = c()

for (i in 1:length(sort(R[,2]))){
  a = c()
  
  for (j in 1:length(sort(Q[,2]))){
    if(sort(Q[,2])[j] < sort(R[,2])[i]){    # R파 위치값보다 작은 Q파 위치값 중 Q파의 최대 위치값 추출 
      a = c(a, sort(Q[,2])[j])
    }
  }
  if(length(a)>1){
    Q2 = c(Q2, max(a))
  }else{
    Q2 = c(Q2, a)
  }
}

# Q peak, 위치값 매트릭스 만들기
Q_level = Q[,1][which(Q[,2]%in%Q2)]
Q_time = Q[,2][which(Q[,2]%in%Q2)]

Q_rev = as.matrix(cbind(Q_level,Q_time))

# plot그리기
par(new=TRUE)

points(R[,2],R[,1],col="red")
points(S[,2],-S[,1],col="blue")
points(Q_rev[,2],-Q_rev[,1],col="green")

# 평균 상승 시간 
avg_riseTime = mean(sort(R[,2])-sort(Q_rev[,2]))

# 평균 하강 시간 
avg_fallTime = mean(sort(S[,2])-sort(R[,2]))

R_level =  R[order(R[,2]),]
S_level =  S[order(S[,2]),]
Q_rev_level = Q_rev[order(Q_rev[,2]),]

# 평균 상승 레벨
avg_riseLevel = mean(R_level[,1]-(-Q_rev_level[,1]))

# 평균 하강 레벨
avg_fallLevel = mean(R_level[,1]-(-S_level[,1]))

