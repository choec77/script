#!/bin/bash

ansible="/etc/ansible/ansible.cfg"

if [ ! -e ${ansible} ]; then
 if [ -e /etc/redhat-release ]; then
 yum install -y epel-release
 yum install -y ansible sshpass expect
 yum install -y python3
 else
 apt-get update -y
 apt-get install -y ansible sshpass expect
 fi
sleep 1
sed -i "s/#host_key_checking = False/host_key_checking = False/g" /etc/ansible/ansible.cfg
fi

## apache, tomcat install
line_count=$(grep -n stop /root/ansible/sw_variables.txt  | cut -d: -f1)
run_count="$(($line_count / 5))"

i=1
count=0
for i in $(bash -c "echo {1..${run_count}}")
do

line1=$((1 + $(($count*5))))"p"
line2=$((2 + $(($count*5))))"p"
line3=$((3 + $(($count*5))))"p"
line4=$((4 + $(($count*5))))"p"

IP=$(cat /root/ansible/sw_variables.txt | sed -n $line1)
apache_v=$(cat /root/ansible/sw_variables.txt | sed -n $line2)
tomcat_v=$(cat /root/ansible/sw_variables.txt | sed -n $line3)
java_v=$(cat /root/ansible/sw_variables.txt | sed -n $line4)

# apache yum // python2 use
echo "[config_servers]" > /root/ansible/config_hosts
echo "$IP" >> /root/ansible/config_hosts

expect <<EOF
set timeout 600
spawn ansible-playbook -i config_hosts config.yaml -k
expect -re "SSH password"
send "ektspt001##\r"
expect eof
EOF

# apache install
if [ "$apache_v" = "None" ]; then

echo ""
else

echo "[web_servers]" > /root/ansible/apache_hosts
echo "$IP" >> /root/ansible/apache_hosts
echo "$IP" >> /root/ansible/apache_ip_list

expect <<EOF
set timeout 600
spawn ansible-playbook -i apache_hosts apache.yaml -k
expect -re "SSH password"
send "ektspt001##\r"
expect -re "Apache version"
send "$apache_v\r"
expect -re "apr version"
send "1.7.0\r"
expect -re "apr util version"
send "1.6.1\r"
expect -re "connect version"
send "1.2.48\r"
expect eof
EOF

fi

# tomcat install
if [ "$tomcat_v" = "None" ]; then

echo ""
else

echo "[was_servers]" > /root/ansible/tomcat_hosts
echo "$IP" >> /root/ansible/tomcat_hosts

expect <<EOF
set timeout 180
spawn ansible-playbook -i tomcat_hosts tomcat.yaml -k
expect -re "SSH password"
send "ektspt001##\r"
expect -re "tomcat version"
send "$tomcat_v\r"
expect eof
EOF

fi

# java install
if [ "$java_v" = "None" ]; then

echo ""
else

echo "[java_servers]" > /root/ansible/java_hosts
echo "$IP" >> /root/ansible/java_hosts

expect <<EOF
set timeout 180
spawn ansible-playbook -i java_hosts java.yaml -k
expect -re "SSH password"
send "ektspt001##\r"
expect -re "java version"
send "$java_v\r"
expect eof
EOF

fi

count=$((count+1))
done

## apache -> tomcat

expect <<EOF
spawn ansible-playbook -i apache_ip_list file_copy.yaml -k
expect -re "SSH password"
send "ektspt001##\r"
expect eof
EOF

expect <<EOF
spawn ansible-playbook -i apache_ip_list apache_config.yaml -k
expect -re "SSH password"
send "ektspt001##\r"
expect eof
EOF


