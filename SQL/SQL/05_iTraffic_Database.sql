use [$(DBName)]
go

-- 補充 I3S 欄位
alter table Class add bPublished bit not null default(1)
alter table CO add Since datetime not null default(getdate())


/****************
	iTraffic Schema
	tables: Stop, SP, Transportation, ST, TS, MemberExt, Block, BO, BC, (Route)
****************/


create table Stop
(
	SID int not null,
	StopID nvarchar(255) not null,
	Longitude decimal(9,6) null, --經度
	Latitude decimal(8,6) null,  --緯度
	Phone nvarchar(255) null,
	Address nvarchar(500) null,
	constraint PK_Stop primary key clustered (SID),
	constraint FK_Stop_SID foreign key(SID) references Object(OID)
)

create table SP
(
	SID1 int not null,
	SID2 int not null,
	Type1 nvarchar(255) not null default(''),
	Type2 nvarchar(255) not null default(''),
	Price smallint not null,
	Note nvarchar(255) null,
	LastModifiedDT datetime null default(getdate()),
	constraint PK_SP primary key clustered (SID1, SID2, Type1, Type2),
	constraint FK_SP_SID1 foreign key(SID1) references Stop(SID),
	constraint FK_SP_SID2 foreign key(SID2) references Stop(SID)
)

create table Transportation
(
	TID int not null,
	Number nvarchar(255) not null, --台高鐵:車次，公車/客運:ID
	StartStop int null, --起站
	EndStop int null,   --迄站
	Direction bit null, -- 0順去、1逆返
	PassRank int null,
	DelayTime int null,
	MD5 nvarchar(32) null, -- 將班次詳細資訊做MD5 Hash，判斷是否更新
	constraint PK_Transportation primary key clustered (TID),
	constraint FK_Transportation_StartStop foreign key(StartStop) references Stop(SID),
	constraint FK_Transportation_EndStop foreign key(EndStop) references Stop(SID),
	constraint FK_Transportation_TID foreign key(TID) references Object(OID)
)

create table ST
(
	SID int not null,
	TID int not null,
	Rank smallint not null,
	Departure time(0) null,
	constraint PK_ST primary key clustered (SID, TID),
	constraint FK_ST_SID foreign key(SID) references Stop(SID), 
	constraint FK_ST_TID foreign key(TID) references Transportation(TID)
)

create table TS
(
	TID int not null,
	SID int not null,
	Rank smallint not null,
	Arrive time(0) null,
	constraint PK_TS primary key clustered (TID, SID),
	constraint FK_TS_TID foreign key(TID) references Transportation(TID), 
	constraint FK_TS_SID foreign key(SID) references Stop(SID)
)

create table Chatbot
(
  FBID nvarchar(255) not null,
  Type nvarchar(255) null default('台鐵'),
  FromStop int null,
  ToStop int null,
  Dates nvarchar(255) null,
  Times nvarchar(255) null,
  Number int null default(1),
  Response nvarchar(1000) null
)

create table Block
(
	BID int not null,
	-- 預設值為0，指此Block內，有什麼類型的點
	-- N/A | 景點 | 餐廳 | 公車 | 客運 | 捷運 | 台鐵 | 高鐵
	--  7     6      5      4     3      2     1      0
	Type binary(1) null default(0),
	-- 以九宮格範圍(level = 2)內的站點來做權重計算
	-- 台、高鐵100，捷運50，客運5，公車1
	Weight int null,
	constraint PK_Block primary key clustered (BID)
)

create table Keyblock
(
	BID int not null,
	constraint FK_Keyblock_BID foreign key(BID) references Block(BID)
)

create table BO
(
	BID int not null,
	OID int not null,
	-- 預設值為0，指此Object為什麼類型的點
	-- N/A | 景點 | 餐廳 | 公車 | 客運 | 捷運 | 台鐵 | 高鐵
	--  7     6      5      4     3      2     1      0
	Type binary(1) null default(0),
	Longitude decimal(9,6) null,
	Latitude decimal(8,6) null,
	constraint PK_BO primary key clustered (BID, OID),
	constraint FK_BO_BID foreign key(BID) references Block(BID),
	constraint FK_BO_OID foreign key(OID) references Object(OID)
)

create table BC
(
	BID int not null,
	CID int not null,
	-- 預設值為0，指此Class(站位)為什麼類型的站牌
	-- N/A | N/A | N/A | 公車 | 客運 | 捷運 | 台鐵 | 高鐵
	--  7     6     5     4      3      2     1      0
	Type binary(1) null default(0),
	Longitude decimal(9,6) null,
	Latitude decimal(8,6) null,
	constraint PK_BC primary key clustered (BID, CID),
	constraint FK_BC_BID foreign key(BID) references Block(BID),
	constraint FK_BC_CID foreign key(CID) references Class(CID)
)

create table DataVersion
(
	Name nvarchar(255) not null,
	VersionID int not null default(0),
	Since datetime null default(getdate())
)

-- 記錄台灣各鄉鎮市區，挑選Keyblock用
create table City
(
	City nvarchar(255) not null,
	County nvarchar(255) not null
)

go