@echo off
::ת����ǰ�̷�
%~d0
::�򿪵�ǰĿ¼
cd %~dp0
echo �ѽ�����λ����ǰĿ¼����ʼ����AIR����
::ִ��AIR���򣬲���InvokeEvent�¼�������
bin\adl bin\Main-app.xml -- %1