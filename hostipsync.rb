config = {
		 	:vm_name => 'Windows 8 x64',
		 	:vm_path => '/Users/jcb/Documents',
		 	:vmware_app => '/Applications/VMware Fusion.app',
		 	:host_path => '/private/etc/hosts',
		 	:default_ip => '192.168.75.138',
		 	:last_ip_file => "#{ENV['HOME']}/.hostipsync"
         } 

#
# allow to sync an ip address in the host system file (/private/etc/hosts)
# with the ip address currently being used on a VMWare guest vineirtual mach
#
# @jcbatista 2014
#
class HostIpSync
	
public

	def initialize(config)
		@config = config
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
		content = replace(content, old_ip, new_ip)
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
 		return ip.chomp
	end

	def retrieve_ip
		ip = @config[:default_ip]
		if File.exist?(@config[:last_ip_file]) 
			ip = File.read(@config[:last_ip_file])
			         .strip
			         .chomp
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

host = HostIpSync.new(config)
				 .update()

