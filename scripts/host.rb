class Host
  def Host.install(config, provisionFile)
    config.vm.provision "shell", path: provisionFile
  end

  def Host.configure(config, settings)
    # The most common configuration options are documented and commented below.
    # For a complete reference, please see the online documentation at
    # https://docs.vagrantup.com.

    # Every Vagrant development environment requires a box. You can search for
    # boxes at https://atlas.hashicorp.com/search.
    config.vm.box = "ubuntu/xenial64"
    config.vm.hostname = "devbox"

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    # config.vm.network "private_network", ip: "192.168.33.10"
    config.vm.network :private_network, ip: settings["ip"] ||= "192.168.8.8"

    # Create a public network, which generally matched to bridged network.
    # Bridged networks make the machine appear as another physical device on
    # your network.
    # config.vm.network "public_network"

    if settings['networking'][0]['public']
      config.vm.network "public_network", type: "dhcp"
    end

    # Configure A Few VirtualBox Settings
    config.vm.provider "virtualbox" do |vb|
      vb.name = 'devbox'
      vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
      vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ostype", "Debian_64"]
      vb.customize ["modifyvm", :id, "--audio", "none", "--usb", "off", "--usbehci", "off"]
    end

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    # config.vm.network "forwarded_port", guest: 80, host: 8080


    config.vm.network "forwarded_port", guest: 80, host: 8001
    config.vm.network "forwarded_port", guest: 443, host: 44300
    config.vm.network "forwarded_port", guest: 3306, host: 33060

    # Add Custom Ports From Configuration
    if settings.has_key?("ports")
      settings["ports"].each do |port|
        config.vm.network "forwarded_port", guest: port["guest"], host: port["host"], protocol: port["protocol"] ||= "tcp"
      end
    end

    # Add Configured Sites
    config.vm.provision "shell" do |s|
        s.path = "./scripts/clear-sites.sh"
    end

    if settings['sites'].kind_of?(Array)

      settings["sites"].each do |site|
        config.vm.provision "shell" do |s|
          s.args = [site["hostname"], site["to"]]
          s.path = "./scripts/create-sites.sh"
        end
      end
    end
    
    if !Vagrant::Util::Platform.windows?
      # Configure The Public Key For SSH Access
      settings["authorize"].each do |key|
        if File.exists? File.expand_path(key) then
          config.vm.provision "shell" do |s|
            s.inline = "echo $1 | grep -xq \"$1\" /home/ubuntu/.ssh/authorized_keys || echo $1 | tee -a /home/ubuntu/.ssh/authorized_keys"
            s.args = [File.read(File.expand_path(key))]
          end
        end
      end
      # Copy The SSH Private Keys To The Box
      settings["keys"].each do |key|
        if File.exists? File.expand_path(key) then
          config.vm.provision "shell" do |s|
            s.privileged = false
            s.inline = "echo \"$1\" > /home/ubuntu/.ssh/$2 && chmod 600 /home/ubuntu/.ssh/$2"
            s.args = [File.read(File.expand_path(key)), key.split('/').last]
         end
        end
      end
    end

    # Register All Of The Configured Shared Folders
    # Share an additional folder to the guest VM. The first argument is
    # the path on the host to the actual folder. The second argument is
    # the path on the guest to mount the folder. And the optional third
    # argument is a set of non-required options.
    # config.vm.synced_folder "../data", "/vagrant_data"
    if settings['folders'].kind_of?(Array)
      settings["folders"].each do |folder|
        config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil
      end
    end

    # Configure All Of The Configured Databases
    if settings['databases'].kind_of?(Array)
      settings["databases"].each do |db|
          config.vm.provision "shell" do |s|
              s.path = "./scripts/create-databases.sh"
              s.args = [db]
          end
      end
    end

    config.vm.provision "shell" do |s|
      s.privileged = false
      s.path = "./scripts/clone-repos.sh"
    end
    #
    ## Update Composer On Every Provision
    #config.vm.provision "shell" do |s|
    #  s.inline = "/usr/local/bin/composer self-update --no-progress"
    #end
  end

end
