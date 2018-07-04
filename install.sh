#!/bin/bash

# 内网需要使用代理，则安装以下命令执行
# @param proxy_address http代理地址
# @param proxy_port http代理端口
# @param interface 设置构建tars环境依赖ip地址在网卡名称
# @param tars_image 创建docker镜像的名称和tag
# proxy_address=http://proxy.company.com proxy_port=8080 interface=eth0 tars_image=tars:v1.0 sh install.sh

PROXY_ADDRESS=
PROXY_PORT=
PROXY=
TARS_IMAGE=tars:v1.0
DOCKERFILE=Dockerfile
BAK_DOCKERFILE=Dockerfile.tmp
MAVEN_SETTINGS=res/settings.xml
BAK_MAVEN_SETTINGS=res/settings.xml.tmp
ENTRY_TARS=res/entry_tars.sh
BAK_ENTRY_TARS=res/entry_tars.sh.tmp

# 获取代理
if [ -n "$proxy_address" ]; then
    PROXY_ADDRESS=$proxy_address
fi
if [ -n "$proxy_port" ]; then
    PROXY_PORT=proxy_port
fi

if [ -n "$PROXY_ADDRESS" ]; then
    if [ -n "$PROXY_PORT" ]; then
        PROXY=${PROXY_ADDRESS}:${PROXY_PORT}
    else
        PROXY=${PROXY_ADDRESS}
    fi
fi

# 替换代理
cp $DOCKERFILE $BAK_DOCKERFILE
cp $MAVEN_SETTINGS $BAK_MAVEN_SETTINGS
cp $ENTRY_TARS $BAK_ENTRY_TARS
if [ -n "$PROXY" ]; then
    sed -i "s?# ENV http_proxy=http://proxy.company.com:8080?ENV http_proxy=$PROXY?g" $DOCKERFILE
    sed -i "s?# COPY res/settings.xml?COPY res/settings.xml?g" $DOCKERFILE
    ADDRESS=`echo $PROXY_ADDRESS | awk -F'/' '{print $3}'`
    sed -i "s?proxy.company.com?$ADDRESS?g" $MAVEN_SETTINGS
    if [ -n "$PROXY_PORT" ]; then
        sed -i "s/8080/$PROXY_PORT/g" $MAVEN_SETTINGS
    else
        sed -i '/*8080*/d' $MAVEN_SETTINGS
    fi
else
    sed -i "s?-e \"https_proxy=\$http_proxy\"??g" $DOCKERFILE
fi

# 镜像名称
if [ -n "$tars_image" ]; then
    TARS_IMAGE=$tars_image
fi

# 网卡名称
if [ -n "$interface" ]; then
    sed -i "s/eth0/$interface/g" $ENTRY_TARS
fi

# 创建镜像
docker build -t $TARS_IMAGE .

# 恢复配置
mv $BAK_DOCKERFILE $DOCKERFILE
mv $BAK_MAVEN_SETTINGS $MAVEN_SETTINGS
mv $BAK_ENTRY_TARS $ENTRY_TARS

# 由于容器需要启动mysql服务，因此需要以/usr/sbin/init启动
# @param my_container 是创建的容器名称
# @machine_port 是通过宿主机映射tars容器的8080端口
echo "Please run command to start you container:"
echo "docker run --name my_container --privileged -p machine_port:8080 -tid $TARS_IMAGE /usr/sbin/init"

