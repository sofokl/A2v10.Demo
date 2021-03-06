﻿/*
------------------------------------------------
Copyright © 2008-2018 Alex Kukhtin

Last updated : 15 jan 2018 
module version : 7007
*/
------------------------------------------------
set noexec off;
go
------------------------------------------------
if DB_NAME() = N'master'
begin
	declare @err nvarchar(255);
	set @err = N'Error! Can not use the master database!';
	print @err;
	raiserror (@err, 16, -1) with nowait;
	set noexec on;
end
go
------------------------------------------------
set nocount on;
if not exists(select * from a2sys.Versions where Module = N'demo')
	insert into a2sys.Versions (Module, [Version]) values (N'demo', 7007);
else
	update a2sys.Versions set [Version] = 7007 where Module = N'demo';
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SCHEMATA where SCHEMA_NAME=N'a2demo')
begin
	exec sp_executesql N'create schema a2demo';
end
go
------------------------------------------------
-- Tables
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2demo' and SEQUENCE_NAME=N'SQ_Agents')
	create sequence a2demo.SQ_Agents as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2demo' and TABLE_NAME=N'Agents')
begin
	create table a2demo.Agents
	(
		Id	bigint not null constraint PK_Agents primary key
			constraint DF_Agents_PK default(next value for a2demo.SQ_Agents),
		Kind nvarchar(255) null,
		Void bit not null
			constraint DF_Agents_Void default(0),
		Parent bigint null
			constraint FK_Agents_Parent_Agents foreign key references a2demo.Agents(Id),
		[Code] nvarchar(32) null,
		[Name] nvarchar(255) null,
		[Tag] nvarchar(255) null,
		[Memo] nvarchar(255) null,
		DateCreated datetime not null constraint DF_Agents_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Agents_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Agents_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Agents_UserModified_Users foreign key references a2security.Users(Id)
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2demo' and SEQUENCE_NAME=N'SQ_Units')
	create sequence a2demo.SQ_Units as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2demo' and TABLE_NAME=N'Units')
begin
	create table a2demo.Units
	(
		Id	bigint not null constraint PK_Units primary key
			constraint DF_Units_PK default(next value for a2demo.SQ_Units),
		Void bit not null
			constraint DF_Units_Void default(0),
		[Short] nvarchar(32) null,
		[Name] nvarchar(255) null,
		[Memo] nvarchar(255) null,
		DateCreated datetime not null constraint DF_Units_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Units_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Units_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Units_UserModified_Users foreign key references a2security.Users(Id)
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2demo' and SEQUENCE_NAME=N'SQ_Entities')
	create sequence a2demo.SQ_Entities as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2demo' and TABLE_NAME=N'Entities')
begin
	create table a2demo.Entities
	(
		Id	bigint not null constraint PK_Entities primary key
			constraint DF_Entities_PK default(next value for a2demo.SQ_Entities),
		Kind nvarchar(255) null,
		Void bit not null
			constraint DF_Entities_Void default(0),
		Parent bigint null
			constraint FK_Entities_Parent_Entities foreign key references a2demo.Entities(Id),
		[Article] nvarchar(64) null,
		[Name] nvarchar(255) null,
		[Tag] nvarchar(255) null,
		[Memo] nvarchar(255) null,
		Unit bigint null
			constraint FK_Entities_Unit_Units foreign key references a2demo.Units(Id),
		DateCreated datetime not null constraint DF_Entities_DateCreated default(getdate()),
		UserCreated bigint not null 
			constraint FK_Entities_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Entities_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Entities_UserModified_Users foreign key references a2security.Users(Id)
	);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2demo' and SEQUENCE_NAME=N'SQ_Documents')
	create sequence a2demo.SQ_Documents as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2demo' and TABLE_NAME=N'Documents')
begin
	create table a2demo.Documents
	(
		Id	   bigint not null constraint PK_Documents primary key
			constraint DF_Documents_PK default(next value for a2demo.SQ_Documents),
		Kind nvarchar(255) null,
		Parent bigint null
			constraint FK_Document_Parent_Documents foreign key references a2demo.Documents(Id),
		Done bit not null constraint DF_Documents_Done default(0),
		[Date] datetime null,
		[No]   int      null,
		Agent  bigint   null
			constraint FK_Document_Agent_Agents foreign key references a2demo.Agents(Id),
		DepFrom bigint   null
			constraint FK_Document_DepFrom_Agents foreign key references a2demo.Agents(Id),
		DepTo bigint   null
			constraint FK_Document_DepTo_Agents foreign key references a2demo.Agents(Id),
		[Sum] money not null 
			constraint DF_Documents_Sum default(0),
		[Tag]  nvarchar(255) null,
		[Memo] nvarchar(255) null,
		DateCreated datetime not null constraint DF_Documents_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Documents_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Documents_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Documents_UserModified_Users foreign key references a2security.Users(Id)
	);
end
go
------------------------------------------------
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2demo' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'Done'))
begin
	alter table a2demo.Documents add Done bit not null constraint DF_Documents_Done default(0) with values;
end
go
------------------------------------------------
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'a2demo' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'DepFrom'))
begin
	alter table a2demo.Documents add DepFrom bigint null
				constraint FK_Document_DepFrom_Agents foreign key references a2demo.Agents(Id);
	alter table a2demo.Documents add DepTo bigint   null
				constraint FK_Document_DepTo_Agents foreign key references a2demo.Agents(Id);
end
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'a2demo' and SEQUENCE_NAME=N'SQ_DocDetails')
	create sequence a2demo.SQ_DocDetails as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'a2demo' and TABLE_NAME=N'DocDetails')
begin
	create table a2demo.DocDetails
	(
		Id	   bigint not null constraint PK_DocDetails primary key
			constraint DF_DocDetails_PK default(next value for a2demo.SQ_DocDetails),
		Document bigint null
			constraint FK_DocDetails_Document_Documents foreign key references a2demo.Documents(Id),
		[RowNo] int      null,
		Entity  bigint   null
			constraint FK_DocDetails_Entity_Entities foreign key references a2demo.Entities(Id),
		[Qty] float not null
			constraint DF_DocDetails_Qty default(0),
		[Price] float not null
			constraint DF_DocDetails_Price default(0),
		[Sum] money not null 
			constraint DF_DocDetails_Sum default(0)
	);
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Agent.Metadata')
	drop procedure a2demo.[Agent.Metadata]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Agent.Update')
	drop procedure a2demo.[Agent.Update]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Entity.Metadata')
	drop procedure a2demo.[Entity.Metadata]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Entity.Update')
	drop procedure a2demo.[Entity.Update]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Document.Metadata')
	drop procedure a2demo.[Document.Metadata]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Document.Update')
	drop procedure a2demo.[Document.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'a2demo' and DOMAIN_NAME=N'Document.TableType' and DATA_TYPE=N'table type')
	drop type a2demo.[Document.TableType];
go
------------------------------------------------
create type a2demo.[Document.TableType]
as table(
	Id bigint null,
	Kind nvarchar(255),
	[Date] datetime,
	[No] int,
	[Sum] money,
	Agent bigint,
	DepFrom bigint,
	DepTo bigint,
	[Memo] nvarchar(255)
)
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'a2demo' and DOMAIN_NAME=N'DocDetails.TableType' and DATA_TYPE=N'table type')
	drop type a2demo.[DocDetails.TableType];
go
------------------------------------------------
create type a2demo.[DocDetails.TableType]
as table(
	Id bigint null,
	ParentId bigint null,
	RowNumber int,
	[Qty] float,
	[Price] float,
	[Sum] money,
	Entity bigint
)
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'a2demo' and DOMAIN_NAME=N'Agent.TableType' and DATA_TYPE=N'table type')
	drop type a2demo.[Agent.TableType];
go
------------------------------------------------
create type a2demo.[Agent.TableType]
as table(
	Id bigint null,
	Kind nvarchar(255),
	[Name] nvarchar(255),
	Code nvarchar(32),
	[Memo] nvarchar(255)
)
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'a2demo' and DOMAIN_NAME=N'Entity.TableType' and DATA_TYPE=N'table type')
	drop type a2demo.[Entity.TableType];
go
------------------------------------------------
create type a2demo.[Entity.TableType]
as table(
	Id bigint null,
	Kind nvarchar(255),
	[Name] nvarchar(255),
	Article nvarchar(64),
	[Memo] nvarchar(255),
	Unit bigint
)
go
------------------------------------------------
-- Document procedures
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Document.Index')
	drop procedure a2demo.[Document.Index]
go
------------------------------------------------
create procedure a2demo.[Document.Index]
@UserId bigint,
@Kind nvarchar(255),
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc'
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	-- list of users
	with T([Id!!Id], [Date], [No], [Sum], Memo, 
		[Agent.Id!TAgent!Id], [Agent.Name!TAgent!Name], 
		[DepFrom.Id!TAgent!Id],  [DepFrom.Name!TAgent!Name],
		[DepTo.Id!TAgent!Id],  [DepTo.Name!TAgent!Name], Done,
		DateCreated, DateModified, [Parent!TDocParent!RefId],
		[!!RowNumber])
	as(
		select d.Id, d.[Date], d.[No], d.[Sum], d.Memo, 
			d.Agent, a.[Name], d.DepFrom, f.[Name], d.DepTo, t.[Name], d.Done,
			d.DateCreated, d.DateModified, d.Parent,
			[!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then d.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then d.Id end desc,
				case when @Order=N'Date' and @Dir = @Asc then d.[Date] end asc,
				case when @Order=N'Date' and @Dir = @Desc  then d.[Date] end desc,
				case when @Order=N'No' and @Dir = @Asc then d.[No] end asc,
				case when @Order=N'No' and @Dir = @Desc then d.[No] end desc,
				case when @Order=N'Sum' and @Dir = @Asc then d.[Sum] end asc,
				case when @Order=N'Sum' and @Dir = @Desc then d.[Sum] end desc,
				case when @Order=N'Memo' and @Dir = @Asc then d.Memo end asc,
				case when @Order=N'Memo' and @Dir = @Desc then d.Memo end desc,
				case when @Order=N'Agent.Name' and @Dir = @Asc then a.[Name] end asc,
				case when @Order=N'Agent.Name' and @Dir = @Desc then a.[Name] end desc
			)
		from a2demo.Documents d
			left join a2demo.Agents a on d.Agent = a.Id
			left join a2demo.Agents f on d.DepFrom = f.Id
			left join a2demo.Agents t on d.DepTo = t.Id
		where d.Kind=@Kind
	)
	select [Documents!TDocument!Array]=null, *, [Links!TDocLink!Array] = null, 
		[!!RowCount] = (select count(1) from T)
	into #tmp
	from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize

	select * from #tmp
	order by [!!RowNumber];

	select [!TDocLink!Array] = null, [Id!!Id] = Id, [!TDocument.Links!ParentId] = Parent, Kind, [Date], [No], [Sum]
	from a2demo.Documents where Parent in (select [Id!!Id] from #tmp)

	select [!TDocParent!Map] = null, [Id!!Id] = Id, Kind, [Date], [No], [Sum]
	from a2demo.Documents where Id in (select [Parent!TDocParent!RefId] from #tmp);

	select [!$System!] = null, [!!PageSize] = 20;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Document.Load')
	drop procedure a2demo.[Document.Load]
go
------------------------------------------------
create procedure a2demo.[Document.Load]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	select [Document!TDocument!Object] = null, [Id!!Id] = d.Id, Kind, [Date], [No], [Sum], Tag, d.Memo,
		[Agent!TAgent!RefId] = Agent, [DepFrom!TAgent!RefId] = DepFrom, [DepTo!TAgent!RefId] = DepTo,
		Done,
		DateCreated, DateModified, [UserCreated!TUser!RefId] = UserCreated, [UserModified!TUser!RefId] = UserModified,
		[Rows!TRow!Array] = null,
		[Shipment!TDocLink!Array] = null,
		[Parent!TDocParent!RefId] = Parent
	from a2demo.Documents d 
	where d.Id=@Id;

	select [!TRow!Array] = null, [Id!!Id] = Id, [!TDocument.Rows!ParentId] = Document, [RowNo!!RowNumber] = RowNo,
		[Entity!TEntity!RefId] = Entity, Qty, Price, [Sum] 
	from a2demo.DocDetails where Document = @Id
	order by RowNo;

	select [!TAgent!Map] = null, [Id!!Id] = a.Id,  [Name!!Name] = a.[Name], a.Code 
	from a2demo.Agents a 
		inner join a2demo.Documents d on a.Id in (d.Agent, d.DepFrom, d.DepTo)
	where d.Id=@Id;

	select [!TUser!Map] = null, [Id!!Id] = u.Id,  [Name!!Name] = isnull(u.PersonName, u.UserName)
	from a2security.ViewUsers u
		inner join a2demo.Documents d on u.Id in (d.UserCreated, d.UserModified)
	where d.Id=@Id;

	select [!TEntity!Map] = null, [Id!!Id] = e.Id, [Name!!Name] = e.[Name], e.Article,
		[Unit.Id!TUnit!Id] = e.Unit, [Unit.Short!TUnit!Name] = u.[Short]
	from a2demo.Entities e
		inner join a2demo.DocDetails dd on e.Id = dd.Entity
		left join a2demo.Units u on e.Unit = u.Id
	where dd.Document = @Id;

	select [!TDocLink!Array] = null, [Id!!Id] = Id, [!TDocument.Shipment!ParentId] = Parent,
		[No], [Date], [Sum]
	from a2demo.Documents where Parent = @Id
	order by Id;

	-- parent document
	select [!TDocParent!Map] = null, [Id!!Id] = p.Id, p.[No], p.[Date], p.[Sum]
	from a2demo.Documents d inner join a2demo.Documents p on d.Parent = p.Id
	where d.Id = @Id;

	select [Warehouses!TAgent!Array] = null, [Id!!Id] = Id, [Name!!Name] = [Name]
	from a2demo.Agents where Kind=N'Warehouse';

	select [!$System!] = null, [!!ReadOnly] = Done 
	from a2demo.Documents where Id=@Id;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Document.Report')
	drop procedure a2demo.[Document.Report]
go
------------------------------------------------
create procedure a2demo.[Document.Report]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	select [Document!TDocument!Object] = null, [Id!!Id] = d.Id, Kind, [Date], [No], [Sum], Tag, d.Memo,
		[Agent!TAgent!RefId] = Agent, [DepFrom!TAgent!RefId] = DepFrom, [DepTo!TAgent!RefId] = DepTo,
		DateCreated, DateModified, [UserCreated!TUser!RefId] = UserCreated, [UserModified!TUser!RefId] = UserModified,
		[Rows!TRow!Array] = null
	from a2demo.Documents d 
	where d.Id=@Id;

	select [!TRow!Array] = null, [Id!!Id] = Id, [!TDocument.Rows!ParentId] = Document, [RowNo!!RowNumber] = RowNo,
		[Entity!TEntity!RefId] = Entity, Qty, Price, [Sum] 
	from a2demo.DocDetails where Document = @Id
	order by RowNo;

	select [!TAgent!Map] = null, [Id!!Id] = a.Id,  [Name!!Name] = a.[Name], a.Code 
	from a2demo.Agents a 
		inner join a2demo.Documents d on a.Id in (d.Agent, d.DepFrom, d.DepTo)
	where d.Id=@Id;

	select [!TUser!Map] = null, [Id!!Id] = u.Id,  [Name!!Name] = isnull(u.PersonName, u.UserName)
	from a2security.ViewUsers u
		inner join a2demo.Documents d on u.Id in (d.UserCreated, d.UserModified)
	where d.Id=@Id;

	select [!TEntity!Map] = null, [Id!!Id] = e.Id, [Name!!Name] = e.[Name], e.Article,
		[Unit.Id!TUnit!Id] = e.Unit, [Unit.Short!TUnit!Name] = u.[Short]
	from a2demo.Entities e
		inner join a2demo.DocDetails dd on e.Id = dd.Entity
		left join a2demo.Units u on e.Unit = u.Id
	where dd.Document = @Id;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'NextDocNo')
	drop procedure a2demo.NextDocNo
go
------------------------------------------------
create procedure a2demo.[NextDocNo]
	@UserId bigint,
	@Id bigint,
	@Kind nvarchar(255)
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @DocNo int;
	select @DocNo=max([No]) from a2demo.Documents
	where Id <> @Id and Kind = @Kind

	select [Result!Result!Object]=null, [DocNo]=isnull(@DocNo, 0) + 1;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Document.Delete')
	drop procedure a2demo.[Document.Delete]
go
------------------------------------------------
create procedure a2demo.[Document.Delete]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;
	declare @done bit;
	select @done = Done from a2demo.Documents where Id=@Id;
	if @done = 1
		throw 60000, N'UI:Невозможно удалить проведенный документ.', 0;
	else if exists(select * from a2demo.Documents where Parent=@Id)
		throw 60000, N'UI:Невозможно удалить документ. Есть дочерние документы.', 0;
	else
	begin
		delete from a2demo.DocDetails where Document=@Id;
		delete from a2demo.Documents where Id=@Id;
		-- todo: log
	end
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Document.Apply')
	drop procedure a2demo.[Document.Apply]
go
------------------------------------------------
create procedure a2demo.[Document.Apply]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	declare @done bit;
	select @done = Done from a2demo.Documents where Id=@Id;
	if @done = 0
	begin
		update a2demo.Documents set Done = 1, DateModified = getdate(), UserModified = @UserId where Id=@Id;
		-- todo: log
	end
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Document.UnApply')
	drop procedure a2demo.[Document.UnApply]
go
------------------------------------------------
create procedure a2demo.[Document.UnApply]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	declare @done bit;
	select @done = Done from a2demo.Documents where Id=@Id;
	if @done = 1
	begin
		if exists(select * from a2demo.Documents where Parent=@Id)
			throw 60000, N'UI:Проведение отменить невозможно.\nСуществуют дочерние документы.', 0;
		else 
		begin
			update a2demo.Documents set Done = 0, DateModified = getdate(), UserModified = @UserId  where Id=@Id;
			-- todo: log
		end
	end
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Invoice.Delete')
	drop procedure a2demo.[Invoice.Delete]
go
------------------------------------------------
create procedure a2demo.[Invoice.Delete]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	exec a2demo.[Document.Delete] @UserId, @Id;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Waybill.Delete')
	drop procedure a2demo.[Waybill.Delete]
go
------------------------------------------------
create procedure a2demo.[Waybill.Delete]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	exec a2demo.[Document.Delete] @UserId, @Id;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'WaybillIn.Delete')
	drop procedure a2demo.[WaybillIn.Delete]
go
------------------------------------------------
create procedure a2demo.[WaybillIn.Delete]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	exec a2demo.[Document.Delete] @UserId, @Id;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Invoice.CreateShipment')
	drop procedure a2demo.[Invoice.CreateShipment]
go
------------------------------------------------
create procedure a2demo.[Invoice.CreateShipment]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	declare @done bit;
	declare @Kind nvarchar(255) = N'Waybill';
	select @done = Done from a2demo.Documents where Id=@Id;
	if @done = 0 return;
	if exists(select * from a2demo.Documents where Kind=@Kind and Parent=@Id) return;
	-- create shipment document
	declare @output table(id bigint);
	declare @NewId bigint;
	declare @DocNo int;
	select @DocNo=max([No]) from a2demo.Documents
		where Kind = @Kind;

	set @DocNo = isnull(@DocNo, 0) + 1;

	insert into a2demo.Documents(Parent, Kind, [Date], [No], [Agent], [Sum], UserCreated, UserModified)
		output inserted.Id into @output(id)
	select Id, @Kind, a2sys.fn_trimtime(getdate()), @DocNo, Agent, [Sum], @UserId, @UserId
		from a2demo.Documents where Id=@Id;

	select top(1) @NewId = id from @output;

	-- details
	insert into a2demo.DocDetails (Document, Entity, Qty, Price, [Sum], RowNo)
		select @NewId, Entity, Qty, Price, [Sum], RowNo
		from a2demo.DocDetails where Document=@Id;

	select [Document!TShipment!Object] = null, [Id!!Id] = Id, [Date], [Sum], [No]
	from a2demo.Documents where Id=@NewId;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Document.Metadata')
	drop procedure a2demo.[Document.Metadata]
go
------------------------------------------------
create procedure a2demo.[Document.Metadata]
as
begin
	set nocount on;
	declare @Document a2demo.[Document.TableType];
	declare @Rows a2demo.[DocDetails.TableType];
	select [Document!Document!Metadata]=null, * from @Document;
	select [Rows!Document.Rows!Metadata]=null, * from @Rows;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Document.Update')
	drop procedure a2demo.[Document.Update]
go
------------------------------------------------
create procedure a2demo.[Document.Update]
@UserId bigint,
@Document a2demo.[Document.TableType] readonly,
@Rows a2demo.[DocDetails.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;


	declare @output table(op sysname, id bigint);

	merge a2demo.Documents as target
	using @Document as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Date] = source.[Date],
			target.[No] = source.[No],
			target.[Sum] = source.[Sum],
			target.[Memo] = source.Memo,
			target.[Agent] = source.Agent,
			target.DepFrom = source.DepFrom,
			target.DepTo = source.DepTo,
			target.[DateModified] = getdate(),
			target.[UserModified] = @UserId
	when not matched by target then 
		insert (Kind, [Date], [No], [Sum], Memo, Agent, DepFrom, DepTo, UserCreated, UserModified)
		values (Kind, [Date], [No], [Sum], Memo, Agent, DepFrom, DepTo, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	merge a2demo.DocDetails as target
	using @Rows as source
	on (target.Id = source.Id and target.Document = @RetId)
	when matched then 
		update set
			target.RowNo = source.RowNumber,
			target.Entity = source.Entity,
			target.Qty = source.Qty,
			target.Price = source.Price,
			target.[Sum] = source.[Sum]
	when not matched by target then
		insert (Document, RowNo, Entity, Qty, Price, [Sum])
		values (@RetId, RowNumber, Entity, Qty, Price, [Sum])
	when not matched by source and target.Document = @RetId then delete;

	-- todo: log
	exec a2demo.[Document.Load] @UserId, @RetId;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Agent.Index')
	drop procedure a2demo.[Agent.Index]
go
------------------------------------------------
create procedure a2demo.[Agent.Index]
@UserId bigint,
@Kind nvarchar(255),
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc',
@Fragment nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	if @Fragment is not null
		set @Fragment = N'%' + upper(@Fragment) + N'%';

	-- list of users
	with T([Id!!Id], [Name], Code, Memo, [!!RowNumber])
	as(
		select a.Id, a.[Name], Code, a.Memo,
			[!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then a.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then a.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then a.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then a.[Name] end desc,
				case when @Order=N'Code' and @Dir = @Asc then a.[Code] end asc,
				case when @Order=N'Code' and @Dir = @Desc then a.[Code] end desc,
				case when @Order=N'Memo' and @Dir = @Asc then a.Memo end asc,
				case when @Order=N'Memo' and @Dir = @Desc then a.Memo end desc
			)
		from a2demo.Agents a
		where a.Kind=@Kind and a.Void = 0
		and (@Fragment is null or upper(a.[Name]) like @Fragment or upper(a.[Code]) like @Fragment
			or upper(a.Memo) like @Fragment or cast(a.Id as nvarchar) like @Fragment)
	)
	select [Agents!TAgent!Array]=null, *, [!!RowCount] = (select count(1) from T)
	from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
	order by [!!RowNumber];

	select [!$System!] = null, [!!PageSize] = 20;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Agent.Load')
	drop procedure a2demo.[Agent.Load]
go
------------------------------------------------
create procedure a2demo.[Agent.Load]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select [Agent!TAgent!Object] = null, [Id!!Id] = Id, [Name!!Name] = [Name], Code, Tag, Memo,
		DateCreated, DateModified
	from a2demo.Agents where Id=@Id and Void=0;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Agent.Delete')
	drop procedure a2demo.[Agent.Delete]
go
------------------------------------------------
create procedure a2demo.[Agent.Delete]
@UserId bigint,
@Id bigint = null,
@Message nvarchar(255) = N'корреспондента'
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	if exists(select 1 from a2demo.Documents d where @Id in (d.Agent, d.DepFrom, d.DepTo))
	begin
		declare @msg nvarchar(max);
		set @msg = N'UI:Невозможно удалить ' + @Message + N'. Есть документы, в которых он используется.';
		throw 60000, @msg, 0;
	end
	else
	begin
		update a2demo.Agents set Void=1 where Id=@Id;
		-- todo: log
	end
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Agent.Metadata')
	drop procedure a2demo.[Agent.Metadata]
go
------------------------------------------------
create procedure a2demo.[Agent.Metadata]
as
begin
	set nocount on;
	declare @Agent a2demo.[Agent.TableType];
	select [Agent!Agent!Metadata]=null, * from @Agent;
end
go
------------------------------------------------
create procedure a2demo.[Agent.Update]
@UserId bigint,
@Agent a2demo.[Agent.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;


	declare @output table(op sysname, id bigint);

	merge a2demo.Agents as target
	using @Agent as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.[Code] = source.[Code],
			target.[Memo] = source.Memo,
			target.[DateModified] = getdate(),
			target.[UserModified] = @UserId
	when not matched by target then 
		insert (Kind, [Name], [Code], Memo, UserCreated, UserModified)
		values (Kind, [Name], [Code], Memo, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	-- todo: log
	select top(1) @RetId = id from @output;

	exec a2demo.[Agent.Load] @UserId, @RetId;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Entity.Index')
	drop procedure a2demo.[Entity.Index]
go
------------------------------------------------
create procedure a2demo.[Entity.Index]
@UserId bigint,
@Kind nvarchar(255),
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc',
@Fragment nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	if @Fragment is not null
		set @Fragment = N'%' + upper(@Fragment) + N'%';

	-- list of users
	with T([Id!!Id], [Name], Article, Memo, [Unit.Id!TUnit!Id], [Unit.Short!TUnit!], [!!RowNumber])
	as(
		select e.Id, e.[Name], Article, e.Memo,
			Unit, u.Short,
			[!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then e.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then e.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then e.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then e.[Name] end desc,
				case when @Order=N'Article' and @Dir = @Asc then e.[Article] end asc,
				case when @Order=N'Article' and @Dir = @Desc then e.[Article] end desc,
				case when @Order=N'Memo' and @Dir = @Asc then e.Memo end asc,
				case when @Order=N'Memo' and @Dir = @Desc then e.Memo end desc
			)
		from a2demo.Entities e
		left join a2demo.Units u on e.Unit = u.Id
		where e.Kind=@Kind and e.Void = 0
		and (@Fragment is null or upper(e.[Name]) like @Fragment or upper(e.[Article]) like @Fragment
			or upper(e.Memo) like @Fragment or cast(e.Id as nvarchar) like @Fragment)
	)
	select [Entities!TEntity!Array]=null, *, [!!RowCount] = (select count(1) from T)
	from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
	order by [!!RowNumber];

	select [!$System!] = null, [!!PageSize] = 20;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Entity.Load')
	drop procedure a2demo.[Entity.Load]
go
------------------------------------------------
create procedure a2demo.[Entity.Load]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select [Entity!TEntity!Object] = null, [Id!!Id] = Id, [Name!!Name] = [Name], Article, Tag, Memo,
		[Unit!TUnit!RefId] = Unit,
		DateCreated, DateModified, [UserCreated!TUser!RefId] = UserCreated, [UserModified!TUser!RefId] = UserModified
	from a2demo.Entities where Id=@Id and Void=0;

	select [Units!TUnit!Array] = null, [Id!!Id] = Id, [Short!!Name] = Short, [Name]
	from a2demo.Units;

	select [!TUser!Map] = null, [Id!!Id] = u.Id,  [Name!!Name] = isnull(u.PersonName, u.UserName)
	from a2security.ViewUsers u
		inner join a2demo.Entities e on u.Id in (e.UserCreated, e.UserModified)
	where e.Id=@Id;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Entity.FindArticle')
	drop procedure a2demo.[Entity.FindArticle]
go
------------------------------------------------
create procedure a2demo.[Entity.FindArticle]
@UserId bigint,
@Article nvarchar(64) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select top(1) [Entity!TEntity!Object] = null, [Id!!Id] = e.Id, [Name!!Name] = e.[Name], Article, Tag, e.Memo,
		[Unit.Id!TUnit!Id] = e.Unit, [Unit.Short!TUnit!Name] = u.Short,
		e.DateCreated, e.DateModified
	from a2demo.Entities e 
		left join a2demo.Units u  on e.Unit = u.Id
	where Article=@Article and e.Void=0;

end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Entity.Delete')
	drop procedure a2demo.[Entity.Delete]
go
------------------------------------------------
create procedure a2demo.[Entity.Delete]
@UserId bigint,
@Id bigint = null,
@Message nvarchar(255) = N'объект учета'
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	if exists(select 1 from a2demo.DocDetails dd where @Id in (dd.Entity))
	begin
		declare @msg nvarchar(max);
		set @msg = N'UI:Невозможно удалить ' + @Message + N'. Есть документы, в которых он используется.';
		throw 60000, @msg, 0;
	end
	else
	begin
		update a2demo.Entities set Void=1 where Id=@Id;
		-- todo: log
	end
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Entity.Metadata')
	drop procedure a2demo.[Entity.Metadata]
go
------------------------------------------------
create procedure a2demo.[Entity.Metadata]
as
begin
	set nocount on;
	declare @Entity a2demo.[Entity.TableType];
	select [Entity!Entity!Metadata]=null, * from @Entity;
end
go
------------------------------------------------
create procedure a2demo.[Entity.Update]
@UserId bigint,
@Entity a2demo.[Entity.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;


	declare @output table(op sysname, id bigint);

	merge a2demo.Entities as target
	using @Entity as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.[Article] = source.[Article],
			target.[Memo] = source.Memo,
			target.Unit = source.Unit,
			target.[DateModified] = getdate(),
			target.[UserModified] = @UserId
	when not matched by target then 
		insert (Kind, [Name], [Article], Memo, Unit, UserCreated, UserModified)
		values (Kind, [Name], [Article], Memo, Unit, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	-- todo: log
	select top(1) @RetId = id from @output;

	exec a2demo.[Entity.Load] @UserId, @RetId;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Invoice.Index')
	drop procedure a2demo.[Invoice.Index]
go
------------------------------------------------
create procedure a2demo.[Invoice.Index]
@UserId bigint,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc'
as
begin
	set nocount on;
	exec a2demo.[Document.Index] @UserId=@UserId, @Kind=N'Invoice', @Offset=@Offset, @PageSize=@PageSize, @Order=@Order, @Dir=@Dir;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Waybill.Index')
	drop procedure a2demo.[Waybill.Index]
go
------------------------------------------------
create procedure a2demo.[Waybill.Index]
@UserId bigint,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc'
as
begin
	set nocount on;
	exec a2demo.[Document.Index] @UserId=@UserId, @Kind=N'Waybill', @Offset=@Offset, @PageSize=@PageSize, @Order=@Order, @Dir=@Dir;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'WaybillIn.Index')
	drop procedure a2demo.[WaybillIn.Index]
go
------------------------------------------------
create procedure a2demo.[WaybillIn.Index]
@UserId bigint,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc'
as
begin
	set nocount on;
	exec a2demo.[Document.Index] @UserId=@UserId, @Kind=N'WaybillIn', @Offset=@Offset, @PageSize=@PageSize, @Order=@Order, @Dir=@Dir;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Customer.Index')
	drop procedure a2demo.[Customer.Index]
go
------------------------------------------------
create procedure a2demo.[Customer.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc',
@Fragment nvarchar(255) = null
as
begin
	set nocount on;
	exec a2demo.[Agent.Index] @UserId=@UserId, @Kind=N'Customer', 
	@Offset=@Offset, @PageSize=@PageSize, @Order=@Order, @Dir=@Dir,
	@Fragment = @Fragment
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Customer.Delete')
	drop procedure a2demo.[Customer.Delete]
go
------------------------------------------------
create procedure a2demo.[Customer.Delete]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	exec a2demo.[Agent.Delete] @UserId=@UserId, @Id=@Id, @Message=N'покупателя';
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Supplier.Index')
	drop procedure a2demo.[Supplier.Index]
go
------------------------------------------------
create procedure a2demo.[Supplier.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc',
@Fragment nvarchar(255) = null
as
begin
	set nocount on;
	exec a2demo.[Agent.Index] @UserId=@UserId, @Kind=N'Supplier', 
	@Offset=@Offset, @PageSize=@PageSize, @Order=@Order, @Dir=@Dir,
	@Fragment = @Fragment
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Supplier.Delete')
	drop procedure a2demo.[Supplier.Delete]
go
------------------------------------------------
create procedure a2demo.[Supplier.Delete]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	exec a2demo.[Agent.Delete] @UserId=@UserId, @Id=@Id, @Message=N'поставщика';
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Goods.Index')
	drop procedure a2demo.[Goods.Index]
go
------------------------------------------------
create procedure a2demo.[Goods.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc',
@Fragment nvarchar(255) = null
as
begin
	set nocount on;
	exec a2demo.[Entity.Index] @UserId=@UserId, @Kind=N'Goods', 
		@Offset=@Offset, @PageSize=@PageSize, @Order=@Order, @Dir=@Dir,
		@Fragment = @Fragment;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'a2demo' and ROUTINE_NAME=N'Goods.Delete')
	drop procedure a2demo.[Goods.Delete]
go
------------------------------------------------
create procedure a2demo.[Goods.Delete]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	exec a2demo.[Entity.Delete] @UserId=@UserId, @Id=@Id, @Message=N'товар';
end
go
------------------------------------------------
begin
	-- App Title/SubTitle
	if not exists (select * from a2sys.SysParams where [Name] = N'AppTitle')
		insert into a2sys.SysParams([Name], StringValue) values (N'AppTitle', N'A2:Demo'); 
	if not exists (select * from a2sys.SysParams where [Name] = N'AppSubTitle')
		insert into a2sys.SysParams([Name], StringValue) values (N'AppSubTitle', N'демонстрационное приложение'); 
end
go
------------------------------------------------
begin
	-- create user menu
	declare @menu table(id bigint, p0 bigint, [name] nvarchar(255), [url] nvarchar(255), icon nvarchar(255), [order] int);
	insert into @menu(id, p0, [name], [url], icon, [order])
	values
		(1, null, N'Default',     null,          null,     0),
		(10, 1,   N'Продажи',     N'sales',	     null,     10),
		(20, 1,   N'Закупки',     N'purchase',	 null,     20),
		(31, 10,  N'Документы',   null,		     null,     10),
		(32, 10,  N'Справочники', null,		     null,     20),
		(33, 20,  N'Документы',   null,		     null,     10),
		(34, 20,  N'Справочники', null,		     null,     20),
		(41, 31,  N'Счета',		  N'invoice',    N'file',  10),
		(42, 31,  N'Накладные',	  N'waybill',    N'file',  20),
		(43, 32,  N'Покупатели',  N'customer',   N'user',  10),
		(44, 33,  N'Накладные',	  N'waybillin',  N'file',  10),
		(45, 34,  N'Поставщики',  N'supplier',   N'user',  10),
		(46, 34,  N'Товары',      N'goods',      N'steps', 20);
	merge a2ui.Menu as target
	using @menu as source
	on target.Id=source.id and target.Id >= 1 and target.Id < 200
	when matched then
		update set
			target.Id = source.id,
			target.[Name] = source.[name],
			target.[Url] = source.[url],
			target.[Icon] = source.icon,
			target.[Order] = source.[order]
	when not matched by target then
		insert(Id, Parent, [Name], [Url], Icon, [Order]) values (id, p0, [name], [url], icon, [order])
	when not matched by source and target.Id >= 1 and target.Id < 200 then 
		delete;

	if not exists (select * from a2security.Acl where [Object] = 'std:menu' and [ObjectId] = 1 and GroupId = 1)
	begin
		insert into a2security.Acl ([Object], ObjectId, GroupId, CanView)
			values (N'std:menu', 1, 1, 1);
	end
	exec a2security.[Permission.UpdateAcl.Menu];
end
go
------------------------------------------------
if not exists(select * from a2demo.Units) 
begin
	insert into a2demo.Units(Short, [Name], UserCreated, UserModified)
		values 
		(N'шт.',  N'Штука', 0, 0),
		(N'кг.',  N'Килограмм', 0, 0),
		(N'л.',   N'Литр', 0, 0),
		(N'пач.', N'Пачка', 0, 0),
		(N'м.',   N'Метр', 0, 0);
end
go
------------------------------------------------
if not exists(select * from a2demo.Agents where Kind=N'Warehouse') 
begin
	insert into a2demo.Agents(Kind, [Name], UserCreated, UserModified)
		values 
		(N'Warehouse', N'Основной склад', 0, 0),
		(N'Warehouse', N'Склад материалов', 0, 0);
end
go
------------------------------------------------
begin
	set nocount on;
	grant execute on schema ::a2demo to public;
end
go
------------------------------------------------
set noexec off;
go
