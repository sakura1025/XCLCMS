﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace XCLCMS.View.AdminWeb.Controllers.Common
{
    public class UploadController : BaseController
    {
        /// <summary>
        /// 上传
        /// </summary>
        public ActionResult Index()
        {
            return View("~/Views/Common/Upload.cshtml");
        }
    }
}
