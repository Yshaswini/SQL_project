-- creating the database 
create database icc_cricket ;

-- using the icc_cricket db for further operations
use icc_cricket ;

-- creating the table to store the data
create table icc_cricket(
	Player char(35),
    Span varchar(10),
    Mat integer,
    Inn varchar(3), 
    NO varchar(3),
    Runs varchar(5),
    HS varchar(5),
    Avg varchar(5),
    Century varchar(3),
    Half_century varchar(3), 
    Zero varchar(3),
    Player_Profile char(60) 
) ;  

-- 1.	Import the csv file to a table in the database.
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ICC Test Batting Figures (1).csv'
INTO TABLE icc_cricket
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verifying the number of records in the table
Select * from icc_cricket ;   #it has 3001 records

-- 2.	Remove the column 'Player Profile' from the table.
Alter table icc_cricket drop column Player_Profile ; 
Select * from icc_cricket ; 

-- 3.	Extract the country name and player names from the given data and store it in separate columns for further usage.
ALTER TABLE icc_cricket
ADD COLUMN country_name VARCHAR(20),
ADD COLUMN player_name VARCHAR(30);

#extracting country_name and player_name from Player column
UPDATE icc_cricket
	SET 
    country_name = substring_index(Player, '(' , -1),
    player_name = substring_index(Player, '(' , 1) ;

#formatting country_name column
UPDATE icc_cricket
SET 
country_name = TRIM(TRAILING ')' FROM country_name) ; 

Select * from icc_cricket ; 

-- 4.	From the column 'Span' extract the start_year and end_year and store them in separate columns for further usage.
ALTER TABLE icc_cricket
ADD COLUMN Start_year int,
ADD COLUMN End_year int ; 

UPDATE icc_cricket
	SET
		Start_year = substring_index(SPAN, '-', 1),
        End_year = substring_index(Span, '-', -1) ; 

Select * from icc_cricket ; 

-- 5.	The column 'HS' has the highest score scored by the player so far in any given match. The column also has details if the player 
-- had completed the match in a NOT OUT status. Extract the data and store the highest runs and the NOT OUT status in different columns.
Alter table icc_cricket
	ADD column Highest_score INT, 
	ADD column Not_Out_Status Bool ;   

UPDATE icc_cricket
	SET
    Highest_score = CASE
		when HS = '-' then NULL
        else CAST(Substring_index(HS,'*',1) as UNSIGNED) 
        END,
    Not_Out_Status = IF(RIGHT(HS, 1) = '*', 1, 0); 

Select * from icc_cricket ;
    
-- 6.	Using the data given, considering the players who were active in the year of 2019, create a set of batting order of 
-- best 6 players using the selection criteria of those who have a good average score across all matches for India.
Select * from (
	Select Player_name, CAST(Avg AS DECIMAL(5,2)) AS Average_score
    from icc_cricket where End_year>= 2019
	and country_name = 'INDIA' 
	order by Average_score DESC limit 6
    ) Batting_order_6GoodAvg_IND ;

-- 7.	Using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players 
-- using the selection criteria of those who have the highest number of 100s across all matches for India.    
Select * from (
	Select Player_name, CAST(Century AS UNSIGNED) AS Number_of_100s 
    from icc_cricket where End_year>= 2019
	and country_name = 'INDIA' 
	order by Number_of_100s DESC limit 6
    ) Batting_order_6High_100s_IND ;

-- 8.	Using the data given, considering the players who were active in the year of 2019, create a set of batting order of best 6 players 
-- using 2 selection criteria of your own for India.
Select * from (
	Select Player_name, CAST(Runs AS UNSIGNED) AS Runs, CAST(Century AS UNSIGNED) AS Centuries
		from icc_cricket where End_year>= 2019
		and country_name = 'INDIA' 
		order by Runs DESC ,Centuries DESC
        limit 6
    ) Batting_order_6Top_IND ;
    

-- 9.	Create a View named ‘Batting_Order_GoodAvgScorers_SA’ using the data given, considering the players who were active in the 
-- year of 2019, create a set of batting order of best 6 players using the selection criteria of those who have a good average score 
-- across all matches for South Africa.
Create VIEW Batting_Order_GoodAvgScorers_SA
as
(
	Select Player_name, CAST(Avg as FLOAT) as Avg_score
    from icc_cricket
    where End_year>= 2019 and Country_name = 'SA'
    order by Avg_score DESC
    LIMIT 6 ) ; 

Select * from Batting_Order_GoodAvgScorers_SA ; 

-- 10.	Create a View named ‘Batting_Order_HighestCenturyScorers_SA’ Using the data given, considering the players who were active 
-- in the year of 2019, create a set of batting order of best 6 players using the selection criteria of those who have highest number 
-- of 100s across all matches for South Africa.
Create VIEW Batting_Order_HighestCenturyScorers_SA
as (
	Select Player_name, CAST(Century as UNSIGNED) As Number_of_100s
    from icc_cricket
    where End_year >= 2019 and Country_name = 'SA'
    order by Number_of_100s DESC
    Limit 6 ) ; 

Select * from Batting_Order_HighestCenturyScorers_SA ;

-- 11.	Using the data given, Give the number of player_played for each country.
Select country_name, count(*) as number_of_players
	from icc_cricket
    group by country_name 
    order by number_of_players DESC ; 
     
-- 12.	Using the data given, Give the number of player_played for Asian and Non-Asian continent
Select 
	CASE
	when Country_name in ('INDIA','SL','PAK','BDESH','AFG')  then 'Asian'
	   Else 'Non-Asian'
    end as Continent,
    count(*) as Numer_of_players
    from icc_cricket
    group by Continent ;
 
