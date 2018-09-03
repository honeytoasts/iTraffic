use [$(DBName)]
go

/***
	View
***/

--vd_StopListZh(2018/07/21 完成)
if OBJECT_ID('vd_StopListZh', 'V') IS NOT NULL
	drop view vd_StopListZh
go
create view dbo.vd_StopListZh
as
select C.CName "type",
       S.StopID "stopID",
       O.CName "stop", 
       S.Longitude "longitude",
       S.Latitude "latitude", 
			 S.Phone "phone",
       S.Address "address"
from Class C, CO, Object O, Stop S
where C.CID = CO.CID and CO.OID = O.OID and O.OID = S.SID
go

--vd_StopListEn(2018/07/21 完成)
if OBJECT_ID('vd_StopListEn', 'V') IS NOT NULL
	drop view vd_StopListEn
go
create view dbo.vd_StopListEn
as
select C.EName "type",
       S.StopID "stopID", 
       O.EName "stop",
       S.Longitude "longitude",
       S.Latitude "latitude", 
			 S.Phone "phone",
       S.Address "address"
from Class C, CO, Object O, Stop S
where C.CID = CO.CID and CO.OID = O.OID and O.OID = S.SID
go

--vd_TrainDetailZh(2018/07/21 完成)
if OBJECT_ID('vd_TrainDetailZh', 'V') IS NOT NULL
	drop view vd_TrainDetailZh
go
create view dbo.vd_TrainDetailZh
as
select (select value from dbo.fn_splitString(C.NamePath, '/') where sno = 3) 'type',
       (select date = replace(substring(C.NamePath, 10, 10),'/','-')) 'date',
       T.Number 'number',
       O.CName 'traintype', 
       ST.Rank 'rank',
       S.CName 'stop',
       substring(convert(nvarchar(MAX),TS.Arrive,108),1,5) 'arrive' , 
       substring(convert(nvarchar(MAX),ST.Departure,108),1,5) 'departure',
       IIF( convert(char(10), GetDate(),126) = replace(substring(C.NamePath, 10, 10),'/','-') , T.PassRank, NULL) 'passrank',
       IIF( convert(char(10), GetDate(),126) = replace(substring(C.NamePath, 10, 10),'/','-') , T.DelayTime, NULL) 'delaytime',
       '' 'state'
from Class C, CO, Object O, Transportation T, TS, Object S, ST
where C.CID = CO.CID and CO.OID = O.OID and O.OID = T.TID and T.TID = TS.TID
      and TS.SID = S.OID and S.OID = ST.SID and ST.TID = T.TID and C.nLevel = 5 --列出跟日期關聯的班次
go

--vd_TrainDetailEn(2018/07/21 完成)
if OBJECT_ID('vd_TrainDetailEn', 'V') IS NOT NULL
	drop view vd_TrainDetailEn
go
create view dbo.vd_TrainDetailEn
as
select IIF((select value from dbo.fn_splitString(C.NamePath, '/') where sno = 3) = '高鐵', 'THSR', 'TRA') 'type',
       (select date = replace(substring(C.NamePath, 10, 10),'/','-')) 'date',
       T.Number 'number',
       O.EName 'traintype', 
       ST.Rank 'rank',
       S.EName 'stop',
       substring(convert(nvarchar(MAX),TS.Arrive,108),1,5) 'arrive' , 
       substring(convert(nvarchar(MAX),ST.Departure,108),1,5) 'departure',
       IIF( convert(char(10), GetDate(),126) = replace(substring(C.NamePath, 10, 10),'/','-') , T.PassRank, NULL) 'passrank',
       IIF( convert(char(10), GetDate(),126) = replace(substring(C.NamePath, 10, 10),'/','-') , T.DelayTime, NULL) 'delaytime',
       '' 'state'
from Class C, CO, Object O, Transportation T, TS, Object S, ST
where C.CID = CO.CID and CO.OID = O.OID and O.OID = T.TID and T.TID = TS.TID
      and TS.SID = S.OID and S.OID = ST.SID and ST.TID = T.TID and C.nLevel = 5 --列出跟日期關聯的班次
go

--vd_TrainTimetableZh(2018/07/21 完成)
if OBJECT_ID('vd_TrainTimetableZh', 'V') IS NOT NULL
	drop view vd_TrainTimetableZh
go
create view dbo.vd_TrainTimetableZh
as
select (select value from dbo.fn_splitString(C.NamePath, '/') where sno = 3) 'type',
       (select date = replace(substring(C.NamePath, 10, 10),'/','-')) 'date', 
       OT.CName 'traintype',
       T.Number 'number',
			 S1.StopID 'fromstopID',
       OS1.CName 'fromstop',
       substring(convert(nvarchar(MAX),ST.Departure,108),1,5) 'departure', 
			 S2.StopID 'tostopID',
       OS2.CName 'tostop',
       substring(convert(nvarchar(MAX),TS.Arrive,108),1,5) 'arrive',
       substring(convert(nvarchar(max),dateadd(ss,datediff(second,ST.Departure,TS.Arrive),0),114),1,2)+'時'+
       substring(convert(nvarchar(max),dateadd(ss,datediff(second,ST.Departure,TS.Arrive),0),114),4,2)+'分' 'duration',
       SP.Price 'price'
from 	Object OS1, Stop S1, ST, Class C, CO, Object OT, Transportation T, TS, Stop S2, Object OS2, SP
where C.CID = CO.CID and CO.OID = OT.OID and OT.OID = T.TID
      and OS1.OID = S1.SID and S1.SID = ST.SID and ST.TID = T.TID and T.TID = TS.TID and TS.SID = S2.SID and S2.SID = OS2.OID and ST.Rank < TS.Rank
      and OS1.OID = SP.SID1 and SP.SID2 = OS2.OID 
      and (
				(C.NamePath like '%台鐵%' and SP.Type1 like '%' + OT.CName + '%' and SP.Type2 = '全票')
				or (C.NamePath like '%高鐵%' and SP.Type1 = '標準' and SP.Type2 = '全票')
			)
      and C.nLevel = 5 --列出跟日期關聯的班次
go

-- --vd_TrainTimetableEn(2018/07/21 完成)
if OBJECT_ID('vd_TrainTimetableEn', 'V') IS NOT NULL
	drop view vd_TrainTimetableEn
go
create view dbo.vd_TrainTimetableEn
as
select IIF((select value from dbo.fn_splitString(C.NamePath, '/') where sno = 3) = '高鐵', 'THSR', 'TRA') 'type',
       (select date = replace(substring(C.NamePath, 10, 10),'/','-')) 'date', 
       OT.EName 'traintype',
       T.Number 'number',
			 S1.StopID 'fromstopID',
       OS1.EName 'fromstop',
       substring(convert(nvarchar(MAX),ST.Departure,108),1,5) 'departure', 
			 S2.StopID 'tostopID',
       OS2.EName 'tostop',
       substring(convert(nvarchar(MAX),TS.Arrive,108),1,5) 'arrive',
       substring(convert(nvarchar(max),dateadd(ss,datediff(second,ST.Departure,TS.Arrive),0),114),1,2)+'h'+
       substring(convert(nvarchar(max),dateadd(ss,datediff(second,ST.Departure,TS.Arrive),0),114),4,2)+'m' 'duration',
       SP.Price 'price'
from 	Object OS1, Stop S1, ST, Class C, CO, Object OT, Transportation T, TS, Stop S2, Object OS2, SP
where C.CID = CO.CID and CO.OID = OT.OID and OT.OID = T.TID
			and OS1.OID = S1.SID and S1.SID = ST.SID and ST.TID = T.TID and T.TID = TS.TID and TS.SID = S2.SID and S2.SID = OS2.OID and ST.Rank < TS.Rank
      and OS1.OID = SP.SID1 and SP.SID2 = OS2.OID 
      and (
				(C.NamePath like '%台鐵%' and SP.Type1 like '%' + OT.CName + '%' and SP.Type2 = '全票')
				or (C.NamePath like '%高鐵%' and SP.Type1 = '標準' and SP.Type2 = '全票')
			)
      and C.nLevel = 5 --列出跟日期關聯的班次
go

--vd_StopTimetableZh(2018/07/21 完成)
if OBJECT_ID('vd_StopTimetableZh', 'V') IS NOT NULL
	drop view vd_StopTimetableZh
go
create view dbo.vd_StopTimetableZh
as
select (select value from dbo.fn_splitString(C.NamePath, '/') where sno = 3) 'type',
       (select date = REPLACE(substring(C.NamePath, 10, 10),'/','-')) 'date',
			 S.StopID 'stopID',
       OS.CName 'stop',
       T.Number 'number',
       OT.CName 'traintype',
       D.CName 'destination',
       substring(convert(nvarchar(MAX),TS.Arrive,108),1,5) 'arrive', 
       substring(convert(nvarchar(MAX),ST.Departure,108),1,5) 'departure',
			 IIF( convert(char(10), GetDate(),126) = replace(substring(C.NamePath, 10, 10),'/','-') , T.PassRank, NULL) 'passrank',
       IIF( convert(char(10), GetDate(),126) = replace(substring(C.NamePath, 10, 10),'/','-') , T.DelayTime, NULL) 'delaytime'
from Object OS, Stop S, ST, Class C, CO, Object OT, Transportation T, TS, Object D
where C.CID = CO.CID and CO.OID = OT.OID and OT.OID = T.TID
			and OS.OID = S.SID and S.SID = ST.SID and ST.TID = T.TID and T.TID = TS.TID and TS.SID = S.SID and T.EndStop = D.OID
			and C.nLevel = 5 --列出跟日期關聯的班次
go

--vd_StopTimetableEn(2018/07/21 完成)
if OBJECT_ID('vd_StopTimetableEn', 'V') IS NOT NULL
	drop view vd_StopTimetableEn
go
create view dbo.vd_StopTimetableEn
as
select (select value from dbo.fn_splitString(C.NamePath, '/') where sno = 3) 'type',
       (select date = REPLACE(substring(C.NamePath, 10, 10),'/','-')) 'date',
			 S.StopID 'stopID',
       OS.EName 'stop',
       T.Number 'number',
       OT.EName 'traintype',
       D.EName 'destination',
       substring(convert(nvarchar(MAX),TS.Arrive,108),1,5) 'arrive', 
       substring(convert(nvarchar(MAX),ST.Departure,108),1,5) 'departure',
			 IIF( convert(char(10), GetDate(),126) = replace(substring(C.NamePath, 10, 10),'/','-') , T.PassRank, NULL) 'passrank',
       IIF( convert(char(10), GetDate(),126) = replace(substring(C.NamePath, 10, 10),'/','-') , T.DelayTime, NULL) 'delaytime'
from Object OS, Stop S, ST, Class C, CO, Object OT, Transportation T, TS, Object D
where C.CID = CO.CID and CO.OID = OT.OID and OT.OID = T.TID
			and OS.OID = S.SID and S.SID = ST.SID and ST.TID = T.TID and T.TID = TS.TID and TS.SID = S.SID and T.EndStop = D.OID
			and C.nLevel = 5 --列出跟日期關聯的班次
go

--vd_MaxminDateZh(2018/07/21 完成)
if OBJECT_ID('vd_MaxminDateZh', 'V') IS NOT NULL
	drop view vd_MaxminDateZh
go
create view dbo.vd_MaxminDateZh
as
select (select value from dbo.fn_splitString(C.NamePath, '/') where sno = 3) 'type',
       replace(substring(C.NamePath, 10, 10),'/','-') 'date'	   
from Class C
where len(replace(substring(C.NamePath, 10, 10),'/','-')) = 10 and Type = 102
go

--vd_MaxminDateEn(2018/07/21 完成)
if OBJECT_ID('vd_MaxminDateEn', 'V') IS NOT NULL
	drop view vd_MaxminDate
go
create view dbo.vd_MaxminDateEn
as
select IIF((select value from dbo.fn_splitString(C.NamePath, '/') where sno = 3)='高鐵','THSR','TRA') 'type',
       replace(substring(C.NamePath, 10, 10),'/','-') 'date'	   
from Class C
where len(replace(substring(C.NamePath, 10, 10),'/','-')) = 10 and Type = 102
go

--vd_BusList(2018/08/22 完成)
if OBJECT_ID('vd_BusList', 'V') IS NOT NULL
	drop view vd_BusList
go
create view dbo.vd_BusList
as
select C.CName 'type',
       T1.CName 'name',
       IIF(T.Direction = 0, 0, 1) as 'direction'
from Class C, CO, Object T1, Transportation T
where C.CID = CO.CID and CO.OID = T1.OID and T1.OID = T.TID
and C.Type = 102 and (C.NamePath like '%公路客運%' or C.NamePath like '%市區公車%')
go

--vd_BusListZh(2018/07/21 完成)
if OBJECT_ID('vd_BusListZh', 'V') IS NOT NULL
	drop view vd_BusListZh
go
create view dbo.vd_BusListZh
as
select IIF(C.CName = '公路客運', C.CName, substring(C.CName,1,2)) 'type',
       C.EDes 'url',
       T.Number 'routeUID',
       T1.CName 'name',
       T1.CDes 'headsign',
	     (select value from fn_splitString(T1.CDes, ' - ') where sno = 1) 'outbound',
	     IIF(
		   (select COUNT(*) from vd_BusList where type = C.CName and name = T1.CName and direction = 1) != 0, 
		   (select top(1) value from fn_splitString(T1.CDes, ' - ') order by sno desc), NULL ) 'inbound'
from Class C, CO, Object T1, Transportation T
where C.CID = CO.CID and CO.OID = T1.OID and T1.OID = T.TID and T.Direction = 0
and C.Type = 102 and (C.NamePath like '%公路客運%' or C.NamePath like '%市區公車%')
go

--vd_BusListEn(2018/07/21 完成)
if OBJECT_ID('vd_BusListEn', 'V') IS NOT NULL
	drop view vd_BusListEn
go
create view dbo.vd_BusListEn
as
select IIF(C.EName = 'Intercity Bus',substring(C.EName,1,9),
           IIF(charindex('County',C.EName) = 0, substring(C.EName, 1, len(C.EName)-5), substring(C.EName, 1, len(C.EName)-7))) 'type',
       C.EDes 'url',
       T.Number 'routeUID',
       IIF(T1.EName is NULL or T1.EName = '', T1.CName, T1.EName) 'name',
       IIF(T1.EDes is NULL or T1.EDes = '', T1.CDes, T1.EDes) 'headsign',
	     (select value from fn_splitString(T1.CDes, ' - ') where sno = 1) 'outbound',
	     IIF(
		   (select COUNT(*) from vd_BusList where type = C.CName and name = T1.CName and direction = 1) != 0, 
		   IIF((select CHARINDEX('[', T1.CDes)) = 0, (select top(1) value from fn_splitString(T1.CDes, ' - ') order by sno desc),
			   (select top(1) value from fn_splitString(STUFF(T1.CDes, CHARINDEX('[', T1.CDes), 1000, ''), ' - ') order by sno desc)), NULL ) 'inbound'
from Class C, CO, Object T1, Transportation T
where C.CID = CO.CID and CO.OID = T1.OID and T1.OID = T.TID and T.Direction = 0
and C.Type = 102 and (C.NamePath like '%公路客運%' or C.NamePath like '%市區公車%')
go

--vd_BusDetailZh(2018/07/21 完成)
if OBJECT_ID('vd_BusDetailZh', 'V') IS NOT NULL
	drop view vd_BusDetailZh
go
create view dbo.vd_BusDetailZh
as
select IIF(C.CName = '公路客運', C.CName, substring(C.CName,1,2)) 'type',
			 C.EDes 'url',
       T.Number 'routeUID',
       OT.CName 'name',
	 		 IIF(T.Direction = 0, 0, 1) as 'direction',
       TS.Rank 'rank',
	 		 S.StopID 'stopUID',
       OS.CName 'stop',
			 -- updatetime, state為顯示公車動態用
       '' 'updatetime',
       '今日停駛' 'state'
from Class C, CO, Object OT, Transportation T, TS, Stop S, Object OS
where C.CID = CO.CID and CO.OID = OT.OID and OT.OID = T.TID and T.TID = TS.TID 
and TS.SID = S.SID and S.SID = OS.OID
and C.Type = 102 and (C.NamePath like '%公路客運%' or C.NamePath like '%市區公車%')
go

--vd_BusDetailEn(2018/07/21 完成)
if OBJECT_ID('vd_BusDetailEn', 'V') IS NOT NULL
	drop view vd_BusDetailEn
go
create view dbo.vd_BusDetailEn
as
select IIF(C.EName = 'Intercity Bus',substring(C.EName,1,9),
           IIF(charindex('County',C.EName) = 0, substring(C.EName, 1, len(C.EName)-5), substring(C.EName, 1, len(C.EName)-7))) 'type',
       C.EDes 'url',
       T.Number 'routeUID',
       IIF(OT.EName is NULL or OT.EName = '', OT.CName, OT.EName) 'name',  
	 		 IIF(T.Direction = 0, 0, 1) as 'direction',
       TS.Rank 'rank',
	 		 S.StopID 'stopUID',
	 		 IIF(OS.EName is NULL or OS.EName = '', OS.CName, OS.EName) 'stop',
			 -- updatetime, state為顯示公車動態用
       '' 'updatetime',
       'Serv Over' 'state'
from Class C, CO, Object OT, Transportation T, TS, Stop S, Object OS
where C.CID = CO.CID and CO.OID = OT.OID and OT.OID = T.TID and T.TID = TS.TID 
and TS.SID = S.SID and S.SID = OS.OID
and C.Type = 102 and (C.NamePath like '%公路客運%' or C.NamePath like '%市區公車%')
go