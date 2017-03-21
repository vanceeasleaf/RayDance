@echo off
::转到当前盘符
%~d0
::打开当前目录
cd %~dp0
echo 已将程序定位到当前目录，开始启动AIR程序
::执行AIR程序，并向InvokeEvent事件传参数
bin\adl bin\Main-app.xml -- %1