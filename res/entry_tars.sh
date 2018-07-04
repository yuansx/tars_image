#!/bin/bash

BUILD_SUCCESS="/usr/local/app/tars/build_success"

if [ ! -f $BUILD_SUCCESS ]; then
    set -e
    SOURCE_PATH=/root/src/Tars
    INTERFACE=eth0
    MachineName=`hostname`
    MachineIp=$(ip addr | grep inet | grep $INTERFACE | awk '{print $2}' | sed 's|/.*$||')
    SQL_PASSWD=root@appinside
    
    rm -f /etc/my.cnf
    cd /usr/local/mysql/
    perl scripts/mysql_install_db --user=mysql
    sed -i "s/192.168.2.131/${MachineIp}/g" /usr/local/mysql/my.cnf
    service mysql start
    chkconfig mysql on
    mysqladmin -u root password $SQL_PASSWD
    mysqladmin -u root -h ${MachineName} password $SQL_PASSWD
    mysql -uroot -p$SQL_PASSWD -e "grant all on *.* to 'tars'@'%' identified by 'tars2015' with grant option;"
    mysql -uroot -p$SQL_PASSWD -e "grant all on *.* to 'tars'@'localhost' identified by 'tars2015' with grant option;"
    mysql -uroot -p$SQL_PASSWD -e "grant all on *.* to 'tars'@'${MachineName}' identified by 'tars2015' with grant option;"
    mysql -uroot -p$SQL_PASSWD -e "flush privileges;"
    
    cd ${SOURCE_PATH}/cpp/framework/sql/
    sed -i "s/192.168.2.131/${MachineIp}/g" `grep 192.168.2.131 -rl ./*`
    sed -i "s/db.tars.com/${MachineIp}/g" `grep db.tars.com -rl ./*`
    sed -i "s/root@appinside/${SQL_PASSWD}/g" exec-sql.sh
    sh exec-sql.sh
    
    cd /usr/local/app/tars
    sed -i "s/192.168.2.131/${MachineIp}/g" `grep 192.168.2.131 -rl ./*`
    sed -i "s/db.tars.com/${MachineIp}/g" `grep db.tars.com -rl ./*`
    sed -i "s/registry.tars.com/${MachineIp}/g" `grep registry.tars.com -rl ./*`
    sed -i "s/web.tars.com/${MachineIp}/g" `grep web.tars.com -rl ./*`
    
    cd ${SOURCE_PATH}/web/
    sed -i "s/db.tars.com/${MachineIp}/g" `grep db.tars.com -rl ./src/main/resources/*`
    sed -i "s/registry1.tars.com/${MachineIp}/g" `grep registry1.tars.com -rl ./src/main/resources/*`
    sed -i "s/registry2.tars.com/${MachineIp}/g" `grep registry2.tars.com -rl ./src/main/resources/*`
    mvn clean package
    cp ./target/tars.war /usr/local/resin/webapps/
    touch $BUILD_SUCCESS
    set +e
else
    service mysql start
fi

cd /usr/local/app/tars/
sh tars_install.sh
sh tarspatch/util/init.sh

/usr/local/resin/bin/resin.sh console

