library(tidyverse)

setwd('C:\\Users\\a0105\\Desktop\\개인\\수업\\비정형데이터\\flights.csv')

# read_csv는 data를 불러올 때 컬럼별로 type을 지정할 수 있음.
# row data를 읽어올 수 있음.
flights = read_csv('flights.csv')
read_csv("1,2,3\n4,5,6",col_names = c('x','y','z'))

# 컬럼명이 없어서 첫 행을 컬럼명으로 인식 
# .을 na라고 선언 
read_csv("1,2,3\n4,5",na='.')


# %>%. = placholder
# AIRLINE컬럼만 가져와라
flights%>%.$AIRLINE
flights%>%.[["AIRLINE"]]

# flights에서 destination_airport별로 그룹핑
by_dest = group_by(flights,DESTINATION_AIRPORT)
delay = summarise(by_dest,count = n(),dist=mean(DISTANCE,na.rm=TRUE),delay=mean(ARRIVAL_DELAY,na.rm = TRUE))

# contains함수를 통해 변수의 패턴을 통해 변수를 간단하게 추출 
# flights%>%select(names(flights)[str_detect(names(flights),"TIME")])
select(flights,contains("TIME"))

# 시작 특정단어 또는 끝나는 단어로 변수 추출
# : 를 통해 특정 변수만 가져올 수 있음
# select: 컬럼 추출
# filter: 조건에 맞는 행 추출 
flghts_sml = select(flights,YEAR:DAY, ends_with("DELAY"),DISTANCE)

flights%>%filter(between(ARRIVAL_TIME))

# 각 테이블 따로 저장 
write_rds(flights,'flights.csv')
read_rds('flights.csv')

# 전체 데이터 저장
save.image('class1.RData')
load('class1.RData')


# tidy data
# 각 컬럼의 속성이 다른 것이 더 좋음
# 변수 들의 속성이 같으면 하나의 변수로 두는 것이 좋음 
# 같은 속성의 변수들이 여러개이면 분석을 하는데 시간이 오래걸리고 자동화시키기 복잡
# 회사 내 db에서 컬럼을 추가할려면 테이블 설계를 다시해야하고 데이터 정의서 및 관련 문서들을 업데이트 시켜야되기 때문에 행을 추가하는 것은 쉽지만 컬럼을 추가하는 것은 할 일이 많음.
# 컬럼은 함부로 추가하지 않도록 하는 것이 좋음
# db는 기록하고자 만들었기 때문에 행을 추가한다고 문제가 될 것이 없음.(업데이터 기록만 알려주면 됨)
# 데이터를 경제적으로 저장할 수 있음(메모리 효율)
# 시각화하기 편함(gather함수를 이용해서)

# reshaping
# 연습용 데이터 table4a사용
# gather함수 
table4a%>%gather(`1999`,`2000`,key = "year",value="cases")
table4a%>%gather("1999","2000",key = "year",value="cases")

# spread함수 
# key:변수화할 컬럼 
table4a%>%gather("1999","2000",key = "year",value="cases")%>%
  spread(key='year',value='cases')

# 두 변수를 합쳐서 하나의 변수로 만들기
# century와 year변수가 합쳐져서 new변수로 만들고 기존의 변수 삭제 
table5
table5%>%unite(new,century,year)

# ctr과 return의 개수는 같아야함
stocks = tibble(year=c(2015,2015,2015,2015,2016,2016,2016),ctr=c(1,2,3,4,2,3,4),return=c(1.88,0.59,0.35,NA,0.92,0.17,2.66))
stocks%>%complete(year,ctr)

# 시계열 데이터가 아닌 경우 대표값을 사용하여 대체하거나 삭제 
# 비슷한 레코드를 찾아 결측치를 대체하기도함 
# 시계열 데이터는 전후의 평균 또는 전의 값을 사용하여 대체하기도함
stocks %>% fill(return)    # 이전 값을 채워넣음 



