#!/bin/bash

t_count=$(cat /root/tomcat_ip_list | wc -l)

ip_line_a=1
for a in $(bash -c "echo {1..${t_count}}")
do

cat <<\eof >> /usr/local/apache/conf/workers.properties
worker.workerNUMBER.type=ajp13
worker.workerNUMBER.host=IP
worker.workerNUMBER.port=8009
worker.workerNUMBER.lbfactor=1

eof

ip_line_b=$ip_line_a"p"
ip_addr=$(cat /root/tomcat_ip_list | sed -n $ip_line_b)
sed -i "s/NUMBER/$a/g" /usr/local/apache/conf/workers.properties
sed -i "s/IP/$ip_addr/g" /usr/local/apache/conf/workers.properties
ip_line_a=$(($ip_line_a+1))
done

case $t_count in
1)
 sed -i "s/worker.loadbalancer.balanced_workers=/worker.loadbalancer.balanced_workers=worker1/g" /usr/local/apache/conf/workers.properties
;;
2)
 sed -i "s/worker.loadbalancer.balanced_workers=/worker.loadbalancer.balanced_workers=worker1,worker2/g" /usr/local/apache/conf/workers.properties
;;
3)
 sed -i "s/worker.loadbalancer.balanced_workers=/worker.loadbalancer.balanced_workers=worker1,worker2,worker3/g" /usr/local/apache/conf/workers.properties
;;
4)
 sed -i "s/worker.loadbalancer.balanced_workers=/worker.loadbalancer.balanced_workers=worker1,worker2,worker3,worker4/g" /usr/local/apache/conf/workers.properties
;;
5)
 sed -i "s/worker.loadbalancer.balanced_workers=/worker.loadbalancer.balanced_workers=worker1,worker2,worker3,worker4,worker5/g" /usr/local/apache/conf/workers.properties
;;
6)
 sed -i "s/worker.loadbalancer.balanced_workers=/worker.loadbalancer.balanced_workers=worker1,worker2,worker3,worker4,worker5,worker6/g" /usr/local/apache/conf/workers.properties
;;
7)
 sed -i "s/worker.loadbalancer.balanced_workers=/worker.loadbalancer.balanced_workers=worker1,worker2,worker3,worker4,worker5,worker6,worker7/g" /usr/local/apache/conf/workers.properties
;;
8)
 sed -i "s/worker.loadbalancer.balanced_workers=/worker.loadbalancer.balanced_workers=worker1,worker2,worker3,worker4,worker5,worker6,worker7,worker8/g" /usr/local/apache/conf/workers.properties
;;
9)
 sed -i "s/worker.loadbalancer.balanced_workers=/worker.loadbalancer.balanced_workers=worker1,worker2,worker3,worker4,worker5,worker6,worker7,worker8,worker9/g" /usr/local/apache/conf/workers.properties
;;
10)
 sed -i "s/worker.loadbalancer.balanced_workers=/worker.loadbalancer.balanced_workers=worker1,worker2,worker3,worker4,worker5,worker6,worker7,worker8,worker9,worker10/g" /usr/local/apache/conf/workers.properties
;;
esac

rm -rf /tmp/apr* /tmp/httpd* /tmp/tomcat*

systemctl daemon-reload
systemctl enable apache
