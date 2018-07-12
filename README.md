# 构建Tars Docker镜像

Tars源码：https://github.com/Tencent/Tars


# 构建方法如下：
内网需要使用代理，则命令如下
- @param proxy_address http代理地址
- @param proxy_port http代理端口
- @param interface 设置构建tars环境依赖ip地址在网卡名称
- @param tars_image 创建docker镜像的名称和tag
- proxy_address=http://proxy.company.com proxy_port=8080 interface=eth0 tars_image=tars:v1.0 sh install.sh


# 如果没有代理，则命令如下
tars_image=tars:v1.0 sh install.sh


也可以通过修改install.sh文件中的
PROXY_ADDRESS和PROXY_PORT来设置代理
TARS_IMAGE 设置构建镜像名称


# 容器net模式为host，则按照实际网卡，修改interface
如网卡为enp0s3则命令如下：
tars_image=tars:v1.0 interface=enp0s3 sh install.sh


# 基于这个git构建的容器地址
https://hub.docker.com/r/yuansx/tars/
通过docker pull yuansx/tars:v1.0 拉取

# 注意
这个构建完成后，生成的容器，便直接进入了
https://github.com/Tencent/Tars/blob/master/Install.md
的安装步骤4.4了，请自行安装tarsnotify tarsstat等服务

这个容器仅用于体验使用，所产生的数据均保存在容器内部，数据随着容器的删除而被销毁。
实际部署时，请认真规划好再自行安装部署
