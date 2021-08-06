## Level4
* [보호소에서 중성화한 동물](https://programmers.co.kr/learn/courses/30/lessons/59042)
  <pre><code>SELECT O.ANIMAL_ID, O.NAME
  FROM ANIMAL_INS AS I 
  RIGHT OUTER JOIN ANIMAL_OUTS AS O
  ON I.ANIMAL_ID = O.ANIMAL_ID
  WHERE I.ANIMAL_ID IS NULL
  ORDER BY I.ANIMAL_ID DESC;
  </code></pre> 
  
* [우유와 요거트가 담긴 장바구니](https://programmers.co.kr/learn/courses/30/lessons/62284)
  <pre><code>SELECT A.CART_ID
  FROM CART_PRODUCTS AS A, CART_PRODUCTS  AS B
  WHERE A.CART_ID = B.CART_ID AND A.NAME = "Yogurt" and B.NAME = "Milk"
  ORDER BY CART_ID ASC;

  -- GROUP_CONCAT를 사용하는 경우 
  SELECT CART_ID
  FROM CART_PRODUCTS
  GROUP BY CART_ID
  HAVING
      GROUP_CONCAT(NAME SEPARATOR ' ') LIKE '%Milk%'
      AND
      GROUP_CONCAT(NAME SEPARATOR ' ') LIKE '%Yogurt%'

  -- GROUP_CONCAT(컬럼명 SEPARATOR 구분자)
  -- 기본 구분자는 ","
  -- 중복제거: GROUP_CONCAT(DISTINCT 컬럼명)
  -- 문자열 정렬: GROUP_CONCAT(컬럼명 ORDER BY 컬럼명)
  </code></pre> 
  
* [입양 시각 구하기(2)](https://programmers.co.kr/learn/courses/30/lessons/59413)
  <pre><code>-- WITH RECURSIVE 를 이용하여 가상테이블 생성 
  -- 메모리 사엥서 가상 테이블 저장
  -- 반드시 UNION 사용
  -- 서브쿼리에서 바깥의 가상 테이블을 참조하는 문장 필요
  -- 반복되는 문장은 정지 조건 필요
  WITH RECURSIVE T AS (
  SELECT 0 AS NUM
  UNION ALL 
  SELECT NUM + 1
  FROM T
  WHERE NUM <= 22)  -- 반복되는 문장 정지 조건 
  SELECT NUM AS HOUR, COUNT(DATETIME)
  FROM T LEFT JOIN ANIMAL_OUTS AS A
  ON T.NUM = HOUR(A.DATETIME)
  GROUP BY HOUR
  ORDER BY HOUR;
  </code></pre> 
  

  
