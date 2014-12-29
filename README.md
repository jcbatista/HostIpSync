Allow to sync an ip address in your local host system file (/private/etc/hosts) with the ip address currently being used on a VMWare guest virtual machine

An host entry like '192.168.0.1 domain.local' where the ip address 192.168.0.1 will be replaced by the current ip address of your VM

USAGE

set :default_ip as the intial ip you want to sync in the config map below
(following addresses will be store in the ~/.hostipsync file)
