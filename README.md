# Machine_learning
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


