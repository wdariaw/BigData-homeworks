ADD JAR /opt/cloudera/parcels/CDH/lib/hive/lib/hive-contrib.jar;
USE ovchinnikovada;

SELECT client_info, COUNT(ip) AS visits
FROM Logs
GROUP BY client_info
ORDER BY visits DESC;
