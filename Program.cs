using System;
using System.Collections.Generic;
using System.Linq;
using System.Windows.Forms;
using System.Configuration.Install;
using System.ServiceProcess;

namespace MyService
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
           ServiceBase.Run(new MyService());
        }
    }
}
