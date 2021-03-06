if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Q_SUM_M2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Q_SUM_M2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateM2MakeNum]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateM2MakeNum]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateM2UpdataNumHard]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateM2UpdataNumHard]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateM2UpdataNumIP]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateM2UpdataNumIP]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[M2UserInfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[M2UserInfo]
GO

CREATE TABLE [dbo].[M2UserInfo] (
	[Id] [int] NULL ,
	[User] [nvarchar] (12) COLLATE Chinese_PRC_CI_AS NULL ,
	[Pass] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[QQ] [nvarchar] (20) COLLATE Chinese_PRC_CI_AS NULL ,
	[GameListUrl] [nvarchar] (80) COLLATE Chinese_PRC_CI_AS NULL ,
	[BakGameListUrl] [nvarchar] (16) COLLATE Chinese_PRC_CI_AS NULL ,
	[PatchListUrl] [nvarchar] (42) COLLATE Chinese_PRC_CI_AS NULL ,
	[Who] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[RegTimer] [datetime] NULL ,
	[IpAddress] [nvarchar] (50) COLLATE Chinese_PRC_CI_AS NULL ,
	[Timer] [datetime] NULL ,
	[DayMakeNum] [int] NULL ,
	[UpdataNum] [int] NULL ,
	[Zt] [char] (1) COLLATE Chinese_PRC_CI_AS NULL ,
	[UpType] [int] NULL 
) ON [PRIMARY]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


CREATE PROCEDURE Q_SUM_M2(@Dt1 Datetime,@Dt2 Datetime,@ZT char(1)) AS

select a.DLUserName,b.name as userName,a.SL,
case b.zt when '1' then a.SL*300
          when '0' then a.SL*200
End  as Yue 
 from
(select DLUserName,Count(*) SL from Tips 
where
DateDiff(DD,InputDate,@Dt1)<=0 and DateDiff(DD,InputDate,@Dt2)>=0 and Status=@ZT
Group by  DLUserName) a
inner join DLUserInfo b on a.DLUserName=b.[User]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


CREATE PROCEDURE UpdateM2MakeNum (@UserName char(50),@MaxNum int) AS set nocount on
BEGIN TRANSACTION -----开始事务

Declare @Num int

Set @Num=0

SELECT @Num=DayMakeNum FROM M2UserInfo where [User]= @UserName

if @Num < @MaxNum
begin
    set @Num= @Num +1
     Update M2UserInfo set dayMakeNum=@Num  Where [User]=@UserName      
end


Select  @Num  as num

set nocount off

  IF @@error<>0 
    BEGIN
      ROLLBACK
      RETURN -1
    END			
COMMIT TRANSACTION-----结束事务

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO


--用户修改次数,同时修改硬件信息
CREATE PROCEDURE UpdateM2UpdataNumHard(@Hard char(42),@UserName char(50),@IP char(16),@MaxNum int) AS set nocount on
BEGIN TRANSACTION -----开始事务

Declare @Num int
Declare @OK int
Declare @type int

Set @Num=0
Set @OK=0


SELECT @Num=UpdataNum,@type=Uptype FROM M2UserInfo where [User]= @UserName and  BakGameListUrl=@IP

if (@Num < @MaxNum) and ((@type=0) or (@type=2))
begin
    set @Num= @Num +1
    Update M2UserInfo set PatchListUrl =@Hard,UpdataNum=@Num,Uptype=2 Where  [User]= @UserName and  BakGameListUrl=@IP
    set @OK=1
end



Select  @OK  as num

set nocount off

  IF @@error<>0 
    BEGIN
      ROLLBACK
      RETURN -1
    END			
COMMIT TRANSACTION-----结束事务

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS OFF 
GO


--用户修改次数,同时修改IP信息
CREATE PROCEDURE UpdateM2UpdataNumIP(@IP char(16),@UserName char(50),@PatchListUrl char(42),@MaxNum int) AS set nocount on
BEGIN TRANSACTION -----开始事务

Declare @Num int
Declare @OK int
Declare @Tpye int

Set @Num=0
Set @OK=0


SELECT @Num=UpdataNum, @Tpye=Uptype  FROM M2UserInfo where [User]= @UserName and  PatchListUrl =@PatchListUrl 


if (@Num < @MaxNum) and ((@Tpye=0) or (@Tpye=1))
begin
    set @Num= @Num +1
    Update M2UserInfo set BakGameListUrl=@IP,UpdataNum=@Num,Uptype=1  Where  [User]= @UserName and  PatchListUrl =@PatchListUrl 
    set @OK=1
end


Select  @OK  as num

set nocount off

  IF @@error<>0 
    BEGIN
      ROLLBACK
      RETURN -1
    END			
COMMIT TRANSACTION-----结束事务

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

