# -*- mode: ruby -*-
# vi: set ft=ruby :

require "yaml"
conf = YAML.load_file(File.join(__dir__, "config.yml"))

Vagrant.configure("2") do |config|
        config.vbguest.auto_update = true
	config.ssh.insert_key = false

	conf.each do |role, confs|
		confs["hosts"].each.with_index(1) do |host, num|
			config.vm.define vm_name = confs["hosts"].size >= 2 ? "%s-%02d" % [role, num] : role do |role|
				role.vm.box = confs["box"]
				host["lips"].each do |lip|
					role.vm.network "private_network", ip: lip
				end
				role.vm.hostname = host["hostname"]

				if confs.has_key?("volumes") then
					confs["volumes"].each do |volume|
						v = volume.split(":")
						role.vm.synced_folder v.shift, v.shift,
						mount_options: ["dmode=%s,fmode=%s" % ["777","777"]]
					end
				end

				if confs.has_key?("provisions") then
					confs["provisions"].each do |script|
						role.vm.provision :shell do |shell|
							shell.env = confs["environment"] if confs.has_key?("environment")
							shell.inline = script
						end
					end
				end
			end
		end
	end
end
