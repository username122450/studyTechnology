# MySQL 常用命令整理

---

## 一、数据库基本操作

| 命令 | 说明 |
|------|------|
| `SHOW DATABASES;` | 查看所有数据库 |
| `CREATE DATABASE db_name;` | 创建数据库 |
| `CREATE DATABASE db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;` | 创建数据库（指定字符集） |
| `DROP DATABASE db_name;` | 删除数据库 |
| `USE db_name;` | 切换数据库 |
| `SELECT DATABASE();` | 查看当前数据库 |

---

## 二、表操作

### 1. 创建表

```sql
CREATE TABLE student (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(20)  NOT NULL,
    age         TINYINT      DEFAULT 0,
    gender      ENUM('男','女'),
    score       DECIMAL(5,2),
    created_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 2. 查看表

| 命令 | 说明 |
|------|------|
| `SHOW TABLES;` | 查看当前库所有表 |
| `DESC table_name;` | 查看表结构 |
| `SHOW CREATE TABLE table_name;` | 查看建表语句 |
| `SHOW COLUMNS FROM table_name;` | 查看列信息 |
| `SHOW TABLE STATUS;` | 查看表状态信息 |

### 3. 修改表

| 命令 | 说明 |
|------|------|
| `ALTER TABLE t ADD col_name VARCHAR(20);` | 添加列 |
| `ALTER TABLE t MODIFY col_name INT NOT NULL;` | 修改列定义 |
| `ALTER TABLE t CHANGE old new VARCHAR(50);` | 重命名列 |
| `ALTER TABLE t DROP COLUMN col_name;` | 删除列 |
| `ALTER TABLE t ADD INDEX idx_name(col);` | 添加索引 |
| `ALTER TABLE t DROP INDEX idx_name;` | 删除索引 |
| `ALTER TABLE old_name RENAME TO new_name;` | 重命名表 |
| `DROP TABLE table_name;` | 删除表 |
| `TRUNCATE TABLE table_name;` | 清空表（不可回滚） |

---

## 三、数据操作 (CRUD)

### 1. 插入

```sql
-- 单行插入
INSERT INTO student (name, age, score) VALUES ('张三', 20, 88.5);

-- 多行插入
INSERT INTO student (name, age, score) VALUES
    ('李四', 22, 91.0),
    ('王五', 21, 76.5);

-- 从查询结果插入
INSERT INTO student_backup SELECT * FROM student;
```

### 2. 删除

```sql
DELETE FROM student WHERE id = 1;       -- 条件删除
DELETE FROM student;                     -- 删除全部（谨慎）
```

### 3. 更新

```sql
UPDATE student SET score = 95 WHERE id = 1;
UPDATE student SET score = score + 5 WHERE age < 20;   -- 基于原值更新
```

### 4. 查询

```sql
-- 基本查询
SELECT * FROM student;
SELECT name, score FROM student;

-- 条件查询
SELECT * FROM student WHERE age >= 20 AND score > 80;
SELECT * FROM student WHERE name LIKE '张%';
SELECT * FROM student WHERE age IN (18, 20, 22);
SELECT * FROM student WHERE score BETWEEN 60 AND 100;
SELECT * FROM student WHERE name IS NOT NULL;
SELECT * FROM student WHERE age > 18 ORDER BY score DESC;
SELECT * FROM student LIMIT 10 OFFSET 20;

-- 聚合查询
SELECT COUNT(*) FROM student;
SELECT AVG(score), MAX(score), MIN(score), SUM(score) FROM student;
SELECT gender, COUNT(*), AVG(score) FROM student GROUP BY gender;
SELECT gender, AVG(score) FROM student GROUP BY gender HAVING AVG(score) > 80;

-- 去重
SELECT DISTINCT age FROM student;
```

---

## 四、多表查询

### JOIN 类型

| JOIN 类型 | 说明 |
|-----------|------|
| `INNER JOIN` | 两表都匹配才返回 |
| `LEFT JOIN` | 左表全返回，右表无匹配填 NULL |
| `RIGHT JOIN` | 右表全返回，左表无匹配填 NULL |
| `FULL JOIN` | 两表全部返回（MySQL 不直接支持，用 UNION 模拟） |
| `CROSS JOIN` | 笛卡尔积 |
| `SELF JOIN` | 表自身连接 |

### 示例

```sql
-- 学生表 + 班级表
SELECT s.name, c.class_name
FROM student s
INNER JOIN class c ON s.class_id = c.id;

-- LEFT JOIN（含无班级的学生）
SELECT s.name, c.class_name
FROM student s
LEFT JOIN class c ON s.class_id = c.id;

-- 子查询
SELECT name FROM student
WHERE class_id IN (SELECT id FROM class WHERE grade = '三年级');

SELECT name, (SELECT class_name FROM class WHERE id = s.class_id) AS class
FROM student s;
```

### UNION / UNION ALL

```sql
-- UNION 去重，UNION ALL 不去重
SELECT name FROM student_2024
UNION ALL
SELECT name FROM student_2025;
```

---

## 五、用户与权限管理

### 用户管理

| 命令 | 说明 |
|------|------|
| `CREATE USER 'user'@'host' IDENTIFIED BY 'password';` | 创建用户 |
| `DROP USER 'user'@'host';` | 删除用户 |
| `ALTER USER 'user'@'host' IDENTIFIED BY 'new_password';` | 修改密码 |
| `RENAME USER 'old'@'host' TO 'new'@'host';` | 重命名用户 |
| `SELECT user, host FROM mysql.user;` | 查看所有用户 |

> host 常用值：`'localhost'`（仅本地）、`'%'`（任意 IP）、`'192.168.1.%'`（网段）

### 权限管理

```sql
-- 授予权限
GRANT ALL PRIVILEGES ON db_name.* TO 'user'@'host';
GRANT SELECT, INSERT, UPDATE ON db_name.table_name TO 'user'@'host';

-- 撤销权限
REVOKE ALL PRIVILEGES ON db_name.* FROM 'user'@'host';
REVOKE DELETE ON db_name.* FROM 'user'@'host';

-- 查看权限
SHOW GRANTS FOR 'user'@'host';

-- 刷新权限
FLUSH PRIVILEGES;
```

### 常用权限列表

| 权限 | 说明 |
|------|------|
| `ALL PRIVILEGES` | 所有权限 |
| `SELECT` | 查询 |
| `INSERT` | 插入 |
| `UPDATE` | 更新 |
| `DELETE` | 删除 |
| `CREATE` | 创建库/表 |
| `DROP` | 删除库/表 |
| `ALTER` | 修改表结构 |
| `INDEX` | 创建/删除索引 |
| `EXECUTE` | 执行存储过程 |
| `LOCK TABLES` | 锁表 |

---

## 六、索引

### 索引类型

| 类型 | 说明 |
|------|------|
| `PRIMARY KEY` | 主键索引（唯一、非空） |
| `UNIQUE` | 唯一索引 |
| `INDEX` / `KEY` | 普通索引 |
| `FULLTEXT` | 全文索引（MyISAM / InnoDB 5.6+） |
| `SPATIAL` | 空间索引 |
| 联合索引 | 多列组合索引 |

### 索引操作

```sql
-- 创建索引
CREATE INDEX idx_name ON table_name(col);
CREATE UNIQUE INDEX idx_email ON user(email);
CREATE INDEX idx_a_b ON table_name(a, b);      -- 联合索引

-- 删除索引
DROP INDEX idx_name ON table_name;
ALTER TABLE table_name DROP INDEX idx_name;

-- 查看索引
SHOW INDEX FROM table_name;
```

### 索引注意事项

- 遵循**最左前缀原则**（联合索引 `(a,b,c)` 走索引的条件：`a`、`a,b`、`a,b,c`）
- 避免在 WHERE 子句中对字段进行函数运算（如 `WHERE YEAR(create_time) = 2024` 不走索引）
- LIKE `'%xxx'` 不走索引，LIKE `'xxx%'` 走索引
- 用 `EXPLAIN` 分析是否走索引

---

## 七、备份与恢复

### mysqldump

```bash
# 备份单个数据库
mysqldump -u root -p db_name > db_name.sql

# 备份多个数据库
mysqldump -u root -p --databases db1 db2 > multi_db.sql

# 备份所有数据库
mysqldump -u root -p --all-databases > all_db.sql

# 只备份表结构
mysqldump -u root -p --no-data db_name > schema.sql

# 只备份数据
mysqldump -u root -p --no-create-info db_name > data.sql

# 备份单表
mysqldump -u root -p db_name table_name > table.sql

# 带压缩备份
mysqldump -u root -p db_name | gzip > db_name.sql.gz
```

### 恢复

```bash
# 恢复数据库
mysql -u root -p db_name < db_name.sql

# 恢复压缩备份
gunzip < db_name.sql.gz | mysql -u root -p db_name

# 进入 MySQL 后导入
mysql> source /path/to/backup.sql;
```

### 二进制日志恢复（时间点恢复）

```bash
# 查看 binlog 是否开启
mysql> SHOW VARIABLES LIKE 'log_bin';

# 查看 binlog 文件列表
mysql> SHOW BINARY LOGS;

# 导出 binlog
mysqlbinlog mysql-bin.000001 > binlog.sql

# 按时间点恢复
mysqlbinlog --start-datetime="2024-01-01 10:00:00" \
            --stop-datetime="2024-01-01 11:00:00" \
            mysql-bin.000001 | mysql -u root -p
```

---

## 八、事务

```sql
-- 开启事务
START TRANSACTION;
-- 或
BEGIN;

-- SQL 操作...

-- 提交
COMMIT;

-- 回滚
ROLLBACK;

-- 设置保存点
SAVEPOINT sp1;
ROLLBACK TO SAVEPOINT sp1;
RELEASE SAVEPOINT sp1;
```

### 事务隔离级别

```sql
-- 查看当前隔离级别
SELECT @@transaction_isolation;

-- 设置隔离级别
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- 全局设置
SET GLOBAL TRANSACTION ISOLATION LEVEL REPEATABLE READ;
```

| 隔离级别 | 脏读 | 不可重复读 | 幻读 |
|----------|------|------------|------|
| READ UNCOMMITTED | ✓ | ✓ | ✓ |
| READ COMMITTED | ✗ | ✓ | ✓ |
| REPEATABLE READ (默认) | ✗ | ✗ | ✓ |
| SERIALIZABLE | ✗ | ✗ | ✗ |

---

## 九、性能优化与监控

### 慢查询

```sql
-- 查看慢查询配置
SHOW VARIABLES LIKE 'slow_query%';
SHOW VARIABLES LIKE 'long_query_time';

-- 开启慢查询日志
SET GLOBAL slow_query_log = ON;
SET GLOBAL long_query_time = 2;          -- 超过 2 秒记录

-- 查看慢查询数量
SHOW GLOBAL STATUS LIKE 'Slow_queries';
```

### EXPLAIN 分析查询

```sql
EXPLAIN SELECT * FROM student WHERE name = '张三';
```

| 字段 | 说明 |
|------|------|
| `id` | 查询序号 |
| `select_type` | 查询类型（SIMPLE / SUBQUERY / DERIVED） |
| `type` | 访问类型（ALL < index < range < ref < eq_ref < const < system，越靠后越好） |
| `possible_keys` | 可能使用的索引 |
| `key` | 实际使用的索引 |
| `rows` | 预估扫描行数 |
| `Extra` | 额外信息（Using index / Using temporary / Using filesort） |

### 常用监控命令

| 命令 | 说明 |
|------|------|
| `SHOW PROCESSLIST;` | 查看当前连接和执行中的语句 |
| `SHOW FULL PROCESSLIST;` | 查看完整 SQL（不截断） |
| `KILL connection_id;` | 终止某个连接 |
| `SHOW STATUS;` | 查看服务器状态变量 |
| `SHOW VARIABLES;` | 查看配置参数 |
| `SHOW ENGINE INNODB STATUS\G` | InnoDB 引擎状态 |
| `SHOW OPEN TABLES;` | 查看打开的表 |

### 常用状态变量

| 变量 | 说明 |
|------|------|
| `Threads_connected` | 当前连接数 |
| `Threads_running` | 正在执行的线程数 |
| `Queries` | 总查询数 |
| `Innodb_buffer_pool_read_requests` | 缓冲池读请求 |
| `Innodb_buffer_pool_reads` | 磁盘读取次数 |
| `Qcache_hits` | 查询缓存命中次数 |

---

## 十、MySQL 常用函数

### 字符串函数

| 函数 | 说明 | 示例 |
|------|------|------|
| `CONCAT(s1,s2,...)` | 拼接字符串 | `CONCAT('Hello',' World')` |
| `GROUP_CONCAT(col)` | 分组拼接 | `GROUP_CONCAT(name SEPARATOR ',')` |
| `SUBSTRING(s, start, len)` | 截取子串 | `SUBSTRING('abc', 1, 2)` → `'ab'` |
| `LENGTH(s)` | 字节长度 | `LENGTH('中文')` → 6 |
| `CHAR_LENGTH(s)` | 字符长度 | `CHAR_LENGTH('中文')` → 2 |
| `REPLACE(s, old, new)` | 替换 | `REPLACE('abc','b','x')` |
| `TRIM(s)` | 去空格 | `TRIM(' abc ')` |
| `UPPER(s)` / `LOWER(s)` | 大小写转换 | `UPPER('abc')` → `'ABC'` |

### 数值函数

| 函数 | 说明 |
|------|------|
| `ROUND(x, d)` | 四舍五入保留 d 位小数 |
| `FLOOR(x)` | 向下取整 |
| `CEIL(x)` / `CEILING(x)` | 向上取整 |
| `ABS(x)` | 绝对值 |
| `MOD(x, y)` | 取余 |
| `RAND()` | 随机数 0~1 |

### 日期函数

| 函数 | 说明 |
|------|------|
| `NOW()` | 当前日期时间 |
| `CURDATE()` | 当前日期 |
| `CURTIME()` | 当前时间 |
| `DATE_FORMAT(d, fmt)` | 格式化日期 |
| `DATEDIFF(d1, d2)` | 日期差（天数） |
| `DATE_ADD(d, INTERVAL n UNIT)` | 日期加法 |
| `DATE_SUB(d, INTERVAL n UNIT)` | 日期减法 |
| `UNIX_TIMESTAMP()` | 当前 Unix 时间戳 |
| `FROM_UNIXTIME(ts)` | 时间戳转日期 |

```sql
SELECT DATE_FORMAT(NOW(), '%Y-%m-%d %H:%i:%s');  -- 2024-01-01 12:30:00
SELECT DATEDIFF('2024-12-31', '2024-01-01');     -- 365
SELECT DATE_ADD(NOW(), INTERVAL 7 DAY);           -- 7天后
```

### 条件与类型转换

| 函数 | 说明 |
|------|------|
| `IF(expr, t, f)` | 条件判断 |
| `IFNULL(val, default)` | 如果 NULL 则返回默认值 |
| `COALESCE(v1, v2, ...)` | 返回第一个非 NULL 值 |
| `CASE WHEN ... THEN ... ELSE ... END` | 多条件判断 |
| `CAST(val AS type)` | 类型转换 |
| `CONVERT(val, type)` | 类型转换 |

```sql
SELECT name, IF(score >= 60, '及格', '不及格') AS result FROM student;

SELECT name,
    CASE
        WHEN score >= 90 THEN '优秀'
        WHEN score >= 80 THEN '良好'
        WHEN score >= 60 THEN '及格'
        ELSE '不及格'
    END AS grade
FROM student;
```

---

## 十一、锁相关

### 表级锁

```sql
LOCK TABLES table_name READ;    -- 读锁（其他人可读，不可写）
LOCK TABLES table_name WRITE;   -- 写锁（其他人不可读写）
UNLOCK TABLES;                  -- 释放锁
```

### 查看锁

```sql
-- 查看当前锁等待
SELECT * FROM information_schema.INNODB_TRX;
SELECT * FROM information_schema.INNODB_LOCKS;
SELECT * FROM information_schema.INNODB_LOCK_WAITS;

-- MySQL 8.0+
SELECT * FROM performance_schema.data_locks;
SELECT * FROM performance_schema.data_lock_waits;

-- 查看锁等待超时时间
SHOW VARIABLES LIKE 'innodb_lock_wait_timeout';
```

### 死锁排查

```sql
-- 查看最近一次死锁
SHOW ENGINE INNODB STATUS\G
-- 查看 LATEST DETECTED DEADLOCK 部分
```

---

## 十二、导入导出数据

### 命令行导入导出

```bash
# 导出为 CSV
mysql -u root -p -e "SELECT * FROM db.table" > data.csv

# LOAD DATA 导入
mysql -u root -p
mysql> LOAD DATA LOCAL INFILE '/path/file.csv'
       INTO TABLE table_name
       FIELDS TERMINATED BY ','
       ENCLOSED BY '"'
       LINES TERMINATED BY '\n'
       IGNORE 1 ROWS;       -- 跳过表头
```

### SELECT INTO OUTFILE（需 FILE 权限）

```sql
SELECT * FROM student
INTO OUTFILE '/tmp/student.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
```

---

## 十三、常用系统命令

### 服务管理

```bash
# CentOS
systemctl start mysqld
systemctl stop mysqld
systemctl restart mysqld
systemctl status mysqld
systemctl enable mysqld          # 开机自启

# Ubuntu
systemctl start mysql
systemctl stop mysql
systemctl restart mysql
systemctl status mysql
systemctl enable mysql
```

### MySQL 命令行连接

```bash
# 本地连接
mysql -u root -p

# 远程连接
mysql -h 192.168.1.100 -P 3306 -u root -p

# 指定数据库连接
mysql -u root -p db_name

# 免交互执行 SQL
mysql -u root -p db_name -e "SELECT * FROM student LIMIT 5"

# 静默模式（不显示表头边框）
mysql -u root -p -N -e "SELECT name FROM student"
```

### 命令行常用参数

| 参数 | 说明 |
|------|------|
| `-h` | 主机地址 |
| `-P` | 端口（大写） |
| `-u` | 用户名 |
| `-p` | 密码（可紧跟密码：`-pPass123`） |
| `-D` | 指定数据库 |
| `-e` | 执行 SQL 语句 |
| `-N` | 不显示列名 |
| `-B` | 批处理模式（Tab 分隔） |
| `--default-character-set=utf8mb4` | 指定字符集 |

---

## 十四、存储过程与函数

### 存储过程

```sql
DELIMITER //

CREATE PROCEDURE get_students_by_age(IN min_age INT)
BEGIN
    SELECT * FROM student WHERE age >= min_age;
END //

DELIMITER ;

-- 调用
CALL get_students_by_age(20);

-- 删除
DROP PROCEDURE IF EXISTS get_students_by_age;
```

### 函数

```sql
DELIMITER //

CREATE FUNCTION get_score_level(score DECIMAL(5,2))
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE level VARCHAR(10);
    IF score >= 90 THEN SET level = '优秀';
    ELSEIF score >= 80 THEN SET level = '良好';
    ELSEIF score >= 60 THEN SET level = '及格';
    ELSE SET level = '不及格';
    END IF;
    RETURN level;
END //

DELIMITER ;

-- 调用
SELECT name, score, get_score_level(score) AS level FROM student;

-- 删除
DROP FUNCTION IF EXISTS get_score_level;
```

---

## 十五、视图

```sql
-- 创建视图
CREATE VIEW v_student_score AS
SELECT s.name, s.score, c.class_name
FROM student s
LEFT JOIN class c ON s.class_id = c.id
WHERE s.score >= 60;

-- 查询视图
SELECT * FROM v_student_score;

-- 删除视图
DROP VIEW IF EXISTS v_student_score;
```

---

## 十六、常用故障排查

| 问题 | 排查步骤 |
|------|----------|
| 连接数过多 | `SHOW PROCESSLIST;` → 排查慢查询或连接泄漏 |
| 死锁频繁 | `SHOW ENGINE INNODB STATUS\G` 查看死锁日志 |
| CPU 飙高 | `SHOW FULL PROCESSLIST;` → 找到执行中 SQL → `EXPLAIN` 分析 |
| 磁盘占满 | 检查 binlog 是否过期、是否有大表 |
| 主从延迟 | `SHOW SLAVE STATUS\G` → 看 `Seconds_Behind_Master` |
| 无法远程连接 | 检查 bind-address、防火墙、用户 host 配置 |
| 表损坏 | `CHECK TABLE t;` → `REPAIR TABLE t;` |

---

## 十七、常用配置参数

```ini
# /etc/my.cnf 或 /etc/mysql/my.cnf

[client]
default-character-set = utf8mb4

[mysql]
default-character-set = utf8mb4

[mysqld]
# 基本配置
port            = 3306
bind-address    = 0.0.0.0
datadir         = /var/lib/mysql
socket          = /var/lib/mysql/mysql.sock

# 字符集
character-set-server    = utf8mb4
collation-server        = utf8mb4_unicode_ci

# 连接数
max_connections         = 200
max_connect_errors      = 100

# InnoDB 缓冲池（建议设为物理内存的 50%~80%）
innodb_buffer_pool_size = 1G

# 日志
log_error               = /var/log/mysqld.log
slow_query_log          = 1
slow_query_log_file     = /var/log/mysql-slow.log
long_query_time         = 2

# binlog
log_bin                 = /var/lib/mysql/mysql-bin
binlog_expire_logs_days = 7

# 其他
sql_mode                = STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ENGINE_SUBSTITUTION
```

---

> **提示：** 生产环境中建议定期备份、开启慢查询日志，并通过 `EXPLAIN` 和 `SHOW PROCESSLIST` 定期检查 SQL 执行情况。
