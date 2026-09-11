# Linux 常用命令整理

---

## 一、文件和目录操作

### 1. 基本操作

| 命令 | 说明 | 示例 |
|------|------|------|
| `ls` | 列出目录内容 | `ls -la` / `ls -lh` |
| `cd` | 切换目录 | `cd /home` / `cd ..` / `cd -` |
| `pwd` | 显示当前路径 | `pwd` |
| `mkdir` | 创建目录 | `mkdir -p a/b/c` (递归创建) |
| `rmdir` | 删除空目录 | `rmdir dirname` |
| `rm` | 删除文件/目录 | `rm -rf dirname` (强制递归删除) |
| `cp` | 复制 | `cp -r source dest` |
| `mv` | 移动/重命名 | `mv old new` |
| `touch` | 创建空文件/更新时间戳 | `touch file.txt` |

### 2. 文件查看

| 命令 | 说明 | 示例 |
|------|------|------|
| `cat` | 查看文件全部内容 | `cat file.txt` |
| `more` | 分页查看（向下翻） | `more file.txt` |
| `less` | 分页查看（可上下翻） | `less file.txt` |
| `head` | 查看文件头部 | `head -n 20 file.txt` |
| `tail` | 查看文件尾部 | `tail -f file.txt` (实时追踪) |
| `nl` | 带行号查看 | `nl file.txt` |

### 3. 文件查找与定位

| 命令 | 说明 | 示例 |
|------|------|------|
| `find` | 查找文件 | `find / -name "*.log"` |
| `find` | 按大小查找 | `find / -size +100M` |
| `find` | 按时间查找 | `find / -mtime -7` (7天内修改) |
| `locate` | 快速定位文件 | `locate filename` |
| `which` | 查找命令路径 | `which java` |
| `whereis` | 查找命令及手册位置 | `whereis nginx` |

### 4. 文件权限 (chmod / chown / chgrp)

| 数字 | 权限 | 说明 |
|------|------|------|
| 4 | r-- | 读 |
| 2 | -w- | 写 |
| 1 | --x | 执行 |

| 命令 | 说明 |
|------|------|
| `chmod 755 file` | 所有者 rwx, 组 rx, 其他 rx |
| `chmod +x file` | 添加执行权限 |
| `chown user:group file` | 修改所有者与组 |
| `chgrp group file` | 仅修改组 |

---

## 二、系统信息与监控

### 1. 系统信息

| 命令 | 说明 |
|------|------|
| `uname -a` | 查看系统/内核版本 |
| `cat /etc/os-release` | 查看发行版信息 |
| `hostnamectl` | 查看/设置主机名 |
| `df -h` | 查看磁盘使用情况 |
| `du -sh *` | 查看目录/文件大小 |
| `free -h` | 查看内存使用 |
| `lscpu` | 查看 CPU 信息 |
| `lsblk` | 列出块设备（磁盘） |
| `uptime` | 系统运行时间 |

### 2. 进程管理

| 命令 | 说明 |
|------|------|
| `ps aux` | 查看所有进程 |
| `ps -ef` | 查看所有进程（另一种格式） |
| `top` | 实时进程监控 |
| `htop` | 更友好的 top（需安装） |
| `kill -9 PID` | 强制终止进程 |
| `killall pname` | 按名称终止进程 |
| `pkill -f java` | 按关键字终止 |
| `nohup cmd &` | 后台运行不受终端关闭影响 |
| `jobs` | 查看后台任务 |
| `fg %n` | 将后台任务调到前台 |

### 3. 端口与网络

| 命令 | 说明 |
|------|------|
| `netstat -tunlp` | 查看所有监听端口 |
| `ss -tunlp` | 更快的端口查看 |
| `lsof -i:8080` | 查看指定端口占用 |
| `curl -I url` | 查看 HTTP 响应头 |
| `wget url` | 下载文件 |
| `ping host` | 测试网络连通性 |
| `ifconfig` / `ip addr` | 查看 IP 地址 |
| `ip route` | 查看路由表 |
| `nslookup domain` | DNS 解析查询 |

---

## 三、用户与组管理

| 命令 | 说明 |
|------|------|
| `useradd username` | 添加用户 |
| `userdel -r username` | 删除用户及其家目录 |
| `usermod -aG group user` | 将用户加入组 |
| `passwd username` | 设置/修改密码 |
| `groupadd groupname` | 添加用户组 |
| `su - user` | 切换用户 |
| `whoami` | 显示当前用户 |
| `id username` | 查看用户 UID/GID |
| `last` | 最近登录记录 |

---

## 四、压缩与解压

| 格式 | 压缩 | 解压 |
|------|------|------|
| `.tar` | `tar -cvf a.tar dir/` | `tar -xvf a.tar` |
| `.tar.gz` / `.tgz` | `tar -zcvf a.tar.gz dir/` | `tar -zxvf a.tar.gz` |
| `.tar.bz2` | `tar -jcvf a.tar.bz2 dir/` | `tar -jxvf a.tar.bz2` |
| `.tar.xz` | `tar -Jcvf a.tar.xz dir/` | `tar -Jxvf a.tar.xz` |
| `.gz` | `gzip file` | `gunzip file.gz` |
| `.zip` | `zip -r a.zip dir/` | `unzip a.zip` |

---

## 五、文本处理

### 1. 常用文本命令

| 命令 | 说明 |
|------|------|
| `grep "pattern" file` | 搜索匹配行 |
| `grep -r "pattern" dir/` | 递归搜索 |
| `grep -v "pattern" file` | 反向匹配 |
| `sed 's/old/new/g' file` | 文本替换 |
| `awk '{print $1}' file` | 按列输出 |
| `sort file` | 排序 |
| `uniq` | 去重（常配合 sort） |
| `wc -l file` | 统计行数 |
| `diff file1 file2` | 文件对比 |
| `echo "text"` | 输出文本 |
| `tee` | 同时输出到屏幕和文件 |

### 2. 重定向与管道

| 符号 | 说明 |
|------|------|
| `>` | 覆盖写入 |
| `>>` | 追加写入 |
| `<` | 输入重定向 |
| `|` | 管道，左边输出作为右边输入 |
| `2>&1` | 错误输出重定向到标准输出 |
| `/dev/null` | 黑洞，丢弃输出 |

---

## 六、包管理

### CentOS/RHEL (yum/dnf)

| 命令 | 说明 |
|------|------|
| `yum install pkg` | 安装 |
| `yum remove pkg` | 卸载 |
| `yum update` | 更新所有包 |
| `yum search keyword` | 搜索包 |
| `yum list installed` | 列出已安装 |
| `yum clean all` | 清理缓存 |

### Ubuntu/Debian (apt)

| 命令 | 说明 |
|------|------|
| `apt update` | 更新源 |
| `apt install pkg` | 安装 |
| `apt remove pkg` | 卸载 |
| `apt upgrade` | 升级所有包 |
| `apt search keyword` | 搜索包 |
| `apt list --installed` | 列出已安装 |

---

## 七、服务管理 (systemctl)

| 命令 | 说明 |
|------|------|
| `systemctl start svc` | 启动服务 |
| `systemctl stop svc` | 停止服务 |
| `systemctl restart svc` | 重启服务 |
| `systemctl status svc` | 查看状态 |
| `systemctl enable svc` | 开机自启 |
| `systemctl disable svc` | 取消开机自启 |
| `systemctl list-units --type=service` | 列出所有服务 |
| `journalctl -u svc -f` | 查看服务日志 |

---

## 八、SSH 与远程操作

| 命令 | 说明 |
|------|------|
| `ssh user@host` | 远程登录 |
| `ssh -p 2222 user@host` | 指定端口登录 |
| `scp file user@host:/path` | 远程拷贝文件 |
| `scp -r dir user@host:/path` | 远程拷贝目录 |
| `rsync -avz src/ dest/` | 增量同步 |
| `ssh-keygen -t rsa` | 生成 SSH 密钥 |
| `ssh-copy-id user@host` | 复制公钥到远程 |

---

## 九、防火墙 (firewalld / iptables / ufw)

### firewalld (CentOS 7+)

| 命令 | 说明 |
|------|------|
| `firewall-cmd --add-port=8080/tcp --permanent` | 永久开放端口 |
| `firewall-cmd --reload` | 重载生效 |
| `firewall-cmd --list-ports` | 查看已开放端口 |

### ufw (Ubuntu)

| 命令 | 说明 |
|------|------|
| `ufw allow 8080/tcp` | 开放端口 |
| `ufw enable` | 启用防火墙 |
| `ufw status` | 查看状态 |

---

## 十、定时任务 (crontab)

| 命令 | 说明 |
|------|------|
| `crontab -l` | 查看定时任务 |
| `crontab -e` | 编辑定时任务 |

**cron 表达式格式：**

```
分 时 日 月 周  命令
*  *  *  *  *  /path/script.sh
```

| 示例 | 说明 |
|------|------|
| `0 2 * * *` | 每天凌晨 2 点 |
| `*/10 * * * *` | 每 10 分钟 |
| `0 0 * * 0` | 每周日 0 点 |

---

## 十一、Vim 常用操作

| 操作 | 说明 |
|------|------|
| `i` | 进入插入模式 |
| `Esc` | 退出插入模式 |
| `:w` | 保存 |
| `:q` | 退出 |
| `:wq` / `ZZ` | 保存并退出 |
| `:q!` | 不保存强制退出 |
| `dd` | 删除一行 |
| `yy` | 复制一行 |
| `p` | 粘贴 |
| `u` | 撤销 |
| `/pattern` | 搜索 |
| `n` / `N` | 下一个/上一个匹配 |
| `G` | 跳到文件末尾 |
| `gg` | 跳到文件开头 |
| `:set nu` | 显示行号 |
| `:%s/old/new/g` | 全文替换 |

---

## 十二、快捷键与技巧

| 操作 | 说明 |
|------|------|
| `Ctrl + C` | 终止当前命令 |
| `Ctrl + Z` | 挂起当前任务 |
| `Ctrl + D` | 退出终端 |
| `Ctrl + L` | 清屏 |
| `Ctrl + R` | 搜索历史命令 |
| `!!` | 执行上一条命令 |
| `!$` | 上一条命令的最后一个参数 |
| `history` | 查看命令历史 |
| `alias ll='ls -la'` | 设置别名 |

---

## 十三、常用工具

| 命令 | 说明 |
|------|------|
| `screen` | 终端复用（会话保持） |
| `tmux` | 更强大的终端复用 |
| `nmap` | 端口扫描 |
| `tcpdump` | 抓包 |
| `strace` | 追踪系统调用 |
| `lsof` | 列出打开的文件 |
| `nc` (netcat) | 网络工具，瑞士军刀 |
| `telnet` | 测试端口连通性 |

---

> **提示：** 建议将常用命令写成 `alias` 放入 `~/.bashrc` 或 `~/.bash_aliases` 中，提高效率。
