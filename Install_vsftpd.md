centos7下docker部署vsftpd服务

1. 安装docker（略）
2. OSS下载安装脚本和docker镜像包：
OSS下载路径： oss://rich-ops/CentOS7_vsftp_Install/
脚本：deploy_ftp.sh
镜像： vsftpd.tar
文档：Install_vsftpd.md
注：镜像为 https://hub.docker.com/r/fauria/vsftpd 重新tag获得

3. 安装ftp
 1）下载安装包和脚本放置到部署机器（注：安装包和安装脚本要在同一目录下）；
   给安装脚本可执行权限：
   chmod +x deploy_ftp.sh

 2) 安装vsftpd:
 ./deploy_ftp.sh deploy

 3) 卸载vsftpd：
 ./deploy_ftp.sh unftp

4. 使用 
通过ftp客户端 或浏览器输入：ftp://{IP}
账户：ftpuser
密码：pass4ftp

5. 添加新用户
例如，添加dev账户
docker exec -i -t vsftpd bash						   #进入容器
mkdir /home/vsftpd/dev								   #用户访问目录
echo -e "dev\ndev" >> /etc/vsftpd/virtual_users.txt    #账户：dev 密码：dev
/usr/bin/db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db
exit
docker restart vsftpd     #重启服务

