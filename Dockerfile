FROM centos

MAINTAINER DerekYuan <ysxiaoit@foxmail.com>

WORKDIR /root/

# 安装常用和tars依赖软件，中文乱码设置
# ENV http_proxy=http://proxy.company.com:8080
RUN source /etc/profile && yum install -y vim initscripts gcc gcc-c++ glibc-devel git \
        zlib zlib-devel openssl openssl-devel boost boost-devel cmake unzip net-tools \
        tcpdump flex bison ncurses-devel perl perl-Module-Install.noarch kde-l10n-Chinese \
        file wget && yum clean all
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.utf8
ENV LC_ALL zh_CN.utf8
RUN mkdir /root/src/

# 安装mysql
RUN cd /root/src && wget http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.36.tar.gz
RUN tar xf /root/src/mysql-5.6.36.tar.gz -C /root/src/
RUN cd /root/src/mysql-5.6.36 && cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
        -DWITH_INNOBASE_STORAGE_ENGINE=1 -DMYSQL_USER=mysql -DDEFAULT_CHARSET=utf8 \
        -DDEFAULT_COLLATION=utf8_general_ci && make && make install
RUN rm -rf /root/src/mysql*

RUN useradd mysql
RUN rm -rf /usr/local/mysql/data && mkdir -p /data/mysql-data && ln -s /data/mysql-data /usr/local/mysql/data && \
        chown -R mysql:mysql /data/mysql-data /usr/local/mysql/data
RUN cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
COPY res/my.cnf /usr/local/mysql/
RUN echo "/usr/local/mysql/lib/" >> /etc/ld.so.conf && ldconfig

# 安装maven
RUN cd /root/src/ && wget http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz
RUN tar xf /root/src/apache-maven-3.5.3-bin.tar.gz -C /usr/local/ && rm -f /root/src/apache-maven-3.5.3-bin.tar.gz
ENV MAVEN_HOME=/usr/local/apache-maven-3.5.3/

# 安装java
RUN cd /root/src && wget --header "Cookie: oraclelicense=accept" -c --no-check-certificate -e "https_proxy=$http_proxy" \
        http://download.oracle.com/otn-pub/java/jdk/8u171-b11/512cd62ec5174c3487ac17c61aaa89e8/jdk-8u171-linux-x64.tar.gz
RUN tar xf /root/src/jdk-8u171-linux-x64.tar.gz -C /usr/local/ && rm -f /root/src/jdk-8u171-linux-x64.tar.gz
ENV JAVA_HOME=/usr/local/jdk1.8.0_171
ENV CLASSPATH="$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar"

ENV PATH="$PATH:/usr/local/apache-maven-3.5.3/bin:/usr/local/mysql/bin:$JAVA_HOME/bin"

# 安装resin
RUN cd /root/src/ && wget http://caucho.com/download/resin-4.0.55.tar.gz
RUN tar xf /root/src/resin-4.0.55.tar.gz -C /root/src
RUN cd /root/src/resin-4.0.55 && ./configure --prefix=/usr/local/resin && make && make install
RUN rm -rf /root/src/resin*

# 下载Tars源码
RUN git clone https://github.com/Tencent/Tars.git /root/src/Tars
RUN git clone https://github.com/Tencent/rapidjson.git /root/src/Tars/cpp/thirdparty/rapidjson

# mvn代理配置文件
# COPY res/settings.xml /root/.m2/settings.xml

# 安装java语言框架
RUN cd /root/src/Tars/java && mvn clean install && mvn clean install -f core/client.pom.xml && \
        mvn clean install -f core/server.pom.xml

# 安装C++语言框架
RUN cd /root/src/Tars/cpp/build && chmod +x build.sh && ./build.sh all && ./build.sh install

# 打包框架基础服务
RUN cd /root/src/Tars/cpp/build && make framework-tar && make tarsstat-tar && make tarsnotify-tar && \
        make tarsproperty-tar && make tarslog-tar && make tarsquerystat-tar && make tarsqueryproperty-tar
# 安装核心基础服务
RUN mkdir -p /usr/local/app/tars && cp /root/src/Tars/cpp/build/framework.tgz /usr/local/app/tars && \
        tar xf /usr/local/app/tars/framework.tgz -C /usr/local/app/tars/

# 安装web管理系统
RUN cd /root/src/Tars/web && mvn clean package
RUN mkdir -p /data/log/tars/
RUN sed -i 's/ROOT/tars/g' /usr/local/resin/conf/resin.xml

# 拷贝后续根据ip安装脚本
COPY res/entry_tars.sh /sbin/

ENTRYPOINT ["/bin/bash", "/sbin/entry_tars.sh"]

EXPOSE 8080

