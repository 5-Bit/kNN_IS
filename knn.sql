Drop table IF EXISTS iris_train;
Drop table IF EXISTS iris_test;
Drop table IF EXISTS iris_id_dist;
Drop table IF EXISTS iris_test_id;
Drop table if EXISTS confusion;

CREATE TABLE iris_train (
	SepalLength double,
	SepalWidth double,
	PetalLength double,
	PetalWidth double, 
	Class string)
USING csv
OPTIONS (path "/home/sparky/iris/iris_train.csv", header "false", inferSchema "false");


CREATE TABLE iris_test (
	-- id int,
	SepalLength double,
	SepalWidth double,
	PetalLength double,
	PetalWidth double, 
	Class string)
USING csv
OPTIONS (path "/home/sparky/iris/iris_test.csv", header "false", inferSchema "false");

-- So now we need to figure out how we calculate stuff here, naively
CREATE TABLE iris_test_id (
	id int,
	SepalLength double,
	SepalWidth double,
	PetalLength double,
	PetalWidth double, 
	Class string);
Insert into iris_test_id
Select 
	ROW_NUMBER() OVER(Order by PetalWidth) as id,
	SepalLength, 
	SepalWidth,
	PetalLength,
	PetalWidth, 
	Class string
from iris_test;

Create Table iris_id_dist (
	id int,
	dist double,
	class string,
	actual_class string
);

Insert into iris_id_dist
Select 
	test.id as id, 
	SQRT(
		POW((test.SepalLength - train.SepalLength ), 2) +
		POW((test.SepalWidth - train.SepalWidth ), 2) +
		POW((test.PetalLength - train.PetalLength ), 2) +
		POW((test.PetalWidth - train.PetalWidth ), 2)
	) as distance,
	train.class,
	test.class
from iris_test_id as test
cross join iris_train train;

Create table confusion (
	id int,
	actual_class string,
	class string
);

insert into confusion
Select id, actual_class, class as predictedClass from (
	Select 
	id, 
	actual_class, 
	class, 
	ROW_NUMBER() OVER (Partition by id order by votes desc) as vote_rank
	from (
		Select  
		id, 
		actual_class, 
		class, 
		Count(*) as votes
		from (
			Select 
				iris_id_dist.*,
				ROW_NUMBER() OVER (Partition by id Order By iris_id_dist.dist asc ) as dist_class
			from iris_id_dist
		) top_n
		where top_n.dist_class <= 5
		group by id, class, actual_class
	) as ranked
) as topped
where topped.vote_rank = 1
order by id asc ;

Select * from confusion;

Select 
(COUNT (
	case 
		when actual_class = class then 1
		else null
	end 
) / COUNT(*)) as accurarcy, 
(COUNT (
	case 
		when actual_class <> class then 1
		else null
	end 
) / COUNT(*)) as inaccuarcy
from confusion;

