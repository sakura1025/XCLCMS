USE [XCLCMS]
GO
/****** Object:  StoredProcedure [dbo].[sp_SysUserRole_ADD]    Script Date: 04/06/2015 17:22:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	保存用户角色关系表
*/
CREATE PROCEDURE [dbo].[sp_SysUserRole_ADD]
(
	@FK_UserInfoID bigint,
	@FK_SysRoleIDXML XML=NULL,--该用户对应的角色id xml（一个或多个）
	
	@RecordState char(1),
	@CreateTime DATETIME,
	@CreaterID bigint,
	@CreaterName nvarchar(50),
	@UpdateTime datetime,
	@UpdaterID bigint,
	@UpdaterName nvarchar(50),
	
	@ResultCode INT OUTPUT,
	@ResultMessage NVARCHAR(1000) OUTPUT
)
 AS 

 BEGIN
 
	SET @ResultCode=1
	SET @ResultMessage=N'' 
	
	BEGIN TRY
		BEGIN TRAN trans
		
			/********其它附加处理********/
			BEGIN
			
				--清空该用户的所有角色
				DELETE dbo.SysUserRole WHERE FK_UserInfoID=@FK_UserInfoID	
				
				--检查当前用户最大权力,筛选中当前要添加的权力中小于等于当前创建用户的最大权力记录
				DECLARE @maxWeight BIGINT=NULL
				SELECT @maxWeight=RoleMaxWeight FROM dbo.UserInfo WHERE UserInfoID=@CreaterID

			END
		 
			/********解析角色xml及保存信息********/
			BEGIN
			
				;WITH RoleIdList AS (
					--角色list
					SELECT 
					T.C.value('text()[1]','bigint') AS FK_SysRoleID
					FROM @FK_SysRoleIDXML.nodes('//long') AS T(C)	
				),
				BaseInfo AS (
					--用户角色表基本信息
					SELECT 
					@FK_UserInfoID AS FK_UserInfoID,
					@RecordState AS RecordState,
					@CreateTime AS CreateTime,
					@CreaterID AS CreaterID,
					@CreaterName AS CreaterName,
					@UpdateTime AS UpdateTime,
					@UpdaterID AS UpdaterID,
					@UpdaterName AS UpdaterName
				),
				JoinInfo AS (
					--该用户与角色list组合成多个记录便于写入表中
					SELECT * FROM RoleIdList CROSS JOIN BaseInfo
				),
				ResultInfo AS (
					--排除无效的角色信息
					SELECT 
					a.*,
					b.Weight 
					FROM JoinInfo AS a
					INNER JOIN dbo.v_SysDic_Roles AS b ON a.FK_SysRoleID=b.SysDicID AND @maxWeight IS NOT NULL AND b.Weight<=@maxWeight
				)
				SELECT * INTO #ResultInfoTemp FROM ResultInfo
				
				
				/********保存********/
				INSERT dbo.SysUserRole( FK_UserInfoID ,FK_SysRoleID ,RecordState ,CreateTime ,CreaterID ,CreaterName ,UpdateTime ,UpdaterID ,UpdaterName)
				SELECT FK_UserInfoID ,FK_SysRoleID ,RecordState ,CreateTime ,CreaterID ,CreaterName ,UpdateTime ,UpdaterID ,UpdaterName FROM #ResultInfoTemp
		 
		 
				/********更新用户表********/
				DECLARE @roleNameListString NVARCHAR(100)=NULL
				DECLARE @roleMaxWeight INT=NULL
				
				--获取角色名逗号分隔的字符串
				SET @roleNameListString=(SELECT RoleNameInfo.RoleName+',' FROM (
					SELECT 
					b.DicName AS RoleName 
					FROM #ResultInfoTemp AS a
					INNER JOIN dbo.SysDic AS b ON a.FK_SysRoleID=b.SysDicID
				) AS RoleNameInfo FOR XML PATH(''))
				IF(@roleNameListString IS NOT NULL AND LEN(@roleNameListString)>0)
				BEGIN
					set @roleNameListString=LEFT(@roleNameListString,LEN(@roleNameListString)-1)
				END
				
				--获取该用户最大角色
				SELECT @roleMaxWeight=MAX(Weight) FROM #ResultInfoTemp
				
				--更新
				UPDATE dbo.UserInfo SET RoleName=@roleNameListString,RoleMaxWeight=@roleMaxWeight WHERE UserInfoID=@FK_UserInfoID
				

				/********其它处理********/
				DROP TABLE #ResultInfoTemp
				
				
			END 			
		
		SET @ResultCode=1
		COMMIT TRAN trans
	END TRY
	BEGIN CATCH
		set @ResultMessage= ERROR_MESSAGE() 
		SET @ResultCode=0
		ROLLBACK TRAN trans	
	END CATCH
	
	 

	
	
 END
GO
