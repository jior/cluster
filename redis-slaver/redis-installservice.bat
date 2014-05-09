sc create redis-slaver binpath= "E:\cluster\redis-slaver\RedisService.exe E:\cluster\redis-slaver\redis.conf  " start= auto
pause
sc start redis-slaver 
pause