redis-server.exe --service-install "E:\cluster\redis-slaver\redis.windows.conf" --service-name "redis_slaver" --loglevel verbose
pause
redis-server --service-start  --service-name "redis_slaver"
pause
cmd
