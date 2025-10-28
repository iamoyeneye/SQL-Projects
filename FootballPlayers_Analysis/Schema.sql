--Craeting Database
create database footballPlayers

-- creating the year dim table
create table [Year]
(
YearID int identity primary key not null,
[Year] int not null
);

-- creating the team dim table
create table Team 
(
TeamID int identity primary key not null,
TeamName nvarchar(50) not null
);

-- creating the college dim table
create table College 
(
CollegeID int identity primary key not null,
CollegeName nvarchar(50) not null
);

-- creating the player fact table
create table player
(
PlayerID int identity primary key not null,
FirstName nvarchar(50) not null,
LastName nvarchar(50) not null,
Age tinyint not null,
Height decimal(4,1),
[Weight] decimal(5,2),
YrsofExp tinyint,
YearID int foreign key references [Year](YearID) not null, -- this links the player table to the Year table
TeamID int foreign key references Team(TeamID) not null,  -- this links the player table to the Team table
CollegeID int foreign key references College(CollegeID) not null  -- this links the player table to the College table
);

-- adding position column which was omitted at the point of creation
alter table Player
add Position nvarchar(10);

-- alering age column to accept null
alter table Player
alter column Age tinyint;

/*The raw data was first uploaded into a staging area named [dbo].['FootballPlayersData$']
	where few data preprocessing were done*/

-- age = 0 in the staging area is unrealistic, so it is replaced with the average age of the other players 
update [dbo].['FootballPlayersData$']
set Age = cast((select round(AVG(cast(age as float)),0) 
			from [dbo].['FootballPlayersData$'] 
			where age <> 0)
			as tinyint)
where Age = 0

-- For data compatibility, Exp = 'R' in the staging area is replaced with 0 which is a numeric data
update [dbo].['FootballPlayersData$']
set [Exp] = 'R'
where [Exp] = 0

-- Populating the tables

insert into [Year]([Year])
select distinct [Year] 
from [dbo].['FootballPlayersData$'];

insert into Team(TeamName)
select distinct Team 
from [dbo].['FootballPlayersData$'];

insert into College(CollegeName)
select distinct College 
from [dbo].['FootballPlayersData$'];

insert into Player(FirstName, LastName, Age, Height, [Weight], YrsofExp, YearID, TeamID, CollegeID, Position)
select 
f.FirstName, 
f.LastName,
cast(f.Age as tinyint),
cast(f.Inches as decimal(4,1)),
cast(f.Wt as decimal(5,2)),
cast(f.[Exp] as tinyint),
y.yearID,
t.teamID,
c.collegeID,
f.Pos
from [dbo].['FootballPlayersData$'] f
join [Year] y on y.[Year] = f.[year]
join team t on t.TeamName = f.Team
join College c on c.CollegeName = f.College;
