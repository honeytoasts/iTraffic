
create table ObjectExt
(
	OID int not null unique,
	nInlinks int null,
	nOutlinks int null,
	bPublished bit null default(1),
	GroupID int null,
	OtherDT datetime not null default(getdate()),
	primary key(OID),
	foreign key(OID) references Object(OID)
)

create table ClassExt
(
	CID int not null unique,
	cRank tinyint null default(0),
	oRank tinyint null default(0),
	nClickTrue int not null default(0),
	Property smallint not null default(0),
	Code nvarchar(255) null,
	primary key(CID),
	foreign key(CID) references Class(CID)
)

Create nonclustered index IX_Class_CName on Class(CName asc)
go
