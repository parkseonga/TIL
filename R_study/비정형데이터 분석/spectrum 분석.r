# 신호 생성 
t = seq(0,200,by=0.1) # 0.1초 단위로 신호 생성
x = cos(2*pi*t/16) + 0.75*sin(2*pi*t/5)
par(mfrow=c(2,1))

plot(t,x,"l")

x.spec = spectrum(x)  # list형태로 반환 
str(x.spec)

# 주기값 추출 (1초에 몇 번 왔다갔다했냐는 주파수) 
# 주기는 주파스 역수분의 1
spx = x.spec$freq*1/0.1  # freq: frequency값 (0.1초 단위로 증폭)
spy = 2*x.spec$spec  # spec: frequency 키 

plot(spy*spx,xlab = "frequency", ylab = "spectral density", type ="l")

# 스펙트럼을 통한 변수화 
spx[which(spy%in%sort(spy,decreasing = TRUE)[1:2])]

# 보통 상위 5-6개를 추출해서 해당 frequency와 spectral density값을 변수로 사용
