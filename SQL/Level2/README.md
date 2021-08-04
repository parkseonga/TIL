## Level2
* [동물 수 구하기 (SUM, MAX, MIN)](https://programmers.co.kr/learn/courses/30/lessons/59406)
  <pre><code>SELECT COUNT(ANIMAL_ID) AS count
  FROM ANIMAL_INS;
  </code></pre> 

* [중복 제거하기 (SUM, MAX, MIN)](https://programmers.co.kr/learn/courses/30/lessons/59408)
  <pre><code>SELECT COUNT(DISTINCT(NAME))
  FROM ANIMAL_INS;
  </code></pre> 

* [최솟값 구하기 (SUM, MAX, MIN)](https://programmers.co.kr/learn/courses/30/lessons/59038)
  <pre><code>SELECT MIN(DATETIME) AS 시간
  FROM ANIMAL_INS;
  </code></pre> 
  
* [고양이와 개는 몇 마리 있을까 (GROUP BY)](https://programmers.co.kr/learn/courses/30/lessons/59040)
  <pre><code>SELECT ANIMAL_TYPE, COUNT(ANIMAL_TYPE) AS count
  FROM ANIMAL_INS
  GROUP BY ANIMAL_TYPE
  ORDER BY ANIMAL_TYPE;
  </code></pre> 

* [동명 동물 수 찾기 (GROUP BY)](https://programmers.co.kr/learn/courses/30/lessons/59041)
  <pre><code>SELECT NAME, COUNT(NAME) AS COUNT
  FROM ANIMAL_INS
  GROUP BY NAME
  HAVING COUNT(NAME) >= 2
  ORDER BY NAME;
  </code></pre>
  
* [입양 시각 구하기(1) (GROUP BY)](https://programmers.co.kr/learn/courses/30/lessons/59412)
  <pre><code>SELECT HOUR(DATETIME) AS HOUR, COUNT(HOUR(DATETIME)) AS COUNT
  FROM ANIMAL_OUTS
  WHERE HOUR(DATETIME) >= 9 AND HOUR(DATETIME) < 20
  GROUP BY HOUR(DATETIME)
  ORDER BY HOUR(DATETIME);
  </code></pre> 

* [루시와 엘라 찾기 (String, Date)](https://programmers.co.kr/learn/courses/30/lessons/59046)
  <pre><code>SELECT ANIMAL_ID, NAME, SEX_UPON_INTAKE
  FROM ANIMAL_INS
  WHERE NAME in ('Lucy', 'Ella', 'Pickle', 'Rogan', 'Sabrina', 'Mitty') 
  ORDER BY ANIMAL_ID;
  </code></pre> 

* [이름에 el이 들어가는 동물 찾기 (String, Date)](https://programmers.co.kr/learn/courses/30/lessons/59047)
  <pre><code>SELECT ANIMAL_ID, NAME
  FROM ANIMAL_INS
  WHERE NAME LIKE '%EL%' AND ANIMAL_TYPE = 'Dog'
  ORDER BY NAME;
  </code></pre> 
  
* [중성화 여부 파악하기 (String, Date)](https://programmers.co.kr/learn/courses/30/lessons/59409)
  <pre><code>SELECT ANIMAL_ID, NAME,
    CASE 
        WHEN SEX_UPON_INTAKE LIKE "%Neutered%" OR SEX_UPON_INTAKE LIKE "%Spayed%" THEN "O"
        ELSE "X"
    END AS 중성화
  FROM ANIMAL_INS
  ORDER BY ANIMAL_ID;
  </code></pre> 
  
* [DATETIME에서 DATE로 형 변환 (String, Date)](https://programmers.co.kr/learn/courses/30/lessons/59414)
  <pre><code>SELECT ANIMAL_ID, NAME, date_format(DATETIME, '%Y-%m-%d') AS 날짜
  FROM ANIMAL_INS
  ORDER BY ANIMAL_ID;
  </code></pre> 
  
*  [NULL 처리하기 (IS NULL)](https://programmers.co.kr/learn/courses/30/lessons/59410)
  <pre><code>SELECT ANIMAL_TYPE, IFNULL(NAME, "No name"), SEX_UPON_INTAKE
  FROM ANIMAL_INS;
  </code></pre> 
