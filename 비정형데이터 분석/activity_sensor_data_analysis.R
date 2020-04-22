d = getwd()

fls = dir(getwd(),recursive = TRUE)

library(stringr)

for(f in fls){
  a = file.path(str_c(getwd(),'/',f))
  
  temp = read.csv(a)
  
  assign(str_c(f),temp)
}

mag = function(df, column){
  df[,str_c('mag',column)] = with(df,sqrt(get(str_c(column,'.x'))^2+get(str_c(column, '.y'))^2+get(str_c(column,'.z'))^2))

  return(df)
}

fls = ls()

user1 = fls[str_detect(fls,'sub_1.csv')]

user_walking = user1[str_detect(user1,'wlk')]

user1_walking_total = data.frame()

# 1번 유저가 걸었던 것만 추출 
# f는 table명 안에 내용물은 get함수를 사용하여 f가 가르치는 객체를 가져올 수 있음.
for(f in user_walking){
  
  temp = get(f)
  
  user1_walking_total = rbind(user1_walking_total,
                              temp%>%mutate(exp_no = unlist(regmatches(f,gregexpr("[[:digit:]]+",f)[1]))[1],
                                                              id = unlist(regmatches(f,gregexpr("[[:digit:]]+", f)[1]))[2]))
  # 특정 패턴을 발견할 것임.
  # +를 붙여주는 이유는 두 글자인 경우도 있기 때문
}
  
HAR_total = data.frame()

fls2 = subset(ls(), str_detect(ls(),'.csv'))

for(f in fls2){
  temp = get(f)
  HAR_total = rbind(HAR_total,temp%>%mutate(exp_no = unlist(regmatches(f,gregexpr("[[:digit:]]+",f)[1]))[1],
                                            id = unlist(regmatches(f,gregexpr("[[:digit:]]+", f)[1]))[2],
                                            activity=unlist(str_split(f,'\\_'))[1]))
}
  
HAR_total = mag(HAR_total,'userAcceleration')
HAR_total = mag(HAR_total,"rotationRate")
  
library(seewave)

# 함수를 이용해도 되고 함수를 생성해도됨.
skewness = function(x){
  (sum((x-mean(x))^3)/length(x))/
    ((sum((x-mean(x))^2)/length(x))^(3/2))
}

# min, max 값이 얼마나 극단적인지 확인 가능
# 편차를 통해 값이 왼쪽에 치우쳐져 있는지 오른쪽에 치우쳐져 있는지 확인.
# 함수 생성시 . 사용하는 것 주의해야함.
HAR_summary = HAR_total%>%group_by(id,exp_no,activity)%>%summarize_at(.vars = c('maguserAcceleration','magrotationRate'),.funs = c(mean, min, max, sd, skewness))

subject_info = read.csv('C:\\Users\\a0105\\Desktop\\개인\\수업\\비정형데이터\\data_subject_info.csv',stringsAsFactors=FALSE)

head(subject_info)

subject_info$code = as.character(subject_info$code)
HAR_summary = HAR_summary %>% left_join(subject_info, by = c('id'='code'))

library(RWeka)

# m = SMO(class~.,data = df)

# class변수는 factor형이어야함.
RF = make_Weka_classifier("weka/classifiers/trees/RandomForest")

HAR_summary$activity = as.factor(HAR_summary$activity)

activity = HAR_summary%>%ungroup() %>% select(c(colnames(HAR_summary)[str_detect(colnames(HAR_summary),"mag")],'activity'))

RF = make_Weka_classifier("weka/classifiers/trees/RandomForest")

m = RF(activity~.,data=activity)

# 성능
summary(m)

# 카파통계량: 우연히 맞춘 확률을 뺀 것으로 높을수록 좋음.

# 각 class별로 true positive, precision, recall 
# wlk precision은   제대로 맞춘 WLK/wlk이라고 알고리즘 결과낸것
# RECALL은 제대로 맞춘 wlk/실제 데이터상 wlk
# precision: downstairs인 것 중에 정말 downstairsdls rjt
# recall: 실제 dws인 것 중에 맞춘 것 
# f-meauser로 보면 내려가는 것을 제일 못맞춤
e = evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class=TRUE)
# 평균 가속도 값은 얼마 얼마이다 라는 식으로 만드는 것임. 

Bayes_net = make_Weka_classifier("weka/calssifiers/bayes/BayesNet")

m_list = list('RF','IBk','SMO','Bayes_net')

rslt = list()

for( a in m_list){
  m = get(a)(activity~. , data=activity)
  e = evaluate_Weka_classifier(m, numFolds = 10, complexity = TRUE, class=TRUE)
  rslt[[a]] = e
}


# Error in .jcall(man, "Ljava/lang/Object;", "objectForName", as_qualified_name(name)) : 
# java.lang.ClassNotFoundException
# jdk error 발생함 자바 깔기                                                                                     

f = 'wlk_8/sub_19.csv'

# 첫번째 문자열에서 조건에 해당하는 위치를 반환.
gregexpr("[[:digit:]]+",f)  # 패턴의 위치를 찾음
# regmatches 해당 위치에 있는 값을 가져와라 
gerp("[[:digit:]]+",f) # 들어오는 문자열을 하나하나 보고 숫자가 있으면 반환되는 위치를 벡터로 알려줌


g = c('wlk_8/sub_19.csv1','wlk_80/sub_19.csv')
gregexpr('[[:digit:]]+',g)
grep('[[:digit:]]+',g)
