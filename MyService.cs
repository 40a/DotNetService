using System;
using System.ServiceProcess;
using System.Diagnostics;
namespace MyService
{
    public class MyService : ServiceBase
    {
        public MyService()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            this.EventLog.WriteEntry("MyService Service Has Started");
        }

        protected override void OnStop()
        {
            this.EventLog.WriteEntry("MyService Service Has Stopped");
        }

        private void InitializeComponent()
        {
            this.ServiceName = "MyService";
            this.CanStop = true;
            this.AutoLog = false;
            this.EventLog.Log = "Application";
            this.EventLog.Source = "MyService";
        }
    }
}