DROP TABLE IF EXISTS Test;

CREATE TABLE iris (SepalLength double, SepalWidth double, PetalLength double, PetalWidth double, Class string)
USING csv
OPTIONS (path "/home/sparky/iris/iris.csv", header "false", inferSchema "false");
