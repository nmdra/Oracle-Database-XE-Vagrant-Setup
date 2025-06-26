Vagrant.configure("2") do |config|
  config.vm.box = "oraclelinux/8"
  config.vm.box_url = "https://oracle.github.io/vagrant-projects/boxes/oraclelinux/8.json"
  config.vm.hostname = "oracle-xe"
  config.vm.box_check_update = false

  config.vm.network "forwarded_port", guest: 1521, host: 1521, auto_correct: true  # Oracle DB listener
  config.vm.network "forwarded_port", guest: 5500, host: 5500, auto_correct: true  # EM Express web UI

  # Optional: private network for direct access (host-only)
  config.vm.network "private_network", ip: "192.168.56.38"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "oracle-8-xe-21c"
    vb.memory = 2300
    vb.cpus = 2
    vb.gui = false
  end

  config.vm.provision "shell", path: "install-xe.sh"

  # Optional: sync local SQL files or tools into VM
  # config.vm.synced_folder "./sql", "/home/vagrant/sql"

  # Optional: display helpful message at the end
  config.vm.post_up_message = <<-MESSAGE
Oracle Database XE 21c is installed and accessible.
  ➤ ip address: 192.168.56.38
  ➤ SQL*Plus:   sqlplus sys/oracle@localhost:1521/XE

To log into the VM:
  $ vagrant ssh
MESSAGE
end
