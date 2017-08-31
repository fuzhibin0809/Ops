
#! /bin/bash
MYSQL_VER=5.7.17


function mysql_env () {
	yum -y install libaio openssl
	echo -ne 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile
	source /etc/profile	
}

function mysql_user () {
	groupadd mysql
	useradd -r -g mysql mysql
}


function mysql_install () {
	cd /data/soft
	tar zxvf mysql*.tar.gz
	mv mysql*_64 /usr/local/mysql
	chmod 755 /usr/local/mysql -R
	cd /usr/local/mysql
	bin/mysqld --initialize --user=mysql --datadir=/data/mysql 
	bin/mysql_ssl_rsa_setup 

 #   	echo "mysql 初始密码:"
#	cat /data/mysql/mysql-error.log |grep -e 'root@localhos' |grep -e 'password'|sed -e 's/^.*: //g'
}

function mysql_start () {
	cp  /usr/local/mysql/support-files/mysql.server  /etc/init.d/mysql
	/etc/init.d/mysql start
	chmod +x /etc/init.d/mysql
	chkconfig mysql on
}

function mysql_data () {
	mkdir  -p /data/mysql
	chmod 755 /data/mysql -R
	chown mysql:mysql /data/mysql -R
}

function mysql_download () {
	mkdir -p /data/soft
	cd /data/soft
	wget  http://mirrors.sohu.com/mysql/MySQL-${MYSQL_VER%.*}/mysql-${MYSQL_VER}-linux-glibc2.5-x86_64.tar.gz
}

function mysql_conf() {
	\cp  $(dirname $0)/my.cnf /etc/
}

mysql_env
mysql_user
mysql_data
mysql_download
mysql_conf
mysql_install
mysql_start
