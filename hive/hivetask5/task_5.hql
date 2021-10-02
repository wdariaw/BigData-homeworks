ADD JAR /opt/cloudera/parcels/CDH/lib/hive/lib/hive-contrib.jar;
ADD FILE task5.sh;

USE ovchinnikovada;

SELECT TRANSFORM(ip, date, http_query, page_size, http_status, client_info)
USING 'task5.sh' AS ip, date, http_query, page_size, http_status, client_info
FROM Logs
LIMIT 10;
