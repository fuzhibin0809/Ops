#! /bin/bash

SOFT_DIR=/data/soft
NGINX_VER=1.11.8
LUA_VER=0.10.7
LUAJIT_VER=2.0.4
DEVEL_KIT_VER=0.2.19
OPEN_SSL_VER=1.0.2j

function nginx_firewalld () {
	sed -i 's/<\/zone>//g' /etc/firewalld/zones/public.xml 
	echo -ne '  <service name="http"/>\n</zone> \n' >> /etc/firewalld/zones/public.xml 

}

function nginx_openssl () {
	cd $SOFT_DIR
	if [ ! -d "${SOFT_DIR}/openssl-${OPEN_SSL_VER}" ]; then
		if [ ! -f "${SOFT_DIR}/openssl-${OPEN_SSL_VER}.tar.gz" ]; then
			wget https://www.openssl.org/source/openssl-${OPEN_SSL_VER}.tar.gz
		fi
		tar zxvf openssl-${OPEN_SSL_VER}.tar.gz
		cd openssl-${OPEN_SSL_VER}
		pwd
		./config  --prefix=/usr/local/openssl
		make depend
		make
	fi

}

function nginx_install () {
	cd $SOFT_DIR
	if [ ! -d "nginx-${NGINX_VER}" ] ; then 
		if [ ! -f "nginx-$NGINX_VER.tar.gz" ] ; then 
			wget http://nginx.org/download/nginx-$NGINX_VER.tar.gz
		fi
		tar zxvf nginx-$NGINX_VER.tar.gz
	fi
	cd nginx-$NGINX_VER/
        ./configure --with-ld-opt="-ldl"  --user=nginx --group=www --prefix=/usr/local/nginx --with-ld-opt="-Wl,-rpath,$LUAJIT_LIB" \
         --with-http_stub_status_module  --with-http_gzip_static_module   --with-http_ssl_module  \
         --with-http_v2_module --add-module=$SOFT_DIR/lua-nginx-module-$LUA_VER  --add-module=$SOFT_DIR/ngx_devel_kit-$DEVEL_KIT_VER \
         --with-openssl=$SOFT_DIR/openssl-${OPEN_SSL_VER}
        make & make install 
}

function nginx_lua () {
	cd $SOFT_DIR
	if [ ! -d "${SOFT_DIR}/lua-nginx-module-$LUA_VER" ]; then
		if [ ! -f "${SOFT_DIR}/v$LUA_VER.tar.gz" ]; then
			wget https://github.com/openresty/lua-nginx-module/archive/v$LUA_VER.tar.gz
		fi
		tar zxvf v$LUA_VER.tar.gz
	fi


}

function nginx_luajit () {
	cd $SOFT_DIR
	if [ ! -d "${SOFT_DIR}/LuaJIT-${LUAJIT_VER}" ]; then
		if [ ! -f "LuaJIT-${LUAJIT_VER}.tar.gz" ]; then
			wget   http://luajit.org/download/LuaJIT-${LUAJIT_VER}.tar.gz
		fi
		tar zxvf LuaJIT-${LUAJIT_VER}.tar.gz
	fi
	cd LuaJIT-$LUAJIT_VER
	make & make install	
	export LUAJIT_LIB=/usr/local/lib
	export LUAJIT_INC=/usr/local/include/luajit-$(echo $LUAJIT_VER|sed -e 's/.[0-9]$//g')
	export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
}


function ngx_devel_kit () {
	cd $SOFT_DIR
	if [ ! -d "ngx_devel_kit-${DEVEL_KIT_VER}" ]; then 
		if [ ! -f "v${DEVEL_KIT_VER}.tar.gz" ]; then 
			wget https://github.com/simpl/ngx_devel_kit/archive/v${DEVEL_KIT_VER}.tar.gz
		fi
		tar zxvf v${DEVEL_KIT_VER}.tar.gz
	fi
}

function nginx_user () {
	if [[ no`grep /etc/group  -e  '^www:'` == "no" ]] ; then 
		groupadd www
	fi

	if [[ no`grep /etc/passwd -e '^nginx:'` == "no" ]] ; then 
		useradd nginx -g www -s /sbin/nologin
	fi
}

function nginx_start () {
	if [ ! -f "/lib64/libluajit-5.1.so.2" ] ; then 
		ln -s /usr/local/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
	fi
	if [ ! -f "/lib/systemd/system/nginx.service" ] ; then 
		nginx_service
	fi
	chmod 755 /lib/systemd/system/nginx.service 
	systemctl enable nginx.service
	systemctl start nginx.service
	 
}

function nginx_service() {        
echo "
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/usr/local/nginx/logs/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t  -c /usr/local/nginx/conf/nginx.conf
ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target "  > /lib/systemd/system/nginx.service
}

mkdir -p ${SOFT_DIR}
nginx_luajit
nginx_lua
ngx_devel_kit
nginx_openssl
nginx_install
nginx_firewalld
nginx_user
nginx_start
