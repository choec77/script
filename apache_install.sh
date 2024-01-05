#!/bin/bash

# 의존성 패키지 설치
yum -y install acc make gcc-c++ pcre-devel expat-devel

# PCRE 최신 버전 다운로드 및 설치
wget https://ftp.pcre.org/pub/pcre/pcre-8.45.tar.gz
tar xvfz pcre-8.45.tar.gz
cd pcre-8.45
./configure --prefix=/usr/local
make
make install

# 최신 Apache HTTP Server 버전 및 다운로드 링크 가져오기
latest_apache_version=$(curl -s https://httpd.apache.org/download.cgi | grep -oP 'httpd-([0-9]+\.[0-9]+\.[0-9]+)\.tar\.gz' | head -n 1)
apache_download_link="https://downloads.apache.org/httpd/$latest_apache_version"

# 최신 APR 버전 및 다운로드 링크 가져오기
latest_apr_version=$(curl -s https://ftp.wayne.edu/apache/apr/ | grep -oP 'apr-\K([0-9]+\.[0-9]+\.[0-9]+)' | head -n 1)
apr_download_link="https://ftp.wayne.edu/apache/apr/apr-$latest_apr_version.tar.gz"

# 최신 APR-util 버전 및 다운로드 링크 가져오기
latest_apr_util_version=$(curl -s https://ftp.wayne.edu/apache/apr/apr-util/ | grep -oP 'apr-util-\K([0-9]+\.[0-9]+\.[0-9]+)' | head -n 1)
apr_util_download_link="https://ftp.wayne.edu/apache/apr/apr-util-$latest_apr_util_version.tar.gz"

# 각 소프트웨어 다운로드 및 설치
mkdir ~/downloads
cd ~/downloads

# APR 다운로드 및 설치
wget "$apr_download_link"
tar xvfz apr-$latest_apr_version.tar.gz
cd apr-$latest_apr_version
./configure --prefix=/usr/local/apr
make
make install

# APR-util 다운로드 및 설치
cd ~/downloads
wget "$apr_util_download_link"
tar xvfz apr-util-$latest_apr_util_version.tar.gz
cd apr-util-$latest_apr_util_version
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
make
make install

# Apache HTTP Server 다운로드 및 설치
cd ~/downloads
wget "$apache_download_link"
tar xvfz $latest_apache_version
cd httpd-*
./configure --prefix=/usr/local/apache --with-included-apr --with-pcre=/usr/local/bin/pcre-config
make
make install

# Apache 서비스 등록
echo -e "[Unit]\nDescription=Apache HTTP Server\nAfter=network.target\n\n[Service]\nType=forking\nExecStart=/usr/local/apache/bin/apachectl start\nExecStop=/usr/local/apache/bin/apachectl stop\nExecReload=/usr/local/apache/bin/apachectl graceful\nPIDFile=/usr/local/apache/logs/httpd.pid\n\n[Install]\nWantedBy=multi-user.target" > /etc/systemd/system/httpd.service

# 서비스 등록 및 시작
systemctl daemon-reload
systemctl enable httpd
systemctl start httpd
