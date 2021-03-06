﻿using System;
using System.ServiceProcess;
using System.ComponentModel;
using System.Configuration.Install;

namespace MyService
{
[RunInstaller(true)]

    public class MyServiceInstaller : Installer
    {

        private ServiceProcessInstaller ServiceProcessInstaller1;

        private ServiceInstaller ServiceInstaller1;
 

        public MyServiceInstaller()
        {
            InitializeComponent();
        }
 
        private void InitializeComponent()
        {
            this.ServiceProcessInstaller1 = new ServiceProcessInstaller();
            this.ServiceProcessInstaller1.Account = ServiceAccount.LocalSystem;
            this.ServiceProcessInstaller1.Username = null;
            this.ServiceProcessInstaller1.Password = null;
            this.ServiceInstaller1 = new ServiceInstaller();
            this.ServiceInstaller1.Description = "MyService Service Template";
            this.ServiceInstaller1.DisplayName = "My Service";
            this.ServiceInstaller1.ServiceName = "MyService";
            this.ServiceInstaller1.StartType = ServiceStartMode.Manual;
            this.Installers.AddRange(new Installer[] { this.ServiceProcessInstaller1, this.ServiceInstaller1 });
        }
    }
}