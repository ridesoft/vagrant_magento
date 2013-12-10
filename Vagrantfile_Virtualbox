# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box     = "precise64"
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"

    config.vm.network :forwarded_port, guest: 80, host: 8080
    config.vm.hostname = "myproject.vm"

    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true

    config.vm.network :private_network, ip: "10.0.0.2"

    # If true, then any SSH connections made will enable agent forwarding.
    # Default value: false
    # config.ssh.forward_agent = true

    # Define folder to be synced
    # config.vm.synced_folder "srv/", "/srv"

    # Virtualbox customization
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024", "--cpus", "2", "--pae", "on", "--hwvirtex", "on", "--ioapic", "on"]
    end

    # "Provision" with hostmanager
    config.vm.provision :hostmanager

    # Puppet!
    config.vm.provision :puppet do |puppet|

        puppet.manifests_path = "puppet/manifests"
        puppet.manifest_file  = "init.pp"
        puppet.module_path    = "puppet/modules"
        puppet.options        = "--verbose --debug"


        # Factors
        puppet.facter = {
            "vagrant" => "1",

            "db_root_password" => "root",
            "db_user"          => "magento",
            "db_password"      => "magento",
            "db_name"          => "magento",

            "db_name_tests"    => "magento_tests",

            # Apache
            "hostname"         => config.vm.hostname,
            "document_root"    => "/srv/"
        }

    end
end