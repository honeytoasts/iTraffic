use [$(DBName)]
go

/***
	Function
***/

--fn_getMD5Encode2
if exists ( select * from sys.objects o where o.name = N'fn_getMD5Encode2' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_getMD5Encode2
go
create function fn_getMD5Encode2(@String varchar(MAX))
	returns nvarchar(32)
as
begin
	return (select convert(nvarchar(32), hashbytes('MD5', @String),2))
end
go

/***
	stored procedure
***/

--xp_insertClass2(沒回傳值)
if exists(select * from sys.objects o where o.name = N'xp_insertClass2' and type in ('P') )
	drop procedure xp_insertClass2
go
create procedure xp_insertClass2
	@PCID int,				--c.CID，父節點
	@Type int,				--c.Type
	@CName nvarchar(400),	--c.CName
	@EName nvarchar(400) --c.EName
as
begin
	set xact_abort on --指定當 Transact-SQL 陳述式產生執行階段錯誤時，SQL Server 是否自動回復目前的交易
	begin try
		begin transaction --下面的過程設定為一整筆交易動作
			declare @NamePath nvarchar(900) = (select dbo.fn_getPath(@PCID, @CName))
			if ((select count(*) from Class where NamePath = @NamePath) = 0)
			begin
				declare @CID int
				declare @nlevel int
				insert into Class(CName, [Type], EName) values(@CName, @Type, @EName)
				set @CID = @@Identity

				insert into Inheritance(PCID, CCID) values(@PCID, @CID)	-- 利用GetCID 取得Parent的CID

				insert into Permission(CID, RoleType, RoleID, PermissionBits) values(@CID, 0, 0, 63)
				-- insert into Permission(CID, RoleType, RoleID, PermissionBits) values(@CID, 1, 1, 3)
				insert into Permission(CID, RoleType, RoleID, PermissionBits) values(@CID, 0, 1, 3)
				insert into Permission(CID, RoleType, RoleID, PermissionBits) values(@CID, 0, 2, 3)

				update Class set nLevel = dbo.fn_getLevel(@PCID) where CID = @CID

				--select @nlevel = nlevel from Class where CID = @CID
				--if (@nlevel = 1)
				--begin
					--update Class set NamePath = @CName, IDPath = @CID where CID = @CID
				--end
				--else
				--begin
					update Class set NamePath = dbo.fn_getPath(@PCID, @CName), IDPath = dbo.fn_getIDPath(@PCID, @CID) where CID = @CID
				--end
			end
		commit transaction
	end try
	begin catch
		if XACT_STATE() <> 0
		begin
			rollback transaction
		end
		select
			ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage
	end catch
	set xact_abort off
end
go

--xp_insertClass3(多insert EDes，查詢公車動態用)
if exists(select * from sys.objects o where o.name = N'xp_insertClass3' and type in ('P') )
	drop procedure xp_insertClass3
go
create procedure xp_insertClass3
	@PCID int,				--c.CID，父節點
	@Type int,				--c.Type
	@CName nvarchar(400),	--c.CName
	@EName nvarchar(400),   --c.EName
	@EDes  nvarchar(400)
as
begin
	set xact_abort on --指定當 Transact-SQL 陳述式產生執行階段錯誤時，SQL Server 是否自動回復目前的交易
	begin try
		begin transaction --下面的過程設定為一整筆交易動作
			declare @NamePath nvarchar(900) = (select dbo.fn_getPath(@PCID, @CName))
			if ((select count(*) from Class where NamePath = @NamePath) = 0)
			begin
				declare @CID int
				declare @nlevel int
				insert into Class(CName, [Type], EName, EDes) values(@CName, @Type, @EName, @EDes)
				set @CID = @@Identity

				insert into Inheritance(PCID, CCID) values(@PCID, @CID)	-- 利用GetCID 取得Parent的CID

				insert into Permission(CID, RoleType, RoleID, PermissionBits) values(@CID, 0, 0, 63)
				-- insert into Permission(CID, RoleType, RoleID, PermissionBits) values(@CID, 1, 1, 3)
				insert into Permission(CID, RoleType, RoleID, PermissionBits) values(@CID, 0, 1, 3)
				insert into Permission(CID, RoleType, RoleID, PermissionBits) values(@CID, 0, 2, 3)

				update Class set nLevel = dbo.fn_getLevel(@PCID) where CID = @CID

				--select @nlevel = nlevel from Class where CID = @CID
				--if (@nlevel = 1)
				--begin
					--update Class set NamePath = @CName, IDPath = @CID where CID = @CID
				--end
				--else
				--begin
					update Class set NamePath = dbo.fn_getPath(@PCID, @CName), IDPath = dbo.fn_getIDPath(@PCID, @CID) where CID = @CID
				--end
			end
		commit transaction
	end try
	begin catch
		if XACT_STATE() <> 0
		begin
			rollback transaction
		end
		select
			ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage
	end catch
	set xact_abort off
end
go

--xp_insertBO(2018/07/11 完成)
/*
Block範圍:
每0.002度為一個Block
經度:119.000 ~ 122.100 (1550行)，緯度:21.800 ~ 25.300 (1750列)，共 2,712,500格
公式:BID = count(COLUMN) * (ROW_ID -1) + COLUMN_ID (BID = 3100 * (ROW_ID -1) + COLUMN_ID)
ROW_ID = ((latitude捨去至小數點第三位 - 21.800) * 1000)/2 + 1
COLUMN_ID = ((longitude捨去至小數點第三位* - 119.000) * 1000)/2 + 1
*/
if exists(select * from sys.objects o where o.name = N'xp_insertBO' and type in ('P') )
  drop procedure xp_insertBO
go
create procedure xp_insertBO
	@OID int,
	@Longitude decimal(9,6),
	@Latitude decimal(8,6)
as
begin
	set xact_abort on --指定當 Transact-SQL 陳述式產生執行階段錯誤時，SQL Server 是否自動回復目前的交易
	begin try
		begin transaction --下面的過程設定為一整筆交易動作
			declare @old_type binary(1), @type int, @NamePath nvarchar(255)

			declare @row_id int = (round(@Latitude,3,1) * 1000 - 21800)/2 + 1
			declare @column_id int = (round(@Longitude,3,1) * 1000 - 119000)/2 + 1
			declare @block_id int = 1550 * (@row_id - 1) + @column_id

			if (not exists(select * from Block where BID = @block_id)) and @block_id > 0
				insert into Block(BID) values(@block_id)

			if @block_id > 0
			begin
				select @NamePath = C.NamePath from Class C, CO, Object O
				where C.CID = CO.CID and CO.OID = O.OID and O.OID = @OID ;
				select @old_type = Type from Block where BID = @block_id ;
				-- N/A | 景點 | 餐廳 | 公車 | 客運 | 捷運 | 台鐵 | 高鐵
				--  7     6      5      4     3      2     1      0
				if (@NamePath like '%高鐵%')
					set @type = 1
				else if (@NamePath like '%台鐵%')
					set @type = 2
				else if (@NamePath like '%捷運%')
					set @type = 4
				else if (@NamePath like '%公路客運%')
					set @type = 8
				else if (@NamePath like '%市區公車%')
					set @type = 16
				else if (@NamePath like '%餐廳%')
					set @type = 32
				else if (@NamePath like '%景點%')
					set @type = 64
				update Block set Type = @old_type | @type where BID = @block_id ;
				if not exists(select * from BO where BO.OID = @OID)
				begin
					insert into BO(BID, OID, Type, Longitude, Latitude)
								values(@block_id, @OID, @type, @Longitude, @Latitude)
				end
				-- else
				-- begin
				-- 	update BO set Type = @type where OID = @OID
				-- end
			end
		commit transaction
	end try
	begin catch
		if XACT_STATE() <> 0
		begin
			rollback transaction
		end
		select
			ERROR_LINE() as ErrorLine,
			ERROR_MESSAGE() as ErrorMessage,
			ERROR_NUMBER() as ErrorNumber,
			ERROR_PROCEDURE() as ErrorProcedure,
			ERROR_SEVERITY() as ErrorSeverity,
			ERROR_STATE() as ErrorState
	end catch
	set xact_abort off
end
go

--xp_insertStop(2018/07/11 完成)
if exists(select * from sys.objects o where o.name = N'xp_insertStop' and type in ('P') )
	drop procedure xp_insertStop
go
create procedure xp_insertStop
	-- Class
	@Directory nvarchar(255),
	-- Object
	@CName nvarchar(255),
	@EName nvarchar(255),
	@UpdateTime nvarchar(255),
	-- Stop
	@StopID nvarchar(255),
	@Longitude decimal(9,6),
	@Latitude decimal(8,6),
	@Phone nvarchar(255),
	@Address nvarchar(255)
as
begin
	set xact_abort on
	begin try
		begin transaction
			declare @CID int, @OID int, @count int, @old_lon decimal(9,6), @old_lat decimal(8,6)
		
			if exists (  -- 車站已存在
				select * from Class C, CO, Object O, Stop S
				where C.CID = CO.CID and CO.OID = O.OID and O.OID = S.SID 
				and C.Type = 101 and C.NamePath like '%站點%' + @directory 
				and O.CName = @CName and S.StopID = @StopID
			)
			begin
				-- 取得OID
				select @OID = O.OID, @old_lon = S.Longitude, @old_lat = S.Latitude from Class C, CO, Object O, Stop S
				where C.CID = CO.CID and CO.OID = O.OID and O.OID = S.SID  
				and C.Type = 101 and C.NamePath like '%站點%' + @directory 
				and O.CName = @CName and S.StopID = @StopID ; 
				
				-- 更新資料
				update Object set CName = @CName, EName = @EName, LastModifiedDT = convert(datetime, @UpdateTime, 126) 
				where OID = @OID ;
				update Stop
				set Longitude = @Longitude, Latitude = @Latitude, StopID = @StopID, Phone = @Phone, Address = @Address
				where SID = @OID ;
				-- 更新Block
				if (@old_lon != @Longitude) or (@old_lat != @Latitude) --or (not exists(select * from BO where OID = @OID))
				begin
					delete BO where OID = @OID
					exec dbo.xp_insertBO @OID, @Longitude, @Latitude
				end
				-- 更新確認日期
				update Object set OtherDT = getdate() where OID = @OID
			end
			else  -- 車站不存在
			begin
				-- 插入站點
				insert into Object(Type, CName, EName, LastModifiedDT, OtherDT) 
							values(101, @CName, @EName, convert(datetime, substring(@UpdateTime, 1, 19)), getdate()) ;
				set @OID = @@identity ;
				insert into Stop(SID, StopID, Longitude, Latitude, Phone, Address)
							values(@OID, @StopID, @Longitude, @Latitude, @Phone, @Address) ;
				-- 建CO關連
				select @CID = CID, @count = nObject from Class C
				where Type = 101 and C.NamePath like '%站點%' + @directory ;
				insert into CO(CID, OID) values (@CID, @OID) ;
				-- 增加 nObject
				update Class set nObject = @count + 1 where CID = @CID ;
				-- Block
				exec dbo.xp_insertBO @OID, @Longitude, @Latitude
			end
		commit transaction
	end try 
	begin catch
		if XACT_STATE() <> 0
		begin
			rollback transaction
		end
		select
			ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage
	end catch
	set xact_abort off
end
go

-- xp_insertPrice(2018/07/13 完成)
if exists(select * from sys.objects o where o.name = N'xp_insertPrice' and type in ('P') )
	drop procedure xp_insertPrice
go
create procedure xp_insertPrice
	-- Class
	@directory nvarchar(255),
	--SP
	@StopID1 nvarchar(255),
	@StopName1 nvarchar(255),
	@StopID2 nvarchar(255),
	@StopName2 nvarchar(255),
	@Type1 nvarchar(255),
	@Type2 nvarchar(255),
	@Price int,
	@Note nvarchar(255),
	@UpdateTime nvarchar(255)
as
begin
	set xact_abort on
	begin try
		begin transaction
			declare @SID1 int, @SID2 int
			--取得SID1
			select @SID1 = SID from Class C, CO, Object O, Stop S
			where C.CID = CO.CID and CO.OID = O.OID and O.OID = S.SID and
			S.StopID = @StopID1 and C.Type = 101 and C.NamePath like '%站點%' + @directory
			--取得SID2
			select @SID2 = SID from Class C, CO, Object O, Stop S
			where C.CID = CO.CID and CO.OID = O.OID and O.OID = S.SID and
			S.StopID = @StopID2 and C.Type = 101 and C.NamePath like '%站點%' + @directory
			--建SP
			if not exists(
				select * from SP 
				where SP.SID1 = @SID1 and SP.SID2 = @SID2 and SP.Type1 = @Type1 and SP.Type2 = @Type2
			)
			begin
				insert into SP(SID1, SID2, Type1, Type2, Price, Note, LastModifiedDT)
					    values(@SID1, @SID2, @Type1, @Type2, @Price, @Note, @UpdateTime)
			end
			else --更新SP
			begin
				if ( convert(datetime, @UpdateTime, 126) != (
					select LastModifiedDT from SP 
					where SP.SID1 = @SID1 and SP.SID2 = @SID2 and SP.Type1 = @Type1 and SP.Type2 = @Type2
				))
				begin
					update SP set Price = @Price, Note = @Note, LastModifiedDT = convert(datetime, @UpdateTime, 126)
				  where SID1 = @SID1 and SID2 = @SID2 and Type1 = @Type1 and Type2 = @Type2
				end
			end
		commit transaction
	end try
	begin catch
		if XACT_STATE() <> 0
		begin
			rollback transaction
		end
		select
			ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage
	end catch
	set xact_abort off
end
go

--xp_insertTrain(2018/07/11 完成)
if exists(select * from sys.objects o where o.name = N'xp_insertTrain' and type in ('P') )
	drop procedure xp_insertTrain
go
create procedure xp_insertTrain
	-- Class
	@directory nvarchar(255),
	-- Object
	@CName nvarchar(255),     -- 車種
	@EName nvarchar(255),
	@CDes  nvarchar(800),     -- 備註
	@EDes  nvarchar(800),
	-- Transportation
	@Number nvarchar(255),
	@StopID1  nvarchar(255),  -- 起站
	@StopName1 nvarchar(255),
	@StopID2  nvarchar(255),  -- 迄站
	@StopName2 nvarchar(255),
	@Direction bit,           -- 0順1逆
	@md5 nvarchar(255)        -- 以車次時刻加密成md5 
as
begin
	set xact_abort on
	begin try
		begin transaction
			if not exists (  -- 判斷班次是否存在
				select * from Transportation T
				where T.Number = @Number and T.MD5 = @md5
			)
			begin
				declare @CID int, @OID int, @SID1 int, @SID2 int, @count int ;
				-- 取得SID
				select @SID1 = SID from Class C, CO, Object O, Stop S
				   where C.CID = CO.CID and CO.OID = O.OID and O.OID = S.SID 
				   and C.Type = 101 and C.NamePath like '%站點%' + @directory
				   and O.CName = @StopName1 and S.StopID = @StopID1
				select @SID2 = SID from Class C, CO, Object O, Stop S
				   where C.CID = CO.CID and CO.OID = O.OID and O.OID = S.SID 
				   and C.Type = 101 and C.NamePath like '%站點%' + @directory
				   and O.CName = @StopName2 and S.StopID = @StopID2
				-- 插入班次
				insert into Object(Type, CName, EName, CDes, EDes) 
							values(102, @CName, @EName, @CDes, @EDes) ;
				set @OID = @@identity ;
				insert into Transportation(TID, Number, StartStop, EndStop, Direction, MD5)
							values(@OID, @Number, @SID1, @SID2, @Direction, @md5) ;
				-- 建CO關連
				select @CID = CID, @count = nObject from Class 
				       where Type = 102 and NamePath like '%' + @directory ;
				insert into CO(CID, OID) values (@CID, @OID) ;
				-- 增加 nObject
				update Class set nObject = @count + 1 where CID = @CID ;
			end
		commit transaction
	end try 
	begin catch
		if XACT_STATE() <> 0
		begin
			rollback transaction
		end
		select
			ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage
	end catch
	set xact_abort off
end
go

-- xp_insertTrainST(2018/07/12 完成)
if exists(select * from sys.objects o where o.name = N'xp_insertTrainST' and type in ('P') )
	drop procedure xp_insertTrainST
go
create procedure xp_insertTrainST
	-- Class
	@directory nvarchar(255),
	-- Transportation
	@Number nvarchar(255),
	@md5 nvarchar(255),
	-- ST、TS
	@Rank int,
	@StopID nvarchar(255),
	@StopName nvarchar(255),
	@Arrive time(0),
	@Departure time(0)
as
begin
	set xact_abort on
	begin try
		begin transaction
			declare @SID int, @TID int
			--取得SID
			select @SID = SID from Class C, CO, Object O, Stop S
				   where C.CID = CO.CID and CO.OID = O.OID and O.OID = S.SID 
				   and C.Type = 101 and C.NamePath like '%站點%' + @directory
				   and O.CName = @StopName and S.StopID = @StopID ;
			--取得TID
			select @TID = TID from Class C, CO, Object O, Transportation T
				   where C.CID = CO.CID and CO.OID = O.OID and O.OID = T.TID
				   and C.Type = 102 and C.NamePath like '%'+ @directory
				   and T.Number = @Number and T.MD5 = @md5 ;
			--建ST
			if not exists(
				select * from ST where ST.SID = @SID and ST.TID = @TID
			)
			begin
				insert into ST(SID, TID, Rank, Departure)
					        values(@SID, @TID, @Rank, @Departure)
			end
			--建TS
			if not exists(
				select * from TS where TS.SID = @SID and TS.TID = @TID
			)
			begin
				insert into TS(TID, SID, Rank, Arrive)
					        values(@TID, @SID, @Rank, @Arrive)
			end
		commit transaction
	end try 
	begin catch
		if XACT_STATE() <> 0
		begin
			rollback transaction
		end
		select
			ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage
	end catch
	set xact_abort off
end
go

-- xp_updateTrainState(2018/08/22 完成)
if exists(select * from sys.objects o where o.name = N'xp_updateTrainState' and type in ('P') )
	drop procedure xp_updateTrainState
go
create procedure xp_updateTrainState
	-- Class
	@directory nvarchar(255),
	@Year nvarchar(255),
	@Month nvarchar(255),
	@Day nvarchar(255),
	-- Transportation
	@Number nvarchar(255),
	@StopID nvarchar(255),
	@StopName nvarchar(255),
	@Delay int
as
begin
	set xact_abort on
	begin try
		begin transaction
			declare @SID int, @TID int, @rank int
			--取得SID
			select @SID = SID from Class C, CO, Object O, Stop S
				   where C.CID = CO.CID and CO.OID = O.OID and O.OID = S.SID 
				   and C.Type = 101 and C.NamePath like '%站點%' + @directory
				   and O.CName = @StopName and S.StopID = @StopID ;
			--取得TID
			select @TID = TID from Class C, CO, Object O, Transportation T
				   where C.CID = CO.CID and CO.OID = O.OID and O.OID = T.TID
				   and C.Type = 102 and C.NamePath like '%' + @directory + '/' + @Year + '/' + @Month + '/' + @Day
				   and T.Number = @Number
			--取得為此班次第幾個通過的車站(PassRank)
			select @rank = ST.Rank from ST where ST.SID = @SID and ST.TID = @TID

			--更新班次狀態
			update Transportation set PassRank = @rank, DelayTime = @Delay where TID = @TID

			--如班次已通過最末站，則清除班次狀態
			if ( @SID = (select EndStop from Transportation where TID = @TID) )
			begin
				update Transportation set PassRank = NULL, DelayTime = NULL where TID = @TID
			end
		commit transaction
	end try
	begin catch
		if XACT_STATE() <> 0
		begin
			rollback transaction
		end
		select
			ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage
	end catch
	set xact_abort off
end
go

-- xp_insertDailyTimetable(2018/07/12 完成)
if exists(select * from sys.objects o where o.name = N'xp_insertDailyTimetable' and type in ('P') )
	drop procedure xp_insertDailyTimetable
go
create procedure xp_insertDailyTimetable
	-- Class
	@directory nvarchar(255),
	@Year nvarchar(255),
	@Month nvarchar(255),
	@Day nvarchar(255),
	-- Transportation
	@Number nvarchar(255),
	@md5 nvarchar(255)
as
begin
	set xact_abort on
	begin try
		begin transaction
		declare @CID int, @OID int, @count int
		-- 判斷目錄是否存在
		if not exists(
			select CID from Class 
			where NamePath = '首頁/班次/' + @directory + '/' +　@Year + '/' + @Month + '/' + @Day
		)
		begin
			-- 判斷年份目錄是否存在
			if not exists(
				select CID from Class 
				where NamePath = '首頁/班次/' + @directory + '/' +　@Year
			)
			begin
				select @CID = CID from Class where NamePath =  '首頁/班次/' + @directory
				exec dbo.xp_insertClass2 @CID, 102, @Year, @Year
			end
			-- 判斷月份目錄是否存在
			if not exists(
				select CID from Class 
				where NamePath = '首頁/班次/' + @directory + '/' +　@Year + '/' + @Month
			)
			begin
				select @CID = CID from Class where NamePath =  '首頁/班次/' + @directory + '/' + @Year
				exec dbo.xp_insertClass2 @CID, 102, @Month, @Month
			end
			-- 日期目錄一定不存在
			select @CID = CID from Class where NamePath =  '首頁/班次/' + @directory + '/' + @Year + '/' + @Month
			exec dbo.xp_insertClass2 @CID, 102, @Day, @Day
		end

		-- 取得CID
		select @CID = CID, @count = nObject from Class 
		where NamePath = '首頁/班次/' + @directory + '/' + @Year + '/' + @Month + '/' + @Day
		-- 取得OID
		select @OID = TID from Class C, CO, Transportation T
		where C.CID = CO.CID and CO.OID = T.TID and C.Type = 102 and C.NamePath like '%' + @directory
		and T.Number = @Number and T.MD5 = @md5
		-- 建CO關聯
		if not exists(
			select * from CO where CO.CID = @CID and CO.OID = @OID
		)
		begin
			insert into CO(CID, OID) values(@CID, @OID)
			-- 增加 nObject
			update Class set nObject = @count + 1 where CID = @CID ;
		end
		-- 若班次臨時改點，於CO刪除舊資料
		if exists(
			select * from CO, Transportation T
			where CO.CID = @CID and CO.OID = T.TID and T.Number = @Number and T.MD5 != @md5
		)
		begin
			declare @old_OID int
			select @old_OID = OID from CO, Transportation T
			where CO.CID = @CID and CO.OID = T.TID and T.Number = @Number and T.MD5 != @md5

			delete from CO where CO.CID = @CID and CO.OID = @old_OID
		end
		commit transaction
	end try
	begin catch
		if XACT_STATE() <> 0
		begin
			rollback transaction
		end
		select
			ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage
	end catch
	set xact_abort off
end
go

--xp_insertBus(2018/07/14 完成)
if exists(select * from sys.objects o where o.name = N'xp_insertBus' and type in ('P') )
	drop procedure xp_insertBus
go
create procedure xp_insertBus
	-- Class
	@directory nvarchar(255),
	-- Object
	@CName nvarchar(255),	     -- 路線名字
	@EName nvarchar(255),
	@Cheadsign  nvarchar(800), -- 路線描述
	@Eheadsign  nvarchar(800),
	-- Transportation
	@RouteID nvarchar(255),    -- 班次唯一ID
	@Direction bit             -- 0去程1返程
as
begin
	set xact_abort on
	begin try
		begin transaction
			declare @CID int, @OID int, @count int ;
			-- 判斷班次是否存在
			if exists (
				select * from Class C, CO, Object O, Transportation T
				where C.CID = CO.CID and CO.OID = O.OID and O.OID = T.TID 
				and C.Type = 102 and C.NamePath like '%'+ @directory and T.Number = @RouteID and T.Direction = @Direction
			)
			begin
				-- 取得OID
				select @OID = O.OID from Class C, CO, Object O, Transportation T
				where C.CID = CO.CID and CO.OID = O.OID and O.OID = T.TID 
				and C.Type = 102 and C.NamePath like '%'+ @directory and T.Number = @RouteID and T.Direction = @Direction
				--更新Object及資料確認日期(OtherDT)
				update Object set CName = @CName, EName = @EName, CDes = @Cheadsign, 
				       EDes = @Eheadsign, OtherDT = getdate()	where OID = @OID ;
			end
			else
			begin
				-- 插入班次
				insert into Object(Type, CName, EName, CDes, EDes, OtherDT) 
							values(102, @CName, @EName, @Cheadsign, @Eheadsign, getdate()) ;
				set @OID = @@identity ;
				insert into Transportation(TID, Number, Direction)
							values(@OID, @RouteID, @Direction) ;
				-- 建CO關連
				select @CID = CID, @count = nObject from Class 
				       where Type = 102 and NamePath like '%' + @directory ;
				insert into CO(CID, OID) values (@CID, @OID) ;
				-- 增加 nObject
				update Class set nObject = @count + 1 where CID = @CID ;
			end
		commit transaction
	end try 
	begin catch
		if XACT_STATE() <> 0
		begin
			rollback transaction
		end
		select
			ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage
	end catch
	set xact_abort off
end
go

-- xp_checkBus(檢查路線資料是否有更動)(2018/07/14 完成)
if exists(select * from sys.objects o where o.name = N'xp_checkBus' and type in ('P') )
	drop procedure xp_checkBus
go
create procedure xp_checkBus
	-- Class
	@directory nvarchar(255),
	-- Transportation
	@RouteID nvarchar(255),
	@Direction bit,
	@md5 nvarchar(255)
as
begin
	set xact_abort on
	begin try
		begin transaction
			declare @TID int
			-- 若沒MD5，則為新班次
			if exists(
				select * from Class C, CO, Object O, Transportation T
				where C.CID = CO.CID and CO.OID = O.OID and O.OID = T.TID 
				and C.Type = 102 and C.NamePath like '%'+ @directory and T.Number = @RouteID and T.Direction = @Direction and T.MD5 is null
			)
			begin
				select @TID = O.OID from Class C, CO, Object O, Transportation T
				where C.CID = CO.CID and CO.OID = O.OID and O.OID = T.TID 
				and C.Type = 102 and C.NamePath like '%'+ @directory and T.Number = @RouteID and T.Direction = @Direction
				-- 加入md5
				update Transportation set MD5 = @md5 where TID = @TID
			end
			-- 若MD5不同，則路線資料更動，需將原資料(ST、TS)刪除
			else if exists(
				select * from Class C, CO, Object O, Transportation T
				where C.CID = CO.CID and CO.OID = O.OID and O.OID = T.TID 
				and C.Type = 102 and C.NamePath like '%'+ @directory and T.Number = @RouteID and T.Direction = @Direction and T.MD5 != @md5
			)
			begin
				select @TID = O.OID from Class C, CO, Object O, Transportation T
				where C.CID = CO.CID and CO.OID = O.OID and O.OID = T.TID 
				and C.Type = 102 and C.NamePath like '%'+ @directory and T.Number = @RouteID and T.Direction = @Direction
				--更新md5
				update Transportation set MD5 = @md5 where TID = @TID
				--將原與此路線相關的ST、TS刪除
				delete ST where TID = @TID
				delete TS where TID = @TID
			end
		commit transaction
	end try 
	begin catch
		if XACT_STATE() <> 0
		begin
			rollback transaction
		end
		select
			ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage
	end catch
	set xact_abort off
end
go

-- xp_insertBusST(2018/07/14 完成)
if exists(select * from sys.objects o where o.name = N'xp_insertBusST' and type in ('P') )
	drop procedure xp_insertBusST
go
create procedure xp_insertBusST
	-- Class
	@directory nvarchar(255),
	-- Transportation
	@RouteID nvarchar(255),
	@Direction bit,
	-- Stop
	@StopID nvarchar(255),
	@StopName nvarchar(255),
	@Rank int
as
begin
	set xact_abort on
	begin try
		begin transaction
			declare @SID int, @TID int
			--取得SID
			select @SID = SID from Class C, CO, Object O, Stop S
				   where C.CID = CO.CID and CO.OID = O.OID and O.OID = S.SID 
				   and C.Type = 101 and C.NamePath like '%站點%' + @directory
				   and O.CName = @StopName and S.StopID = @StopID ;
			--取得TID
			select @TID = TID from Class C, CO, Object O, Transportation T
				   where C.CID = CO.CID and CO.OID = O.OID and O.OID = T.TID
				   and C.Type = 102 and C.NamePath like '%'+ @directory
				   and T.Number = @RouteID and T.Direction = @Direction ;
			--建ST
			if not exists(
				select SID from ST where ST.SID = @SID and ST.TID = @TID
			)
			begin
				insert into ST(SID, TID, Rank)
					        values(@SID, @TID, @Rank)
			end
			--建TS
			if not exists(
				select SID from TS where TS.TID = @TID and TS.SID = @SID
			)
			begin
				insert into TS(TID, SID, Rank)
					        values(@TID, @SID, @Rank)
			end
		commit transaction
	end try 
	begin catch
		if XACT_STATE() <> 0
		begin
			rollback transaction
		end
		select
			ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage
	end catch
	set xact_abort off
end
go

--xp_deleteBus
if exists(select * from sys.objects o where o.name = N'xp_deleteBus' and type in ('P') )
	drop procedure xp_deleteBus
go
create procedure xp_deleteBus
	@time nvarchar(255),
	@directory nvarchar(255)
as
begin
	set xact_abort on
	begin try
		begin transaction
			declare @temp1 table(OID int)
			declare @temp2 table(OID int)

			insert into @temp1
			select O.OID from Class C, CO, Object O
			where C.CID = CO.CID and CO.OID = O.OID
			and O.Type = 101 and @time > convert(nvarchar(255),O.OtherDT,120) and C.NamePath like '%站點%' + @directory

			insert into @temp2
			select O.OID from Class C, CO, Object O
			where C.CID = CO.CID and CO.OID = O.OID
			and O.Type = 102 and @time > convert(nvarchar(255),O.OtherDT,120) and C.NamePath like '%' + @directory
			
			-- 先刪ST、TS
			delete ST where TID in
			(select OID from @temp2)
			delete TS where TID in 
			(select OID from @temp2)
			-- 再刪Transportation
      ALTER TABLE Transportation NOCHECK CONSTRAINT ALL;
      ALTER INDEX ALL ON Transportation DISABLE;
      ALTER INDEX ALL ON Transportation REBUILD;
      ALTER TABLE Transportation CHECK CONSTRAINT ALL;
			delete Transportation where TID in 
			(select OID from @temp2)
      delete CO where OID in
      (select OID from @temp2)
			delete Object where OID in 
			(select OID from @temp2)
			-- 最後刪Stop
      ALTER TABLE Stop NOCHECK CONSTRAINT ALL;
      ALTER INDEX ALL ON Stop DISABLE;
      ALTER INDEX ALL ON Stop REBUILD;
      ALTER TABLE Stop CHECK CONSTRAINT ALL;
			delete Stop where SID in 
			(select OID from @temp1)
      delete CO where OID in
      (select OID from @temp1)
      delete BO where OID in
      (select OID from @temp1)
			delete Object where OID in 
			(select OID from @temp1)
		commit transaction
	end try 
	begin catch
		if XACT_STATE() <> 0
		begin
			rollback transaction
		end
		select
			ERROR_NUMBER() as ErrorNumber,
			ERROR_MESSAGE() as ErrorMessage
	end catch
	set xact_abort off
end
go