

 /*
 Query 1: Over how many years was the unemployment data collected?
 */
 db.unemployment.distinct("Year").length;

/*
Query 2: How many states were reported on in this dataset?
*/
db.unemployment.distinct("State").length;

/*
Query 3: Count the number of records with unemployment rates below 1.0.
*/
db.unemployment.find({ Rate: { $lt: 1.0 } }).count();

/*
Query 4: Find all counties with an unemployment rate higher than 10%.
*/
db.unemployment.find({ Rate: { $gt: 10.0 } });

/*
Query 5: Calculate the average unemployment rate across all states.
*/
db.unemployment.aggregate([
    { $group: { _id: null, averageRate: { $avg: "$Rate" } } }
]);

/*
Query 6: Find all counties with unemployment rates between 5% and 8%.
*/
db.unemployment.find({ Rate: { $gte: 5.0, $lte: 8.0 } });

/*
Query 7: Find the state with the highest unemployment rate.
*/
db.unemployment.aggregate([
    { $sort: { Rate: -1 } },
    { $limit: 1 }
]);

/*
Query 8: Count how many counties have an unemployment rate above 5%.
*/
db.unemployment.aggregate([
    { $match: { Rate: { $gt: 5.0 } } },
    { $count: "totalCount" }
]);

/*
Query 9: Calculate the average unemployment rate per state by year.
*/
db.unemployment.aggregate([
    { $group: { _id: { State: "$State", Year: "$Year" }, averageRate: { $avg: "$Rate" } } }
]);

/*
Query 10: Calculate the total unemployment rate across all counties per state.
*/
db.unemployment.aggregate([
    { $group: { _id: "$State", totalRate: { $sum: "$Rate" } } }
]);

/*
Query 11: Calculate the total unemployment rate across counties for states with data from 2015 onward.
*/
db.unemployment.aggregate([
    { $match: { Year: { $gte: 2015 } } },
    { $group: { _id: "$State", totalRate: { $sum: "$Rate" } } }
]);
