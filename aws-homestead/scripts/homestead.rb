class Homestead
  def Homestead.configure(config, settings)
    # Set The VM Provider
    # Configure Local Variable To Access Scripts From Remote Location
    scriptDir = File.dirname(__FILE__)

    # Prevent TTY Errors
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Copy User Files Over to VM
    if settings.include? 'copy'
      settings["copy"].each do |file|
        config.vm.provision "file" do |f|
          f.source = File.expand_path(file["from"])
          f.destination = file["to"].chomp('/') + "/" + file["from"].split('/').last
        end
      end
    end

    # Register All Of The Configured Shared Folders
    if settings.include? 'folders'
      settings["folders"].each do |folder|
        mount_opts = []

        if (folder["type"] == "nfs")
            mount_opts = folder["mount_options"] ? folder["mount_options"] : ['actimeo=1', 'nolock']
        elsif (folder["type"] == "smb")
            mount_opts = folder["mount_options"] ? folder["mount_options"] : ['vers=3.02', 'mfsymlinks']
        end

        # For b/w compatibility keep separate 'mount_opts', but merge with options
        options = (folder["options"] || {}).merge({ mount_options: mount_opts })

        # Double-splat (**) operator only works with symbol keys, so convert
        options.keys.each{|k| options[k.to_sym] = options.delete(k) }

        config.vm.synced_folder folder["map"], folder["to"], type: folder["type"] ||= nil, **options

        # Bindfs support to fix shared folder (NFS) permission issue on Mac
        if Vagrant.has_plugin?("vagrant-bindfs")
          config.bindfs.bind_folder folder["to"], folder["to"]
        end
      end
    end

    # Install All The Configured Nginx Sites
    config.vm.provision "shell" do |s|
        s.path = scriptDir + "/clear-nginx.sh"
    end


    if settings.include? 'sites'
      settings["sites"].each do |site|
        type = site["type"] ||= "laravel"

        if (site.has_key?("hhvm") && site["hhvm"])
          type = "hhvm"
        end

        if (type == "symfony")
          type = "symfony2"
        end

        config.vm.provision "shell" do |s|
          s.name = "Creating Site: " + site["map"]
          s.path = scriptDir + "/serve-#{type}.sh"
          s.args = [site["map"], site["to"], site["port"] ||= "80", site["ssl"] ||= "443"]
        end

        # Configure The Cron Schedule
        if (site.has_key?("schedule"))
          config.vm.provision "shell" do |s|
            s.name = "Creating Schedule"

            if (site["schedule"])
              s.path = scriptDir + "/cron-schedule.sh"
              s.args = [site["map"].tr('^A-Za-z0-9', ''), site["to"]]
            else
              s.inline = "rm -f /etc/cron.d/$1"
              s.args = [site["map"].tr('^A-Za-z0-9', '')]
            end
          end
        end

      end
    end

    config.vm.provision "shell" do |s|
      s.name = "Restarting Nginx"
      s.inline = "sudo service nginx restart; sudo service php7.1-fpm restart"
    end

    # Install MariaDB If Necessary
    if settings.has_key?("mariadb") && settings["mariadb"]
      config.vm.provision "shell" do |s|
        s.path = scriptDir + "/install-maria.sh"
      end
    end


    # Configure All Of The Configured Databases
    if settings.has_key?("databases")
        settings["databases"].each do |db|
          config.vm.provision "shell" do |s|
            s.name = "Creating MySQL Database"
            s.path = scriptDir + "/create-mysql.sh"
            s.args = [db]
          end

          config.vm.provision "shell" do |s|
            s.name = "Creating Postgres Database"
            s.path = scriptDir + "/create-postgres.sh"
            s.args = [db]
          end
        end
    end

    # Configure All Of The Server Environment Variables
    config.vm.provision "shell" do |s|
        s.name = "Clear Variables"
        s.path = scriptDir + "/clear-variables.sh"
    end

    if settings.has_key?("variables")
      settings["variables"].each do |var|
        config.vm.provision "shell" do |s|
          s.inline = "echo \"\nenv[$1] = '$2'\" >> /etc/php/7.1/fpm/php-fpm.conf"
          s.args = [var["key"], var["value"]]
        end

        config.vm.provision "shell" do |s|
            s.inline = "echo \"\n# Set Homestead Environment Variable\nexport $1=$2\" >> /home/ubuntu/.profile"
            s.args = [var["key"], var["value"]]
        end
      end

      config.vm.provision "shell" do |s|
        s.inline = "service php7.1-fpm restart"
      end
    end

    # Update Composer On Every Provision
    config.vm.provision "shell" do |s|
      s.name = "Update Composer"
      s.inline = "sudo /usr/local/bin/composer self-update && sudo chown -R ubuntu:ubuntu /home/ubuntu/.composer/"
      s.privileged = false
    end

    # Configure Blackfire.io
    if settings.has_key?("blackfire")
      config.vm.provision "shell" do |s|
        s.path = scriptDir + "/blackfire.sh"
        s.args = [
          settings["blackfire"][0]["id"],
          settings["blackfire"][0]["token"],
          settings["blackfire"][0]["client-id"],
          settings["blackfire"][0]["client-token"]
        ]
      end
    end
  end
end
