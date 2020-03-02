import os

os.chdir(r'C:\Users\admin\Desktop\me2')

from selenium import webdriver
import pandas as pd
from bs4 import BeautifulSoup
import requests

from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By

path = 'chromedriver_win32\chromedriver.exe'

data = pd.read_csv('화학물질취급정보(상세검색)_20200227.csv',engine='python')

col_=['업체명',
 '대표자',
 '소재지',
 '대표업종',
 '종업원수',
 '관할 환경청',
 '산업단지',
 '농공단지',
 '유입수계명',
 '상수원 보호구역명',
 '대기보전특별대책지역명',
 '수질보전특별대책지역명',
 '대기오염물질배출시설종류',
 '폐수배출시설종류',
 '유해화학물질 보관·저장현황',
 '최대 보관량(범위)',
 '최대 저장량(범위)',
 '화학사고 발생현황',
 '화학사고시 비상연락처']

url_ = 'https://icis.me.go.kr/main.do'

# 빈 리스트 생성
alldf = []
alldf2 = []
alldf3 = []
pro2 = []
    
for name in data:
    try:
        url = url_
        
        driver = webdriver.Chrome(path)
    
        driver.get(url)
                
        button_path = '//*[@id="content"]/div[3]/div[3]/ul/li[2]'
                
        wait = WebDriverWait(driver, 10)
                
        button = wait.until(EC.visibility_of_element_located((By.XPATH,button_path)))
                
        button.click()
        
        button_path1 = '//*[@id="tab2"]/div[1]/ul/li[2]/a'
                
        wait = WebDriverWait(driver, 10)
                
        button = wait.until(EC.visibility_of_element_located((By.XPATH,button_path1)))
                
        button.click()
        
        elem = driver.find_element_by_id("search3")
        elem.send_keys(name)
        
        button_path_search = '//*[@id="cont_search_bx"]/div/div/div/a[1]'
                
        wait = WebDriverWait(driver, 10)
                
        button = wait.until(EC.visibility_of_element_located((By.XPATH,button_path_search)))
                
        button.click() 
        
        wait = WebDriverWait(driver, 10)
    
        wait.until(EC.element_to_be_clickable((By.LINK_TEXT, name))).click()              
            
        soup = driver.page_source
        
        target = BeautifulSoup(soup,'html.parser') 
        
        target.select('#main_container > div:nth-of-type(3) > table')    
        
        title=[]
        
        for tag in target.find_all('td',class_=''):
            title.append(tag.text)  
        alldf.append(title)
        
        pro = driver.find_element_by_xpath('//*[@id="main_container"]/div[3]/table/tbody')
        pro2.append(pro.text) 
        
        abc=[]
        for tag2 in target.find_all('div',class_='srch_result_group mgt30'):
            for tag in tag2.find_all('td',class_='left'):
                abc.append(tag.text)   
        alldf2.append(''.join(abc))
        
        in_=[]
        for tag_numeric in target.find_all('span',class_='tt'):
            in_.append(tag_numeric.text)  
        alldf3.append(in_)
    
    except:
        pass
    
    finally:
        driver.close()      

# 추출된 데이터를 데이터프레임 형태로 변환 
df = pd.DataFrame(alldf)
product = pd.DataFrame(pro2,columns=['제품명'])    
material = pd.DataFrame(alldf2,columns=['물질명'])
material_quantity = pd.DataFrame({'물질량':alldf3})
       
product['제품명'] = product['제품명'].replace('혼합물질   단일물질','',regex=True)
product['제품명'] = product['제품명'].replace('\n','|',regex=True)

material['물질명'] = material['물질명'].str.strip()
material['물질명'] = material['물질명'].replace('\n\t\t\t\t\t\t\t\t\n\t\t\t\t\t\t\t\t\t','|',regex=True)

material_quantity['물질량'] = material_quantity['물질량'].apply(lambda x: '|'.join(x))
material_quantity['물질량'] = material_quantity['물질량'].replace('범주','',regex=True)
material_quantity['물질량'] = material_quantity['물질량'].str.split('|')
material_quantity['물질량'] = material_quantity['물질량'].apply(lambda x: list(filter(None,x)))

# 물질량의 홀수번째는 연간입고량, 짝수번째 위치하는 값은 연간 사용,판매량으로 할당
material_quantity['연간입고량'] = material_quantity['물질량'].apply(lambda x: x[0::2] )
material_quantity['연간 사용,판매량'] = material_quantity['물질량'].apply(lambda x: x[1::2] )

# 리스트를 문자열로 변환 
material_quantity['연간입고량'] = material_quantity['연간입고량'].apply(lambda x: '|'.join(x))
material_quantity['연간 사용,판매량'] = material_quantity['연간 사용,판매량'].apply(lambda x: '|'.join(x))

# 불필요한 필드 삭제
del material_quantity['물질량']

df2 = df.iloc[:,0:19]
df2.columns = col_
    
df_total = pd.concat([df2,product,material,material_quantity],axis=1)   

# 엑셀로 내보내기
df_total.to_excel('total.xlsx')


