## Programmers
> 프로그래머스 SQL 문제 저장소입니다. 

## Contents
* Level2
1. 고양이와 개는 몇 마리 있을까(Group by)
<pre><code>
SELECT ANIMAL_TYPE, COUNT(ANIMAL_TYPE) AS count
FROM ANIMAL_INS
GROUP BY ANIMAL_TYPE
ORDER BY ANIMAL_TYPE;
</code></pre> 
