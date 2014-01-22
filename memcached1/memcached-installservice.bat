sc create memcached-11211 binpath= "E:\cluster\memcached1\memcached.exe -d runservice -m 256 -p 11211 -l 127.0.0.1" start= auto
pause
sc start memcached-11211 
pause