ADD JAR /opt/cloudera/parcels/CDH/lib/hive/lib/hive-contrib.jar;
USE ovchinnikovada;

SELECT Logs.http_status,
    SUM(IF(Users.sex='male', 1, 0)) AS males,
    SUM(IF(Users.sex='female', 1, 0)) AS females
FROM Logs
JOIN Users ON Logs.ip = Users.ip
GROUP BY Logs.http_status;
