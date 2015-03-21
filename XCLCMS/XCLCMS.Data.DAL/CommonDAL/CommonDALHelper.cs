﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using XCLCMS.CodeTool.DBUtility;

namespace XCLCMS.Data.DAL.CommonDAL
{
    public class CommonDALHelper
    {
        /// <summary>
        /// 分页(可按非主键排序)
        /// </summary>
        /// <param name="PageSize">每页最多显示的条数</param>
        /// <param name="PageIndex">当前为第几页 1为第1页</param>
        /// <param name="recordCount">总记录数</param>
        /// <param name="strWhere"> 查询条件 (注意: 不要加 where)</param>
        /// <param name="fieldName">列名，若为空，则取所有列</param>
        ///<param name="fieldKey">主键名</param>
        ///<param name="fieldOrder">排序字段，可加DESC/ASC</param>
        /// <returns>DataTable</returns>
        public static DataTable GetPageList(string tableName, int pageSize, int pageIndex, ref int recordCount, string strWhere, string fieldName, string fieldKey, string fieldOrder)
        {
            DataTable dt = null;
            SqlParameter[] parameters = {
											new SqlParameter("@RecordCount", SqlDbType.Int),//总记录数
											new SqlParameter("@PageCount", SqlDbType.Int),//总页数
											new SqlParameter("@PageSize", SqlDbType.Int),//每页最多显示多少条
											new SqlParameter("@PageCurrent", SqlDbType.Int),	//当前页码  1为第一页
											new SqlParameter("@tbname", SqlDbType.NVarChar),//表名
											new SqlParameter("@FieldShow", SqlDbType.NVarChar),
											new SqlParameter("@Where", SqlDbType.NVarChar),
											new SqlParameter("@FieldOrder", SqlDbType.NVarChar),
                                            new SqlParameter("@FieldKey", SqlDbType.NVarChar)
											};
            parameters[0].Direction = ParameterDirection.Output;
            parameters[1].Direction = ParameterDirection.Output;
            parameters[2].Value = pageSize;
            parameters[3].Value = pageIndex;//存储过程中1为第一页。
            parameters[4].Value = tableName;
            parameters[5].Value = fieldName;
            parameters[6].Value = strWhere;
            parameters[7].Value = fieldOrder;
            parameters[8].Value = fieldKey;
            DataSet ds = DbHelperSQL.RunProcedure("proc_pager", parameters, "ds");
            int.TryParse(parameters[0].Value.ToString(), out recordCount);

            if (null != ds && ds.Tables.Count > 0)
            {
                dt = ds.Tables[0];
            }
            return dt;
        }

        /// <summary>
        /// 垃圾数据清理
        /// </summary>
        public static void ClearRubbishData()
        {
            string strSql = "exec proc_ClearRubbishData";
            DbHelperSQL.ExecuteSql(strSql);
        }
    }
}
