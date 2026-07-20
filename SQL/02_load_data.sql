SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE "<update_with_your_local_path>/Train_Inpatientdata.csv"
INTO TABLE stg_ip
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE "<update_with_your_local_path>/Train_Outpatientdata.csv"
INTO TABLE stg_op 
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE "<update_with_your_local_path>/Train_Provider.csv"
INTO TABLE stg_provider
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;