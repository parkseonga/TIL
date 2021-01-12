data<-read.csv("data_final.csv")
data1<-data$ts_1
data2<-data$ts_2
class(data1)

data1<-na.omit(data1)
table(is.na(data1))

data1<-ts(data1,start=c(2001,1),frequency = 1)
ggtsdisplay(data1)
ggtsdisplay(diff(data1))
summary(ur.kpss(data1))

Y<-Arima(data1,c(0,1,0)) #AICc : 1299.43
arima1_2<-Arima(data1,c(1,1,1)) #AICc : 1303.15
arima1_3<-Arima(data1,c(1,1,0)) #AICc : 1301.5
arima1_4<-Arima(data1,c(0,1,1)) #AICc : 1300.99

checkresiduals(arima1_1$residuals)
checkresiduals(arima1_2$residuals)
checkresiduals(arima1_3$residuals)
checkresiduals(arima1_4$residuals)

Box.test(arima1_1$residuals,type="Ljung-Box") #p-value : 0.4691
Box.test(arima1_2$residuals,type="Ljung-Box") #p-value : 0.994
Box.test(arima1_3$residuals,type="Ljung-Box") #p-value : 0.943
Box.test(arima1_4$residuals,type="Ljung-Box") #p-value : 0.993

F_1_1<-forecast(arima1_1,h=12)
accuracy(F_1_1)


library(ggplot2)
autoplot(F_1_1)+autolayer(fitted(F_1_1),series = "fitted")+xlab("Time")+ylab("Arima(0,1,0) simualtion")



data2<-na.omit(data2)
table(is.na(data2))

data2<-ts(data2,start = c(2006,1),frequency = 12)
data2_train<-window(data2,start=c(2006,1),end=c(2018,6))
data2_test<-window(data2,start=c(2018,7))

ggtsdisplay(diff(diff(data2_train)))
ggtsdisplay(diff(diff(log(data2_train))))
ggtsdisplay(diff(log(data2_train)))
summary(ur.kpss(diff(diff(log(data2_train)))))
summary(ur.kpss(data2_train))


arima2_1<-Arima(data2_train,order=c(0,2,1),lambda = 0) #AICc : -280.11
arima2_2<-Arima(data2_train,c(2,2,1),lambda = 0) #AICc : -277.91
arima2_3<-Arima(data2_train,c(2,2,0),lambda = 0) #AICc : -247.17
arima2_4<-Arima(data2_train,c(0,1,0),lambda = 0,include.drift = TRUE) #AICc : -288.07

checkresiduals(arima2_1$residuals)
checkresiduals(arima2_2$residuals)
checkresiduals(arima2_3$residuals)
checkresiduals(arima2_4$residuals)

Box.test(arima2_1$residuals,type="Ljung-Box") #p-value : 0.2421
Box.test(arima2_2$residuals,type="Ljung-Box") #p-value : 0.9969
Box.test(arima2_3$residuals,type="Ljung-Box") #p-value : 0.5584
Box.test(arima2_4$residuals,type="Ljung-Box") #p-value : 0.2831

F_2_1<-forecast(arima2_4,h=12)
F_2_3<-forecast(arima2_3,h=12)

accuracy(F_2_1,data2_test)



library(ggplot2)
autoplot(F_2_1)+autolayer(fitted(F_2_1),series = "fitted")+xlab("Time")+ylab("Arima(0,1,0) with drift simualtion")+autolayer(data2_test)
autoplot(F_2_3)+autolayer(fitted(F_2_3),series = "fitted")+xlab("Time")+ylab("Arima(2,2,0) simualtion")+autolayer(data2_test)

ARIMA <- forecast(auto.arima(data2_train, lambda=0, biasadj=TRUE),h=12)
F_2_4<-forecast(arima2_1,h=12)
comb<-(ARIMA[["mean"]]+F_2_1[["mean"]])/2
accuracy(comb,data2_test)
