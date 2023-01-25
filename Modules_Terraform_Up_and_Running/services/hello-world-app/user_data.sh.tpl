#!bin/bash
yum -y update
yum -y install httpd
PrivateIP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo "<html><body bgcolor=black><center><h2><p><font color=red>${server_text} Web Server with: $PrivateIP Build by Terraform! DB-port: ${db_port}, DB-address: ${db_address}</h2></center></body></html>" > /var/www/html/index.html
sudo service httpd start
chkconfig httpd on
