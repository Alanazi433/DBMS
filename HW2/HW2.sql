use DB_Assignment2;
 

-- This query retrieves all rows and columns from the chefs table, showing details of each chef,
-- including their ID, name, and specialty.
SELECT *
FROM chefs;


-- This query retrieves all rows and columns from the restaurants table,
-- showing details of each restaurant, including its ID, name, and location.
SELECT *
FROM restaurants;



-- This query retrieves all rows and columns from the works table,
-- showing which chefs work at which restaurants.
SELECT *
FROM works;


-- This query retrieves all rows and columns from the foods table,
-- showing each food item, its type, and its price.
SELECT *
FROM foods;



-- This query retrieves all rows and columns from the serves table,
-- showing which restaurants serve which food items and the date they were sold.
SELECT *
FROM serves;



-- Create Chefs Table
CREATE
TABLE chefs (

	chefID INT PRIMARY KEY,
	name VARCHAR(255),
	specialty VARCHAR(255)
);

-- Create Restaurants Table
CREATE
TABLE restaurants (
	restID INT PRIMARY KEY,
	name VARCHAR(255),
	location VARCHAR(255)
);

-- Create Works Table (relationship between chefs and restaurants)
CREATE
TABLE works (
	chefID INT,
	restID INT,
	PRIMARY KEY (chefID, restID),
	FOREIGN KEY (chefID) REFERENCES chefs(chefID),
	FOREIGN KEY (restID) REFERENCES restaurants(restID)
);

-- Create Foods Table
CREATE
TABLE foods (
	foodID INT PRIMARY KEY,
	name VARCHAR(255),
	type VARCHAR(255),
	price DECIMAL(5,2)
);

-- Create Serves Table (relationship between restaurants and foods)
CREATE
TABLE serves (
	restID INT,
	foodID INT,
	date_sold DATE,
	PRIMARY KEY (restID, foodID, date_sold),
	FOREIGN KEY (restID) REFERENCES restaurants(restID),
	FOREIGN KEY (foodID) REFERENCES foods(foodID)
);
-- Insert data into Chefs Table
INSERT
INTO chefs (chefID, name, specialty) VALUES


-- Insert data into Restaurants Table
INSERT1
INTO restaurants (restID, name, location) VALUES



-- Insert data into Works Table
INSERT
INTO works (chefID, restID) VALUES



-- Insert data into Foods Table
INSERT
INTO foods (foodID, name, type, price) VALUES



-- Insert data into Serves Table
INSERT
INTO serves (restID, foodID, date_sold) VALUES


/*-------------------------------------------------------------------------------------------------
-- Part-TWO
--------------------------------------------------------------------------------------------------*/




-- This Part i counted the average price of food items for each restaurant 
SELECT r.name AS restaurant, AVG(f.price) AS avg_price
FROM restaurants r
JOIN serves s ON r.restID = s.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY r.name;


-- This part is to fine the most expensive food item for each restaurant
SELECT r.name AS restaurant, MAX(f.price) AS max_price
FROM restaurants r
JOIN serves s ON r.restID = s.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY r.name;


-- This query is to count the number food types that served by each restaurant
SELECT r.name AS restaurant, COUNT(DISTINCT f.type) AS food_types_count
FROM restaurants r
JOIN serves s ON r.restID = s.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY r.name;


-- This part ia to finde the average food price for dishes that has been done by each chef
SELECT c.name AS chef, AVG(f.price) AS avg_food_price
FROM chefs c
JOIN works w ON c.chefID = w.chefID
JOIN serves s ON w.restID = s.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY c.name;


-- Here is to finde the restaurant with the highest average food price from highest to lowest 
SELECT r.name AS restaurant, AVG(f.price) AS avg_price
FROM restaurants r
JOIN serves s ON r.restID = s.restID
JOIN foods f ON s.foodID = f.foodID
GROUP BY r.name
ORDER BY avg_price DESC
LIMIT 1;



