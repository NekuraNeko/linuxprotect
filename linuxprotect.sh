#!/bin/bash
#Script for hardening Linux servers
v="version 0.1"
#@naivenom

#help function
usage () 
{ 
echo -e "\n\e[00;31m#########################################################\e[00m" 
echo -e "\e[00;31m#\e[00m" "\e[00;33mMonitoring and defending Linux servers\e[00m" "\e[00;31m#\e[00m"
echo -e "\e[00;31m#########################################################\e[00m"
echo -e "\e[00;33m# www.fwhibbit.es && @naivenom \e[00m"
echo -e "\e[00;33m# $v\e[00m\n"
echo -e "\e[00;33m# Example: ./linuxprotect.sh -i advanced -k status"

		echo "OPTIONS:"
		echo "-k		Enter keyword or option"
		echo "-e		Enter export location"
		echo "-t		Include thorough (lengthy) tests"
		echo "-r		Enter report name" 
		echo "-h		Displays this help text"
		echo "-i  		Displays IPTABLES Execution Command for LAN Network. Mode: -i basic/advanced"
		echo "-r 		Displays RECON in LAN Network. Mode: -r scan/dhcp/dns"
		echo "-s 		Displays SERVICES in Server. Mode: -s disable/enable/info"
		echo "-H 		Displays HOST FILE in Server. Mode: -H malicious/dns"
		echo -e "\n"
		echo "Running with no options = limited execution/no output file"
		
echo -e "\e[00;31m#########################################################\e[00m"		
}
header()
{
echo -e "\n\e[00;31m#########################################################\e[00m" 
echo -e "\e[00;31m#\e[00m" "\e[00;33mMonitoring and defending Linux servers\e[00m" "\e[00;31m#\e[00m" 
echo -e "\e[00;31m#########################################################\e[00m" 
echo -e "\e[00;33m# www.fwhibbit.es\e[00m" 
echo -e "\e[00;33m# @naivenom\e[00m" 
echo -e "\e[00;33m# $v\e[00m\n" 

}

debug_info()
{
echo "Debug Info" 

if [ "$keyword" ]; then 
	echo "keyword = $keyword" 
else 
	:
fi

if [ "$report" ]; then 
	echo "report name = $report" 
else 
	:
fi

if [ "$export" ]; then 
	echo "export location = $export" 
else 
	:
fi

if [ "$thorough" ]; then 
	echo "thorough tests = enabled" 
else 
	echo "thorough tests = disabled" 
fi

if [ "$iptables" ]; then 
	echo "iptables execution = enabled" 
else 
	echo "iptables execution = disabled" 
fi

if [ "$recon" ]; then 
	echo "recon execution = enabled" 
else 
	echo "recon execution = disabled" 
fi

if [ "$services" ]; then 
	echo "services execution = enabled" 
else 
	echo "services execution = disabled" 
fi

if [ "$host" ]; then 
	echo "host execution = enabled" 
else 
	echo "host execution = disabled" 
fi

sleep 2

if [ "$export" ]; then
	mkdir $export 2>/dev/null
	format=$export/linuxprotect-export-`date +"%d-%m-%y"`
	mkdir $format 2>/dev/null
else 
	:
fi


echo -e "\e[00;33mThe Tool was executed:"; date 
echo -e "\e[00m\n" 
}

iptables_basic()
{
echo -e "\e[00;33m### IPTABLES ##############################################\e[00m" 
echo -e "Using default policy to DROP"
#basic iptables status of firewall
if [ "$keyword" = "status" ]; then 
	iptables -L -n -v
else 
	:
fi

echo 1 >/proc/sys/net/ipv4/ip_forward

########################OUTGOING AND INCOMING REQUESTS TO THIS FIREWALL SERVER
#Loopback traffic ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#DNS request through Internet
if [ "$keyword" = "dns_ext" ]; then
	read -p 'External interface: ' ext_int
	echo -e "Allow DNS request through Internet"
	iptables -A INPUT -i $ext_int -p udp --sport 53 -j ACCEPT
	iptables -A OUTPUT -o $ext_int -p udp --dport 53 -j ACCEPT
else 
	:
fi

#HTTP and HTTPS request through Internet
if [ "$keyword" = "http_ext" ]; then
	read -p 'External interface: ' ext_int
	echo -e "Allow HTTP and HTTPS request through Internet"
	iptables -A INPUT -i $ext_int -p tcp --sport 80 -j ACCEPT
	iptables -A OUTPUT -o $ext_int -p tcp --dport 80 -j ACCEPT
	iptables -A INPUT -i $ext_int -p tcp --sport 443 -j ACCEPT
	iptables -A OUTPUT -o $ext_int -p tcp --dport 443 -j ACCEPT
else 
	:
fi

#DHCP request
if [ "$keyword" = "dhcp_ext" ]; then
	read -p 'External interface: ' ext_int
	echo -e "Allow DHCP"
	iptables -A INPUT -i $ext_int -p udp --sport 67:68 -j ACCEPT
	iptables -A OUTPUT -o $ext_int -p udp --dport 67:68 -j ACCEPT
else 
	:
fi

#Allow or enable outgoing ping request
if [ "$keyword" = "icmp_ext" ]; then
	read -p 'External interface: ' ext_int
	echo -e "Allow or enable outgoing ping request"
	iptables -A INPUT -i $ext_int -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT
	iptables -A OUTPUT -o $ext_int -p icmp -j ACCEPT
else 
	:
fi

#SSH request
if [ "$keyword" = "ssh_ext" ]; then
	read -p 'External interface: ' ext_int
	echo -e "Allow SSH"
	iptables -A INPUT -i $ext_int -p tcp --sport 22 -j ACCEPT
	iptables -A OUTPUT -o $ext_int -p tcp --dport 22 -j ACCEPT
else 
	:
fi

#Allow SSH conexion to this Server
if [ "$keyword" = "ssh_server" ]; then
	echo -e "Allow SSH conexion to this Server"
	iptables -A INPUT -p tcp --sport 22 -j ACCEPT
	iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
else 
	:
fi

########################FORWARDING TO LAN NETWORK

#Allow ICMP
if [ "$keyword" = "icmp_lan" ]; then
	read -p 'External interface: ' ext_int
	read -p 'LAN interface: ' lan_int
	echo -e "Allow or enable outgoing ping request"
	iptables -t filter -A FORWARD -i $lan_int -o $ext_int -p icmp -j ACCEPT
	iptables -t filter -A FORWARD -i $ext_int -o $lan_int -p icmp -j ACCEPT
else 
	:
fi

#Allow HTTP and HTTPS traffic
if [ "$keyword" = "http_lan" ]; then
	read -p 'External interface: ' ext_int
	read -p 'LAN interface: ' lan_int
	echo -e "Allow HTTP and HTTPS traffic"
	iptables -A FORWARD -i $lan_int -o $ext_int -p tcp --dport 80 -j ACCEPT
	iptables -A FORWARD -i $ext_int -o $lan_int -p tcp --sport 80 -j ACCEPT
	iptables -A FORWARD -i $lan_int -o $ext_int -p tcp --dport 443 -j ACCEPT
	iptables -A FORWARD -i $ext_int -o $lan_int -p tcp --sport 443 -j ACCEPT
else 
	:
fi

#HTTP Server
if [ "$keyword" = "http_server" ]; then
	read -p 'External interface: ' ext_int
	read -p 'LAN interface: ' lan_int
	echo -e "HTTP Server"
	iptables -A FORWARD -i $ext_int -o $lan_int -p tcp --dport 80 -j ACCEPT
	iptables -A FORWARD -i $lan_int -o $ext_int -p tcp --sport 80 -j ACCEPT
else 
	:
fi

#DNS Requests
if [ "$keyword" = "dns_lan" ]; then
	read -p 'External interface: ' ext_int
	read -p 'LAN interface: ' lan_int
	echo -e "DNS Requests"
	iptables -A FORWARD -i $lan_int -o $ext_int -p tcp --dport 53 -j ACCEPT
	iptables -A FORWARD -i $ext_int -o $lan_int -p tcp --sport 53 -j ACCEPT
else 
	:
fi

#################################NAT
#DNAT to client of the LAN Network. HTTP 
if [ "$keyword" = "dnat_http" ]; then
	read -p 'External interface: ' ext_int
	read -p 'Client OR Server IP: ' ip
	echo -e "DNAT to client of the LAN Network --> HTTP Port 80"
	iptables -t nat -A PREROUTING -i $ext_int -p tcp --dport 80 -j DNAT --to-destination $ip
else 
	:
fi

#SNAT FOR OUTGOING PACKETS THROUGH INTERNET (EXTERNAL INTERFACE)
if [ "$keyword" = "snat_lan" ]; then
	read -p 'External interface: ' ext_int
	read -p 'LAN Network: ' net #192.168.1.0/24
	echo -e "SNAT for outgoing packets through internet"
	iptables -t nat -A POSTROUTING -s $net -o $ext_int -j MASQUERADE
else 
	:
fi

#List of rules applied to the filter table
if [ "$keyword" = "list_filter" ]; then 
	iptables -t filter -nvL --line-numbers
	echo -e "List of rules applied to the filter table"
else 
	:
fi

#List of rules applied for the table nat
if [ "$keyword" = "list_nat" ]; then 
	iptables -t nat -nvL --line-numbers
	echo -e "List of rules applied for the table nat"
else 
	:
fi

#Selective deleting by rule number
if [ "$keyword" = "delete_selective" ]; then
	read -p 'Introduce table: ' table
	read -p 'Introduce chain: ' cadena
	read -p 'Introduce number of rule: ' number
	iptables -t $table -D $cadena $number
	echo -e "Selective deleting by rule number"

else 
	:
fi

#Deleting (flushing) all the rules and delete chain
if [ "$keyword" = "restart_firewall" ]; then 
	iptables -F
	iptables -X
	echo -e "Deleting (flushing) all the rules and delete chain"

else 
	:
fi

if [ "$keyword" = "policy_default" ]; then
	read -p 'Introduce chain: ' chain
	iptables -P $chain DROP
	echo -e "Setting policy by default to DROP"

else 
	:
fi

}

iptables_advanced()
{
echo -e "\e[00;33m### IPTABLES ##############################################\e[00m" 
echo -e "Using default policy to DROP"
#basic iptables status of firewall
if [ "$keyword" = "status" ]; then 
	iptables -L -n -v
else 
	:
fi

echo 1 >/proc/sys/net/ipv4/ip_forward

########################AVOID SCAN
if [ "$keyword" = "avoid_scan" ]; then
	read -p 'External interface: ' ext_int
	read -p 'Introduce chain (INPUT|FORWARD): ' chain
	echo -e "Restrict certain types of scans or malformed packages"
	echo -e "I/O for this own server (INPUT/OUTPUT) OR traffic not directed at this server (FORWARD)"
	iptables -A $chain -i $ext_int -p tcp --tcp-flags ACK ACK -m state --state NEW -j REJECT
	iptables -A $chain -i $ext_int -p tcp --tcp-flags RST RST -m state --state NEW -j REJECT
	iptables -A $chain -i $ext_int -p tcp --tcp-flags PSH PSH -m state --state NEW -j REJECT
	iptables -A $chain -i $ext_int -p tcp --tcp-flags FIN FIN -m state --state INVALID -j REJECT
	iptables -A $chain -i $ext_int -p tcp --tcp-flags FIN,PSH,URG FIN,PSH,URG -j DROP
	iptables -A $chain -i $ext_int -p tcp --tcp-flags ALL ACK,RST,SYN,FIN -j DROP
	iptables -A $chain -i $ext_int -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
	iptables -A $chain -i $ext_int -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
	iptables -A $chain -i $ext_int -p tcp --tcp-flags ALL NONE -j DROP
	
else 
	:
fi

##########################AVOID TCP SYN INPUT CONNECTIONS (SYN FLOOD)

if [ "$keyword" = "avoid_syn" ]; then
	read -p 'External interface: ' ext_int
	read -p 'Introduce chain (INPUT|FORWARD): ' chain
	echo -e "Limit incoming TCP SYN connections"
	echo -e "I/O for this own server (INPUT/OUTPUT) OR traffic not directed at this server (FORWARD)"
	iptables -A $chain -i $ext_int -p tcp --syn -m recent --set
	iptables -A $chain -i $ext_int -p tcp --syn -m recent --update --seconds 5 --hitcount 20 -j DROP
	
	
else 
	:
fi

##########################AVOID PING PER SECOND AND IP ADDRESS (ICMP FLOOD)

if [ "$keyword" = "avoid_ping" ]; then
	read -p 'External interface: ' ext_int
	read -p 'Introduce chain (INPUT|FORWARD): ' chain
	echo -e "Avoid ping per second and IP ADDRESS"
	echo -e "I/O for this own server (INPUT/OUTPUT) OR traffic not directed at this server (FORWARD)"
	iptables -A $chain -i $ext_int -p icmp --icmp-type echo-request -m hashlimit --hashlimit-name ping --hashlimit-above 1/s --hashlimit-burst 2 --hashlimit-mode srcip -j REJECT
	
	
else 
	:
fi


########################OUTGOING AND INCOMING REQUESTS TO THIS FIREWALL SERVER
#Loopback traffic ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#DNS request through Internet
if [ "$keyword" = "dns_ext" ]; then
	read -p 'External interface: ' ext_int
	echo -e "Allow DNS request through Internet"
	iptables -A INPUT -i $ext_int -p udp --sport 53 -j ACCEPT
	iptables -A OUTPUT -o $ext_int -p udp --dport 53 -j ACCEPT
else 
	:
fi

#HTTP and HTTPS request through Internet
if [ "$keyword" = "http_ext" ]; then
	read -p 'External interface: ' ext_int
	echo -e "Allow HTTP and HTTPS request through Internet"
	iptables -A INPUT -i $ext_int -p tcp --sport 80 -j ACCEPT
	iptables -A OUTPUT -o $ext_int -p tcp --dport 80 -j ACCEPT
	iptables -A INPUT -i $ext_int -p tcp --sport 443 -j ACCEPT
	iptables -A OUTPUT -o $ext_int -p tcp --dport 443 -j ACCEPT
else 
	:
fi

#Allow ICMP
if [ "$keyword" = "icmp_ext" ]; then
	echo -e "Allow or enable ping request"
	iptables -A INPUT -p icmp -j ACCEPT
	iptables -A OUTPUT -p icmp -j ACCEPT
else 
	:
fi

#SSH request
if [ "$keyword" = "ssh_ext" ]; then
	read -p 'External interface: ' ext_int
	echo -e "Allow SSH"
	iptables -A INPUT -i $ext_int -p tcp --sport 22 -j ACCEPT
	iptables -A OUTPUT -o $ext_int -p tcp --dport 22 -j ACCEPT
else 
	:
fi

#SSH request TO DMZ
if [ "$keyword" = "ssh_dmz" ]; then
	read -p 'DMZ interface: ' dmz_int
	read -p 'External interface: ' ext_int
	read -p 'DMZ Network: ' net_dmz
	echo -e "Allow SSH request to DMZ"
	iptables -A INPUT -i $dmz_int -s $net_dmz -p tcp --sport 22 -j ACCEPT
	iptables -A OUTPUT -o $ext_int -d $net_dmz -p tcp --dport 22 -j ACCEPT
else 
	:
fi

#SSH Server
if [ "$keyword" = "ssh_server" ]; then
	read -p 'LAN interface: ' lan_int
	read -p 'External interface: ' ext_int
	echo -e "Allow SSH Server traffic"
	iptables -A INPUT -i $lan_int -p tcp --dport 22 -j ACCEPT
	iptables -A OUTPUT -o $lan_int -p tcp --sport 22 -j ACCEPT
	iptables -A INPUT -i $ext_int -s 8.8.8.8 -p tcp --dport 22 -j ACCEPT
	iptables -A OUTPUT -o $ext_int -d 8.8.8.8 -p tcp --sport 22 -j ACCEPT
	iptables -A INPUT -i $ext_int -s 8.8.4.4 -p tcp --dport 22 -j ACCEPT
	iptables -A OUTPUT -o $ext_int -d 8.8.4.4 -p tcp --sport 22 -j ACCEPT
else 
	:
fi

##############################FORWARDING TO DMZ NETWORK

#Allow source ICMP traffic from DMZ
if [ "$keyword" = "icmp_dmz" ]; then
	read -p 'DMZ interface: ' dmz_int
	read -p 'External interface: ' ext_int
	read -p 'DMZ Network: ' net_dmz
	echo -e "Allow source ICMP traffic from DMZ"
	iptables -A FORWARD -i $dmz_int -s $net_dmz -p icmp -j ACCEPT
	iptables -A FORWARD -o $dmz_int -d $net_dmz -p icmp --icmp-type destination-unreachable -j ACCEPT
	iptables -A FORWARD -o $dmz_int -d $net_dmz -p icmp --icmp-type time-exceeded -j ACCEPT
	iptables -A FORWARD -o $dmz_int -d $net_dmz -p icmp --icmp-type echo-reply -j ACCEPT
	iptables -A FORWARD -o $dmz_int -d $net_dmz -p icmp --icmp-type echo-request -j ACCEPT

else 
	:
fi

#Allow HTTP and HTTPS traffic
if [ "$keyword" = "http_dmz" ]; then
	read -p 'External interface: ' ext_int
	read -p 'DMZ interface: ' dmz_int
	echo -e "Allow HTTP and HTTPS traffic"
	iptables -A FORWARD -i $dmz_int -o $ext_int -p tcp --dport 80 -j ACCEPT
	iptables -A FORWARD -i $ext_int -o $dmz_int -p tcp --sport 80 -j ACCEPT
	iptables -A FORWARD -i $dmz_int -o $ext_int -p tcp --dport 443 -j ACCEPT
	iptables -A FORWARD -i $ext_int -o $dmz_int -p tcp --sport 443 -j ACCEPT
else 
	:
fi

#DNS Requests
if [ "$keyword" = "dns_dmz" ]; then
	read -p 'External interface: ' ext_int
	read -p 'DMZ interface: ' dmz_int
	echo -e "Allow DNS Requests"
	iptables -A FORWARD -i $dmz_int -o $ext_int -p tcp --dport 53 -j ACCEPT
	iptables -A FORWARD -i $ext_int -o $dmz_int -p tcp --sport 53 -j ACCEPT
else 
	:
fi

#Allow DMZ Web Server traffic. HTTP and HTTPS
if [ "$keyword" = "http_dmz_server" ]; then
	read -p 'DMZ interface: ' dmz_int
	read -p 'External interface: ' ext_int
	read -p 'DMZ Network: ' net_dmz
	echo -e "Allow DMZ Web Server traffic. HTTP and HTTPS"
	iptables -A FORWARD -d $net_dmz -i $ext_int -o $dmz_int -p tcp --dport 80 -j ACCEPT
	iptables -A FORWARD -s $net_dmz -i $dmz_int -o $ext_int -p tcp --sport 80 -j ACCEPT
	iptables -A FORWARD -d $net_dmz -i $ext_int -o $dmz_int -p tcp --dport 443 -j ACCEPT
	iptables -A FORWARD -s $net_dmz -i $dmz_int -o $ext_int -p tcp --sport 443 -j ACCEPT
else 
	:
fi

#Allow DMZ Mail Server traffic.
if [ "$keyword" = "mail_dmz_server" ]; then
	read -p 'DMZ interface: ' dmz_int
	read -p 'External interface: ' ext_int
	read -p 'DMZ Network: ' net_dmz
	echo -e "Allow Mail Web Server traffic"
	iptables -A FORWARD -d $net_dmz -i $ext_int -o $dmz_int -p tcp --dport 25 -j ACCEPT
	iptables -A FORWARD -s $net_dmz -i $dmz_int -o $ext_int -p tcp --sport 25 -j ACCEPT
	iptables -A FORWARD -d $net_dmz -i $ext_int -o $dmz_int -p tcp --dport 465 -j ACCEPT
	iptables -A FORWARD -s $net_dmz -i $dmz_int -o $ext_int -p tcp --sport 465 -j ACCEPT
	iptables -A FORWARD -d $net_dmz -i $ext_int -o $dmz_int -p tcp --dport 110 -j ACCEPT
	iptables -A FORWARD -s $net_dmz -i $dmz_int -o $ext_int -p tcp --sport 110 -j ACCEPT
	iptables -A FORWARD -d $net_dmz -i $ext_int -o $dmz_int -p tcp --dport 995 -j ACCEPT
	iptables -A FORWARD -s $net_dmz -i $dmz_int -o $ext_int -p tcp --sport 995 -j ACCEPT
	iptables -A FORWARD -d $net_dmz -i $ext_int -o $dmz_int -p tcp --dport 220 -j ACCEPT
	iptables -A FORWARD -s $net_dmz -i $dmz_int -o $ext_int -p tcp --sport 220 -j ACCEPT
	iptables -A FORWARD -d $net_dmz -i $ext_int -o $dmz_int -p tcp --dport 993 -j ACCEPT
	iptables -A FORWARD -s $net_dmz -i $dmz_int -o $ext_int -p tcp --sport 993 -j ACCEPT
else 
	:
fi

##############################FORWARDING TO LAN NETWORK
#Allow source ICMP traffic from LAN Network
if [ "$keyword" = "icmp_lan" ]; then
	read -p 'LAN interface: ' lan_int
	read -p 'LAN Network: ' net
	echo -e "Allow source ICMP traffic from LAN Network"
	iptables -A FORWARD -i $lan_int -s $net -p icmp -j ACCEPT
	iptables -A FORWARD -o $lan_int -d $net -p icmp --icmp-type destination-unreachable -j ACCEPT
	iptables -A FORWARD -o $lan_int -d $net -p icmp --icmp-type time-exceeded -j ACCEPT
	iptables -A FORWARD -o $lan_int -d $net -p icmp --icmp-type echo-reply -j ACCEPT
	iptables -A FORWARD -o $lan_int -d $net -p icmp --icmp-type echo-request -j ACCEPT

else 
	:
fi

#Allow HTTP and HTTPS traffic
if [ "$keyword" = "http_lan" ]; then
	read -p 'External interface: ' ext_int
	read -p 'LAN interface: ' lan_int
	echo -e "Allow HTTP and HTTPS traffic"
	iptables -A FORWARD -i $lan_int -o $ext_int -p tcp --dport 80 -j ACCEPT
	iptables -A FORWARD -i $ext_int -o $lan_int -p tcp --sport 80 -j ACCEPT
	iptables -A FORWARD -i $lan_int -o $ext_int -p tcp --dport 443 -j ACCEPT
	iptables -A FORWARD -i $ext_int -o $lan_int -p tcp --sport 443 -j ACCEPT
else 
	:
fi

#Allow HTTP server in LAN Network
if [ "$keyword" = "http_server" ]; then
	read -p 'LAN interface: ' dmz_int
	read -p 'External interface: ' ext_int
	echo -e "Allow HTTP server in LAN Network"
	iptables -A FORWARD -i $ext_int -o $lan_int -p tcp --dport 80 -j ACCEPT
	iptables -A FORWARD -i $lan_int -o $ext_int -p tcp --sport 80 -j ACCEPT
else 
	:
fi

#DNS Requests
if [ "$keyword" = "dns_lan" ]; then
	read -p 'External interface: ' ext_int
	read -p 'LAN interface: ' lan_int
	echo -e " Allow DNS Requests"
	iptables -A FORWARD -i $lan_int -o $ext_int -p tcp --dport 53 -j ACCEPT
	iptables -A FORWARD -i $ext_int -o $lan_int -p tcp --sport 53 -j ACCEPT
else 
	:
fi

################################NAT
#OPEN PORTS
#DNAT to client of the DMZ Network. HTTP 
if [ "$keyword" = "dnat_http" ]; then
	read -p 'External interface: ' ext_int
	read -p 'Client OR Server IP: ' ip
	echo -e "DNAT to client of the DMZ Network --> HTTP Port 80"
	iptables -t nat -A PREROUTING -i $ext_int -p tcp --dport 80 -j DNAT --to-destination $ip
else 
	:
fi

#DNAT to client of the DMZ Network. HTTPS
if [ "$keyword" = "dnat_https" ]; then
	read -p 'External interface: ' ext_int
	read -p 'Client OR Server IP: ' ip
	echo -e "DNAT to client of the DMZ Network --> HTTPS Port 443"
	iptables -t nat -A PREROUTING -i $ext_int -p tcp --dport 443 -j DNAT --to-destination $ip
else 
	:
fi

#DNAT to client of the DMZ Network. SMTP
if [ "$keyword" = "dnat_smtp" ]; then
	read -p 'External interface: ' ext_int
	read -p 'Client OR Server IP: ' ip
	echo -e "DNAT to client of the DMZ Network --> SMTP Port 25"
	iptables -t nat -A PREROUTING -i $ext_int -p tcp --dport 25 -j DNAT --to-destination $ip
else 
	:
fi

#DNAT to client of the DMZ Network. SMTPS
if [ "$keyword" = "dnat_smtps" ]; then
	read -p 'External interface: ' ext_int
	read -p 'Client OR Server IP: ' ip
	echo -e "DNAT to client of the DMZ Network --> SMTPS Port 465"
	iptables -t nat -A PREROUTING -i $ext_int -p tcp --dport 465 -j DNAT --to-destination $ip
else 
	:
fi

#DNAT to client of the DMZ Network. POP3
if [ "$keyword" = "dnat_pop3" ]; then
	read -p 'External interface: ' ext_int
	read -p 'Client OR Server IP: ' ip
	echo -e "DNAT to client of the DMZ Network --> POP3 Port 110"
	iptables -t nat -A PREROUTING -i $ext_int -p tcp --dport 110 -j DNAT --to-destination $ip
else 
	:
fi

#DNAT to client of the DMZ Network. POP3 Securely
if [ "$keyword" = "dnat_pop3secure" ]; then
	read -p 'External interface: ' ext_int
	read -p 'Client OR Server IP: ' ip
	echo -e "DNAT to client of the DMZ Network --> POP3 Securely Port 995"
	iptables -t nat -A PREROUTING -i $ext_int -p tcp --dport 995 -j DNAT --to-destination $ip
else 
	:
fi

#DNAT to client of the DMZ Network. IMAP
if [ "$keyword" = "dnat_imap" ]; then
	read -p 'External interface: ' ext_int
	read -p 'Client OR Server IP: ' ip
	echo -e "DNAT to client of the DMZ Network --> IMAP Port 220"
	iptables -t nat -A PREROUTING -i $ext_int -p tcp --dport 220 -j DNAT --to-destination $ip
else 
	:
fi

#DNAT to client of the DMZ Network. IMAPS
if [ "$keyword" = "dnat_imaps" ]; then
	read -p 'External interface: ' ext_int
	read -p 'Client OR Server IP: ' ip
	echo -e "DNAT to client of the DMZ Network --> IMAPS Port 993"
	iptables -t nat -A PREROUTING -i $ext_int -p tcp --dport 993 -j DNAT --to-destination $ip
else 
	:
fi

#SNAT FOR OUTGOING PACKETS THROUGH INTERNET (EXTERNAL INTERFACE)
if [ "$keyword" = "snat_lan" ]; then
	read -p 'External interface: ' ext_int
	read -p 'LAN Network: ' net #192.168.1.0/24
	echo -e "SNAT for outgoing packets through internet and LAN NETWORK"
	iptables -t nat -A POSTROUTING -s $net -o $ext_int -j MASQUERADE
else 
	:
fi

#SNAT FOR OUTGOING PACKETS THROUGH INTERNET (EXTERNAL INTERFACE)
if [ "$keyword" = "snat_dmz" ]; then
	read -p 'External interface: ' ext_int
	read -p 'DMZ Network: ' net_dmz #192.168.1.0/24
	echo -e "SNAT for outgoing packets through internet and DMZ NETWORK"
	iptables -t nat -A POSTROUTING -s $net_dmz -o $ext_int -j MASQUERADE
else 
	:
fi

if [ "$keyword" = "list_filter" ]; then 
	iptables -t filter -nvL --line-numbers
	echo -e "List of rules applied to the filter table"
else 
	:
fi

if [ "$keyword" = "list_nat" ]; then 
	iptables -t nat -nvL --line-numbers
	echo -e "List of rules applied for the table nat"
else 
	:
fi

if [ "$keyword" = "delete_selective" ]; then
	read -p 'Introduce table: ' table
	read -p 'Introduce chain: ' cadena
	read -p 'Introduce number of rule: ' number
	iptables -t $table -D $cadena $number
	echo -e "Selective deleting by rule number"

else 
	:
fi

if [ "$keyword" = "restart_firewall" ]; then 
	iptables -F
	iptables -X
	echo -e "Deleting (flushing) all the rules and delete chain"

else 
	:
fi

if [ "$keyword" = "policy_default" ]; then
	read -p 'Introduce chain: ' chain
	iptables -P $chain DROP
	echo -e "Setting policy by default to DROP"

else 
	:
fi

if [ "$keyword" = "disable_ipv6" ]; then
	read -p 'Introduce chain: ' chain
	ip6tables -P $chain DROP
	echo -e "Deactivation of the ipv6 protocol"

else 
	:
fi

}

recon_scan()
{
	echo -e "\e[00;33m### SCAN ##############################################\e[00m"
	sleep 1
	
	if [ "$keyword" = "bash_ping" ]; then
		read -p 'Introduce Network (Ex:10.10.1): ' net
		for i in {1..254}; do ping -c 1 -W 1 $net.$i | grep 'from'; done
	else 
		:
	fi

	if [ "$keyword" = "nmap_ping" ]; then
		read -p 'Introduce Network (Ex:10.10.1.0/24): ' net
		nmap -sn -PE $net
	else 
		:
	fi

	if [ "$keyword" = "nmap_scan" ]; then
		read -p 'Introduce IP: ' ip
		nmap -v -Pn -T4 -A -p- $ip
	else 
		:
	fi
	
}

recon_dhcp()
{
	echo -e "\e[00;33m### DHCP LEASE LOGS ##############################################\e[00m"
	grep -Ei 'dhcp' /var/log/syslog.1
	
	
}

recon_dns()
{
	echo -e "\e[00;33m### DNS LOGS ##############################################\e[00m"
	tail -f /var/log/messages | grep named
	
	
}

services_info()
{
	echo -e "\e[00;33m### SERVICES INFO ##############################################\e[00m"
	if [ "$keyword" = "service" ]; then
		service --status-all
	else 
		:
	fi

	if [ "$keyword" = "ps" ]; then
		ps -ef
		ps -aux
	else 
		:
	fi
	
	
}

services_start()
{
	echo -e "\e[00;33m### SERVICE START ##############################################\e[00m"
	if [ "$keyword" = "apache2" ]; then
		/etc/init.d/apache2 start
	else 
		:
	fi

	if [ "$keyword" = "mysql" ]; then
		service mysql start
	else 
		:
	fi
	
	
}

services_restart()
{
	echo -e "\e[00;33m### SERVICE RESTART ##############################################\e[00m"
	if [ "$keyword" = "apache2" ]; then
		/etc/init.d/apache2 restart
	else 
		:
	fi

	if [ "$keyword" = "mysql" ]; then
		service mysql restart
	else 
		:
	fi
	
	
}

services_stop()
{
	echo -e "\e[00;33m### SERVICE STOP ##############################################\e[00m"
	if [ "$keyword" = "apache2" ]; then
	/etc/init.d/apache2 stop
	else 
		:
	fi

	if [ "$keyword" = "mysql" ]; then
	service mysql stop
	else 
		:
	fi
	
	
}

host_malicious()
{
	echo -e "\e[00;33m### NEW MALICIOUS DOMAIN ##############################################\e[00m"
	if [ "$keyword" = "route_localhost" ]; then
		read -p 'Introduce MALICIOUS DOMAIN: ' domain
		echo 127.0.0.1 $domain >> /etc/hosts
	else 
		:
	fi

	if [ "$keyword" = "check_route" ]; then
		read -p 'Introduce MALICIOUS DOMAIN: ' domain
		ping -c 1 $domain
	else 
		:
	fi
	
	
}

host_dns()
{
	echo -e "\e[00;33m### DNS CACHE ##############################################\e[00m"
	if [ "$keyword" = "dns_flush" ]; then
		/etc/init.d/dns-clean start
	else 
		:
	fi

	if [ "$keyword" = "dnsmasq_flush" ]; then
		noexist=`apt-cache policy nmap | grep Installed | cut -d' ' -f4`
		if [ "$noexist" == "(none)" ]; then
			apt-get install dnsmasq
		else 
			/etc/init.d/dnsmasq restart
		fi
	else 
		:
	fi
	
	
}
call_functions()
{
	header
	debug_info
	if [ "$iptables" = "basic" ]; then
	iptables_basic
	else 
		:
	fi
	if [ "$iptables" = "advanced" ]; then
	iptables_advanced
	else 
		:
	fi
	if [ "$recon" = "scan" ]; then
	recon_scan
	else 
		:
	fi

	if [ "$recon" = "dhcp" ]; then
	recon_dhcp
	else 
		:
	fi

	if [ "$recon" = "dns" ]; then
	recon_dns
	else 
		:
	fi

	if [ "$services" = "info" ]; then
	services_info
	else 
		:
	fi

	if [ "$services" = "start" ]; then
	services_start
	else 
		:
	fi

	if [ "$services" = "restart" ]; then
	services_restart
	else 
		:
	fi

	if [ "$services" = "stop" ]; then
	services_stop
	else 
		:
	fi

	if [ "$host" = "malicious" ]; then
	host_malicious
	else 
		:
	fi

	if [ "$host" = "dns" ]; then
	host_dns
	else 
		:
	fi
}

while getopts "i:r:s:H:h:k:r:e:t" option; do
 case "${option}" in
 		i) iptables=${OPTARG};;
		r) recon=${OPTARG};;
		s) services=${OPTARG};;
		H) host=${OPTARG};;
		k) keyword=${OPTARG};;
		r) report=${OPTARG}"-"`date +"%d-%m-%y"`;;
		e) export=${OPTARG};;
		t) thorough=1;;
		h) usage; exit;;
		*) usage; exit;;
 esac
done



call_functions | tee -a $report 2> /dev/null
