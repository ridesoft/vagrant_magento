# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
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



  config.vm.synced_folder "srv/", "/srv"

    # Virtualbox customization
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024", "--cpus", "2", "--pae", "on", "--hwvirtex", "on", "--ioapic", "on"]
    end



  # "Provision" with hostmanager
  config.vm.provision :hostmanager

end
