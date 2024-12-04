-- Create the database and use it
CREATE DATABASE IF NOT EXISTS DB_Assignment6;
USE DB_Assignment6;

-- Create the accounts table procedure
DELIMITER $$

CREATE PROCEDURE generate_accounts()
BEGIN
    CREATE TABLE IF NOT EXISTS accounts (
        account_num INT PRIMARY KEY AUTO_INCREMENT, -- Unique account number
        branch_name VARCHAR(50), -- Branch name
        balance DECIMAL(10, 2), -- Account balance
        account_type ENUM('Checking', 'Savings') -- Account type
    );
END $$

DELIMITER ;

-- Call the procedure to create the accounts table
CALL generate_accounts();

-- Procedure to populate the accounts table with random data
DELIMITER $$

DROP PROCEDURE IF EXISTS populate_accounts $$

CREATE PROCEDURE populate_accounts(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < num_records DO
        INSERT INTO accounts (branch_name, balance, account_type)
        VALUES (
            CASE
                WHEN RAND() < 0.2 THEN 'Downtown'
                WHEN RAND() < 0.4 THEN 'Uptown'
                WHEN RAND() < 0.6 THEN 'Suburb'
                WHEN RAND() < 0.8 THEN 'Eastside'
                ELSE 'Westside'
            END,
            ROUND(RAND() * 100000, 2), -- Random balance between 0 and 100,000
            CASE WHEN RAND() < 0.5 THEN 'Checking' ELSE 'Savings' END -- Random account type
        );
        SET i = i + 1;
    END WHILE;
END $$

DELIMITER ;

-- Populate the accounts table with initial data
CALL populate_accounts(50000);

-- Extend timeout settings to handle large inserts
SET GLOBAL net_write_timeout = 600;
SET GLOBAL wait_timeout = 600;

-- Add more data to the accounts table
CALL populate_accounts(10000);
CALL populate_accounts(10000);
CALL populate_accounts(10000);
CALL populate_accounts(10000);
CALL populate_accounts(10000);

-- Verify the data population
CALL populate_accounts(5);
SELECT COUNT(*) FROM accounts;
SELECT * FROM accounts LIMIT 10;

-- Display current indexes
SHOW INDEX FROM accounts;

-- Create indexes to optimize query performance
DELIMITER $$

CREATE PROCEDURE create_indexes()
BEGIN
    -- Create index on branch_name
    CREATE INDEX idx_branch_name ON accounts(branch_name);

    -- Create index on account_type
    CREATE INDEX idx_account_type ON accounts(account_type);

    -- Create index on balance
    CREATE INDEX idx_balance ON accounts(balance);
END $$

DELIMITER ;

-- Call the procedure to create indexes
CALL create_indexes();

-- Procedure to measure query execution time
DELIMITER $$

CREATE PROCEDURE measure_query_time(IN query_text TEXT)
BEGIN
    DECLARE start_time DATETIME(6);
    DECLARE end_time DATETIME(6);
    DECLARE total_time INT DEFAULT 0;
    DECLARE i INT DEFAULT 0;

    WHILE i < 10 DO
        SET start_time = CURRENT_TIMESTAMP(6); -- Record start time
        SET @stmt_query = query_text; -- Assign the query text to @stmt_query
        PREPARE stmt FROM @stmt_query; -- Prepare the statement
        EXECUTE stmt; -- Execute the statement
        DEALLOCATE PREPARE stmt; -- Deallocate the prepared statement
        SET end_time = CURRENT_TIMESTAMP(6); -- Record end time
        SET total_time = total_time + TIMESTAMPDIFF(MICROSECOND, start_time, end_time); -- Calculate time taken
        SET i = i + 1;
    END WHILE;

    -- Output average execution time
    SELECT total_time / 10 AS avg_time_microseconds;
END $$

DELIMITER ;

-- Measure query execution time for point and range queries
CALL measure_query_time('SELECT count(*) FROM accounts WHERE branch_name = "Downtown" AND balance = 50000');
CALL measure_query_time('SELECT count(*) FROM accounts WHERE branch_name = "Downtown" AND balance BETWEEN 10000 AND 50000');
