sc create memcached-11212 binpath= "E:\cluster\memcached2\memcached.exe -d runservice -m 256 -p 11212 -l 127.0.0.1" start= auto
pause
sc start memcached-11212 
pause