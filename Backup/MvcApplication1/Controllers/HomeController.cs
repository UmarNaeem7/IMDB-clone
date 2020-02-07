using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using MvcApplication1.Models;

namespace MvcApplication1.Controllers
{
    public class HomeController : Controller
    {
        //
        // GET: /Home/

        public ActionResult Index()
        {
            return View();
        }
        public ActionResult Post(string userName, string email, string password, DateTime DOB)
        {
            ViewBag.Title = userName + " " + email + " " + password + " " + DOB.ToString();
            int result = CRUD.SignUp(userName, email, DOB, password);
            ViewBag.Title = result;
            return View();
        }
        public ActionResult Login(string email, string password)
        {
            int result = CRUD.Login(email, password);
            if(result == 1)
                ViewBag.Title = "SUCCESSFUL";
            else
                ViewBag.Title = "WRONG USERNAME OR PASSWORD";
            return View();
        }

    }
}
