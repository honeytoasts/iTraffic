use [$(DBName)]
go

--啟用CLR功能
EXEC sp_configure 'clr enable', '1'
go
RECONFIGURE
go

--Create Assembly
if exists ( select * from  sys.assemblies asms where asms.name = N'BitwiseOperatorsCLRFunc' )
	drop assembly BitwiseOperatorsCLRFunc
go

if exists ( select * from sys.objects o where o.name = N'fn_checkBitValue' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_checkBitValue
go

if exists ( select * from sys.objects o where o.name = N'fn_setBitValue' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_setBitValue
go

create assembly BitwiseOperatorsCLRFunc from '$(DLLDir)\BitwiseOperators.dll' with permission_set = unsafe
go

create function fn_checkBitValue(@BinaryData varbinary(16), @Position int)
	returns bit with execute as caller
as
	external name BitwiseOperatorsCLRFunc.UserDefinedFunctions.checkBitValue
go

create function fn_setBitValue(@BinaryData varbinary(16), @Position int, @SettingValue bit)
	returns binary(16) with execute as caller
as
	external name BitwiseOperatorsCLRFunc.UserDefinedFunctions.setBitValue
go

/*
Sample
--1.) fn_checkBitValue 查詢是否有該領域
-- select * from Keywords where dbo.fn_checkBitValue(@BinaryData, @Position ) = @Value
輸入參數 :
	@BinaryData :  Binary 資料
	@Position : 要檢查的 bit 位置
範圍 : 1~ 128
輸出結果 :
	0 或 1

select * from Keywords where dbo.fn_checkBitValue(Field, 5) = 1


--fn_setBitValue
-- update Keywords set Field = dbo.fn_setBitValue(@BinaryData, @Position , @Value ) where words = @CName
更新 Binary 資料欄位中的某一 bit 值
輸入參數 :
	@BinaryData : Binary資料
	@Position : 要更新的 bit 位置
範圍 : 1~ 128
	@Value : 0或是1
輸出結果 :
	更新後的 Binary 資料

update Keywords set Field = dbo.fn_setBitValue(Field, 4, 1) where words = '國家'

*/

/***
	Function
***/

if exists ( select * from sys.objects o where o.name = N'fn_getMD5Encode' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_getMD5Encode
go
create function fn_getMD5Encode(@String nvarchar(16))
	returns nvarchar(32)
as
begin
	return (select convert(nvarchar(32), hashbytes('MD5', @String),2))
end
go

--取得nLevel資料
if exists ( select * from sys.objects o where o.name = N'fn_getLevel' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_getLevel
go
create function fn_getLevel(@CID int)
	returns int
as
begin
	return (select nLevel from Class where CID = @CID) + 1
end
go

--取得NamePath資料
if exists ( select * from sys.objects o where o.name = N'fn_getPath' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_getPath
go
create function fn_getPath(@CID int, @CName nvarchar(255))
	returns nvarchar(900)
as
begin
	declare @nLevel int = (select nLevel from Class where CID = @CID)
	declare @NamePath nvarchar(900)
	--if (@nLevel = 0)
		--set @NamePath = @CName
	--else
		set @NamePath = (select NamePath + '/' + @CName from Class where CID = @CID)
	return @NamePath
end
go

--取得IDPath資料
if exists ( select * from sys.objects o where o.name = N'fn_getIDPath' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_getIDPath
go
create function fn_getIDPath(@PCID int, @CID int)
	returns varchar(255)
as
begin
	declare @nLevel int = (select nLevel from Class where CID = @PCID)
	declare @IDPath nvarchar(900)
	--if (@nLevel = 0)
		--set @IDPath = convert(nvarchar(max), @CID)
	--else
		set @IDPath = (select IDPath + '/' + convert(nvarchar(max), @CID) from Class where CID = @PCID)
	return @IDPath
end
go

--fn_Split用字元切字串
if exists ( select * from sys.objects o where o.name = N'fn_Split' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_split
go
Create function fn_split(@String nvarchar(255), @Symbol nchar(1))
	returns @Strings table(Word nvarchar(255) not null)
begin
	declare @TmpString nvarchar(255)

	while(len(@String) > 0)
	begin
		if (Charindex(@Symbol, @String) = 0)
		begin
			insert into @Strings values(@String)
			set @String = ''
		end
		else
		begin
			set @TmpString = substring(@String, 1, Charindex(@Symbol, @String) - 1)
			insert into @Strings values(@TmpString)
			set @String = subString(@String, Charindex(@Symbol, @String) + 1, len(@String))
		end
	end
	return
end
go

--取得Class路徑列表，以table呈現
if exists ( select * from sys.objects o where o.name = N'fn_getClassPath' and o.type in (N'FT', N'FN', N'TF','FS') )
	drop function fn_getClassPath
go
create function fn_getClassPath (@CID int)
	returns @ClassPath table(CID int Primary Key not null, CName nvarchar(255))
as
begin
	declare @IDPath varchar(255), @NamePath varchar(900),@ID int, @CName nvarchar(255)
	select @IDPath = IDPath, @NamePath = NamePath from Class where CID = @CID
	declare IDPathSet cursor for select * from fn_Split(@IDPath, '/')
	declare NamePathSet cursor for select * from fn_Split(@NamePath, '/')
	open IDPathSet
	open NamePathSet
	Fetch next from IDPathSet into @ID
	Fetch next from NamePathSet into @CName
	while(@@Fetch_Status <> -1)
	begin
		insert into @ClassPath values(@ID, @CName)
		Fetch next from IDPathSet into @ID
		Fetch next from NamePathSet into @CName
	end
	close IDPathSet
	close NamePathSet
	deallocate IDPathSet
	deallocate NamePathSet

	return
end
go

/***
	Stored procedure
***/

--xp_insertClass(有回傳值)
if exists(select * from sys.objects o where o.name = N'xp_insertClass' and type in ('P') )
	drop procedure xp_insertClass
go
create procedure xp_insertClass
	@PCID int,				--c.CID，父節點
	@Type int,				--c.Type
	@CName nvarchar(400),	--c.CName
	@EName nvarchar(400), --c.EName
	@CCID int output		--c.CID,新產生的節點，回傳
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

				--設定回傳值
				set @CCID = @CID
			end
			else
			begin
				set @CCID = null
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

--xp_deleteClass
if exists(select * from sys.objects o where o.name = N'xp_deleteClass' and type in ('P') )
	drop procedure xp_deleteClass
go
create procedure xp_deleteClass
	@CID int
as
begin
	set xact_abort on --指定當 Transact-SQL 陳述式產生執行階段錯誤時，SQL Server 是否自動回復目前的交易
	begin try
		begin transaction --下面的過程設定為一整筆交易動作
			delete CO where CID = @CID
			delete Permission where CID = @CID
			delete Inheritance where CCID = @CID or PCID = @CID
			delete Class where CID = @CID
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

--xp_insertUrl
if exists(select * from sys.objects o where o.name = N'xp_insertUrl' and type in ('P') )
	drop procedure xp_insertUrl
go
create procedure xp_insertUrl
	@CName nvarchar(800),	--Object.CName
	@CDes nvarchar(800),	--Object.CDes
	@Scheme nvarchar(10),	--URLScheme.Scheme
	@HostName nvarchar(80), --URL.HostName
	@Path nvarchar(1000),	--URL.Path
	@MID int,
	@Keywords nvarchar(255)
as
begin
	set xact_abort on --指定當 Transact-SQL 陳述式產生執行階段錯誤時，SQL Server 是否自動回復目前的交易
	begin try
		begin transaction --下面的過程設定為一整筆交易動作
			declare @UID int -- URL中的UID指向Object的OID
			declare @SID int
			declare @URL nvarchar(4000) = (@Scheme + '://' + @HostName + @Path)

			if not exists (select SID from URLScheme where Scheme = @Scheme)
				insert Into URLScheme(SCheme) Values (@Scheme);
			select @SID = SID from URLScheme where [Scheme] = @Scheme

			if not exists (select UID from URL where MD5 = HashBytes('MD5', @URL))
			begin -- 若URL不存在, 才Insert URL並取出UID(即OID)
				insert into Object([Type], CName, CDes, OwnerMID) Values(1, @CName, @CDes, @MID)
				set @UID = @@Identity
				insert into URL(UID, [Scheme], HostName, [Path], MD5URL, MD5, Keywords)
					values(@UID, @SID, @HostName, @Path, HashBytes('MD5', @URL), HashBytes('MD5', @URL), @Keywords)
			end
			else
			begin -- 若URL存在, 取出URL的UID(即OID)
				select @UID = UID from URL where MD5 = HashBytes('MD5', @URL)
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