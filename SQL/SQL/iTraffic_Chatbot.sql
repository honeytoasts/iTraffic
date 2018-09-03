use [$(DBName)]
go

--xp_Chatbot
if exists(select * from sys.objects o where o.name = N'xp_Chatbot' and type in ('P') )
  drop procedure xp_Chatbot
go
create procedure xp_Chatbot
  @FBID nvarchar(255),
  @answer nvarchar(255)
  -- , @response nvarchar(255) output
as
begin
	set xact_abort on --指定當 Transact-SQL 陳述式產生執行階段錯誤時，SQL Server 是否自動回復目前的交易
	begin try
		begin transaction --下面的過程設定為一整筆交易動作
      declare @number int

      -- 檢查是否用過系統
      if not exists(select * from Chatbot where FBID = @FBID)
        insert into Chatbot(FBID) values(@FBID)
      -- 問到哪個階段
      select @number = Number from Chatbot where FBID = @FBID

      if (@answer = '台鐵')
      begin
        update Chatbot set Type = '台鐵', Number = 2, Response = '哪一站上車?(例: 台北)' where FBID = @FBID
      end
      else if (@answer = '高鐵')
      begin
        update Chatbot set Type = '高鐵', Number = 2, Response = '哪一站上車?(例: 台北)' where FBID = @FBID
      end
      else if exists(select * from vd_StopListZh where stop = @answer)
      begin
        declare @stopID nvarchar(255), @type nvarchar(255)
        select @type = Type from Chatbot where FBID = @FBID
        if (@number = 2)
        begin
          select @stopID = stopID from vd_StopListZh where type = @type and stop = @answer
          update Chatbot set fromStop = @stopID, Number = 3, Response = '哪一站下車?(例: 台中)' where FBID = @FBID
          -- set @response = '哪一站下車?(例: 台中)'
        end
        else if (@number = 3)
        begin
          select @stopID = stopID from vd_StopListZh where type = @type and stop = @answer
          update Chatbot set toStop = @stopID, Number = 4, Response = '出發日期?(例: 2018-08-30)' where FBID = @FBID
        end
      end
      else if (@answer like '____-__-__' and @number = 4)
      begin
        update Chatbot set Dates = @answer, Number = 5, Response = '出發時間?(例: 08:00)' where FBID = @FBID
      end
      else if (@answer like '__:__' and @number = 5)
      begin
        update Chatbot set Times = @answer, Number = 1 where FBID = @FBID

        declare @types nvarchar(255), @fromStop nvarchar(255), @toStop nvarchar(255), @date nvarchar(255), @time nvarchar(255)
        select @types = Type, @fromStop = fromStop, @toStop = toStop, @date = Dates, @time = Times from Chatbot where FBID = @FBID
        if (@types = '台鐵')
        begin
          update Chatbot set Response = 'url https://chatbot.csie.ncnu.edu.tw:923/timetablelist/TRA?from=' + @fromStop + '&to=' +
            @toStop + '&date=' + @date + '&time=' + @time where FBID = @FBID
        end
        else if (@types = '高鐵')
        begin
          update Chatbot set Response = 'url https://chatbot.csie.ncnu.edu.tw:923/timetablelist/THSR?from=' + @fromStop + '&to=' +
            @toStop + '&date=' + @date + '&time=' + @time where FBID = @FBID
        end
      end
      else
      begin
        if (@number > 1)
        begin
          update Chatbot set Response = '您輸入的查詢條件有誤，請重新輸入' where FBID = @FBID
        end
        else
        begin
          update Chatbot set Response = '我聽不懂QAQ' where FBID = @FBID
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