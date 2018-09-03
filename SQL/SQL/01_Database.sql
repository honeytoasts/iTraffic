/********************
	建立資料庫
********************/

create database $(DBName) on
(
	NAME = $(DBName)_data,
	FILENAME = '$(DirPath)\$(DBName)_data.mdf',
	SIZE = 10,
	FILEGROWTH = 5
)
log on
(
	NAME = $(DBName)_log,
	FILENAME = '$(DirPath)\$(DBName)_log.ldf',
	SIZE = 10,
	FILEGROWTH = 5
)
go
--sp_dboption '$(DBName)', 'select into/bulkcopy', TRUE /*MS Sql Server從2008後就預計移除這個功能，請避免使用
go

/********************
	建立預設的Tables
********************/

use $(DBName)
go

/********************
	Object Tables
	Tables: Entity, Object, ORel
********************/

-- Entity Table
create table Entity
(
	EID smallint identity(1,1) not null,
	CName nvarchar(50) not null,
	EName nvarchar(50) not null,
	bORel bit not null default(1),
	constraint PK_Entity primary key clustered (EID)
)
go

--Object Table
create table Object
(
	OID int identity(1,1) not null,
	Type smallint not null,
	CName nvarchar(255) null,
	CDes nvarchar(800) null,
	EName nvarchar(255) null,
	EDes nvarchar(800) null,
	Since datetime not null default(getdate()),
	LastModifiedDT datetime not null default(getdate()),
	OtherDT datetime not null default(getdate()),
	DataByte binary(1) null,
	OwnerMID int null,
	nClick int not null default(0),
	nOutlinks int null,			-- total citations (outlinks)
	nInlinks int null,			-- total citated counts (inlinks)
	bPublished bit not null default(1),
	constraint PK_Object primary key clustered (OID)
)
create nonclustered index IX_Object_CName on Object(CName asc)
go

--ORel Table
create table ORel
(
	OID1 int not null,
	OID2 int not null,
	Rank int null,
	Des nvarchar(255) null,
	constraint PK_ORel primary key clustered (OID1, OID2),
	constraint FK_ORel_OID1 foreign key(OID1) references Object(OID),
	constraint FK_ORel_OID2 foreign key(OID2) references Object(OID)
)
go

/****************
	Concept Hierarchy Schema
	tables: CLayout, Class, Inheritance, CO
****************/

-- Layout (main frame for page)
create table CLayout
(
	LID int not null identity(1, 1),
	LName nvarchar(255),
	LDes nvarchar(900),
	constraint PK_CLayout primary key clustered (LID)
)

---- Block (javascript template)
--create table CBlock
--(
--	BID int not null identity(1, 1),
--	BName nvarchar(255),
--	constraint PK_CBlock primary key clustered (BID)
--)

---- Data(view by naming policy vd_*)
--create table CData
--(
--	DID int not null identity(1, 1),
--	DName varchar(255),
--	NSpace varchar(20),
--	constraint PK_CData primary key clustered (DID)
--)

-- Class Definition: Directory, Category
create table Class
(
	CID int identity(1,1) not null,
	Type smallint null,
	CName nvarchar(255) null default(''),
	CDes nvarchar(800) null default(''),
	EName nvarchar(255) null default(''),
	EDes nvarchar(800) null default(''),
	IDPath nvarchar(255) null,
	NamePath nvarchar(900) null,
	Since datetime null default(getdate()),
	LastModifiedDT datetime null default(getdate()),
	nObject int not null default(0),
	cRank tinyint null default(0), -- Sorting policy for subdirectories (i.e., Inheritance)
	oRank tinyint null default(0), -- Sorting policy for Objects (i.e., CO)
	nLevel tinyint null,
	Layout int null,
	ImgID smallint not null default(0),
	nClick int not null default(0),
	Keywords nvarchar(255) null default(''),
 	constraint PK_Class primary key clustered (CID),
	constraint UQ_Class_IDPath unique nonclustered (IDPath),
	constraint UQ_Class_NamePath unique nonclustered (NamePath),
	constraint FK_Class_Type foreign key(Type) references Entity(EID),
	constraint FK_Class_Layout foreign key(Layout) references CLayout(LID)
)
go

-- Inheritance (Relationship): Direct subclasses of Class (Class-Class)
-- In default, inheritance is a tree strucuture
create table Inheritance
(
	PCID int not null,
	CCID int not null,
	Rank smallint null,
	MG tinyint null,
	constraint PK_Inheritance primary key clustered (PCID, CCID),
	constraint FK_Inheritance_PCID foreign key(PCID) references Class(CID),
	constraint FK_Inheritance_CCID foreign key(CCID) references Class(CID)
)
go

-- CO (Relationship): Direct child Objects of the Class (Class-Object)
create table CO
(
	CID int not null,
	OID int not null,
	Rank smallint null, -- Object ranks in the Class
	MG tinyint null,  -- Membership Grade for Automatic Classification
	constraint PK_CO primary key clustered (CID, OID),
	constraint FK_CO_CID foreign key(CID) references Class(CID),
	constraint FK_CO_OID foreign key(OID) references Object(OID)
)
go

---- CBMap (Relationship):  Class/Block Mapping
--create table CBMap
--(
--	CID int not null,
--	BID int not null,
--	DID int,
--	--Method varchar(255),
--	LimitNum smallint,	-- default top value
--	Sort nvarchar,			-- default order column
--	SortDesc bit default(0),	-- order desc or not (0: asc, 1: desc)
--	MapKey varchar(80),
--	constraint PK_CBMap primary key clustered(CID, BID),
--	constraint FK_CBMap_CID foreign key(CID) references Class(CID),
--	constraint FK_CBMap_BID foreign key(BID) references CBlock(BID)
--)

/****************
	URI Schema
	tables: StatusCode, URLScheme, ContentType, URL
****************/

create table StatusCode
(
	Status int not null,
	Msg nvarchar(64) null,
	CDes nvarchar(800) null,
	constraint PK_Status primary key clustered (Status)
)
go

-- Url Scheme, e.g. HTTP, HTTPS, FTP
create table URLScheme
(
	SID smallint identity(1,1) not null,
	Scheme nvarchar(10) null,
	CDes nvarchar(255) null,
	constraint PK_URLScheme primary key clustered (SID),
	constraint UQ_URLScheme unique nonclustered ([Scheme])
)
go

create table ContentType
(
	CTID smallint not null identity(1, 1),
	Title varchar(255) not null,
	Des nvarchar(255) null,			-- Unicode (UTF-8) for English or Chinese

	constraint PK_ContentType primary key clustered (CTID),
	constraint UQ_ContentType unique nonclustered (Title),
)
go

create table URL
(
	UID int not null,
	Scheme smallint not null,
	HostName varchar(900) not null,
	Path nvarchar(900) not null default('/'),
	--QueryGet nvarchar(900) null,
	--QueryPost nvarchar(4000) null,
	Title nvarchar(255) null,  -- <title> ... </title>
	Des nvarchar(1024) null,
	Lang tinyint null,
	ContentLen int null,
	Keywords nvarchar(255) null,
	Indexable bit null,	-- 是否適合索引搜尋
	IndexInfo nvarchar(255) null, -- Only index Content Blocks, how to define CB?
	SID int null,				-- FK: StatusCode.SID
	MD5URL binary(16) not null,
	MD5 binary(16) null,
	ContentType smallint null, --FK.ContentType.CTID
	Weight tinyint null,	-- the quality of an URL document
	Crawl tinyint null, -- crawl depth
	ModifyFreq int null,
	OKFreq int null,
	--JID int null,
	constraint PK_URL primary key clustered (UID),
	constraint FK_URL_UID foreign key(UID) references Object(OID),
	constraint FK_URL_Scheme foreign key(Scheme) references URLScheme(SID),
	constraint FK_URL_SID foreign key(SID) references StatusCode(Status),
	constraint UQ_URL_MD5URL unique nonclustered (MD5URL),
	constraint UQ_URL_MD5 unique nonclustered (MD5)
)
go

--Archive Table
create table Archive (
	AID int not null ,
	[FileName] nvarchar (128) not null,
	Keywords nvarchar(255) not null default(''), -- separated by ","
	Lang tinyint null,
	Indexable bit null,
	IndexInfo nvarchar(255) null default(''),
	ContentLen int null ,
	MD5 binary (16) null ,
	ContentType smallint null default(0),

	constraint PK_Archive primary key clustered (AID),
	constraint FK_Archive_AID foreign key (AID) references Object (OID),
	constraint FK_Archive_CTID foreign key (ContentType) references ContentType (CTID)
)
go
create index IX_Archive_MD5 on Archive(MD5)
go

/****************
	User Schema
	tables: Member, Nation, Groups, GM, Permission
****************/

-- Member: Extension table from Object, Detail for member (user) information
create table Member
(
	MID int not null,
	Account nvarchar(30) not null unique,
	PWD nvarchar(40) null,
	Valid bit null, -- 1: pass, 0: freeze, null: non-active
	LastLoginDT datetime null,
	LoginErrCount tinyint not null default(0),
	EMail nvarchar(100) null,
	Status tinyint null,
    Sex bit null,
	LoginCount int not null default(0),
	VerifyCode nvarchar(50) null, -- for registration
	CID int null, -- Personal directory
	Birthday date null,
	Nation tinyint null,
	Address nvarchar(200) null,
	Phone nvarchar(25) null,
	SendEMailOK bit null,
	constraint PK_Member primary key clustered (MID),
	constraint UQ_Member_Name unique nonclustered ([Account]),
	constraint FK_Member_MID foreign key(MID) references Object(OID)
)
go
create nonclustered index IX_Member_Name on Member([Account] asc)
go
alter table dbo.Object WITH CHECK ADD constraint FK_Object_OwnerMID foreign key(OwnerMID) references Member(MID)
go

create table Nation
(
	NID tinyint identity(1,1) not null,
	CountryCode char(2) not null,
	CName nvarchar(255) not null,
	EName nvarchar(255) not null,
	constraint PK_Nation primary key clustered (NID)
)
go
alter table dbo.Member WITH CHECK ADD constraint FK_Member_Nation foreign key(Nation) references Nation(NID)
go

create table Groups
(
	GID int identity(1,1) not null,
	GName nvarchar(40) not null,
	GDes nvarchar(1024) null,
	Status tinyint null,
	Since datetime not null default(getdate()),
	Type tinyint null,
	constraint PK_Groups primary key clustered (GID),
	constraint UQ_Groups unique nonclustered (GName)
)
go

--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0為等待系統管理者審核，1為正常' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Groups', @level2type=N'COLUMN', @level2name=N'Status'
--GO
--EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'0為系統群組，1為使用者自建群組' ,@level0type=N'SCHEMA', @level0name=N'dbo', @level1type=N'TABLE', @level1name=N'Groups', @level2type=N'COLUMN', @level2name=N'Type'
--go

-- GroupMember
create table GM
(
	GID int not null,
	MID int not null,
	Role tinyint not null,  -- Owner, Manager, Member, ...
	Type bit null,
	Status bit null,
	constraint PK_GownUs primary key clustered (GID, MID),
	constraint FK_GM_GID foreign key(GID) references Groups(GID),
	constraint FK_GM_MID foreign key(MID) references Member(MID)
)
go

-- Permission is set on Class (目錄) for Groups or Member
create table Permission
(
	CID int not null,	-- Permission主要設定在Class，但也可以是Object (OID)
	RoleType bit not null,  -- 0: Class, 1: Object
	RoleID int not null,  -- CID or OID
	PermissionBits tinyint not null default(1), -- default View

	constraint UQ_Permission unique nonclustered (CID, RoleType, RoleID)
)
go

/****************
	Log Diary Schema
	tables: UserAgent, MSession, LogDir, LogObject LogMan, LogManTx, LogSearch, LogError
****************/

create table UserAgent
(
	UAID int not null identity(1, 1),
	UAString nvarchar(900) not null unique,
	Since datetime not null default(getdate()),
	primary key(UAID)
)

-- Member Session (MSession): create new session for each connection
-- Log以session為單位：PassportCode in Cookie, map to primary key SID
-- MSession to Log* is: 1-to-N
create table MSession
(
	SID int identity(1,1) not null,
	MID int not null default(0),  -- Guest = 0。不需FK to Object.OID or Member.MID
	IP varchar(16) not null,
	UserAgent int,
	PassportCode nvarchar(32) not null, -- UQ = MD5(MID, IP)
	Since datetime not null default(getdate()),
	LastModifiedDT datetime null default(getdate()),
	ExpiredDT datetime null,
	constraint PK_MSession primary key clustered (SID),
	constraint FK_MSession_UA foreign key(UserAgent) references UserAgent(UAID)
)
go

-- Browse Directories ==> Index.aspx ==> Class (Directories)
create table LogDir
(
	SID int not null, --MSession.SID
	CID int not null, -- 不需FK，因為使用者可能亂產生CID來測試：不存在==>Fail
	Operation bit not null, -- Operation: success or fail
	Sort tinyint null,  -- Use which sorting method
	VisitDate datetime not null default(getdate()),

	--constraint FK_LogDir_SID Foreign key(SID) References MSession(SID),
	constraint PK_LogDir primary key clustered (SID, VisitDate)
)
go

-- Show Objects ==> ShowObject.aspx
create table LogObject
(
	SID int not null,
	OID int not null,
	Operation bit not null, -- Operation: success or fail
	IndexCount int null,
	VisitDate datetime not null default(getdate()),

	--constraint FK_LogObject_SID Foreign key(SID) References MSession(SID),
	constraint PK_LogObject primary key clustered (SID, VisitDate)
)
go

-- Browse with Permission ==> Manage.aspx
create table LogMan
(
	SID int not null, --MSession.SID
	TargetType bit null,  -- Class: 0, Object: 1
	TargetID int null,  -- CID or OID
	Operation bit not null, -- Operation: success or fail
	Sort tinyint null,  --
	IndexCount int null,  -- Page number or Object ranking #
	VisitDate datetime not null default(getdate()),

	--constraint FK_LogMan_SID Foreign key(SID) References MSession(SID),
	constraint PK_LogMan primary key clustered (SID, VisitDate)
)
go

-- All transactions ==> Tx<InserClass>.aspx, ...
create table LogManTx
(
	SID int not null,
	Method bit null,  -- Insert/delete/update = null/0/1
	PostString nvarchar(4000) null, -- 可以記錄，就記錄全部，不行的話，紀錄 <max-20> + MD5(剩下的部分)
	VisitDate datetime not null default(getdate()),
	--constraint FK_LogManTx_SID Foreign key(SID) References MSession(SID),
	constraint PK_LogManTx primary key clustered (SID, VisitDate)
)
go

create table LogSearch
(
	[SID] [int] not null,
	[QueryString] [nvarchar](60) not null,
	[SearchDate] [datetime] not null default (getdate())
)
go

create table LogError
(
	SID int not null,
	ErrCode int null,
	ErrMsg nvarchar(900),
	ThrowDate datetime not null default(getdate()),
	constraint PK_LogError primary key clustered(SID, ThrowDate)
)

/****************
	Other Extension Table Schema
****************/

--Post Table
create Table Post(
	PID int not null,
	Detail nvarchar(max),
	constraint PK_Post primary key clustered (PID),
	constraint FK_Post_PID foreign key (PID) references Object(OID)
)
go

create table EntityM2DC
(
	EID smallint not null,
	Field nvarchar(20) not null,
	DCField smallint not null,
  SNo tinyint default(0) not null,
  JsonField nvarchar(20) not null,
	Caption nvarchar(20),

	constraint PK_EntityM2DC primary key clustered (EID, DCField, SNo, JsonField),
	constraint FK_EntityM2DC_EID foreign key(EID) references Entity(EID)
)
go
