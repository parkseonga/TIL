import numpy as np
import pandas as pd
from io import StringIO
from sklearn import preprocessing
from sklearn.model_selection import train_test_split
from sklearn.svm import SVC


# 데이터 불러오기 
datapath = "./badges.data"

# 구분자 생성
with open(datapath,'r') as f:
    content = f.read()
while '+' in content:
    content = content.replace('+','+\t')
while '-' in content:
    content = content.replace('-','-\t')
    
raw_data = pd.read_csv(StingIO(content), sep = '\t', dtype='unicode',names=['class','name'])

raw_data.head()

vocab = list({k.lower() for x in raw_Data['name'].unique() for k in x.split()})

raw_data2 = raw_data.copy()
for i, x in enumerate(raw_data2['name']):
    tmp = np.zeros(len(vocab))
    tmp[x] =1
    raw_data3['name'][i] = tmp
    
# 라벨 인코더 적용 
le_class = preprocessing.LabelEncoder()
final_data = raw_data3.copy()
final_data['class'] = le_class.fit_transform(raw_data3['class'])

final_data.head()

# train 데이터와 test 데이터 나누기 
train_d, test_d = train_test_split(final_data, test_size=0.1)

train_y = train_d['class']
train_x = []
for k in train_d['name']:
    train_x += [[x for x in k]]
    
test_y = test_d['class']
test_x = []
for k in test_d['name']:
    test_x += [[x for x in k]]
    
# SVM 모델 적용 
model = SVC(gamma = 'auto', C = 10.0)   # C값이 클수록 오버피팅이 발생
model.fit(train_x,train_y)

model.score(test_x,test_y)   # 0.86
