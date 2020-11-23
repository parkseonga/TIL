
d = getwd()

# 해당폴더에 파일 가져오기 
fls = dir(getwd(),recursive = TRUE)

library(stringr)

#파일 가져와서 할당하기 
for(f in fls){
  a = file.path(str_c(getwd(),'/',f))
  
  temp = read.csv(a)
  
  # assign: 변수에 할당 
  assign(str_c(f),temp)   # temp에 저장된 파일들을 파일명으로 변수를 생성하여 데이터를 할당 
}


# with: 필드 이름만으로 필드에 바로 접근하기 
# get: 문자열로 변수 생성
# column과 문자열 x를 합치고 get함수를 통해 변수를 생성하고 with으로 변수에 접근
mag = function(df, column){
  df[,str_c('mag',column)] = with(df,sqrt(get(str_c(column,'.x'))^2+get(str_c(column, '.y'))^2+get(str_c(column,'.z'))^2))

  return(df)
}


fls = ls()

# 1번 사람만 추출 
user1 = fls[str_detect(fls,'sub_1.csv')]

# 1번 사람 걷는 것만 추출 
user_walking = user1[str_detect(user1,'wlk')]

user1_walking_total = data.frame()

# f는 table명 안에 내용물은 get함수를 사용하여 f가 가르치는 객체를 가져올 수 있음.
for(f in user_walking){
  
  temp = get(f)
  
  user1_walking_total = rbind(user1_walking_total,
                              temp%>%mutate(exp_no = unlist(regmatches(f,gregexpr("[[:digit:]]+",f)[1]))[1],
                                                              id = unlist(regmatches(f,gregexpr("[[:digit:]]+", f)[1]))[2]))
  # 특정 패턴을 발견할 것임.
  # +를 붙여주는 이유는 두 글자인 경우도 있기 때문
}


# 첫번째 문자열에서 조건에 해당하는 위치를 반환.
gregexpr("[[:digit:]]+",f)  # 패턴의 위치를 찾음
# regmatches 해당 위치에 있는 값을 가져와라 
gerp("[[:digit:]]+",f) # 들어오는 문자열을 하나하나 보고 숫자가 있으면 반환되는 위치를 벡터로 알려줌

  
HAR_total = data.frame()

fls2 = subset(ls(), str_detect(ls(),'.csv'))


for(f in fls2){
  
  temp = get(f)
  
  # gregexpr을 통해 해당 글자가 있는 위치를 반환하고 regmatches를 통해 가져옴
  HAR_total = rbind(HAR_total,temp%>%mutate(exp_no = unlist(regmatches(f,gregexpr("[[:digit:]]+",f)[1]))[1],
                                            id = unlist(regmatches(f,gregexpr("[[:digit:]]+", f)[1]))[2],
                                            activity=unlist(str_split(f,'\\_'))[1]))
}
  
HAR_total = mag(HAR_total,'userAcceleration')
HAR_total = mag(HAR_total,"rotationRate")
  
# 통계를 다루는 함수 
library(seewave)  # skewness 등등 존재 

# 패키지 내 함수를 이용해도 되고 함수를 생성해도됨.
# skewness = function(x){
#   (sum((x-mean(x))^3)/length(x))/
#     ((sum((x-mean(x))^2)/length(x))^(3/2))
# }

# min, max 값이 얼마나 극단적인지 확인 가능
# 편차를 통해 값이 왼쪽에 치우쳐져 있는지 오른쪽에 치우쳐져 있는지 확인.
# 함수 생성시 . 사용하는 것 주의해야함.
HAR_summary = HAR_total%>%group_by(id,exp_no,activity)%>%summarize_at(.vars = c('maguserAcceleration','magrotationRate'),.funs = c(mean, min, max, sd, skewness))

subject_info = read.csv('C:\\Users\\a0105\\Desktop\\개인\\수업\\비정형데이터\\data_subject_info.csv',stringsAsFactors=FALSE)

head(subject_info)

subject_info$code = as.character(subject_info$code)
HAR_summary = HAR_summary %>% left_join(subject_info, by = c('id'='code'))

# RWeka를 이용하며 
library(RWeka)

# m = SMO(class~.,data = df)

# class변수는 factor형이어야함.
RF = make_Weka_classifier("weka/classifiers/trees/RandomForest")

HAR_summary$activity = as.factor(HAR_summary$activity)

activity = HAR_summary%>%ungroup() %>% select(c(colnames(HAR_summary)[str_detect(colnames(HAR_summary),"mag")],'activity'))
gender = HAR_summary%>%ungroup() %>% select(c(colnames(HAR_summary)[str_detect(colnames(HAR_summary),"mag")],'gender'))

RF = make_Weka_classifier("weka/classifiers/trees/RandomForest")

m = RF(activity~.,data=activity)

m_gender = RF(gender~.,data=gender)

# 성능
summary(m)
summary(m_gender)
# 카파통계량: 우연히 맞춘 확률을 뺀 것으로 높을수록 좋음.

# 각 class별로 true positive, precision, recall 
# wlk precision은 제대로 맞춘 WLK/wlk이라고 알고리즘 결과낸것
# RECALL은 제대로 맞춘 wlk/실제 데이터상 wlk
# precision: downstairs인 것 중에 정말 downstairs 인 것 
# recall: 실제 dws인 것 중에 맞춘 것 
# f-meauser로 보면 내려가는 것을 제일 못맞춤

# 앙상블: 복잡하고 여러 알고리즘을 합치는 방식(메타방식이라고 하기도함) 

# 평균 가속도 값은 얼마 얼마이다 라는 식으로 만드는 것임. 

## 따로따로 돌리기 귀찮아서 for문으로 
# 베이지 이웃에 따른 모델 
Bayes_net = make_Weka_classifier("weka/calssifiers/bayes/BayesNet")

# 여러 모델 이용 
# IBK:최근접 이웃을 이용한 모델 
m_list = list('RF','IBk','SMO','Bayes_net')  

rslt = list()

for(a in m_list){
  
  m = get(a)(activity~. , data=activity)   # a가 가르치는 알고리즘 이름을 가져오라 라는 뜻
  
  # 공부했으면 시험볼수 있도록 10번 confusionmatix들어갈 수 있도록 설정
  e = evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class=TRUE)
  
  # 결과는 복잡하니까 리스트에 저장하는 것이 좋음
  # 리스트의 키는 알고리즘명으로 함
  rslt[[a]] = e
}

# gender로 해보기 
# for( a in m_list){
#   m = get(a)(gender~. , data=gender)
#   e = evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class=TRUE)
#   rslt[[a]] = e
# }

# 데이터의 길이도 고려
rss<-function(x) rms(x)*length(x)
# cf) rms는 데이터의 길이는 고려하지 않고 신호의 평균값만 구한 것

gener = HAR_summary %>% ungroup() %>% select(c(colnames(HAR_summary)[str_detect(colnames(HAR_summary),'mag')],'gender'))

m = RF(as.factor(gender)~.,data=gender)
summary(m)

e = evaluate_Weka_classifier(m,numFolds = 10, complexity = TRUE, class=TRUE)

e

HAR_summary_extend = HAR_total %>%group_by(id, exp_no, activity) %>%summarize_at(.vars=c('maguserAcceleration','magrotationRate'),.funs=c(mean, min, max, sd, skewness, rms, rss, IQR, e1071::kurtosis))
HAR_summary_extend = HAR_summary_extend%>%left_join(subject_info, by = c('id'='code'))

gender_ext = HAR_summary_extend%>%ungroup()%>%select(c(colnames(HAR_summary_extend)[str_detect(colnames(HAR_summary_extend),'mag')],'gender'))  

m = RF(as.factor(gender)~.,data=gender_ext)

summary(m)

e = evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class = TRUE)
e


mtcars.pca = prcomp(HAR_summary_extend%>%ungroup()%>%select(-id, -exp_no,-activity,-gender,-weight,-height,-age),center = TRUE, scale=TRUE)

mtcars.pca

plot(mtcars.pca$sdev)+title("ScreePlot")

# 정확도보다 빨리 돌려야한다는 관점에서 18차원을 3차원으로 만들고 중요하게 작동했던 변수들만을 통해 분류모델 적용 
# 정확도는 떨어져도 속도는 빠름
m = RF(as.factor(gender)~maguserAcceleration_fn1+magrotationRate_fn1+
         maguserAccelertaion_fn7+magrotationRate_fn7+
         mgauserAcceleration_fn9+magrotationRate_fn9,data=gender_ext)


summary(m)

e = evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class=TRUE)

e

# 변화분석하기 
library(changepoint)

# 1주차에 했던 것 같으니까 참고해보기 
# cpt.mean()  mean only changes
# cpt.var() variance only changes
# cpt.meanvar() mean and variance changes  


# mag함수 앞에서 만들어놨으니까 안만들거임

fls = ls()[str_detect(ls(),'.csv')]

total_peak = data.frame()


for(d in fls){
  f = get(d)
  f$magrotationRate= mag(f, "rotationRate")
  f$maguserAcceleration = mag(f, "userAcceleration")
  rslt = sapply(f%>%select(magrotationRate,maguserAcceleration),cpt.mean)
  rslt_cpts1 = cpts(rslt$magrotationRate)
  rslt_cpts2 = cpts(rslt$maguserAcceleration)
  rslt2 = sapply(f%>%select(magrotationRate,maguserAcceleration),cpt.var)
  rslt2_cpts1 = cpts(rslt2$magrotationRate)
  rslt2_cpts2 = cpts(rslt2$maguserAcceleration)
  rslt3 = sapply(f%>%select(magrotationRate,maguserAcceleration),cpt.meanvar )
  rslt3_cpts1 = cpts(rslt3$magrotationRate)
  rslt3_cpts2 = cpts(rslt3$maguserAcceleration)
  
  total_peak = rbind(total_peak, data.frame(d,cp1=length(rslt_cpts1),cp2=length(rslt_cpts2),cp3=length(rslt2_cpts1),cp4=length(rslt2_cpts2),
                                           cp5=length(rslt3_cpts1),cp6=length(rslt3_cpts2) ))
}

# 좀 더 예쁘게 볼 수 있음
# 파이썬은 pprint패키지가 제공해주는 것 
total_peak = data.table(total_peak)
head(total_peak)

temp = get(fls[1])

findpeaks(f$magrotationRate, threshold=4)


# 매번 magnitude구하기 귀찮음 모든 테이블 계산
for(d in fls){
  f = get(d)
  f$magrotationRate = mag(f, "rotationRate")
  f$maguserAcceleration = mag(f, "userAcceleration")
  assign(d,f)}

library(pracma)
peak_rslt<-data.frame()

for(d in fls){
  f = get(d)
  p = findpeaks(f$magrotationRate,threshold=4)
  peak_rslt = rbind(peak_rslt,data.frame(d,f_n=ifelse(!is.null(p), dim(p)[1],0),
                                        p_interval=ifelse(!is.null(p), ifelse(dim(p)[1]>2, mean(diff(p[,2])),0),0),
                                        p_interval_std=ifelse(!is.null(p),ifelse(dim(p)[1]>2, std(diff(p[,2])),0), 0),
                                        p_mean=ifelse(!is.null(p),mean(p[,1]),0),p_max=ifelse(!is.null(p),max(p[,1]),0), p_min=ifelse(!is.null(p),min(p[,1]),0),
                                        p_std=ifelse(!is.null(p),std(p[,1]),0)))}

temp<-get(fls[1])

plot(temp$magrotationRate)


crest(temp$magrotationRate,50,plot = TRUE)

temp = data.frame()

for (d in fls){
  f = get(d)
  f =  f%>%select(magrotationRate,maguserAcceleration)
  cfR = crest(f$magrotationRate,1, plot=TRUE)
  cfA = crest(f$maguserAcceleration,1, plot=TRUE)
  temp = rbind(temp,data.frame(d,cfR=cfR$C,cfA=cfA$C))
}        

peak_final <-merge(peak_rslt, temp, by="d")
peak_final <-merge(peak_final, total_peak, by="d")

