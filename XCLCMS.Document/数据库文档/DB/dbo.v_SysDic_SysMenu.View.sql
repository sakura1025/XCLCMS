USE [XCLCMS]
GO
/****** Object:  View [dbo].[v_SysDic_SysMenu]    Script Date: 04/06/2015 17:22:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_SysDic_SysMenu] AS 

--所有系统菜单信息
SELECT * FROM dbo.fun_SysDic_GetAllUnderListByCode('SysMenu')
GO
