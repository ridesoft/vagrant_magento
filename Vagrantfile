# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box     = "trusty64"
    # config.vm.box_url = "http://files.vagrantup.com/precise64_vmware.box"
    config.vm.box_url = "https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vmwarefusion.box"

    config.vm.network :forwarded_port, guest: 80, host: 8080
    config.vm.hostname = "mothership.vm"

    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true

    config.vm.network :private_network, ip: "192.168.162.140"

    # If true, then any SSH connections made will enable agent forwarding.
    # Default value: false
    # config.ssh.forward_agent = true

    # Define folder to be synced
    # config.vm.synced_folder "srv/", "/srv"


    config.vm.provider :vmware_fusion do |v|
        #v.gui = true
        v.vmx["memsize"] = "2048"
        v.vmx["numvcpus"] = "2"
        v.name = config.vm.hostname
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
            "db_user"          => "root",
            "db_password"      => "root",
            "db_name"          => "dev",

            "db_name_tests"    => "dev",

            # Apache
            "hostname"         => config.vm.hostname,
            "document_root"    => "/srv/"
        }

    end
end