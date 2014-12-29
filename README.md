Allow to sync an ip address in your local host system file (/private/etc/hosts) with the ip address currently being used on a VMWare guest virtual machine. An host entry like '192.168.0.1 domain.local' where the ip address 192.168.0.1 will be replaced by the current ip address of your VM

USAGE
```
sudo ./hostipsync.rb 192.168.x.y

where 192.168.x.y is the initial ip that you want to replace in your host config file
(following addresses will be store in the ~/.hostipsync file, all you will need to do is call sudo ./hostipsync.rb)
```