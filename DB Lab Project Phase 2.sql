use master
drop database WayneDB
create database WayneDB
go
use WayneDB

drop table [User]
drop table [Movie]
drop table [UserRating]
drop table [UserReview]
drop table [UserFeedback]
drop table [Watched_List]

--RELATIONS(TABLES) ================================================
create table [User](
[userID]	int primary key identity (1, 1),
[userName]	varchar(20) not null,
[email]		varchar(50) not null unique CHECK(email LIKE '%.com'),
[DOB]		date not null CHECK(DOB < getDate()),
[password]	varchar(50) not null CHECK(LEN([password])>=8),
[isAdmin]	int not null CHECK (isAdmin <= 1 AND isAdmin >= 0) 
)

go

create table [Movie](
[movieID]		int primary key identity(1,1),
[movieName]		varchar(50) not null unique,
[rating]		float CHECK (rating >= 0 AND rating <=10),
[description]	varchar(5000),
[releaseDate]	Date,
[trailerLink]   varchar(1000),
[posterLink]    varchar (1000)
)

go

create table [Watched_List](
[userID]		int foreign key references [User](userID),
[movieID]		int foreign key references Movie(movieID),
primary key(userID, movieID)
)

go

create table [UserRating](
[userID]		int foreign key references [User](userID),
[movieID]		int foreign key references Movie(movieID),
[userRating]	int CHECK (userRating >= 0 AND userRating <=10),
primary key(userID, movieID)
)

go

create table [UserReview](
[userID]		int foreign key references [User](userID),
[movieID]		int foreign key references Movie(movieID),
[review]		varchar(1000)
primary key(userID, movieID)
)

go

create table [UserFeedback](
[userID]		int foreign key references [User](userID),
[Feedback]		varchar(1000)
)
go


select * from [User]
--PROCEDURES ==============================================

--drop procedure UserSignupProc

--Procedure 1
create procedure UserSignupProc 
@userName varchar(20), 
@email varchar(50), 
@DOB Date, 
@password varchar(50), 
@isAdmin char, 
@output int OUTPUT
As
Begin

	if exists (select * From [User] where userName=@userName)
	Begin
	set @output=0 --user id is not unique
	return
	End

    Insert into [User] (userName, email, DOB, [password], isAdmin) values (@userName, @email, @DOB, @password, @isAdmin)
	set @output=1 --signup successful

End
go


--Procedure 2
create Procedure UserLoginProc 
@email varchar(50), 
@password varchar(50), 
@output int OUTPUT,
@out_userName varchar(20) OUTPUT,
@out_userID int OUTPUT,
@out_password varchar(50) OUTPUT,
@out_email varchar(50) OUTPUT,
@out_isAdmin int OUTPUT
As
Begin
	if  not exists (select * From [User] where email=@email AND [password]=@password)
	Begin
	set @output=0 --user id and password combination incorrect
	return
	End

	set @output=1 --login successful
	select @out_userName = userName, 
		   @out_userID = userID,
		   @out_password = [password],
		   @out_email = [email],
		   @out_isAdmin = isAdmin from [User] 
		   where email=@email AND [password]=@password
End
go

--Procedure 3
create procedure AddMovieToWatchlist 
@userID int, 
@movieID int, 
@output int OUTPUT
As
Begin

	if exists (select * From [Watched_List] where userID=@userID AND movieID = @movieID)
	Begin
		set @output=0 --Already in watch list
	return
	End

    Insert into [Watched_List] values (@userID, @movieID)
	set @output=1 

End
go


--Procedure 4
create procedure DeleteMovieFromWatchlist 
@userID int, 
@movieID int, 
@output int OUTPUT
As
Begin

	if exists (select * From [Watched_List] where userID=@userID AND movieID = @movieID)
	Begin
	delete from [Watched_List] where userID=@userID AND movieID = @movieID
	set @output=1 --Already in watch list
	return
	End

	set @output=0 --delete successful

End
go


--Procedure 5
create procedure AddMovieToDB 
@movieName varchar(50), 
@rating float, 
@description varchar(5000), 
@releaseDate Date,
@trailerLink varchar(1000),
@posterLink  varchar(1000),
@output int OUTPUT
As
Begin

	if exists (select * From [Movie] where movieName = @movieName)
	Begin
	set @output=0 --Already in DB
	return
	End

    Insert into [Movie] values (@movieName, @rating, @description, @releaseDate, @trailerLink, @posterLink)
	set @output=1 --Added successfully

End
go


--Procedure 6
create procedure SearchMovie 
@inp_mov_name varchar(50), 
@movieID int OUTPUT,
@movieName varchar(50) OUTPUT, 
@rating float OUTPUT, 
@description varchar(5000) OUTPUT, 
@releaseDate Date OUTPUT, 
@posterLink varchar(1000) OUTPUT,
@trailerLink varchar(1000) OUTPUT,
@output int OUTPUT
As
Begin
	if exists (select * From [Movie] where movieName LIKE @inp_mov_name)
	Begin
		select @movieID = movieID,
			   @movieName = movieName,
			   @description = [description],
			   @rating = rating,
			   @releaseDate = releaseDate,
			   @posterLink = posterLink,
			   @trailerLink = trailerLink
		from [Movie] 
		where movieName LIKE @inp_mov_name
	
		set @output=1 --Already in watch list
	return
	End

	set @output=0 --signup successful

End
go


--Procedure 7
alter procedure AddUserRating
@userID int,
@movieID int, 
@rating int,
@output int OUTPUT
As
Begin
	set @output = 0
	if exists (select * From [UserRating] where userID=@userID AND movieID = @movieID)
	Begin
		UPDATE [UserRating] 
		SET userRating = @rating
		WHERE userID = @userID AND movieID = @movieID
		set @output=1 
	return
	End

    Insert into [UserRating] values (@userID, @movieID, @rating)
	set @output=2

End
go


--Procedure 8
create procedure AddUserFeedback
@userID int,
@feedback varchar(1000)
As
Begin
	if exists (select * From [User] where userID=@userID)
	Begin
	 Insert into [UserFeedback] values (@userID, @feedback)
	End
End
go


--Procedure 9 
create procedure UpdateUserName
@userID int,
@userName varchar(20),
@output int OUTPUT
As
Begin
	set @output = 0
	if exists (select * From [User] where userID=@userID)
	Begin
	 Update [User] 
	 set userName = @userName
	 where userID = @userID
	 set @output = 1
	End
End 
go

--Procedure 10
create procedure UpdateUserPassword
@userID int,
@password varchar(50),
@output int OUTPUT
As
Begin
	set @output = 0
	if exists (select * From [User] where userID=@userID)
	Begin
	 Update [User] 
	 set [password] = @password
	 where userID = @userID
	 set @output = 1
	End
End 
go

--Procedure 11
CREATE TRIGGER CalcMovieRating
ON UserRating
AFTER INSERT, UPDATE 
AS
	DECLARE @m_rating INT;
	SET @m_rating = (SELECT AVG(userRating) from UserRating WHERE movieID = (SELECT movieID FROM inserted)
					GROUP BY movieID)
	UPDATE Movie
	SET rating = @m_rating 
	WHERE movieID = (SELECT movieID FROM inserted)



select * from [User]
select * from [Movie]
select * from Watched_List
select * from UserFeedback

DELETE FROM [User]
DELETE FROM [Movie]
DELETE FROM Watched_List
DELETE FROM UserFeedback

insert into [User] values ('admin', 'admin@gmail.com', '12-12-1990','admin123', 1)

Insert into Movie values ('Jack Reacher', 7.1, 'One morning in an ordinary town, five people are shot dead in a seemingly random attack. All evidence points to a single suspect: an ex-military sniper who is quickly brought into custody. The man''s interrogation yields one statement: Get Jack Reacher (Tom Cruise). Reacher, an enigmatic ex-Army investigator, believes the authorities have the right man but agrees to help the sniper''s defense attorney (Rosamund Pike). However, the more Reacher delves into the case, the less clear-cut it appears.', '12-21-2012', 'https://www.youtube.com/embed/aRwrdbcAh2s' ,'https://i.imgur.com/vvAG4Sf.jpg')
Insert into Movie values ('John Wick', 8.3, 'Legendary assassin John Wick (Keanu Reeves) retired from his violent career after marrying the love of his life. Her sudden death leaves John in deep mourning. When sadistic mobster Iosef Tarasov (Alfie Allen) and his thugs steal Johns prized car and kill the puppy that was a last gift from his wife, John unleashes the remorseless killing machine within and seeks vengeance. Meanwhile, Iosef''s father (Michael Nyqvist)  John''s former colleague -- puts a huge bounty on John''s head.', '05-15-2014', 'https://www.youtube.com/embed/2AUmvWm5ZDQ', 'https://i.imgur.com/MbDPgnR.jpg')
Insert into Movie values ('Shawshank Redemption', 9.3, 'Andy Dufresne (Tim Robbins) is sentenced to two consecutive life terms in prison for the murders of his wife and her lover and is sentenced to a tough prison. However, only Andy knows he didn''t commit the crimes. While there, he forms a friendship with Red (Morgan Freeman), experiences brutality of prison life, adapts, helps the warden, etc., all in 19 years.'  ,'10-14-1994', 'https://www.youtube.com/embed/6hB3S9bIaco','https://i.imgur.com/8QExiCx.jpg')
