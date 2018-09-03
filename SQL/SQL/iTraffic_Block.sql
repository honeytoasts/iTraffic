use [$(DBName)]
go

/***
	stored procedure
***/

--xp_BlockWeight 算Block權重
/*
Block範圍:
每0.002度為一個Block
經度:119.000 ~ 122.100 (1550行)，緯度:21.800 ~ 25.300 (1750列)，共 2,712,500格
公式:BID = count(COLUMN) * (ROW_ID -1) + COLUMN_ID (BID = 3100 * (ROW_ID -1) + COLUMN_ID)
ROW_ID = ((latitude捨去至小數點第三位*1000) - (21.800 * 1000))/2 + 1
COLUMN_ID = ((longitude捨去至小數點第三位*1000) - (119.000 * 1000))/2 + 1
*/
if exists(select * from sys.objects o where o.name = N'xp_BlockWeight' and type in ('P') )
  drop procedure xp_BlockWeight
go
create procedure xp_BlockWeight
  @level int 
as
begin
	set xact_abort on --指定當 Transact-SQL 陳述式產生執行階段錯誤時，SQL Server 是否自動回復目前的交易
	begin try
		begin transaction --下面的過程設定為一整筆交易動作
      update Block set Weight = NULL
      declare @BID int, @beginBID int, @type binary(1), @i int, @j int, @weight int

      declare ccursor cursor for select BID from Block
      open ccursor
      fetch next from ccursor into @BID
      while @@FETCH_STATUS = 0
      begin
        set @beginBID = @BID - 1550 * @level - @level - 1
        set @weight = 0
        set @i = 1
        while ( @i <= 2 * @level + 1)
        begin
          set @j =  1
          while ( @j <= 2 * @level + 1)
          begin
            set @beginBID = @beginBID + 1
            declare ncursor cursor for select Type from BO where BID = @beginBID
            open ncursor
            fetch next from ncursor into @type
            while @@FETCH_STATUS = 0
            begin
              if  (@type = 1) 	   set @weight = @weight + 100   -- 高鐵
              else if (@type = 2)  set @weight = @weight + 100   -- 台鐵
              else if (@type = 4)	 set @weight = @weight + 50    -- 捷運
              else if (@type = 8)  set @weight = @weight + 5     -- 公路客運
              else if (@type = 16) set @weight = @weight + 1     -- 市區公車
              fetch next from ncursor into @type
            end
            close ncursor
            deallocate ncursor
            set @j = @j + 1
          end
          set @i = @i + 1
          set @beginBID = @beginBID - ( 2 * @level + 1 ) + 1550
        end
        update Block set Weight = @weight where BID = @BID
        fetch next from ccursor into @BID
      end
      close ccursor
      deallocate ccursor
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

--xp_Keyblock
if exists(select * from sys.objects o where o.name = N'xp_Keyblock' and type in ('P') )
  drop procedure xp_Keyblock
go
create procedure xp_Keyblock
  @Weight int
as
begin
	set xact_abort on --指定當 Transact-SQL 陳述式產生執行階段錯誤時，SQL Server 是否自動回復目前的交易
	begin try
		begin transaction --下面的過程設定為一整筆交易動作
      declare @city nvarchar(255), @county nvarchar(255)
      declare @temp table (BID int)

      declare ccursor cursor for select * from City
      open ccursor
      fetch next from ccursor into @city, @county
      while @@FETCH_STATUS = 0
      begin
        insert into @temp
        select distinct B.BID from Class C, CO, Block B, BO, Object O, Stop S
        where C.CID = CO.CID and CO.OID = O.OID and B.BID = BO.BID and BO.OID = O.OID and O.OID = S.SID and O.Type = 101
        and C.NamePath like '%站點%' and replace(O.CName,'臺','台') like '%' + @city + '%' --@county+ '%'
        and ((C.CName = '公路客運' and replace(S.Address,'臺','台') like '%' + @city + '%')
        or C.CName like '%' + @city + '%') and B.Weight >= @Weight

        fetch next from ccursor into @city, @county
      end
      close ccursor
      deallocate ccursor

      -- 台鐵、高鐵所在的Block也都算Keyblock
      insert into @temp
      select distinct B.BID from Class C, CO, Block B, BO, Object O
      where C.CID = CO.CID and CO.OID = O.OID and B.BID = BO.BID and BO.OID = O.OID and O.Type = 101
      and (C.CName = '台鐵' or C.CName = '高鐵') and C.NamePath like '%站點%'

      delete Keyblock
      insert into Keyblock select distinct BID from @temp
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