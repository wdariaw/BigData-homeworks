add jar /opt/cloudera/parcels/CDH/lib/hive/lib/hive-contrib.jar;
add jar /opt/cloudera/parcels/CDH/lib/hive/lib/hive-serde.jar;

SET hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.max.dynamic.partitions=1800;
set hive.exec.max.dynamic.partitions.pernode=200;

USE ovchinnikovada;

DROP TABLE IF EXISTS All_Logs;

CREATE EXTERNAL TABLE All_Logs (
        ip STRING,
        date INT,
        http_query STRING,
        page_size SMALLINT,
        http_status SMALLINT,
        client_info STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
        "input.regex" = '^(\\S*)\\t\\t\\t(\\d{8})\\S*\\t(\\S*)\\t(\\d*)\\t(\\d*)\\t(\\S*).*$'
)
STORED AS TEXTFILE
LOCATION '/data/user_logs/user_logs_M';



DROP TABLE IF EXISTS Logs;

CREATE EXTERNAL TABLE Logs (
        ip STRING,
        http_query STRING,
        page_size SMALLINT,
        http_status SMALLINT,
        client_info STRING
)
PARTITIONED BY (date INT)
STORED AS TEXTFILE;

INSERT OVERWRITE TABLE Logs PARTITION (date)
SELECT ip, http_query, page_size, http_status, client_info, date FROM All_Logs;



DROP TABLE IF EXISTS Users;

CREATE EXTERNAL TABLE Users (
        ip STRING,
        browser STRING,
        sex STRING,
        age TINYINT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
        "input.regex" = '^(\\S*)\\t(\\S*)\\t(\\S*)\\t(\\d*).*$'
)
STORED AS TEXTFILE
LOCATION '/data/user_logs/user_data_M';



DROP TABLE IF EXISTS IPRegions;

CREATE EXTERNAL TABLE IPRegions (
        ip STRING,
        region STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
        "input.regex" = '^(\\S*)\\t(\\S*).*$'
)
STORED AS TEXTFILE
LOCATION '/data/user_logs/ip_data_M';



DROP TABLE IF EXISTS Subnets;

CREATE EXTERNAL TABLE Subnets (
        ip STRING,
        mask STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
        "input.regex" = '^(\\S*)\\t(\\S*).*$'
)
STORED AS TEXTFILE
LOCATION '/data/subnets/variant3';



SELECT * FROM Logs LIMIT 10;
