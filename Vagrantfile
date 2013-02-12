# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.define :master do |master_config|

      # All Vagrant configuration is done here. The most common configuration
      # options are documented and commented below. For a complete reference,
      # please see the online documentation at vagrantup.com.
      master_config.vm.host_name = "puppet.pebbleit.dev"
      # Every Vagrant virtual environment requires a box to build off of.
      master_config.vm.box = "precise64"
    
      # The url from where the 'master_config.vm.box' box will be fetched if it
      # doesn't already exist on the user's system.
      master_config.vm.box_url = "http://files.vagrantup.com/precise64.box"
      # We need moar ramz
      master_config.vm.customize ["modifyvm", :id, "--memory", 1024]
      # Boot with a GUI so you can see the screen. (Default is headless)
      # config.vm.boot_mode = :gui
    
      # Assign this VM to a host-only network IP, allowing you to access it
      # via the IP. Host-only networks can talk to the host machine as well as
      # any other machines on the same network, but cannot be accessed (through this
      # network interface) by any external networks.
      master_config.vm.network :hostonly, "192.168.33.10"
    
      # Assign this VM to a bridged network, allowing you to connect directly to a
      # network using the host's network device. This makes the VM appear as another
      # physical device on your network.
      # config.vm.network :bridged
    
      # Forward a port from the guest to the host, which allows for outside
      # computers to access the VM, whereas host only networking does not.
      #config.vm.forward_port 80, 80
        
      # Share an additional folder to the guest VM. The first argument is
      # an identifier, the second is the path on the guest to mount the
      # folder, and the third is the path on the host to the actual folder.
      
      master_config.vm.provision :shell, :path => "puppet_master.sh"
      # Enable the Puppet provisioner
      master_config.vm.provision :puppet, :module_path => "VagrantConf/modules", :manifests_path => "VagrantConf/manifests", :manifest_file  => "default.pp"

    master_config.vm.share_folder "puppet_manifests", "/etc/puppet/manifests", "puppet/manifests"
    master_config.vm.share_folder "puppet_modules", "/etc/puppet/modules", "puppet/modules"
  end
  
  
end
