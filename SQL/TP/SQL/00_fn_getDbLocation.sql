use $(DBName)
-- declare @DBName varchar(3) = 'iEN3'
go

-- if exists ( select * from sys.objects where object_id = object_id(N'sp_DatabaseName_Repair') and type in ('P') )
-- 	drop procedure sp_DatabaseName_Repair
-- go

-- create procedure sp_DatabaseName_Repair --@sys_name output
-- as
-- begin
-- 	declare @databasename nvarchar(max) = db_name()
-- 	declare @databasename_org nvarchar(max) = ( select top 1 name from sys.master_files where file_guid is not null and data_space_id = 1 and physical_name like '%'+ db_name() +'_data.mdf%')
-- 	exec ( 'alter database ['+@databasename+'] modify file ( NAME=N'''+@databasename_org +''', NEWNAME=N''New_logical_name_Temp'')' )
-- 	exec ( 'alter database ['+@databasename+'] modify file ( NAME=N''New_logical_name_Temp'', NEWNAME=N'''+ @databasename+'_data'')')
-- 	-- alter database [DatabaseName] modify file ( NAME=N'old_logical_name', NEWNAME=N'New_logical_name_Temp')
-- 	-- alter database [DatabaseName] modify file ( NAME=N'New_logical_name_Temp', NEWNAME=N'New_logical_name')
-- 	--set @sys_name = ( select top 1 name from sys.master_files where file_guid is not null and data_space_id = 1 and physical_name like '%'+ db_name() +'_data.mdf%')
-- end
-- go

if exists( select * from sys.objects where object_id = object_id( N'fn_getDbFilePath' ) and type = 'FN' )
	drop function fn_getDbFilePath
go

create function fn_getDbFilePath ( @dbname varchar(100) )
	returns varchar(1000)
as
begin
	return ( select top 1 physical_name from sys.master_files where name = ( @dbname + '_data' ) )
end
go

if exists ( select * from sys.objects where object_id = object_id( N'fn_getDbPath' ) and type = 'FN' )
	drop function fn_getDbPath
go
create function fn_getDbPath ( @dbname varchar(100) )
	returns varchar(1000)
as
begin
	declare @s varchar(1000)
	select @s = dbo.fn_getDbFilePath(@dbname)
	return substring( @s, 1, charindex( @dbname, @s ) - 1 )
end
go
