/*
埔里轉運站：lon:120.969 lat:23.963
建工路：lon:120.319 lat:22.648
高美濕地：lon:120.550 lat:24.311
中研院：lon:121.616 lat:25.043
*/

/***
	Function
***/

--fn_getBlockID
if exists ( select * from sys.objects o where o.name = N'fn_getBlockID' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_getBlockID
go
create function fn_getBlockID(@longitude decimal(9,6), @latitude decimal(8,6))
	returns int
as
begin
  declare @rowID int = (round(@latitude,3,1) * 1000 - 21800)/2 + 1
	declare @columnID int = (round(@longitude,3,1) * 1000 - 119000)/2 + 1
	declare @blockID int = 1550 * (@rowID - 1) + @columnID
	return @blockID
end
go

--fn_getNearbyKeyblock
if exists ( select * from sys.objects o where o.name = N'fn_getNearbyKeyblock' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_getNearbyKeyblock
go
create function [dbo].[fn_getNearbyKeyblock](@BID int)
	returns @block table(ID int IDENTITY(1, 1), BID int, Distance int)
as
begin
	declare @keyBID int, @type binary(1), @row int, @column int
	declare @temp table (BID int, Type binary(1), Distance int)
	
	declare ccursor cursor for select K.BID, B.Type from Block B, Keyblock K where B.BID = K.BID
	open ccursor
	fetch next from ccursor into @keyBID, @type
	while @@FETCH_STATUS = 0
	begin
		set @row = @KeyBID/1550 - @BID/1550
		set @column = Abs((@keyBID - @row*1550) - @BID)
		insert into @temp values(@keyBID, @type, Abs(@row) + @column)
		fetch next from ccursor into @keyBID, @type
	end
	insert into @block(BID, Distance)
	select BID, distance from @temp order by (
		case when Type & 1 = 1 then 1   -- 高鐵
				 when Type & 2 = 2 then 2   -- 台鐵
				 when Type & 4 = 4 then 3   -- 捷運
				 when Type & 8 = 8 then 4   -- 客運
				 when Type & 16 = 16 then 5 -- 公車
				 else 6
		end
	), Distance
	return
end
go

--fn_getNearbyStop 目前以距離作排序
if exists ( select * from sys.objects o where o.name = N'fn_getNearbyStop' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_getNearbyStop
go
create function [dbo].[fn_getNearbyStop](@BID int, @level smallint)
	returns @Stop table(ID int IDENTITY(1, 1), OID int)
as
begin
	declare @i int, @j int, @OID int, @row int, @column int, @beginBID int
	declare @temp table (OID int, Distance int)

  -- 若給定的範圍內沒stop，則往外搜尋
  while (1=1)
  begin
    set @beginBID = @BID - 1550 * @level - @level- 1
    set @i = 1
    while ( @i <= 2 * @level + 1)
    begin
      set @j =  1
      while ( @j <= 2 * @level + 1)
      begin
        set @beginBID = @beginBID + 1
        set @row = @beginBID/1550 - @BID/1550
        set @column = Abs((@beginBID - @row*1550) - @BID)
        insert into @temp
        select O.OID, Abs(@row) + @column from BO, Object O where BO.OID = O.OID and O.Type = 101 and BID = @beginBID
        set @j = @j + 1
      end
      set @beginBID = @beginBID - ( 2 * @level + 1 ) + 1550
      set @i = @i + 1
    end
    if exists(select * from @temp)
      break
    set @level = @level + 1
  end

  insert into @Stop(OID)
  select OID from @temp
  order by (Distance)

  return 
end
go

--fn_getSubrouteZh
if exists ( select * from sys.objects o where o.name = N'fn_getSubrouteZh' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_getSubrouteZh
go
create function [dbo].[fn_getSubrouteZh](
    @BID1 int, @BID2 int, @level smallint, @date nvarchar(255), @time nvarchar(255)
  )
	returns @route table(
    type nvarchar(255), route nvarchar(255), traintype nvarchar(255), des nvarchar(255),
    fromstop nvarchar(255), fromlon decimal(9,6), fromlat decimal(8,6), departure nvarchar(255),
    tostop nvarchar(255), tolon decimal(9,6), tolat decimal(8,6), arrive nvarchar(255),
    duration nvarchar(255), price int
  )
as
begin
	-- 先找台鐵、高鐵
  insert into @route
  select
	IIF(C.NamePath like '%高鐵%', '高鐵', '台鐵'),
	T.Number, OT.CName, OT.CDes,
	OS1.CName, S1.Longitude, S1.Latitude, ST.Departure,
	OS2.CName, S2.Longitude, S2.Latitude, TS.Arrive,
	substring(convert(nvarchar(max),dateadd(ss,datediff(second,ST.Departure,TS.Arrive),0),114),1,2)+'時'+
	substring(convert(nvarchar(max),dateadd(ss,datediff(second,ST.Departure,TS.Arrive),0),114),4,2)+'分',
	SP.Price
	from Class C, CO, Object OT, Object OS1, Stop S1, ST, Transportation T, TS, Stop S2, Object OS2, SP
  where C.CID = CO.CID and CO.OID = OT.OID and OT.OID = T.TID
	and OS1.OID = S1.SID and S1.SID = ST.SID and ST.TID = T.TID and T.TID = TS.TID and TS.SID = S2.SID and S2.SID = OS2.OID
	and S1.SID = SP.SID1 and SP.SID2 = S2.SID and ST.Rank < TS.Rank
	and OS1.OID in (select OID from fn_getNearbyStop(@BID1,@level))
  and OS2.OID in (select OID from fn_getNearbyStop(@BID2,@level))
  and replace(substring(C.NamePath, 10, 10),'/','-') = @date and ST.departure > @time
	and (
		(C.NamePath like '%台鐵%' and SP.Type1 like '%' + OT.CName + '%' and SP.Type2 = '全票')
		or (C.NamePath like '%高鐵%' and SP.Type1 = '標準' and SP.Type2 = '全票')
	)

	-- 再找客運、公車
  if not exists (select * from @route)
  begin
    insert into @route
    select distinct C.CName, OT.CName, NULL, OT.CDes,
    OS1.CName, S1.Longitude, S1.Latitude, NULL,
    OS2.CName, S2.Longitude, S2.Latitude, NULL, NULL, NULL
    from Class C, CO, Object OT, Object OS1, Stop S1, ST, Transportation T, TS, Stop S2, Object OS2 
    where C.CID = CO.CID and CO.OID = OT.OID and OT.OID = T.TID
		and OS1.OID = S1.SID and S1.SID = ST.SID and ST.TID = T.TID and T.TID = TS.TID and TS.SID = S2.SID and S2.SID = OS2.OID
		and ST.Rank < TS.Rank
    and (C.CName not like '%高鐵%' and C.CName not like '%台鐵%')
    and OS1.OID in (select OID from fn_getNearbyStop(@BID1,@level))
    and OS2.OID in (select OID from fn_getNearbyStop(@BID2,@level))
    -- and C.nLevel < 5
  end
  return
end
go

--fn_getSubrouteEn
if exists ( select * from sys.objects o where o.name = N'fn_getSubrouteEn' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_getSubrouteEn
go
create function [dbo].[fn_getSubrouteEn](
    @BID1 int, @BID2 int, @level smallint, @date nvarchar(255), @time nvarchar(255)
  )
	returns @route table(
    type nvarchar(255), route nvarchar(255), traintype nvarchar(255), des nvarchar(255),
    fromstop nvarchar(255), fromlon decimal(9,6), fromlat decimal(8,6), departure nvarchar(255),
    tostop nvarchar(255), tolon decimal(9,6), tolat decimal(8,6), arrive nvarchar(255),
    duration nvarchar(255), price int
  )
as
begin
	-- 先找台鐵、高鐵
  insert into @route
  select
	IIF(C.NamePath like '%高鐵%', 'THSR', 'TRA'),
	T.Number, OT.EName, OT.EDes,
	OS1.EName, S1.Longitude, S1.Latitude, ST.Departure,
	OS2.EName, S2.Longitude, S2.Latitude, TS.Arrive,
	substring(convert(nvarchar(max),dateadd(ss,datediff(second,ST.Departure,TS.Arrive),0),114),1,2)+'h'+
	substring(convert(nvarchar(max),dateadd(ss,datediff(second,ST.Departure,TS.Arrive),0),114),4,2)+'m',
	SP.Price
	from Class C, CO, Object OT, Object OS1, Stop S1, ST, Transportation T, TS, Stop S2, Object OS2, SP
  where C.CID = CO.CID and CO.OID = OT.OID and OT.OID = T.TID
	and OS1.OID = S1.SID and S1.SID = ST.SID and ST.TID = T.TID and T.TID = TS.TID and TS.SID = S2.SID and S2.SID = OS2.OID
	and S1.SID = SP.SID1 and SP.SID2 = S2.SID and ST.Rank < TS.Rank
	and OS1.OID in (select OID from fn_getNearbyStop(@BID1,@level))
  and OS2.OID in (select OID from fn_getNearbyStop(@BID2,@level))
  and replace(substring(C.NamePath, 10, 10),'/','-') = @date and ST.departure > @time
	and (
		(C.NamePath like '%台鐵%' and SP.Type1 like '%' + OT.CName + '%' and SP.Type2 = '全票')
		or (C.NamePath like '%高鐵%' and SP.Type1 = '標準' and SP.Type2 = '全票')
	)

	-- 再找客運、公車
  if not exists (select * from @route)
  begin
    insert into @route
    select distinct C.CName, IIF(OT.EName is NULL, OT.CName, OT.EName),
    NULL, IIF(OT.EDes is NULL, OT.CDes, OT.EDes),
    IIF(OS1.EName is NULL, OS1.CName, OS1.EName), S1.Longitude, S1.Latitude, NULL,
    IIF(OS2.EName is NULL, OS2.CName, OS2.EName), S2.Longitude, S2.Latitude, NULL, NULL, NULL
    from Class C, CO, Object OT, Object OS1, Stop S1, ST, Transportation T, TS, Stop S2, Object OS2 
    where C.CID = CO.CID and CO.OID = OT.OID and OT.OID = T.TID
		and OS1.OID = S1.SID and S1.SID = ST.SID and ST.TID = T.TID and T.TID = TS.TID and TS.SID = S2.SID and S2.SID = OS2.OID
		and ST.Rank < TS.Rank
    and (C.CName not like '%高鐵%' and C.CName not like '%台鐵%')
    and OS1.OID in (select OID from fn_getNearbyStop(@BID1,@level))
    and OS2.OID in (select OID from fn_getNearbyStop(@BID2,@level))
  end
  return
end
go

--fn_getkeyblockRouteZh
if exists ( select * from sys.objects o where o.name = N'fn_getKeyblockRouteZh' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_getKeyblockRouteZh
go
create function [dbo].[fn_getKeyblockRouteZh](
    @fromKeyblock int, @toKeyblock int, @level smallint, @date nvarchar(255), @time nvarchar(255)
  )
	returns @route table(
    seq int, type nvarchar(255), route nvarchar(255), traintype nvarchar(255), des nvarchar(255),
    fromstop nvarchar(255), fromlon decimal(9,6), fromlat decimal(8,6), departure nvarchar(255),
    tostop nvarchar(255), tolon decimal(9,6), tolat decimal(8,6), arrive nvarchar(255),
    duration nvarchar(255), price int
  )
as
begin
  declare @middleKeyblock int
  if exists(select * from fn_getSubrouteZh(@fromKeyblock, @toKeyblock, @level, @date, @time))
  begin
    insert into @route
    select 2, * from fn_getSubrouteZh(@fromKeyblock, @toKeyblock, @level, @date, @time)
  end
  else
  begin
    select top(1) @middleKeyblock = BID from fn_getNearbyKeyblock(@toKeyblock) order by ID
    insert into @route
    select * from fn_getKeyblockRouteZh(@fromKeyblock, @middleKeyblock, @level, @date, @time)
    insert into @route
    select * from fn_getKeyblockRouteZh(@middleKeyblock, @toKeyblock, @level, @date, @time)
  end
  return
end
go

--fn_getAllrouteZh
if exists ( select * from sys.objects o where o.name = N'fn_getAllrouteZh' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_getAllrouteZh
go
create function [dbo].[fn_getAllrouteZh](
  @fromlon decimal(9,6), @fromlat decimal(8,6), @tolon decimal(9,6), @tolat decimal(8,6),
  @level int, @date nvarchar(255), @time nvarchar(255)
)
	returns @route table(
    seq int, type nvarchar(255), route nvarchar(255), traintype nvarchar(255), des nvarchar(255),
    fromstop nvarchar(255), fromlon decimal(9,6), fromlat decimal(8,6), departure nvarchar(255),
    tostop nvarchar(255), tolon decimal(9,6), tolat decimal(8,6), arrive nvarchar(255),
    duration nvarchar(255), price int
  )
as
begin
  declare @fromBID int, @toBID int, @fromKeyblock int, @toKeyblock int, @count int, @ID int = 1
  -- declare @temp table(
  --   type nvarchar(255), route nvarchar(255), traintype nvarchar(255), des nvarchar(255),
  --   fromstop nvarchar(255), fromlon decimal(9,6), fromlat decimal(8,6), departure nvarchar(255),
  --   tostop nvarchar(255), tolon decimal(9,6), tolat decimal(8,6), arrive nvarchar(255),
  --   duration nvarchar(255), price int
  -- )

  set @fromBID = dbo.fn_getBlockID(@fromlon, @fromlat)
  set @toBID   = dbo.fn_getBlockID(@tolon, @tolat)
  -- 起點可直接到終點，不用轉乘
  if exists(select * from fn_getSubrouteZh(@fromBID, @toBID, @level, @date, @time))
  begin
    insert into @route
    select 1, * from fn_getSubrouteZh(@fromBID, @toBID, @level, @date, @time)
  end
  else
  begin
    -- 起點到keyblock
    while (1=1)
    begin
      if exists(select * from fn_getNearbyKeyblock(@fromBID) where Distance < 8) -- level = 4，一公里內可走路
      begin
        -- 之後來寫
        select top(1) @fromKeyblock = BID from fn_getNearbyKeyblock(@fromBID) where Distance < 8 order by Distance, ID
        break
      end
      else
      begin
        select @fromKeyblock = BID from fn_getNearbyKeyblock(@fromBID) where ID = @ID
        if exists(select * from fn_getSubrouteZh(@fromBID, @fromKeyblock, @level, @date, @time))
        begin
          insert into @route select 1, * from fn_getSubrouteZh(@fromBID, @fromKeyblock, @level, @date, @time)
          break
        end
        set @ID = @ID + 1
      end
    end
    set @ID = 1
    -- keyblock到終點
    while (1=1)
    begin
      if exists(select * from fn_getNearbyKeyblock(@toBID) where Distance < 8) -- level = 4，一公里內可走路
      begin
        -- 之後來寫
        select top(1) @toKeyblock = BID from fn_getNearbyKeyblock(@toBID) where Distance < 8 order by Distance, ID
        break
      end
      else
      begin
        select @toKeyblock = BID from fn_getNearbyKeyblock(@toBID) where ID = @ID
        if exists(select * from fn_getSubrouteZh(@toKeyblock, @toBID, @level, @date, @time))
        begin
          insert into @route select 3, * from fn_getSubrouteZh(@toKeyblock, @toBID, @level, @date, @time)
          break
        end
        set @ID = @ID + 1
      end
    end
    -- keyblock到Keyblock
    -- insert into @route
    -- select * from fn_getKeyblockRouteZh(@fromKeyblock, @toKeyblock, @level, @date, @time)

    if @fromKeyblock not in (select BID from fn_getNearbyKeyblock(@toKeyBlock) where Distance < 8)
      insert into @route select 2, * from fn_getSubrouteZh(@fromKeyblock, @toKeyBlock, @level, @date, @time)
  end
  return
end
go