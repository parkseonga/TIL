# Machine_learning

* [1. 정의](https://github.com/parkseonga/Machine_learning#1-%EC%A0%95%EC%9D%98)
* [2. 모델평가](https://github.com/parkseonga/Machine_learning/blob/master/README.md#3-%ED%95%99%EC%8A%B5%EB%B0%A9%EB%B2%95)
* [3. 학습방법](https://github.com/parkseonga/Machine_learning/blob/master/README.md#3-%ED%95%99%EC%8A%B5%EB%B0%A9%EB%B2%95)
* [4. supervised learning 종류](https://github.com/parkseonga/Machine_learning/blob/master/README.md#3-%ED%95%99%EC%8A%B5%EB%B0%A9%EB%B2%95)
  * [4.1. Decision Tree](https://github.com/parkseonga/Machine_learning/blob/master/README.md#41-decision-tree)

## 1. 정의
- 기계 "스스로" 데이터를 학습시켜 규칙을 발견하여 예측
- 통계학과 달리 베이즈 분석과 같은 고전적인 통계 분석에 효율적이지 못할 뿐만 아니라 복잡한 대규모 데이터셋을 처리해야하는 경향이 있음.

![image](https://user-images.githubusercontent.com/33725048/75602608-45f97b80-5b0a-11ea-9825-4048ffe7e40d.png)

- 학습의 목적?
  - 임의의 주어진 모델의 파라메터값들의 값을 데이터에 맞게 업데이트 하는 것
  (***파라메터 최적화***)
  - 목적함수의 함수값을 최적화하는 파라메터 값 찾기!
  
  ex) 학습 알고리즘
  - MLE(Maximum Likelihood Estimation)
  - MAP(Maximum a Posteriori Estimation)
  - Gradient Descent
  
- Feature 
  - 모델을 돌릴 때 어떤 feature(어떤 속성값)를 사용할 것인가는 어떤 목적으로 모델을 생성하느냐에 따라 매우 중요하다. 예를들어 돈을 빌려줄지 말지를 예측하는 경우 집주소는 있는가? 범죄기록이 있는가?와 같은 속성은 목적에 적합하지만 손톱이 긴가? 짧은가?는 목적에 적합하지 않는 것처럼 feature를 선택하는 것은 모델의 성능에 매우 중요하다.
  - feature의 개수는 수백~수만개 이상이 될 수 있고 classification의 경우, data의 개수보다 적고 label의 개수보다 많은 것이 일반적이다. 하지만 **feature의 수를 무턱대고 늘리는 것은 curse of dimensionality(차원의 저주) 문제**가 발생할 수 있기 때문에 주의하여야한다.
    - 차원이 증가하면 각 차원의 다양한 값들에 대한 조합의 개수가 증가하고 그에 따른 필요 데이터가 증가하지만 차원에 비해 데이터가 너무 적으면 overfitting(과적합)이 발생할 수 있기 때문에 조심해야한다.
    
- data부족하거나 분포가 치우쳐져 있다면?
  i. sampling이용
    - 비율이 많은 데이터를 더 적게 채택하는 down-sampling, 비율이 적은 데이터를 더 많이 채택하는 up-sampling 
 ii. Bagging(Bootstrap Aggregating)
    - 샘플을 랜덤하게 분류기에 나눠서 학습

## 2. 모델 평가
### 2.1. 정량평가
- 문제에 답이 명확하게 존재하고 점수가 객관적으로 매겨질 수 있는 평가방법
- 혼동 행렬로부터 계산할 수 있는 계산 메트릭 종류
i. Accuracy(정확도)
- 전체 예측 건수에서 정답을 맞힌 건수의 비율
ii. Recall(재현율)
- 실제로 정답이 True인 것들 중에서 분류기가 True로 예측한 비율
( 애초에 True가 발생하는 확률이 적을 때 사용하는 것이 좋음)
iii. Precision(정밀도)
- True라고 예측한 것들 중에 진짜 True일 확률

  *Recall과 Precision은 trade-off관계*

iv. F1 score
- Recall과 Precision 조화평균
- 조화평균을 사용하는 이유는 Recall, Precision 두 지표를 모두 균형있게 반영하여 모델의 성능이 좋지 않다는 것의 확인을 잘하기 위해.
- 0~1 사이 값으로 두 값이 균형있게 클 때 큰 값을 가짐.

v. Specificity(특이도)
- 실제로 Negaitve인 것들 중에 예측이 Negative인 비율

vi. FP-Rate
- 실제 값이 negative인데 positive로 예측한 비율
- 1-Specificity

vii. ROC Curve
- FP Rate 대비 TP Rate 변화율

viii. AUC
- ROC Curve를 그린 뒤 모델 간 성능 비교에 사용하는 것으로 랜덤분류분석기의 AUC값=0.5, 좋은 분류기일수록 1.0에 가까움.

### 2.2. 정성평가
- 문제에 답이 명확하게 존재하지 않아 점수가 주관적으로 매겨질 수 있는 평가방법
## 3. 학습방법
### 3.1. supervised learning
- 정답이 존재하는 데이터를 이용하여 "분류"하는 작업에서 새로운 데이터의 값 예측
- 예측하는 값이 이산값이면 분류, 연속값이면 회귀

  ex) Decision Trees, Suppor Vector Machine, Neural networks, Regression 

### 3.2. unsupervised leaning
- 정답이 존재하지 않는 데이터의 패턴을 이용하여 "군집화"하는 작업에서 새로운 데이터의 값 예측
- 계산속도가 느리지만 데이터에 대한 가정이 필요없음.
- 모델 정량평가를 위해서는 결국 '정답'이 필요함

  ex) Hierarchical clustering, K-menas clustering
 
### 3.3. semi-supervised learning
- 정답이 존재하는 일부 데이터를 통해 패턴을 발견하고 새로운 데이터의 값 예측
- 이상값 탐지 등에 사용

  ex) OcSVM
  
### 3.4. Reinforcement learning
- 환경에 대한 사전지식 없이도 학습할 수 있는 방법으로 행동에 대한 보상을 통해 데이터를 학습하고 새로운 데이터의 값을 예측

  ex) 알파고의 바둑 대결, 로봇이 걷고 뛰는 과정 학습
  

## 4. Supervised Learing의 종류
### 4.1. Decision Tree?
  - 
#### 4.1.1. decision tree의 구조
  - internal node: 조건문
  - edge: 조건 결과에 따른 분기
  - external node: 결과

#### 4.1.2. 좋은 트리의 기준?
  - leaf node에서 통일된 lable의 데이터만 남는 것
    -> 높은 분류 정확도, 의사결정 정확도
  - 트리의 깊이가 짧은 것
    -> 빠른 수행 속도

#### 4.1.3. 분류 
  - entropy: 클래스 값의 집합 내에서 무작위성(값의 범위 0~1)
  -> **entropy가 클수록 분류가 제대로 안된 것**
  - infromation gain: 부모 노드의 entropy - 자식 노드의 entropy 
   = entropy(parent) - [average entropy(children)]
  -> **information gain이 클수록 분류가 잘된 것**
  
#### 4.1.4. ID3알고리즘(트리 생성 알고리즘)?
        
  * 순서: root node -> leaf node

  * 가정1: root node는 모든 데이터를 고려한다.   
  * 가정2: 하위 노드로 내려가면서 데이터들이 분류된다.

    1. 노드에서 고려할 데이터가 이미 하나의 class에만 속해있거나 더 이상 고려할 feature가 없으면 leaf node로 여기고 자식노드 생성하지 않음.
    2. 각 노드에서 고려할 feature 선택 시, 데이터를 가장 잘 나눠주는 feature 선택
      -> information gain이 가장 큰 feature선택
        - label이 섞여 있으면 나누고 더 이상 나눌 label이 없다면 leaf node   
        (이상적인 경우라면 label이 다소 섞여 있더라도 몇 개 이하면 나누지 않음.)
    3. 선택된 feature에 대해 조건 별로 자식 노드 생성
    4. 각 자식 노드에서 해당 조건을 만족하는 데이터만 고려하여 반복

  * [참고]
    - 가지를 너무 많이치면 overfitting이 일어날 수 있음.
    -feature가 categorical feature가 아닌, real-value feature라면? 
      - bin 생성: 구간을 정해서 하나의 카테고리인 것처럼 만드는 것.
        * 장점: 계산량이 줄어듦.
        * 단점: 정보손실량이 커짐    
        -> 데이터의 성격을 보고 bin생성 방안 
   
**즉, root node는 모든 data를 고려하고 information gain이 증가하는 것을 골라서 나눈다.    
  이때 feature에 대한 조건 별로 자식노드 생성**


 
#### 4.1.5 특징
##### 장점
  - flow chart와 같은 트리 구조가 사람이 읽을 수 있는 형식으로 출력되기 때문에 **모델이 어떻게, 왜 특정 작업에 잘 작동한는지 또는 작동하지 않는지에 대한 통찰력 제공**

##### 단점
  - 명목 특징이 여러 라벨로 이루어져 있거나 다수의 특징을 가지고 있는 경우 트리가 복잡해짐
    -> train 데이터에서는 좋은 성능을 보이지만 test 데이터에서는 그렇지 않은 overfitting 발생 가능
  - 다른 방법에 비해 예측 정확도가 낮은 편
  - 모델의 분산이 크다(입력데이터에 영향을 많이 받음)    
      ~~이를 개선한 방법이 randomforest~~

#### 4.1.6. 사용 적합 예시
  - 법적인 이유로 분류 방법이 투명해야하는 애플리케이션
  - 향후 업무를 알리기 위해 다른 사람과 결과를 공유해야하는 경우

  ex)    
      1. 신청자 거절 기준이 명확히 문서화되고 편향되지 않은 신용 평가 모델   
      2. 경영진 또는 광고 대행사와 공유될 고객 만족이나 고객 이탈과 같은 고객 행동 마케팅 연구   
      3. 실험실 측정, 증상, 질병 진행률을 기반으로 하는 질병 진단   

### 4.2. bayesian networks?

### 4.3. Linear Classification, Regression?
### 4.4. SVM?
### 4.5. PCA?

### 4.6. K-NN?
### 4.7. K-means?

### 4.8. Ensemble Learning?
#### 4.8.1. 정의
- 약한 학습기 여러 개를 결합하여 강한 학습기를 만들어내어 더 좋은 성능을 나타내는 머신러닝 기법

#### 4.8.2. 장점
- 여러 학습 모델을 사용하기 때문에 overfitting 될 가능성이 줄어듦.
- 대용량 데이터나 매우 적은 데이터에서도 모두 잘 작용함.
- 데이터를 분할하여 학습하기 때문에 미세한 패턴을 좀 더 정확하게 포착할 수 있음   

**높은 variance로 인한 overfitting, 높은 bias로 인한 underfitting을 개선할 수 있음!!**

#### 4.8.3. 종류
voting
  - 다른 알고리즘 모델의 조합에 대한 다수결 투표 방식으로 class 결정
  - (hard voting)예측한 결과값을 다수결로 결과 측정    
    ex) 어떤 class를 svm은 1, decesiontree는 2, naviebayes는 1로 예측했을 때 voting result결과는 1 
  - (soft voting)해당 class별로 맞출 확률을 평균내어 가장 높은 값 선택

bagging(bootstrap aggregating)
  - 하나의 데이터셋으로 여래 개의 trainset을 나누어 만든다(**복원 추출**)
  - 분류를 위한 투표 or 수치 예측을 위한 평균화를 이용하여 예측
  - 병렬 학습   
    ex) randomforest

boosting
  - 틀린 문제에 가중치를 주어 최적의 학습 모델 도출 -> 정확도는 높지만 outlier에 민감   
  - 학습이 끝난 후 나온 결과에 따라 가중치가 재분배되는 순차적 학습    
    ex) Adaboost, Xgboost, Gradient boost

stacking
  - 하나의 데이터에 다른 여러 모델을 학습하여 새로운 모델을 만드는 방법
  - 각 모델이 예측한 데이터를 다시 train data로 사용하여 예측   
     
  
  참고) https://lsjsj92.tistory.com/558
  
  
### 4.9. perceptron?
### 4.10. 인공신경망?

