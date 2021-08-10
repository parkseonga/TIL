## Leetcode
> Leetcode SQL 문제 저장소입니다. 

## Easy
* [combine-two-tables](https://leetcode.com/problems/combine-two-tables/)
<pre><code>SELECT P.FirstName, P.LastName, A.City, A.State 
FROM Person as P LEFT JOIN Address as A
ON P.PersonId = A.PersonId;</code></pre>
  
* [second-highest-salary](https://leetcode.com/problems/second-highest-salary/)
<pre><code>SELECT MAX(Salary) AS SecondHighestSalary 
FROM Employee
WHERE Salary < (Select MAX(Salary) FROM Employee);
</code></pre> 

* [employees-earning-more-than-their-managers](https://leetcode.com/problems/employees-earning-more-than-their-managers/)
<pre><code>SELECT E1.Name AS Employee
FROM Employee AS E1, Employee AS E2
WHERE E1.Salary > E2.Salary AND E1.ManagerId = E2.Id;
</code></pre> 

* [duplicate-emails](https://leetcode.com/problems/duplicate-emails/)
<pre><code>SELECT Email
FROM Person
GROUP BY Email
HAVING COUNT(Email) >= 2;
</code></pre> 
* [customers-who-never-order](https://leetcode.com/problems/customers-who-never-order/)
<pre><code>SELECT C.Name as Customers
FROM Customers as c left join Orders as o
ON c.Id = o.CustomerId
where o.CustomerId is null;
</code></pre> 
