# StudyRedis

## 基础知识

- Redis默认端口号是6379 

- 默认数据库实例有16个，从0开始到15  ，默认为0，用`select [dbid]`切换数据库

- `dbsize`查看当前数据库的key的数量

- `flushdb`清空数据库

- redis效率高：redis采用单线程+多路IO复用技术，但是memcached采用串行+多线程+锁





## 常用数据类型操作

### key操作

- 设置key

    `set [key] [value]`

- 查询key是否存在

​	`exists [key]` 返回0表示不存在，1表示存在

- 查询key的类型

​	`type [key]`

- 设置过期时间

​	`expire [key] [Time:s]`

- 查看剩余（过期）时间

​	`ttl [key]` 返回-2表示已删除，正数是剩余存活时间

- 删除key

​	`del [key]` 返回1表示成功

- 清空所有数据库所有内容

​	`flushall`



### string操作

string类型是redis最基本的类型，是二进制安全的，意味着string可以包含任何数据包括jpg图片或者序列化对象最大是512M

- 设置string

​	`set [key] [value]` 设置重复的key就是内容的覆盖

- 获取string

​	`get [key]`

- 追加string

​	`append [key] [value]`

- 获取字符串长度

​	`strlen [key]`

- 不存在key则设置

​	`setnx [key] [value]` 

- 自增（需要值为数字类型）

​	`incr [key]` incr命令是原子操作，因为redis是单线程的，单条指令不会被打断

- 自减（同上）

​	`decr [key]`

- 自定义增减数值

​	`incrby [key] [increment]`

​	`decrby [key] [increment]`

- 批量设置

​	`mset [key] [value] [key] [value] ...`

- 批量获取

​	`mget [key] [key] [key]`

​	使用`msetnx`时，必须所有key都不存在才能放行

- 截取指定区间（[start,end]）字符串

​	`getrange [key] [start] [end]`

- 设置指定区间字符串，替换长度为目标字符串长度

​	`setrange [key] [start] [value]`

- 设置string同时指定过期时间

​	`setex [key] [time] [value]`

- 设置新值同时返回旧值

​	`getset [key] [value]`



### list操作

list列表时单键多值列表，是简单的字符串列表，底层是双向链表，对两端的操作性能很高，但是通过索引下标操作中间的节点性能会较差

- 左端插入

​	`lpush [key] [value] [value] [value] ...`

- 右端插入

​	`rpush [key] [value] [value] [value] ...`

- 查询列表中区间的元素，从0到-1可以查询全部元素

​	`lrange [key] [start] [end]`

- 左端弹出并返回

​	`lpop [key]`

- 右端弹出并返回

​	`rpop [key]`

- 右端弹出追加到左端

​	`rpoplpush [key] [key]`

- 下标取值

​	`lindex [key] [index]`

- 获取列表长度

​	`llen [key]`

- 在元素前后追加

​	`linsert [key] before(after) [targetValue] [value]`

- 删除元素

​	`lrem [key] [count] [value]`

- 替换元素根据下标

​	`lset [key] [index] [value]`



### set操作

set是string类型的无序集合，与list功能类似，但set可以自动去重，底层是一个value为null的hash表，所以添加删除查找的复杂度都是O(1)

- 添加元素

​	`sadd [key] [value] [value] [value] ...`

- 查询集合元素

​	`smembers [key]`

- 判断元素是否在集合中，存在返回1，不存在返回0

​	`sismember [key] [value]` 

- 返回集合中元素的个数

​	`scard [key]`

- 随机获取指定个数的值，不会删除

​	`srandmember [key] [count]`

- 随机弹出某个元素

​	`spop [key]`

- 移动元素

​	`smove [key] [key] [value]`

- 取交集

​	`sinter [key] [key]`

- 取并集

​	`sunion [key] [key]`

- 取key1补集

​	`sdiff [key1] [key2]`



### hash操作

hash 是一个string类型的field和value的映射表，特别适合存储对象

- 设置hash

​	`hset [key] [field] [value]`

- 获取hash

​	`hget [key] [field]`

- 批量设置

​	`hmset [key] [field] [value] [field] [value] ...`

- 批量获取 

​	`hmget [key] [field] [field] [field] ...`

- 判断是否存在，存在返回1，不存在返回0

​	`hexists [key] [field]`

- 获取所有field

​	`hkeys [key]`

- 获取所有value

​	`hvals [key]`

- 删除field

​	`hdel [key] [field]`

- 自增（field必须是数字类型)

​	`hincrby [key] [field] [count]`

- 不存在则设置

​	`hsetnx [key] [field] [value]`



### zset操作

zset是有序集合，与普通zset相似，是没有重复元素的字符串集合，不同在zset每个成员都关联了一个评分score，被用来从最低分到最高分排序，成员是唯一的，评分是可以重复的,底层采用hash+跳跃表实现

添加元素

`zadd [key] [score] [value] [score] [value] [score] [value] ...`

根据下标查询元素，0到-1可以查询所有元素（withscores同时查询分数）

`zrange [key] [start] [end] (withscores)`

根据分数区间查询（withscores同时查询分数）

`zrangebyscore [key] [start] [end] (withscores)`

增加评分

`zincrby [key] [count] [value]`

删除指定元素

`zrem [key] [value]`

统计分数区间

`zcount [key] [start] [end]`

根据分数降序排序查询(start]end)

`zrevrangebyscore [key] [start] [end] (withscores)`





## redis配置文件

### INCLUDES

- 可以通过`include [path]`导入redis的自定义配置文件



### NETWORK

- 本机自我保护 `protected-mode`

- 允许访问地址 `bind`

- 端口号 `port`

- 连接队列时间 `tcp-backlog` 高并发环境下需要高backlog值避免满客户端连接问题，注意与Linux内核的两个值配合

- 空闲客户端维持时间 `timeout` 0表示关闭功能，永不关闭

- 心跳检测 `tcp-keepalive` 



GENERAL

- 后台进程守护 `daemonize` 

- pid文件存放地址 `pidfile`

- 日志级别 `loglevel`

- 日志输出地址 `logfile`

- 数据库实例 `databases`



### SECURITY

可以在redis-cli里使用命令设置密码

`config set requirepass [password]`



LIMITS

- 最大连接数量 `maxclients`

- 最大内存占用 `maxmemory`

- 最大内存是移除内存规则 `maxmemory-policy`
    - volatile-lru：使用LRU算法移除key，只对设置了过期时间的键；（最近最少使用）
    - allkeys-lru：在所有集合key中，使用LRU算法移除key
    - volatile-random：在过期集合中移除随机的key，只对设置了过期时间的键
    - allkeys-random：在所有集合key中，移除随机的key
    - volatile-ttl：移除那些TTL值最小的key，即那些最近要过期的key
    - noeviction：不进行移除。针对写操作，只是返回错误信息





## redis发布与订阅

### 认识

完成redis的发布与订阅需要两个步骤：

1. 客户端（订阅者）订阅频道
2. 发送者给频道发送消息后，消息会发送给订阅的客户端



### 实现

- 打开客户端1，订阅channel1 `subscribe channel1`
- 打开客户端2，发送消息hello `publish channel1 [message]`





## 新的数据类型

### bitmap操作

bitmap（位图），底层是string，最大位数是512M即2^31位，用于标记，极度节省空间

- 设置bitmap

​	`setbit [key] [offset] [value]`

- 根据下标获取信息

​	`getbit [key] [offset]`

- 统计为1的个数

​	`bitcount [key]`

- 操作一段连续bit 
    - type：u=无符号，i=有符号，后面跟位数，最大支持64位
    - offset：bit偏移量，从0开始


​	`BITFIELD key `

​	`[GET type offset] `

​	`[SET type offset value] `

​	`[INCRBY type offset increment] `

​	`[OVERFLOW WRAP|SAT|FAIL]`

- 查询第一次出现的位置

​	`bitpos [key] [value]`

- 获取bitmap中的bit数组，并用十进制返回

​	`bitfield_ro [key]`

- 位运算
    - operation：运算类型，and（与），or（或），xor（异或），not（非）
    - destkey：结果保存到
    - key：参与运算的key

​	`bitop [operation] [destkey] [key] [key]`

​	

### hyperloglog操作

hyperloglog是redis中的一种基数统计数据结构，用来做去重计数，不保存原始数据，只能拿到估算的数量

- 添加元素

​	`pfadd [key] [value]`

- 统计元素个数

​	`pfcount [key]`

- 合并key到targetKey

​	`pfmerge [targetKey] [key] [key]`



### geospatial操作

geospatial是redis对经纬度信息定义的一种数据类型

- 添加元素
    - longitude：经度
    - latitude：纬度

​	`geoadd [key] [longitude] [latitude] [member]`

- 获取元素的经纬度

​	`geopos [key] [member]`

- 计算两地的直线距离
    - 不带km单位为m

​	`geodist [key] [member] [member] [km]`

- 找出经纬度一定距离内的城市

​	`georadius [key] [longitude] [latitude] [dist]`





## redis事务

redis事务是一个单独的隔离操作：事务中的所有命令都会序列化、按顺序执行。事务在执行的过程中，不会被其他客户端发送过来的命令请求打断，redis事务的主要作用就是串联多个命令防止别的命令插队

输入的命令依次进入命令队列中

`multi`

将命令队列中的命令依次执行

`exec`

放弃将队列中的命令执行

`discard`



### 事务的错误处理

- 组队中命令出现报告错误（组队时出现错误），整个队列都会被取消，如命令语法问题

- 在执行的时候出现了问题，值只有报错的命令不会被执行，其他命令都会执行，不会回滚



### 实现redis乐观锁

在执行multi之前，先执行

`watch key key ...`

如果在事务执行之前这个key被其他命令所修改，那么事务将被打断



### redis事务的特性

- 单独的隔离操作 ：事务中所有命令都会序列化，按顺序执行，事务在执行的过程中，不会被其他客户端发送过来的命令请求打断
- 没有隔离级别的概念：队列中的命令没有提交之前都不会实际被执行
- 不保证原子性：如果事务中有一条命令执行失败，其他命令依旧会被执行，没有回滚





## redis持久化策略

### RDB策略

在指定的时间间隔内将内存中的数据集快照写入磁盘，也就是Snapshop快照，他恢复时是直接将快照读到内存里

#### 触发策略

1. 手动触发

    - `save`：阻塞redis主进程，直到持久化完成
    - `bgsave`：fork一个子进程，由子进程负责持久化过程，阻塞只会发生在fork子进程中

2. 自动触发

    redis在指定的时间内，数据发生了多少次变化时，会自动执行`bgsave`

    - `save m n`的含义是从第一次变化开始的时间m秒内，如果redis数据至少发生了n次变化就自动执行`bgsave`命令

        

#### dump.rdb文件

在redis.conf中配置文件名称，默认为dump.rdb

`421 dbfilename dump.rdb`

rdb文件的保存路径，也可以修改，默认为redis启动时命令行所在的目录下，我们也可以自定义目录位置

` 444 dir ./`



#### stop-writes-on-bgsave-error

当redis无法写入磁盘的话，直接关掉redis的写操作



#### redis持久化的特点

- 优势
    - 适合大规模数据恢复
    - 对数据完整性和一致性要求不高更适合使用
    - 节省磁盘空间
    - 恢复速度快
- 劣势
    - fork的时候，内存中的数据被克隆了一份，大致两倍的膨胀性需要考虑
    - redis在fork时使用了写时拷贝技术，在数据庞大时是比较消耗性能
    - 在备份周期内一定间隔时间做一次备份，如果redis意外down掉的话，就会丢失最后一次快照的所有修改





### AOF策略

AOF：append only file

以日志的形式来记录每个写操作，将redis执行过的写指令记录下来（读操作不记录），只许追加文件内但不可以改文件，redis启动之初会读取该文件重新构建数据

AOF默认不开启：

`1230 appendonky no`

文件名默认为`appendonly.aof`可以修改文件名

`1234 appendfilename "appendonly.aof"`



#### AOF持久化规则

- `appendfsync always`

    始终同步，每次redis的写入都会立刻记入日志；性能较差但数据完整性比较好

- `appendfsync everysec`

    每秒同步，每秒记入日志一次，如果宕机，本秒数据可能丢失

- `appendfsyncno`

    redis不主动进行同步，将同步时机交给操作系统



#### rewrite重写机制

Redis会记录上次重写时的AOF大小，默认配置是当AOF文件大小是上次rewrite后大小的一倍且文件大于64M时触发

重写虽然可以节约大量磁盘空间，减少恢复时间。但是每次重写还是有一定的负担的，因此设定Redis要满足一定条件才会进行重写。

`auto-aof-rewrite-percentage`：设置重写的基准值，文件达到100%时开始重写（文件是原来重写后文件的2倍时触发）

`auto-aof-rewrite-min-size`：设置重写的基准值，最小文件64MB，达到这个值开始重写



#### AOF持久化特点

- 优势
    - 备份机制更稳健，丢失数据概率更低
    - 可读的日志文本，通过操作AOF稳健，可以处理误操作
- 劣势
    - 比起RDB更占用磁盘空间
    - 恢复备份速度慢
    - 每次读写都同步有一定的性能压力



对两种策略，官方**推荐两个都启用**

在同时开启两种持久化方式时

- 当redis重启的时候会优先载入AOF文件来恢复原始的数据，因为在通常情况下AOF文件保存的数据集要比RDB文件保存的数据集更完整
- RDB的数据不实时，同时使用两者时服务器重启也只会找AOF文件，但RDB更适合用于备份数据库（AOF在不断变化不好备份），快速重启，而且不会有AOF可能潜在的bug





## 主从复制

主机数据更新后根据配置和策略，自动同步到备机的机制，主机就是master，备机就是slave

主机处理写操作

从机处理读操作

优点：

- 读写分离，性能扩展
- 容灾快速恢复



### 配置

创建主机从机conf文件后，写入以下配置

```bash
include /myredis/redis.conf
pidfile /var/run/redis_6379.pid
port 6379
dbfilename dump6379.rdb
```

根据主从机修改配置

在从机中添加配置：主机地址和端口

```bash
slaveof 127.0.0.1 6379
```

启动主从机即可

对redis-cli，可以用`-p 端口号`来指定操作服务器

可以在cli里面用`info replication`



### 原理

- slave启动成功连接到master后会发送一个sync命令
- master接收到命令，启动后台的存盘进程，同时收集所有接收到的用于修改数据集的命令，在后台进程执行完毕后，master将传送整个数据文件到slave，完成一次完全同步
- 全量复制：在slave服务接收到数据库文件数据后，将其存盘并加载到内存中
- 增量复制：master继续将新的所有收集到的修改命令依此传给slave，完成同步
- 但是只要时重新连接master，已经完全同步（全量复制）将被自动执行



### 薪火相传

优势：分担主机数据同步的压力（去中心化）

劣势：如果某台从机挂机后，这台机器下面的节点机器无法同步最新数据

搭建：将新创建的redis服务器作为从机挂载到非6379的redis服务器下`slaveof 127.0.0.1 6381`



### 反客为主

默认情况下，如果主机挂了，从机的角色不会发生变化，如果我们想主机挂了只会，从机的角色发生转换，转换成主机，这就是反客为主

在要设置的服务器cli里面`slaveof no one`可以临时设为主机

在其他主机的从机里设置`slaveof 临时主机地址 端口号`



### 哨兵模式

**反客为主的自动版**，后台监控主机是否故障，如果故障了，根据票数自动将节点切换为主节点

#### 搭建

- 在myredis文件夹下，创建**sentinel.conf**文件

- 定义 
    ```bash
    sentinel monitor mymaster 127.0.0.1 6379 1
    ```

    - mymaster：监控对象起的服务器名称
    - 1：至少有多少个哨兵同意迁移的数量

- 启动哨兵
    ```bash
    redis-sentinel sentinel.conf
    ```



在原主机挂掉，哨兵模式自动选取新主机后，如果原主机重启，新主机不会让位，主机还是保持为新主机



#### 哨兵模式的选举策略

1. 优先级靠前的
    优先级在conf中设置：默认为100

    ```bash
    658 replica-priority 100
    ```

2. 偏移量最大的
    偏移量是指获取原主机数据最全的

3. runid最小的
    每个redis服务重启后会随机生成一个40位的runid码





## redis集群

### 搭建三主三从集群

在redis-cluster复制redis.conf文件

6个端口分别是6379，6380，6381，6389，6390，6391

在配置文件中定义

```bash
include /redis-cluster/redis.conf
pidfile /var/run/redis_6379.pid
port 6379
dbfilename dump6379.rdb
cluster-enabled yes
cluster-config-file nodes-6379.conf
cluster-node-timeout 15000
```

注意：

- cluster-enabled yes：打开集群模式

- cluster-config-file nodes-6379.conf：设定节点配置文件名

- cluster-node-timeout 15000：设定节点失联时间，超过该时间（毫秒），集群自动进行主从切换。

快捷命令：用6380替换文件中的6379

```bash
%s/6379/6380
```

