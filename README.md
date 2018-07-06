构建Tars Docker镜像

Tars源码：https://github.com/Tencent/Tars

# 构建方法如下：
内网需要使用代理，则命令如下
@param proxy_address http代理地址
@param proxy_port http代理端口
@param interface 设置构建tars环境依赖ip地址在网卡名称
@param tars_image 创建docker镜像的名称和tag
proxy_address=http://proxy.company.com proxy_port=8080 interface=eth0 tars_image=tars:v1.0 sh install.sh


# 如果没有代理，则命令如下
tars_image=tars:v1.0 sh install.sh

也可以通过修改install.sh文件中的
PROXY_ADDRESS和PROXY_PORT来设置代理
TARS_IMAGE 设置构建镜像名称

# 容器net模式为host，则按照实际网卡，修改interface
如网卡为enp0s3则命令如下：
tars_image=tars:v1.0  sh install.sh
