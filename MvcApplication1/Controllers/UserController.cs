using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using MvcApplication1.Models;

namespace MvcApplication1.Controllers
{
    public class UserController : Controller
    {
        //
        // GET: /User/

        public ActionResult Index()
        {
            return View();
        }
        public ActionResult ChangeUserName(string userName)
        {
            CRUD.UpdateUserName((int)Session["userID"], userName);
            Session["userName"] = userName;
            return RedirectToAction("Index", "User");
        }
        public ActionResult ChangePassword(string password)
        {
            CRUD.UpdateUserPassword((int)Session["userID"], password);
            Session["userPassword"] = password;
            return RedirectToAction("Index", "User");
        }
        public ActionResult Feedback(string userFeedback)
        {
            CRUD.AddUserFeedback((int)Session["userID"], userFeedback);
            return RedirectToAction("Index", "User");
        }

    }
}
