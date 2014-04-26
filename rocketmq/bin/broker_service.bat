@echo off
SETLOCAL

if NOT DEFINED JAVA_HOME goto err

set SCRIPT_DIR=%~dp0
for %%I in ("%SCRIPT_DIR%..") do set MQ_HOME=%%~dpfI

rem Detect JVM version to figure out appropriate executable to use
if not exist "%JAVA_HOME%\bin\java.exe" (
echo JAVA_HOME points to an invalid Java installation (no java.exe found in "%JAVA_HOME%"^). Existing...
goto:eof
)
"%JAVA_HOME%\bin\java" -version 2>&1 | find "64-Bit" >nul:

if errorlevel 1 goto x86
set EXECUTABLE=%MQ_HOME%\bin\service-x64.exe
set SERVICE_ID=zookeeper-service-x64
set ARCH=64-bit
goto checkExe

:x86
set EXECUTABLE=%MQ_HOME%\bin\service-x86.exe
set SERVICE_ID=zookeeper-service-x86
set ARCH=32-bit

:checkExe
if EXIST "%EXECUTABLE%" goto okExe
echo zookeeper-service-(x86|x64).exe was not found...

:okExe
set MQ_VERSION=3

if "%LOG_DIR%" == "" set LOG_DIR=%MQ_HOME%\logs

if "x%1x" == "xx" goto displayUsage
set SERVICE_CMD=%1
shift
if "x%1x" == "xx" goto checkServiceCmd
set SERVICE_ID=%1

:checkServiceCmd

if "%LOG_OPTS%" == "" set LOG_OPTS=--LogPath "%LOG_DIR%" --LogPrefix "%SERVICE_ID%" --StdError auto --StdOutput auto

if /i %SERVICE_CMD% == install goto doInstall
if /i %SERVICE_CMD% == remove goto doRemove
if /i %SERVICE_CMD% == start goto doStart
if /i %SERVICE_CMD% == stop goto doStop
if /i %SERVICE_CMD% == manager goto doManagment
echo Unknown option "%SERVICE_CMD%"

:displayUsage
echo.
echo Usage: service.bat install^|remove^|start^|stop^|manager [SERVICE_ID]
goto:eof

:doStart
"%EXECUTABLE%" //ES//%SERVICE_ID% %LOG_OPTS%
if not errorlevel 1 goto started
echo Failed starting '%SERVICE_ID%' service
goto:eof
:started
echo The service '%SERVICE_ID%' has been started
goto:eof

:doStop
"%EXECUTABLE%" //SS//%SERVICE_ID% %LOG_OPTS%
if not errorlevel 1 goto stopped
echo Failed stopping '%SERVICE_ID%' service
goto:eof
:stopped
echo The service '%SERVICE_ID%' has been stopped
goto:eof

:doManagment
set EXECUTABLE_MGR=%MQ_HOME%\bin\service-mgr.exe
"%EXECUTABLE_MGR%" //ES//%SERVICE_ID%
if not errorlevel 1 goto managed
echo Failed starting service manager for '%SERVICE_ID%'
goto:eof
:managed
echo Succesfully started service manager for '%SERVICE_ID%'.
goto:eof

:doRemove
rem Remove the service
"%EXECUTABLE%" //DS//%SERVICE_ID% %LOG_OPTS%
if not errorlevel 1 goto removed
echo Failed removing '%SERVICE_ID%' service
goto:eof
:removed
echo The service '%SERVICE_ID%' has been removed
goto:eof

:doInstall
echo Installing service      :  "%SERVICE_ID%"
echo Using JAVA_HOME (%ARCH%):  "%JAVA_HOME%"

rem Check JVM server dll first
set JVM_DLL=%JAVA_HOME%\jre\bin\server\jvm.dll
if exist "%JVM_DLL%" goto foundJVM

rem Check 'server' JRE (JRE installed on Windows Server)
set JVM_DLL=%JAVA_HOME%\bin\server\jvm.dll
if exist "%JVM_DLL%" goto foundJVM

rem Fallback to 'client' JRE
set JVM_DLL=%JAVA_HOME%\bin\client\jvm.dll

if exist "%JVM_DLL%" (
echo Warning: JAVA_HOME points to a JRE and not JDK installation; a client (not a server^) JVM will be used...
) else (
echo JAVA_HOME points to an invalid Java installation (no jvm.dll found in "%JAVA_HOME%"^). Existing...
goto:eof
)

:foundJVM
if "%MQ_MIN_MEM%" == "" set MQ_MIN_MEM=256m
if "%MQ_MAX_MEM%" == "" set MQ_MAX_MEM=1g

if NOT "%MQ_HEAP_SIZE%" == "" set MQ_MIN_MEM=%MQ_HEAP_SIZE%
if NOT "%MQ_HEAP_SIZE%" == "" set MQ_MAX_MEM=%MQ_HEAP_SIZE%

call:convertxm %MQ_MIN_MEM% JVM_XMS
call:convertxm %MQ_MAX_MEM% JVM_XMX

rem java_opts might be empty - init to avoid tripping commons daemon (if the command starts with ;)
if not "%JAVA_OPTS%" == "" set JAVA_OPTS=%JAVA_OPTS% -XX:+UseParNewGC
if "%JAVA_OPTS%" == "" set JAVA_OPTS=-XX:+UseParNewGC

if NOT "%MQ_HEAP_NEWSIZE%" == "" set JAVA_OPTS=%JAVA_OPTS% -Xmn%MQ_HEAP_NEWSIZE%

if NOT "%MQ_DIRECT_SIZE%" == "" set JAVA_OPTS=%JAVA_OPTS% -XX:MaxDirectMemorySize=%MQ_DIRECT_SIZE%

rem thread stack size
set JVM_SS=256

REM Enable aggressive optimizations in the JVM
REM    - Disabled by default as it might cause the JVM to crash
REM set JAVA_OPTS=%JAVA_OPTS% -XX:+AggressiveOpts


set JAVA_OPTS=%JAVA_OPTS% -XX:+UseConcMarkSweepGC

set JAVA_OPTS=%JAVA_OPTS% -XX:CMSInitiatingOccupancyFraction=75
set JAVA_OPTS=%JAVA_OPTS% -XX:+UseCMSInitiatingOccupancyOnly

REM GC logging options -- uncomment to enable
REM JAVA_OPTS=%JAVA_OPTS% -XX:+PrintGCDetails
REM JAVA_OPTS=%JAVA_OPTS% -XX:+PrintGCTimeStamps
REM JAVA_OPTS=%JAVA_OPTS% -XX:+PrintClassHistogram
REM JAVA_OPTS=%JAVA_OPTS% -XX:+PrintTenuringDistribution
REM JAVA_OPTS=%JAVA_OPTS% -XX:+PrintGCApplicationStoppedTime
REM JAVA_OPTS=%JAVA_OPTS% -Xloggc:/var/log/zookeeper/gc.log

REM Causes the JVM to dump its heap on OutOfMemory.
set JAVA_OPTS=%JAVA_OPTS% -XX:+HeapDumpOnOutOfMemoryError
REM The path to the heap dump location, note directory must exists and have enough
REM space for a full heap dump.
REM JAVA_OPTS=%JAVA_OPTS% -XX:HeapDumpPath=$MQ_HOME/logs/heapdump.hprof

if "%DATA_DIR%" == "" set DATA_DIR=%MQ_HOME%\data

if "%WORK_DIR%" == "" set WORK_DIR=%MQ_HOME%

if "%CONF_DIR%" == "" set CONF_DIR=%MQ_HOME%\conf


set MQ_CLASSPATH=%MQ_CLASSPATH%;%MQ_HOME%/lib/*;
set MQ_PARAMS=-Drocketmq;-Drocketmq.home.dir="%MQ_HOME%";-Dmq.cfg.path="%CONF_FILE%";-Dmq.default.path.home="%MQ_HOME%";-Dmq.default.path.logs="%LOG_DIR%";-Dmq.default.path.data="%DATA_DIR%";-Dmq.default.path.work="%WORK_DIR%";-Dmq.default.path.conf="%CONF_DIR%";-Djava.ext.dirs="%MQ_HOME%/lib";-Drocketmq.namesrv.addr="127.0.0.1:9876"

set JVM_OPTS=%JAVA_OPTS: =;%

if not "%MQ_JAVA_OPTS%" == "" set JVM_MQ_JAVA_OPTS=%MQ_JAVA_OPTS: =#%
if not "%MQ_JAVA_OPTS%" == "" set JVM_OPTS=%JVM_OPTS%;%JVM_MQ_JAVA_OPTS%

if "%MQ_START_TYPE%" == "" set MQ_START_TYPE=auto
if "%MQ_STOP_TIMEOUT%" == "" set MQ_STOP_TIMEOUT=0

"%EXECUTABLE%" //IS//%SERVICE_ID% --Startup %MQ_START_TYPE% --StopTimeout %MQ_STOP_TIMEOUT% --StartClass com.alibaba.rocketmq.broker.BrokerStartup --StopClass com.alibaba.rocketmq.broker.BrokerStartup --StartMethod main --StopMethod close --Classpath "%MQ_CLASSPATH%" --JvmSs %JVM_SS% --JvmMs %JVM_XMS% --JvmMx %JVM_XMX% --JvmOptions %JVM_OPTS% ++JvmOptions %MQ_PARAMS% %LOG_OPTS%  --DisplayName "Rocketmq Broker %MQ_VERSION% (%SERVICE_ID%)" --Description "Rocketmq Broker %MQ_VERSION% Windows Service" --Jvm "%JVM_DLL%" --StartMode jvm --StopMode jvm --StartPath "%MQ_HOME%"


if not errorlevel 1 goto installed
echo Failed installing '%SERVICE_ID%' service
goto:eof

:installed
echo The service '%SERVICE_ID%' has been installed.
goto:eof

:err
echo JAVA_HOME environment variable must be set!
pause

goto:eof

rem ---
rem Function for converting Xm[s|x] values into MB which Commons Daemon accepts
rem ---
:convertxm
set value=%~1
rem extract last char (unit)
set unit=%value:~-1%
rem assume the unit is specified
set conv=%value:~0,-1%

if "%unit%" == "k" goto kilo
if "%unit%" == "K" goto kilo
if "%unit%" == "m" goto mega
if "%unit%" == "M" goto mega
if "%unit%" == "g" goto giga
if "%unit%" == "G" goto giga

rem no unit found, must be bytes; consider the whole value
set conv=%value%
rem convert to KB
set /a conv=%conv% / 1024
:kilo
rem convert to MB
set /a conv=%conv% / 1024
goto mega
:giga
rem convert to MB
set /a conv=%conv% * 1024
:mega
set "%~2=%conv%"
goto:eof

ENDLOCAL