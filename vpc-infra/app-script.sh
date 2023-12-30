# This script (runs in the backend, visible in EC2 launch configuration) installs a Tetris app which was developed by Harshicorp
# Source ->: https://github.com/hashicorp/learn-terramino
# I've modified it as I'm not sure if Canonical or Amazon Linux distros have httpd installed.

yum update -y
if rpm -q httpd; then
  yum -y remove httpd
  yum -y remove httpd-tools
else
  echo "**** installing httpd24.... ****"
fi
yum install -y httpd24 php72 mysql57-server php72-mysqlnd
service httpd start
chkconfig httpd on

echo "**** Finished installing httpd ****"
echo "**** I stand with Ukraine and peace in the world at large! ****"

usermod -a -G apache ec2-user
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
cd /var/www/html
curl http://169.254.169.254/latest/meta-data/instance-id -o index.html
curl https://raw.githubusercontent.com/hashicorp/learn-terramino/master/index.php -O