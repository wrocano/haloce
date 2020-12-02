
#!/bin/bash



# Function to create default configuration depending on path
create_default_firewall()
{
    echo "Troubleshooter WARNING:"
    echo "This install is for Linode, DigitalOcean, ONLY (for now). You have 5 seconds to abort now (press CTL +C). This will block SSH and DNS" 
    sleep 5
    echo "If you already ran this install script on this system and have not restored your own previous /etc/sysctl.conf_backup settings"
    echo "you need to do that before running this install script again. Reboot to flush iptables as well."
    echo "If you need to do that abort now (press CTL +C)"
    sleep 3
    wait
    echo "Installing ipset"
    echo "apt-get install ipset -y" | bash    
    echo "Backing up current /etc/sysctl.conf and then applying new settings"
    cp /etc/sysctl.conf /etc/sysctl.conf_backup
    wait    
    echo 0 > /proc/sys/net/ipv4/ipfrag_high_thresh echo 0 > /proc/sys/net/ipv4/ipfrag_low_thresh
    echo "kernel.pid_max = 65535" >> /etc/sysctl.conf
    echo "kernel.msgmnb = 65535" >> /etc/sysctl.conf
    echo "kernel.msgmax = 65535" >> /etc/sysctl.conf
    echo "fs.suid_dumpable = 0" >> /etc/sysctl.conf
    echo "vm.min_free_kbytes = 65535" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.forwarding = 0" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.forwarding = 0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.mc_forwarding=0" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.accept_redirects=0" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.eth0.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.all.accept_source_route = 0" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.default.accept_source_route = 0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.all.proxy_arp = 0" >> /etc/sysctl.conf
    echo "net.ipv4.conf.all.bootp_relay = 0" >> /etc/sysctl.conf
    echo "net.ipv4.udp_rmem_min = 16384" >> /etc/sysctl.conf
    echo "net.core.rmem_default = 262144" >> /etc/sysctl.conf
    echo "net.core.rmem_max = 16777216" >> /etc/sysctl.conf
    echo "net.ipv4.udp_wmem_min = 16384" >> /etc/sysctl.conf
    echo "net.core.wmem_default = 262144" >> /etc/sysctl.conf
    echo "net.core.wmem_max = 16777216" >> /etc/sysctl.conf
    echo "net.core.optmem_max = 65535" >> /etc/sysctl.conf
    echo "kernel.sysrq = 0" >> /etc/sysctl.conf
    sysctl -p
    wait
    sleep 2
    echo "Applying default firewall rules"
    echo "ipset create DDOS hash:ip timeout 400" | bash
    wait
    echo "ipset create LEGIT hash:ip" | bash
    wait
    echo "iptables -t raw -A PREROUTING -f -j DROP" | bash
    # echo "iptables -t mangle -I PREROUTING -s your.ssh.IP.here -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT" | bash
    echo "iptables -t mangle -A PREROUTING -s 34.197.71.170 -j ACCEPT" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --dport 2302 -m state --state NEW -m recent --update --seconds 60 --hitcount 3 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -m set --match-set LEGIT src,dst -m state --state ESTABLISHED -j ACCEPT" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --dport 2302 -m set --match-set DDOS src -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --dport 2302 -m state --state ESTABLISHED -m recent --name badguy --set" | bash
    echo "iptables -t mangle -A PREROUTING -m state --state ESTABLISHED -m recent --update --name badguy --seconds 410 --hitcount 15 -j SET --add-set DDOS src" | bash
    echo "iptables -t mangle -A PREROUTING ! -p udp -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp -s s1.master.hosthpc.com -j ACCEPT" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --dport 2302 --source-port 53 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --dport 53 --source-port 53 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --dport 2302 -m state --state INVALID,RELATED -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -s 169.254.0.0/16 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -s 192.0.2.0/24 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -s 192.168.0.0/16 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -s 10.0.0.0/8 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -s 0.0.0.0/8 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -s 240.0.0.0/5 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -s 127.0.0.0/8 ! -i lo,docker0 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -s 224.0.0.0/3 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp -m length ! --length 32:900 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --dport 2302 -m string --string ffffffff676574737461747573 --algo kmp -j DROP" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp --dport 2302 -m u32 --u32 "22&0xFFFF=0x0008" -j DROP)" | bash
    wait
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --source-port 389 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --source-port 123 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --source-port 80 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --source-port 443 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --source-port 427 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --source-port 500 -j DROP" | bash
    echo "iptables -t mangle -A PREROUTING -i eth0 -p udp --source-port 2869 -j DROP" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "Config" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "VALUE" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "SNMP" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "NTP" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "Source Engine Query" --algo kmp --to 65535 -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "getstatus" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "QUIC" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "SNMP" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "MDNS" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "SRVLOC" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "ISAKMP" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "NBDS" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "XDCMP" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "SSDP" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "RTCP" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "H.248" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A PREROUTING -i eth0 -p udp -m string --string "H.323" --algo kmp -j DROP)" | bash
    wait
    echo "$(iptables -t mangle -A POSTROUTING -m state --state INVALID -j DROP)" | bash
    wait

}

create_default_firewall

if [ -f "awkloop.sh" ];
then
   echo "awkloop found! Installation finished. Don't forget to start awkloop.sh or players will get banned by the firewall!"   
else
   echo "awkloop.sh not found! This is required. Check halopc.org"
fi

exit 0