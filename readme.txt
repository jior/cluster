#####################################################################################
################ 本安装说明只适用于64位版Windows操作系统，Linux不适用 ###############
################ 推荐使用服务器版的64位Windows系统                    ###############
#####################################################################################
=====================================================================================
==============================================配置说明===============================
推荐安装到E:/cluster目录，如果安装到E:/cluster，只要修改3）4）tomcat虚拟目录即可。
修改如下配置文件：
1）apache2.4\conf\httpd.conf
找到37行：
ServerRoot "E:/cluster/apache2.4"
找到241,242行
DocumentRoot "E:/cluster/apache2.4/htdocs"
<Directory "E:/cluster/apache2.4/htdocs">

把这些路径修改成你的apache的目录。

2）apache2.4\conf\extra\mod_jk.conf
找到16行
增加你自己的虚拟映射处理器

3）tomcat1\conf\server.xml
修改147行，把其中的内容修改成你的应用的路径
<Context path="/glaf" docBase="e:/wechat/WebContent" reloadable="false"/>

4）tomcat2\conf\server.xml
修改147行，把其中的内容修改成你的应用的路径
<Context path="/glaf" docBase="e:/wechat/WebContent" reloadable="false"/>


=====================================================================================
==============================================安装说明===============================
1）安装VC10
如果是如下操作系统
Windows 7 SP1, 
Windows 8 / 8.1, 
Windows Vista SP2, 
Windows Server 2008 R2 SP1, 
Windows Server 2012 / R2
请安装vc11redist_x64.exe
!!!!!!!!!!!!!!如果需要在XP或2003下安装!!!!!!!!!!!
请使用vc10redist_x64.exe

2）安装apache服务
执行apache2.4目录下的apache_installservice.bat

3）安装zookeeper服务
执行每个zookeeper的bin目录下的zk-installservice.bat

4）安装memcached服务
执行每个memcached下面的memcached-installservice.bat

5）安装tomcat服务
执行每个tomcat下面的tomcat_service_install.bat

6）进入Windows服务管理界面，把上述服务按顺序启动起来
启动完成后再浏览器中输入
http://127.0.0.1/glaf

如果正常将进入到登录页面
Good Luck！