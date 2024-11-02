# Redis

Super fast in memory "database"

Installation via building / compilation:

```
cd ~
mkdir -p .apps
mkdir -p bin
cd .apps

# Can check latest at https://redis.io/download/#redis-downloads
mkdir redis
wget https://download.redis.io/releases/redis-6.2.9.tar.gz
tar xvzf redis-6.2.9.tar.gz -C redis --strip-components 1
cd redis
make
```