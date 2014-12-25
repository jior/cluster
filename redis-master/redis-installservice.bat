redis-server --service-install E:\cluster\redis-master\redis.windows.conf --service-name "redis_master" --loglevel verbose  
pause
redis-server --service-start  --service-name "redis_master"
pause
cmd
