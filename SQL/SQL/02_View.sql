use [$(DBName)]
go

--create View vd_URL
if OBJECT_ID('vd_URL', 'V') IS NOT NULL
	drop view vd_URL
go
create view dbo.vd_URL
as
select	O.OID, O.[Type], O.CName, O.CDes, S.[Scheme],
		U.HostName, U.[Path], U.Title, U.Des as URLDes, C.Title as MIMEType, U.Keywords, U.Lang, U.Indexable, U.IndexInfo,
		O.nClick, O.Since, O.LastModifiedDT
from URL U, Object O, URLScheme S, ContentType C
where O.OID = U.UID and S.SID = U.[Scheme] and C.CTID = U.ContentType
go

--create View vd_Member
if OBJECT_ID('vd_Member', 'V') IS NOT NULL
	drop view vd_Member
go
create view dbo.vd_Member
as
Select O.OID, O.[Type], O.CName, O.EName, M.Account, M.Email, M.Phone, M.Address, M.Birthday, M.Valid, M.LastLoginDT, M.LoginErrCount, O.nClick, O.Since, M.SendEmailok, O.LastModifiedDT
from Object O, Member M
where M.MID = O.OID
go

--create View vd_Archive
if OBJECT_ID('vd_Archive', 'V') IS NOT NULL
	drop view vd_Archive
go
create view dbo.vd_Archive
as
select	O.OID, O.[Type], O.CName, A.[FileName], C.Title as MIMEType, O.nClick,
		A.Keywords, A.Lang, A.Indexable, A.IndexInfo, O.Since, O.LastModifiedDT
from	Archive A, Object O, ContentType C
where	A.AID = O.OID and A.ContentType = C.CTID
go

/***
	vd_SubClass:Default attributes for single layer class inheritance
	author: Wilson
	date: 2014/01/16
***/

if OBJECT_ID('vd_SubClass', 'V') IS NOT NULL
	drop view vd_SubClass
go
create view vd_SubClass
as
select	pc.CID 'cid', pc.CName 'pcname', cc.CID 'ccid', cc.CName 'ccname',
		cc.Type 'type', i.Rank 'rank'
from	Class pc, Inheritance i, Class cc
where	pc.CID = i.PCID and i.CCID = cc.CID
go

/***
	vd_ObjectList:Default attributes for sigle layer class-object
	author: Wilson
	date: 2014/01/16
***/

if OBJECT_ID('vd_ObjectList', 'V') IS NOT NULL
	drop view vd_ObjectList
go
create view vd_ObjectList
as
select c.CID 'cid', c.CName 'cname', o.OID 'oid', o.CName 'oname'
	, o.Type 'type', r.Rank 'rank'
from Class c, CO r, Object o
where c.CID = r.CID and r.OID = o.OID
go

/***
	vd_ShowObject:Default attributes for object view
	author: Wilson
	date: 2014/01/16
***/

if OBJECT_ID('vd_ShowObject', 'V') IS NOT NULL
	drop view vd_ShowObject
go
create view vd_ShowObject
as
select OID 'oid', Type 'type', CName 'cname', CDes 'cdes', Since 'since'
from Object
go

/***
	vd_ShowObjectRel:Default attributes for single layer object-object relationship
	author: Wilson
	date: 2014/01/16
***/

if OBJECT_ID('vd_ShowObjectRel', 'V') IS NOT NULL
	drop view vd_ShowObjectRel
go
create view vd_ShowObjectRel
as
select o1.OID 'oid', o1.CName 'cname', o2.OID 'oid2', o2.CName 'cname2'
	, r.Rank, r.Des
from Object o1, ORel r, Object o2
where o1.OID = r.OID1 and r.OID2 = o2.OID
