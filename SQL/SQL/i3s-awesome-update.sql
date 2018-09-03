
Create function checkpermission_subclass(@CID int,@MID int)
returns @CT table(CID int)
as
begin
	declare @ID int
	if not exists (select permissionbits from Permission where 
	cid=@CID and roletype=CAST(1 AS bit) and roleid=@MID and 
	PermissionBits&7=7)
	begin
		if exists (select cid from permission where cid=@CID and roletype=CAST(0 AS bit)
		and roleid in (select gid from gm where mid=@MID)
		and permissionbits&7=7)
		begin
			declare cidcursor cursor for select distinct cid from permission where 
			cid in(select ccid from inheritance where pcid=@CID) and
			roletype=CAST(0 AS bit) and
			roleid in (select gid from gm where mid=@MID) and permissionbits&1=1 
			open cidcursor
			Fetch next from cidcursor into @ID
			while(@@Fetch_Status <> -1)
			begin
				insert into @CT values(@ID)
				Fetch next from cidcursor into @ID
			end
			close cidcursor
			deallocate cidcursor
		end
	end
	else 
		begin
		declare cidcursor cursor for select cid from permission where 
		cid in(select ccid from inheritance where pcid=@CID) and
		roletype=CAST(1 AS bit) and
		roleid=@MID and permissionbits&1=1
		open cidcursor
		Fetch next from cidcursor into @ID
		while(@@Fetch_Status <> -1)
		begin
			insert into @CT values(@ID)
			Fetch next from cidcursor into @ID
		end
		close cidcursor
		deallocate cidcursor
		end
		return
end
go
 --------------------------------------------------------------------------------------------------------
 -- select * from class where cid in(select * from checkpermission_subclass(0,1))-------------------------
 --------------------------------------------------------------------------------------------------------

Create function checkpermission_objlist(@CID int,@MID int)
returns @CT table(CID int)
as
begin
	if exists(select permissionbits from permission where cid=@CID 
	and roletype=CAST(1 AS bit) and roleid=@MID
	and permissionbits&7=7) 
	begin
		insert into @CT values(@CID)
	end

	else if exists(select permissionbits from permission where cid=@CID
	and roletype=CAST(0 AS bit) and roleid in(select gid from gm where mid=@MID)
	and permissionbits&7=7)
	begin 
		insert into @CT values(@CID)
	end
	return
end
go

 --------------------------------------------------------------------------------------------------------
 --select * from class where cid in(select * from checkpermission_objlist(0,1));-------------------------
 --------------------------------------------------------------------------------------------------------
 
/*----------------------------------------------------------------------------*/


Create function getPassportcodeMember(@passportcode nvarchar(32))
returns @MT table(MID int)
as
begin
	declare @ID int
	if @passportcode is null  
	begin 
		declare midcursor cursor for select mid from member where Account='Guest'
		open midcursor
		Fetch next from midcursor into @ID
		if(@@Fetch_Status <> -1)
		begin
			insert into @MT values(@ID)
		end	
		close midcursor
		deallocate midcursor
	end
	else
	begin
		declare midcursor2 cursor for select mid from msession where passportcode like @passportcode
		open midcursor2
		Fetch next from midcursor2 into @ID
		if(@@Fetch_Status <> -1)
			begin
				insert into @MT values(@ID)
			end
		else
			begin
				declare midcursor3 cursor for select mid from member where Account='Guest'
				open midcursor3
				Fetch next from midcursor3 into @ID
				if(@@Fetch_Status <> -1)
				begin
					insert into @MT values(@@Fetch_Status)
					insert into @MT values(@@Fetch_Status)
				end	
				close midcursor3
				deallocate midcursor3
			end
		close midcursor2
		deallocate midcursor2
	end
	return
end
go
/*----------------------------------------------------------------------------*/

/* CData Table*/
create table CData
(
	DID int identity(1,1) not null,
	DName nvarchar(255) null,
	NSpace nvarchar(20) null,
	Condition nvarchar(800) null,
	LimitNum smallint null,
	Sort nvarchar null,
	SortDesc bit null default(1),
	PermissionLevel smallint NOT NULL default(0),
	Name nvarchar(255) null,
	Des nvarchar(800) null,
	constraint PK_CData primary key clustered (DID)
)
go
/*----------------------------------------------------------------------------*/
insert into CData(DName,NSpace,PermissionLevel) values('vd_subclass','Dublin Core',2);
/*----------------------------------------------------------------------------*/
insert into CLayout(LName,LDes) values('i3s-awesome','i3s awesome index page');
/*----------------------------------------------------------------------------*/
update class set Layout=1 where cid in(1); 
go
/*----------------------------------------------------------------------------*/
create view vs_ClassLayout as
select c.CID as CID, l.LID as LID, l.LName as Layout from Class c, CLayout l
 where c.Layout = l.LID;
 go
 /*----------------------------------------------------------------------------*/
insert into gm values(1,0,1,1,1) go
 /*----------------------------------------------------------------------------*/
insert into cdata(dname,NSpace,PermissionLevel)
values('vd_ObjectList','Dublin Core',1),('vd_ShowObject','Dublin Core',0)
go
 /*----------------------------------------------------------------------------*/
