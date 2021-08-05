## Level3
* [없어진 기록 찾기](https://programmers.co.kr/learn/courses/30/lessons/59042)
  <pre><code>SELECT O.ANIMAL_ID, O.NAME
  FROM ANIMAL_INS AS I 
  RIGHT OUTER JOIN ANIMAL_OUTS AS O
  ON I.ANIMAL_ID = O.ANIMAL_ID
  WHERE I.ANIMAL_ID IS NULL
  ORDER BY I.ANIMAL_ID DESC;
  </code></pre> 
  
* [있었는데요 없었습니다](https://programmers.co.kr/learn/courses/30/lessons/59043)
  <pre><code>SELECT I.ANIMAL_ID, I.NAME
  FROM ANIMAL_INS AS I, ANIMAL_OUTS AS O
  WHERE I.ANIMAL_ID = O.ANIMAL_ID AND O.DATETIME < I.DATETIME
  ORDER BY I.DATETIME ASC;
  </code></pre> 
  
* [오랜 기간 보호한 동물(1)](https://programmers.co.kr/learn/courses/30/lessons/59044)
  <pre><code>SELECT I.NAME, I.DATETIME
  FROM ANIMAL_INS AS I 
  LEFT OUTER JOIN ANIMAL_OUTS AS O
  ON I.ANIMAL_ID = O.ANIMAL_ID
  WHERE O.ANIMAL_ID IS NULL
  ORDER BY I.DATETIME ASC
  LIMIT 3;
  </code></pre> 
  
* [보호소에서 중성화한 동물](https://programmers.co.kr/learn/courses/30/lessons/59045)
  <pre><code>SELECT I.ANIMAL_ID, I.ANIMAL_TYPE, I.NAME
  FROM ANIMAL_INS AS I INNER JOIN ANIMAL_OUTS AS O
  ON I.ANIMAL_ID = O.ANIMAL_ID
  WHERE I.SEX_UPON_INTAKE like "Intact%" and (O.SEX_UPON_OUTCOME like "Spayed%" or O.SEX_UPON_OUTCOME like "Neutered%")
  ORDER BY I.ANIMAL_ID ASC;
  </code></pre> 
  

