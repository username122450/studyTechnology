# Linux 环境安装指南

> 涵盖 Java、MySQL、Redis、Docker 四种环境的安装与配置，以 CentOS 7/8 和 Ubuntu 20.04/22.04 为例。

---

## 一、Java 环境安装

### 方式一：yum/apt 安装（推荐，最简单）

#### CentOS 7/8

```bash
# 查看可用版本
yum search java | grep jdk

# 安装 OpenJDK 1.8
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel

# 安装 OpenJDK 11
yum install -y java-11-openjdk java-11-openjdk-devel

# 安装 OpenJDK 17
yum install -y java-17-openjdk java-17-openjdk-devel

# 验证安装
java -version
javac -version
```

#### Ubuntu 20.04 / 22.04

```bash
# 更新源
apt update

# 安装 OpenJDK 1.8
apt install -y openjdk-8-jdk

# 安装 OpenJDK 11
apt install -y openjdk-11-jdk

# 安装 OpenJDK 17
apt install -y openjdk-17-jdk

# 验证安装
java -version
javac -version
```

### 方式二：二进制包安装（多版本共存）

```bash
# 1. 下载 JDK（以 JDK 17 为例）
wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz

# 2. 解压到指定目录
tar -zxvf jdk-17_linux-x64_bin.tar.gz -C /usr/local/

# 3. 设置环境变量
vim /etc/profile

# 在文件末尾添加：
export JAVA_HOME=/usr/local/jdk-17.0.x
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$JAVA_HOME/bin:$PATH

# 4. 使配置生效
source /etc/profile

# 5. 验证
java -version
```

### 多版本切换（CentOS）

```bash
# 列出所有已安装的 Java 版本
alternatives --config java
# 根据提示输入数字选择默认版本
```

### 环境变量说明

| 变量 | 作用 |
|------|------|
| JAVA_HOME | JDK 安装根目录 |
| CLASSPATH | 类加载路径 |
| PATH | 追加 $JAVA_HOME/bin |
---

## 二、MySQL 环境安装

### 方式一：yum 安装（CentOS 7/8）

#### MySQL 8.0

```bash
# 1. 下载官方 yum 源
wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

# 2. 安装 yum 源
rpm -ivh mysql80-community-release-el7-3.noarch.rpm

# 3. 安装 MySQL
yum install -y mysql-community-server

# 4. 启动 MySQL
systemctl start mysqld
systemctl enable mysqld

# 5. 获取临时密码
grep ''temporary password'' /var/log/mysqld.log

# 6. 安全初始化（修改密码等）
mysql_secure_installation
```

#### MySQL 5.7

```bash
# 1. 下载 MySQL 5.7 的 yum 源
wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm

# 2. 安装源
rpm -ivh mysql57-community-release-el7-11.noarch.rpm

# 3. 安装
yum install -y mysql-community-server

# 4. 启动
systemctl start mysqld
systemctl enable mysqld

# 5. 获取临时密码
grep ''temporary password'' /var/log/mysqld.log

# 6. 登录并修改密码
mysql -uroot -p

# 执行 SQL：
ALTER USER ''root''@''localhost'' IDENTIFIED BY ''YourNewPassword123!'';
FLUSH PRIVILEGES;
```

### 方式二：apt 安装（Ubuntu）

```bash
# 1. 更新源
apt update

# 2. 安装 MySQL Server
apt install -y mysql-server

# 3. 启动
systemctl start mysql
systemctl enable mysql

# 4. 安全配置
mysql_secure_installation
```

### MySQL 常用配置

```bash
# 编辑配置文件
vim /etc/my.cnf          # CentOS
vim /etc/mysql/my.cnf    # Ubuntu

# 常用配置项
[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
max_connections=200
default-time-zone=''+08:00''
bind-address=0.0.0.0      # 允许远程连接

# 重启生效
systemctl restart mysqld  # CentOS
systemctl restart mysql   # Ubuntu
```

### 创建远程访问用户

```sql
-- 登录 MySQL
mysql -uroot -p

-- 创建远程用户
CREATE USER ''username''@''%'' IDENTIFIED BY ''Password123!'';

-- 授权
GRANT ALL PRIVILEGES ON *.* TO ''username''@''%'' WITH GRANT OPTION;

-- 刷新
FLUSH PRIVILEGES;
```

### 防火墙开放端口

```bash
# firewalld (CentOS)
firewall-cmd --add-port=3306/tcp --permanent
firewall-cmd --reload

# ufw (Ubuntu)
ufw allow 3306/tcp
```

### 忘记密码解决方案

```bash
# 1. 停止 MySQL
systemctl stop mysqld

# 2. 跳过权限验证启动（后台运行）
mysqld --user=mysql --skip-grant-tables --skip-networking &

# 3. 无密码登录
mysql -uroot

# 4. 修改密码
FLUSH PRIVILEGES;
ALTER USER ''root''@''localhost'' IDENTIFIED BY ''NewPassword123!'';

# 5. 正常重启
systemctl restart mysqld
```
---

## 三、Redis 环境安装

### 方式一：yum/apt 安装（快速）

#### CentOS

```bash
# 安装 EPEL 源
yum install -y epel-release

# 安装 Redis
yum install -y redis

# 启动
systemctl start redis
systemctl enable redis

# 验证
redis-cli ping
```

#### Ubuntu

```bash
apt update
apt install -y redis-server

systemctl start redis-server
systemctl enable redis-server

redis-cli ping
```

### 方式二：源码编译安装（最新版）

```bash
# 1. 安装依赖
# CentOS
yum install -y gcc make wget tcl

# Ubuntu
apt install -y build-essential tcl

# 2. 下载并解压
wget https://download.redis.io/releases/redis-7.2.5.tar.gz
tar -zxvf redis-7.2.5.tar.gz
cd redis-7.2.5

# 3. 编译安装
make
make install PREFIX=/usr/local/redis

# 4. 复制配置文件
cp redis.conf /usr/local/redis/

# 5. 配置环境变量
echo ''export PATH=/usr/local/redis/bin:$PATH'' >> /etc/profile
source /etc/profile
```

### 配置 Redis

```bash
vim /usr/local/redis/redis.conf
# 或
vim /etc/redis.conf
```

```ini
# === 核心配置 ===

# 绑定地址（允许远程访问）
bind 0.0.0.0

# 端口
port 6379

# 守护进程模式（后台运行）
daemonize yes

# 设置密码
requirepass YourRedisPassword

# 持久化 - RDB
save 900 1
save 300 10
save 60 10000

# 持久化 - AOF
appendonly yes
appendfsync everysec

# 最大内存
maxmemory 512mb

# 内存淘汰策略
maxmemory-policy allkeys-lru

# 日志文件
logfile /var/log/redis/redis.log
```

### 设置 Redis 为系统服务（源码安装时）

```bash
# 创建 systemd 服务文件
cat > /etc/systemd/system/redis.service << ''EOF''
[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/redis.conf
ExecStop=/usr/local/redis/bin/redis-cli -a YourPassword shutdown
User=root
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 重载并启动
systemctl daemon-reload
systemctl start redis
systemctl enable redis
```

### 防火墙开放端口

```bash
# firewalld
firewall-cmd --add-port=6379/tcp --permanent
firewall-cmd --reload

# ufw
ufw allow 6379/tcp
```

### Redis 常用命令

```bash
# 连接 Redis
redis-cli                     # 本地无密码
redis-cli -h 127.0.0.1 -p 6379 -a password

# 常用操作
redis-cli ping                # 测试连接
redis-cli info                # 查看信息
redis-cli monitor             # 监控所有请求
redis-cli --stat              # 实时统计
redis-cli keys ''*''          # 查看所有 key
redis-cli flushall            # 清空所有数据
```
---

## 四、Docker 环境安装

### CentOS 7

```bash
# 1. 卸载旧版本
yum remove -y docker docker-client docker-client-latest \
              docker-common docker-latest docker-latest-logrotate \
              docker-logrotate docker-engine

# 2. 安装依赖
yum install -y yum-utils device-mapper-persistent-data lvm2

# 3. 添加 Docker 官方源（国内推荐使用阿里云）
# 官方源
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 阿里云源（国内加速）
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 4. 安装 Docker
yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. 启动 Docker
systemctl start docker
systemctl enable docker

# 6. 验证
docker --version
docker run hello-world
```

### CentOS 8 / Rocky Linux

```bash
# 1. 卸载旧版本
dnf remove -y docker docker-client docker-client-latest \
              docker-common docker-latest docker-latest-logrotate \
              docker-logrotate docker-engine

# 2. 安装依赖
dnf install -y dnf-plugins-core

# 3. 添加源
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 阿里云源
dnf config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 4. 安装
dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. 启动
systemctl start docker
systemctl enable docker
```

### Ubuntu 20.04 / 22.04

```bash
# 1. 卸载旧版本
apt remove -y docker docker-engine docker.io containerd runc

# 2. 更新源并安装依赖
apt update
apt install -y ca-certificates curl gnupg lsb-release

# 3. 添加 Docker 官方 GPG 密钥
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 4. 添加 Docker 源
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

# 国内阿里云源（将上面地址替换为下面）
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. 安装 Docker
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. 启动
systemctl start docker
systemctl enable docker

# 7. 验证
docker --version
docker run hello-world
```

### Docker 安装后配置

#### 1. 配置镜像加速（国内必做）

```bash
# 创建配置目录
mkdir -p /etc/docker

# 编辑 daemon.json
cat > /etc/docker/daemon.json << 'EOF'
{
  "registry-mirrors": [
    "https://docker.1ms.run",
    "https://docker.xuanyuan.me",
    "https://docker.hpcloud.cloud"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "exec-opts": ["native.cgroupdriver=systemd"],
  "storage-driver": "overlay2"
}
EOF

# 重载并重启
systemctl daemon-reload
systemctl restart docker
```

#### 2. 非 root 用户使用 Docker

```bash
# 将用户加入 docker 组
usermod -aG docker your_username

# 重新登录后生效
newgrp docker
```

#### 3. 设置 Docker 开机自启

```bash
systemctl enable docker
systemctl enable containerd
```

### 安装 Docker Compose（独立版）

```bash
# 下载 Docker Compose
curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 \
     -o /usr/local/bin/docker-compose

# 添加执行权限
chmod +x /usr/local/bin/docker-compose

# 创建软链接
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# 验证
docker-compose --version
```

### Docker 常用命令速查

```bash
# === 镜像操作 ===
docker images                    # 查看所有镜像
docker pull nginx:latest         # 拉取镜像
docker rmi image_id              # 删除镜像
docker search keyword            # 搜索镜像
docker build -t name:tag .       # 构建镜像
docker save -o file.tar image    # 导出镜像
docker load -i file.tar          # 导入镜像

# === 容器操作 ===
docker ps                        # 查看运行中容器
docker ps -a                     # 查看所有容器
docker run -d --name web -p 80:80 nginx   # 启动容器
docker stop container_id         # 停止容器
docker start container_id        # 启动容器
docker restart container_id      # 重启容器
docker rm container_id           # 删除容器
docker rm -f container_id        # 强制删除
docker exec -it container_id /bin/bash   # 进入容器
docker logs -f container_id      # 查看日志
docker cp a.txt container_id:/tmp/       # 拷贝文件到容器

# === Docker Compose ===
docker-compose up -d             # 启动服务（后台）
docker-compose down              # 停止并删除服务
docker-compose restart           # 重启服务
docker-compose logs -f           # 查看日志
docker-compose ps                # 查看状态
```

### Docker 网络

```bash
# 查看网络
docker network ls

# 创建网络
docker network create my-network

# 连接容器到网络
docker network connect my-network container_name
```

---

## 五、一键安装脚本（Shell）

将以下脚本保存为 `install_env.sh`，赋予执行权限后运行。

```bash
#!/bin/bash
# ==========================================
# Linux 环境一键安装脚本
# 支持: Java / MySQL / Redis / Docker
# ==========================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检测系统类型
if [ -f /etc/redhat-release ]; then
    OS="centos"
    PKG="yum"
elif [ -f /etc/lsb-release ]; then
    OS="ubuntu"
    PKG="apt"
else
    error "不支持的系统类型"
    exit 1
fi
info "检测到系统: $OS"

# ============ 安装 Java ============
install_java() {
    info "开始安装 Java 1.8..."
    if [ "$OS" = "centos" ]; then
        yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
    else
        apt update
        apt install -y openjdk-8-jdk
    fi
    info "Java 安装完成: $(java -version 2>&1 | head -n1)"
}

# ============ 安装 MySQL ============
install_mysql() {
    info "开始安装 MySQL..."
    if [ "$OS" = "centos" ]; then
        wget -q https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
        rpm -ivh mysql80-community-release-el7-3.noarch.rpm
        yum install -y mysql-community-server
        systemctl start mysqld
        systemctl enable mysqld
        TEMP_PWD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
        info "MySQL 临时密码: $TEMP_PWD"
    else
        apt update
        apt install -y mysql-server
        systemctl start mysql
        systemctl enable mysql
    fi
    info "MySQL 安装完成"
}

# ============ 安装 Redis ============
install_redis() {
    info "开始安装 Redis..."
    if [ "$OS" = "centos" ]; then
        yum install -y epel-release
        yum install -y redis
        systemctl start redis
        systemctl enable redis
    else
        apt update
        apt install -y redis-server
        systemctl start redis-server
        systemctl enable redis-server
    fi
    info "Redis 安装完成"
}

# ============ 安装 Docker ============
install_docker() {
    info "开始安装 Docker..."
    if [ "$OS" = "centos" ]; then
        yum install -y yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum install -y docker-ce docker-ce-cli containerd.io
        systemctl start docker
        systemctl enable docker
    else
        apt update
        apt install -y ca-certificates curl gnupg lsb-release
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
        https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt update
        apt install -y docker-ce docker-ce-cli containerd.io
        systemctl start docker
        systemctl enable docker
    fi
    info "Docker 安装完成: $(docker --version)"
}

# ============ 菜单 ============
echo "=========================================="
echo "       Linux 环境一键安装脚本"
echo "=========================================="
echo "  1) 安装 Java (OpenJDK 1.8)"
echo "  2) 安装 MySQL 8.0"
echo "  3) 安装 Redis"
echo "  4) 安装 Docker"
echo "  5) 全部安装"
echo "  0) 退出"
echo "=========================================="
read -p "请选择 [0-5]: " choice

case $choice in
    1) install_java ;;
    2) install_mysql ;;
    3) install_redis ;;
    4) install_docker ;;
    5)
        install_java
        install_mysql
        install_redis
        install_docker
        ;;
    0) exit 0 ;;
    *) error "无效选择" ;;
esac

info "安装完毕！"
```

---

## 六、常见问题与排查

### Java

| 问题 | 解决 |
|------|------|
| `java: command not found` | 未配置环境变量，执行 `source /etc/profile` |
| 多版本冲突 | 使用 `alternatives --config java` 切换 |
| 内存不足 | 在启动参数中设置 `-Xmx` 和 `-Xms` |

### MySQL

| 问题 | 解决 |
|------|------|
| 无法远程连接 | 检查 bind-address、防火墙、用户权限 |
| 密码不符合策略 | `SHOW VARIABLES LIKE 'validate_password%';` 查看策略 |
| 忘记 root 密码 | 使用 skip-grant-tables 方式重置 |

### Redis

| 问题 | 解决 |
|------|------|
| 无法远程连接 | 检查 `bind 0.0.0.0` 和 `protected-mode no` |
| RDB 持久化失败 | 检查磁盘空间和目录权限 |
| 内存打满 | 检查 `maxmemory` 和淘汰策略 `maxmemory-policy` |

### Docker

| 问题 | 解决 |
|------|------|
| 拉镜像超时 | 配置镜像加速器 |
| `permission denied` | 将用户加入 docker 组 |
| 容器启动失败 | `docker logs container_id` 查看日志 |
| 磁盘占用大 | `docker system prune -a` 清理 |

---

> **提示：** 生产环境中请根据实际需求调整内存、连接数等配置参数，并务必设置强密码。