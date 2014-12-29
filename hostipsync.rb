#!/usr/bin/ruby
#
# allow to sync an ip address in your local host system file (/private/etc/hosts)
# with the ip address currently being used on a VMWare guest virtual machine
#
# An host entry like '192.168.0.1 domain.local' where the ip address 192.168.0.1 
# will be replaced by the current ip address of your VM
#
# USAGE
#
# sudo ./hostipsync.rb 192.168.x.y
#
# where 192.168.x.y is the initial ip that you want to replace in your host config file
# (following addresses will be store in the ~/.hostipsync file, 
#  all you will need to do is call sudo ./hostipsync.rb)
#
# @jcbatista 2014
#
config = {
		 	:vm_name => 'Windows 8 x64',
		 	:vm_path => '/Users/jcb/Documents',
		 	:vmware_app => '/Applications/VMware Fusion.app',
		 	:host_path => '/private/etc/hosts',
		 	:default_ip => '192.168.75.138',
		 	:last_ip_file => "#{ENV['HOME']}/.hostipsync"
         } 

class HostIpSync
	
public

	def initialize(config, ip)
		@config = config
		@ip = ip
	end

	def update
		old_ip = retrieve_ip
		new_ip = get_vm_ip
		
		if(old_ip == new_ip)
			puts "nothing to do ..."
			return
		end

		puts "Updating #{@config[:host_path]}, replacing '#{old_ip}' to '#{new_ip}'"

		content = get_host_data

		#puts "Before ..."
		#puts content

		content = replace(content, old_ip, new_ip)

		puts "After ..."
		puts content

		update_host(content)
		store_ip(new_ip)
		update_ds

		puts "Done."
	end

private

	def get_host_data
		return File.readlines(@config[:host_path])
	end

	def replace(content, old_ip, new_ip)
		return content.map { |line| line.gsub(old_ip, new_ip) } 
	end

	def get_vm_ip
		vmrun = "#{@config[:vmware_app]}/Contents/Library/vmrun"
		vm = "#{@config[:vm_path]}/Virtual Machines.localized/#{@config[:vm_name]}.vmwarevm/#{@config[:vm_name]}.vmx"
 		ip = `'#{vmrun}' getGuestIPAddress '#{vm}'`
 		ip = ip.chomp
 		if(!ip.match('\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'))
 			raise "couldn't retrieve ip address from the vm ..."
 		end
 		return ip
	end

	def retrieve_ip
		ip = nil
		if(@ip!=nil && @ip!="")
			ip = @ip
		elsif File.exist?(@config[:last_ip_file]) 
			ip = File.read(@config[:last_ip_file])
			         .strip
			         .chomp
		else
			ip = @config[:default_ip]
		end

		return ip
	end

	def store_ip(ip)
		File.write(@config[:last_ip_file], ip)
	end

	def update_host(content)
		File.open(@config[:host_path], 'w') do |file|
			file.puts content
		end
	end

	def update_ds
		`dscacheutil -flushcache`
	end
end

host = HostIpSync.new(config, ARGV[0])
				 .update()
