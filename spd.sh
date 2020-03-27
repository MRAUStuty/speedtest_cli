#!/usr/bin/env bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE="\033[0;35m"
CYAN='\033[0;36m'
PLAIN='\033[0m'


#  版本信息 用于更新脚本
SH_VER="1.0.2"

# check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Error:${PLAIN} 请用root权限运行脚本！" && exit 1

#  https://www.speedtest.net/speedtest-servers-static.php

# check wget
if  [ ! -e '/usr/bin/wget' ]; then
	if [ "${release}" == "centos" ]; then
			yum -y install wget
	else
			apt-get -y install wget
	fi
fi


# check curl
if  [ ! -e '/usr/bin/curl' ]; then
	if [ "${release}" == "centos" ]; then
			yum -y install curl
	else
			apt-get -y install curl
	fi
fi

# 检查节点节点
check_speedtest_servers(){
	# 下载所有节点信息
	curl  https://www.speedtest.net/speedtest-servers-static.php  > /tmp/spd_cli/1.txt
	# 将国内节点剔出来
	cat /tmp/spd_cli/1.txt | grep cc=\"CN\" | grep -v "Hong Kong" > /tmp/spd_cli/2.txt
	# 提取 节点ID
	cat /tmp/spd_cli/2.txt | awk -F "=" '{print $9}' | awk -F "\"" '{print $2}'  > /tmp/spd_cli/3.txt
	# 提取节点地区
	cat /tmp/spd_cli/2.txt | awk -F "=" '{print $5}' | awk -F "\"" '{print $2}'  > /tmp/spd_cli/4.txt
	# 提取 节点运营商 
	cat /tmp/spd_cli/2.txt | awk -F "=" '{print $8}' | awk -F "\"" '{print $2}'  > /tmp/spd_cli/5.txt
}

if  [ ! -e '/tmp/spd_cli/1.txt' ]; then
	rm -rf /tmp/spd_cli
	
	mkdir  /tmp/spd_cli
	chmod  777  /tmp/spd_cli
	check_speedtest_servers
fi

# 判断 系统 运行位数
	bit=`uname -m`
	if [[ ${bit} == "x86_64" ]]; then
		bit="x86_64"
	elif [[ ${bit} == "i386" || ${bit} == "i686" ]]; then
		bit="i386"

	fi

# 下载speedtest_cli
if  [ ! -e '/tmp/spd_cli/speedtest' ]; then
	wget --no-check-certificate -O /tmp/spd_cli/speedtest  https://raw.githubusercontent.com/user1121114685/speedtest_cli/master/spd_cli/${bit}/speedtest  > /dev/null 2>&1
	chmod a+rx /tmp/spd_cli/speedtest
fi

if  [ ! -e '/tmp/spd_cli/run_once_speedtest' ]; then
	/tmp/spd_cli/speedtest 
	echo 1 > /tmp/spd_cli/run_once_speedtest

fi

clear

echo "——————————————————————————————————————————————————————————————————————"
echo "     "
echo "     Speedtest_Cli测速"
echo "     作者：联盟少侠"
echo "     "
echo "     项目地址:   https://github.com/user1121114685/speedtest_cli"
echo "     原脚本地址：https://github.com/ernisn/superspeed"
echo "     懒人专用，推荐在晚上21:30至凌晨1:00之间测试，高峰期更具有实际意义。"
echo "     "
echo -e "     ${RED}如遇无限闪屏，请先运行3一次${PLAIN} "
echo "     "
echo "——————————————————————————————————————————————————————————————————————"
echo "     "
echo "     选择菜单: "
echo -e "     ${GREEN}1.${PLAIN} 随机5个国内节点测试  "
echo -e "     ${GREEN}2.${PLAIN} 随机10个国内节点测试"
echo -e "     ${GREEN}3.${PLAIN} 指定单个测试节点     "
echo -e "     ${GREEN}4.${PLAIN} 升级脚本"
echo -e "     ${GREEN}5.${PLAIN} 更新节点信息 "
echo -e "     ${GREEN}6.${PLAIN} 展示所有节点"
echo -e "     ${GREEN}7.${PLAIN} 查看历史测速记录"
echo -e "     ${GREEN}8.${PLAIN} 旋转跳跃，不停的测速"

while :; do echo
		read -p "     请输入数字选择(按回车退出): " selection
		if [[ -z $selection ]]; then
			exit 0
		fi
		if [[ ! $selection =~ ^[1-8]$ ]]; then
				echo -ne "     ${RED}输入错误${PLAIN}, 请输入正确的数字!"
		else
				break   
		fi
done



# install speedtest
if  [ ! -e '/tmp/spd_cli/speedtest' ]; then
	wget --no-check-certificate -P tmp/spd_cli  https://raw.githubusercontent.com/user1121114685/speedtest_cli/master/spd_cli/${bit}/speedtest  > /dev/null 2>&1
	chmod a+rx /tmp/spd_cli/speedtest
fi



# 5个节点测试
if [[ ${selection} == 1 ]]; then
	echo "——————————————————————————————————————————————————————————————————————"

	start=$(date +%s) 

		echo "——————————————————————————————————————————————————————————————————————"

			cat /tmp/spd_cli/3.txt | shuf -n5 | xargs -n 1  /tmp/spd_cli/speedtest -s  $1 | tee -a /tmp/spd_cli/report.txt

	end=$(date +%s)  

	echo -ne "\n  ——————————————————————————————————————————————————————————————————————" | tee -a /tmp/spd_cli/report.txt
	time=$(( $end - $start ))
	if [[ $time -gt 60 ]]; then
		min=$(expr $time / 60)
		sec=$(expr $time % 60)
		echo -ne "     测试完成, 本次测速耗时: ${min} 分 ${sec} 秒" | tee -a /tmp/spd_cli/report.txt
	else
		echo -ne "     测试完成, 本次测速耗时: ${time} 秒" | tee -a /tmp/spd_cli/report.txt
	fi
	echo -ne "\n     当前时间: " | tee -a /tmp/spd_cli/report.txt
	echo $(date +%Y-%m-%d" "%H:%M:%S) | tee -a /tmp/spd_cli/report.txt
fi

# 10 个节点测试
if [[ ${selection} == 2 ]]; then
	echo "——————————————————————————————————————————————————————————————————————"

	start=$(date +%s) 

		echo "——————————————————————————————————————————————————————————————————————"

		cat /tmp/spd_cli/3.txt | shuf -n10 | xargs -n 1  /tmp/spd_cli/speedtest -s  $1 | tee -a /tmp/spd_cli/report.txt

	end=$(date +%s)  

	echo -ne "\n   ——————————————————————————————————————————————————————————————————————" | tee -a /tmp/spd_cli/report.txt
	time=$(( $end - $start ))
	if [[ $time -gt 60 ]]; then
		min=$(expr $time / 60)
		sec=$(expr $time % 60)
		echo -ne "     测试完成, 本次测速耗时: ${min} 分 ${sec} 秒" | tee -a /tmp/spd_cli/report.txt
	else
		echo -ne "     测试完成, 本次测速耗时: ${time} 秒" | tee -a /tmp/spd_cli/report.txt
	fi
	echo -ne "\n     当前时间: " | tee -a /tmp/spd_cli/report.txt
	echo $(date +%Y-%m-%d" "%H:%M:%S) | tee -a /tmp/spd_cli/report.txt
fi


# 单个节点测试
if [[ ${selection} == 3 ]]; then
	echo "——————————————————————————————————————————————————————————————————————"
	read -p "     请输入一个节点ID(可直接回车): " selection

	start=$(date +%s) 

	if [[ -z $selection ]]; then
		/tmp/spd_cli/speedtest | tee -a /tmp/spd_cli/report.txt
	else
		/tmp/spd_cli/speedtest -s $selection | tee -a /tmp/spd_cli/report.txt
	fi
	end=$(date +%s)  

	echo -ne "\n  ——————————————————————————————————————————————————————————————————————" | tee -a /tmp/spd_cli/report.txt
	time=$(( $end - $start ))
	if [[ $time -gt 60 ]]; then
		min=$(expr $time / 60)
		sec=$(expr $time % 60)
		echo -ne "     测试完成, 本次测速耗时: ${min} 分 ${sec} 秒" | tee -a /tmp/spd_cli/report.txt
	else
		echo -ne "     测试完成, 本次测速耗时: ${time} 秒" | tee -a /tmp/spd_cli/report.txt
	fi
	echo -ne "\n     当前时间: " | tee -a /tmp/spd_cli/report.txt
	echo $(date +%Y-%m-%d" "%H:%M:%S) | tee -a /tmp/spd_cli/report.txt

fi

#  脚本更新
if [[ ${selection} == 4 ]]; then

	latest_version=$(curl -H 'Cache-Control: no-cache' -s -L "https://raw.githubusercontent.com/user1121114685/speedtest_cli/master/spd.sh" | grep 'SH_VER' -m1 | cut -d\" -f2)
	if [[ ! $latest_version ]]; then
		echo
		echo -e " ${RED}获取SpeedTest_Cli测试脚本 最新版本失败!!!${PLAIN} "
		echo
		echo -e " 请检查网络配置！"
		echo
		echo " 然后再继续...."
		echo
		exit 1
	fi

	if [[ $latest_version == $SH_VER ]]; then
		echo
		echo -e "${GREEN} 木有发现新版本 ${PLAIN} "
		echo
	else
		echo
		echo -e " ${GREEN} 咦...发现新版本耶....正在拼命更新.......${PLAIN} "
		echo
		wget -N --no-check-certificate "https://raw.githubusercontent.com/user1121114685/speedtest_cli/master/spd.sh" && chmod +x spd.sh
		echo -e "脚本已更新为最新版本[ ${latest_version} ] !(注意：因为更新方式为直接覆盖当前运行的脚本，所以可能下面会提示一些报错，无视即可)" && exit 0
	fi

	
fi

#  手动更新节点信息
if [[ ${selection} == 5 ]]; then
	check_speedtest_servers

fi

# 展示所有的国内节点
if [[ ${selection} == 6 ]]; then
	paste -d" ----" /tmp/spd_cli/3.txt /tmp/spd_cli/4.txt /tmp/spd_cli/5.txt
fi

# 展示所有的历史记录
if [[ ${selection} == 7 ]]; then
	cat /tmp/spd_cli/report.txt
fi
# 不停的测速，直到天荒地老
if [[ ${selection} == 8 ]]; then
	while :
	do

		echo "——————————————————————————————————————————————————————————————————————"

		start=$(date +%s) 

			echo "——————————————————————————————————————————————————————————————————————"

				cat /tmp/spd_cli/3.txt | shuf -n5 | xargs -n 1  /tmp/spd_cli/speedtest -s  $1 | tee -a /tmp/spd_cli/report.txt

		end=$(date +%s)  

		echo -ne "\n  ——————————————————————————————————————————————————————————————————————" | tee -a /tmp/spd_cli/report.txt
		time=$(( $end - $start ))
		if [[ $time -gt 60 ]]; then
			min=$(expr $time / 60)
			sec=$(expr $time % 60)
			echo -ne "     测试完成, 本次测速耗时: ${min} 分 ${sec} 秒" | tee -a /tmp/spd_cli/report.txt
		else
			echo -ne "     测试完成, 本次测速耗时: ${time} 秒" | tee -a /tmp/spd_cli/report.txt
		fi
		echo -ne "\n     当前时间: " | tee -a /tmp/spd_cli/report.txt
		echo $(date +%Y-%m-%d" "%H:%M:%S) | tee -a /tmp/spd_cli/report.txt


	done
fi