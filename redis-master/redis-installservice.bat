sc create redis-master binpath= "E:\cluster\redis-master\RedisService.exe E:\cluster\redis-master\redis.conf  " start= auto
pause
sc start redis-master 
pause