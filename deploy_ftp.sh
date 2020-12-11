#!/bin/bash

# Author: cc
# date:2020-12-11
# version: 1.0

usage(){
	echo $"Usage: $0 [ deploy | unftp ]"
}

if [[ "$(whoami)" != "root" ]]; then

    echo "please run this script as root ." >&2
    exit 1
fi

echo -e "\033[31m 这个是vsftp安装脚本！ 5秒后开始执行！press ctrl+C to cancel \033[0m"
sleep 5



#set config
set_config(){
  #disable selinux
  sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
  setenforce 0
  echo "selinux is disable"
  
  #disable selinux
  echo "Starting disable firewalld..."
   rpm -qa | grep firewalld >> /dev/null
   if [ $? -eq 0 ];then
      systemctl stop firewalld  && systemctl disable firewalld
      [ $? -eq 0 ] && echo "Dsiable firewalld complete."
      else
      echo "Firewalld not install." 
   fi

  #Create a directory
  mkdir -p /data/ftp/files
  mkdir -p /data/ftp/conf

  #import images
  docker load -i vsftpd.tar

}

#install ftp
install_ftp(){
  #deploy
  IP=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|grep -v 255.255.255.255 |grep -v 255.255.0.0|awk '{print $2}'|tr -d "addr:"`
  docker run -d --name vsftpd \
  --restart=always \
  -p 21:21 -p 21100-21110:21100-21110 \
  -e FTP_USER=ftpuser -e FTP_PASS=pass4ftp \
  -e PASV_ADDRESS=$IP -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 \
  -v /data/ftp/files:/home/vsftpd \
  -e TZ="Asia/Shanghai" \
  richinfoai/vsftpd

}
#uninstall ftp
uninstall_ftp(){
  #stop vsftp
  docker stop $(docker ps -a |grep vsftpd |awk '{print $1}')
  #del vsftp
  docker rm $(docker ps -a |grep vsftpd |awk '{print $1}')
  #del images vsftpd
  docker rmi $(docker images |grep vsftpd |awk '{print $3}')
} 

main(){
  case $1 in
  deploy)
       set_config;
       install_ftp;
       ;;
  unftp)
       uninstall_ftp;
       ;;
       *)
      usage;
  esac
}
main $1
