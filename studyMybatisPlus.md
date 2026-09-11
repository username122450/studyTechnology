# MybatisPlus

## 在springBoot环境中引入mybatisPlus

引入依赖

springBoot3

```xml
<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-spring-boot3-starter</artifactId>
    <version>3.5.17</version>
</dependency>
```

Spring Boot4 (自3.5.13开始)

```xml
<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-spring-boot4-starter</artifactId>
    <version>3.5.17</version>
</dependency>
```



配置连接信息

```yml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/mavenstart?severTimezone=Asia/Shanghai
    username: admin
    password: admin123
```

用Lombok快速构建实体类

```java
//pojo.User.java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    private String id;
    private String name;
    private String password;
    private double money;
}
```

用持久层接口实现BeanMapper搭建简单CRUD操作

```java
//mapper.UserMapper.java
public interface UserMapper extends BaseMapper<User> {
}
```

注意要在启动类上面加上对mapper的包扫描

```java
//MybatisPlusStartApplication.java
@SpringBootApplication
@MapperScan("com.springboot.mybatisplus_start.mapper")
public class MybatisPlusStartApplication {
    public static void main(String[] args) {
        SpringApplication.run(MybatisPlusStartApplication.class, args);
    }

}
```



## CRUD操作

### insert

```java
@Test
public void testInsert(){
    User user = new User(null, "张三", 23, "zhangsan@qq.com");
    //INSERT INTO user ( id, name, age, email ) VALUES ( ?, ?, ?, ? )
    int result = userMapper.insert(user);
    System.out.println("受影响行数："+result);
    //1778676561893969922
    System.out.println("id自动获取："+user.getId());
}
```

返回值是一个int类型数据

### delete

deleteBatchIds: 根据id批量删除

```java
@Test
public void testDeleteBatchIds(){
    //通过多个id批量删除
    //DELETE FROM user WHERE id IN ( ? , ? , ? )
    List<Long> idList = Arrays.asList(1L, 2L, 3L);
    int result = userMapper.deleteBatchIds(idList);
    System.out.println("受影响行数："+result);
}
```

deleteByMap: 将条件写入Map,根据map条件匹配删除

```java
@Test
public void testDeleteByMap(){
    //根据map集合中所设置的条件删除记录
    //DELETE FROM user WHERE name = ? AND age = ?
    Map<String, Object> map = new HashMap<>();
    map.put("age", 23);
    map.put("name", "张三");
    int result = userMapper.deleteByMap(map);
    System.out.println("受影响行数："+result);
}
```



### update

updateById:根据id更新

```java
@Test
public void testUpdateById(){
    User user = new User(4L, "admin", 22, null);
    //UPDATE user SET name=?, age=? WHERE id=?
    int result = userMapper.updateById(user);
    System.out.println("受影响行数："+result);
}
```

update:根据条件进行更新

```java
@Test
public void testUpdateUser1(){
    User user = new User();
    user.setAge(22); //更新的字段
    user.setEmail("admin@qq.com");
    //更新的条件
    QueryWrapper<User> wrapper = new QueryWrapper<>();
    wrapper.eq("id", 4L);
    //执行更新操作 UPDATE user SET age=?, email=? WHERE (id = ?)
    int result = this.userMapper.update(user, wrapper);
    System.out.println("受影响行数：" + result);
}
```

或者

```java
@Test
public void testUpdate2() {
    //更新的条件以及字段
    UpdateWrapper<User> wrapper = new UpdateWrapper<>();
    wrapper.eq("id", 4L).set("age", 28).set("email","admin@163.com");
    //执行更新操作 UPDATE user SET age=?,email=? WHERE (id = ?)
    int result = this.userMapper.update(null, wrapper);
    System.out.println("受影响行数：" + result);
}
```



### select

selectBatchIds: 根据id批量查询用户

```java
@Test
public void testSelectBatchIds(){
    //根据多个id查询多个用户信息
    //SELECT id,name,age,email FROM user WHERE id IN ( ? , ? )
    List<Long> idList = Arrays.asList(4L, 5L);
    List<User> list = userMapper.selectBatchIds(idList);
    list.forEach(System.out::println);
}
```

selectByMap: 将条件写入Map,根据map条件匹配查询

```java
@Test
public void testSelectByMap(){
    //通过map条件查询用户信息
    //SELECT id,name,age,email FROM user WHERE name = ? AND age = ?
    Map<String, Object> map = new HashMap<>();
    map.put("age", 20);
    map.put("name", "Jack");
    List<User> list = userMapper.selectByMap(map);
    list.forEach(System.out::println);
}
```

selectList: 查询所有记录，前提是selectList方法中的条件为null

```java
@Test
public void testSelectList(){
    //查询所有用户信息
    //SELECT id,name,age,email FROM user
    List<User> list = userMapper.selectList(null);
    list.forEach(System.out::println);
}
```





## 通用Service

### IRepository

IRepository是一个接口类,它对通用CRUD进行了封装

- `get`表示查询
- `remove`表示删除
- `update`表示更新
- `list`表示查询集合
- `save`表示保存
- `count`表示计数
- `page`表示分页

### CrudRepository

而CrudRepository是一个abstract类,提供了IRepository中基础功能的实现

(关于IService和ServiceImpl分别是对IRepository类和CrudRepository类的继承和实现)

### 使用

```java
/**
* UserService继承IRepository模板提供的基础功能
*/
public interface UserService extends IRepository<User> {
}
```

```java
/**
* 若CrudRepository无法满足业务需求，则可以使用自定的UserService定义方法，并在实现类中实现
*/
@Service
public class UserServiceImpl 
    extends CrudRepository<UserMapper, User> 
    implements UserService {
}
```



## mybatisPlus常用注解

### @TableName

mybatis在确定操作的表时，由实体类型决定，且默认操作的表名和实体类型的类名一致.

在实体类上加上TableName注解就可以解决表名与实体类名不一致的问题

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("tb_user")
public class User {
    private Long id;
    private String name;
    private Integer age;
    private String email;
}
```

还可以通过配置解决这个问题:

```yml
# 配置MyBatis日志
mybatis-plus:
    configuration:
        log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
    global-config:
    	db-config:
    		# 配置MyBatis-Plus操作表的默认前缀
    		table-prefix: tb_
```



### @TableId

将字段标注为主键,mybatisPlus默认主键字段为id,可以解决数据表主键字段不是id的问题

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @TableId 
    // 使用@TableId注解手动将插入数据的主键设置为uid
    private Long uid;
    private String name;
    private Integer age;
    private String email;
}
```

#### valud属性

解决数据表数据表主键字段与实体类字段不一致的问题

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @TableId(value = "uid") //如果前后字段不一致,可以添加@TableId注解,通过value属性指定
    uid的值
    private Long id;
    private String name;
    private Integer age;
    private String email;
}
```

#### type属性

mybatisPlus主键生成策略默认是基于雪花算法生成

type属性可以自定义主键生成策略

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @TableId(value = "uid",type = IdType.AUTO)
    //type属性是一个IdType枚举类型的值,IdType.AUTO是自增长
    private Long id;
    private String name;
    private Integer age;
    private String email;
}
```

还可以通过配置定义其他策略

```yml
# 配置MyBatis日志
mybatis-plus:
    configuration:
    	log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
    global-config:
        db-config:
        # 配置MyBatis-Plus操作表的默认前缀
            table-prefix: tb_
        	# 配置MyBatis-Plus的主键策略为自增长
        	id-type: auto
```

#### IdType

IdType的枚举值

|     值      |                             描述                             |
| :---------: | :----------------------------------------------------------: |
|    AUTO     | 数据库 ID自增，这种情况下将表中主键设置为自增，否则，没有设置主动设置 |
|    NONE     | 无状态，该类型为未设置主键类型（注解里等于跟随全局，全局里默认ASSIGN_ID） |
|    INPUT    | insert 前自行 set 主键值，在采用IKeyGenerator类型的ID生成器时必须为INPUT |
|  ASSIGN_ID  | 分配 ID(主键类型为 Number(Long 和 Integer)或 String)(since 3.3.0),使用接口IdentifierGenerator的方法nextId(默认实现类为DefaultIdentifierGenerator雪花算法) |
| ASSIGN_UUID | 分配 UUID,主键类型为 String(since 3.3.0),使用接口IdentifierGenerator的方法nextUUID(默认 default 方法) |

### @TableField

若实体类中的属性使用的是驼峰命名风格，而表中的字段使用的是下划线命名风格。例如实体类属性

userName，表中字段user_name,MybatisPlus自动将下划线命名风格转化为驼峰命名风格。

若实体类中的属性和表中的字段不满足以上情况,可以用@TableField手动映射

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @TableId(value = "uid")
    private Long id;
    @TableField("name") // 前后字段不一致,需要手动进行映射
    private String userName;
    private Integer age;
    private String email;
}
```

### @TableLogic

对数据表中记录删除有两种。一种是物理删除，还有一种就是逻辑删除。

@TableLogic就是逻辑删除

需要在数据表中添加逻辑删除字段,在实体表中加入对应的字段

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @TableId(value = "uid")
    private Long id;
    @TableField("name")
    private String userName;
    private Integer age;
    private String email;
    @TableLogic // 逻辑删除的字段
    private Integer isDeleted;
}
```



## 雪花算法

是分布式主键生成算法，它能够保证不同表的主键的不重复性，以及相同表的主键的有序性

### 核心思想

长度共64bit（一个long型）。 首先是一个符号位，1bit标识，由于long基本类型在Java中是带符号

的，最高位是符号位，正数是0，负 数是1，所以id一般是正数，最高位是0。

41bit时间截(毫秒级)，存储的是时间截的差值（当前时间截 - 开始时间截)，结果约等于69.73年。

10bit作为机器的ID（5个bit是数据中心，5个bit的机器ID，可以部署在1024个节点）。

12bit作为毫秒内的流水号（意味着每个节点在每毫秒可以产生 4096 个 ID）。

### 优点

整体上按照时间自增排序，并且整个分布式系统内不会产生ID碰撞，并且效率较高。





## 条件构造器和常用接口

### QueryWrapper

#### 组装查询条件

```java
@Test
public void test01(){
//查询用户名包含a，年龄在20到30之间，并且邮箱不为null的用户信息
// SELECT id,username AS name,age,email,is_deleted FROM t_user WHERE
// is_deleted=0 AND (username LIKE ? AND age BETWEEN ? AND ? AND email IS NOT NULL)
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.like("username", "a").
        between("age", 20, 30).
        isNotNull("email");
    List<User> list = userMapper.selectList(queryWrapper);
    list.forEach(System.out::println);
}
```

#### 组装排序条件

```java
@Test
public void test02(){
// 按年龄降序查询用户，如果年龄相同则按id升序排列
// SELECT id,username AS name,age,email,is_deleted FROM t_user WHERE
// is_deleted=0 ORDER BY age DESC,id ASC
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.orderByDesc("age")
        .orderByAsc("id");
    List<User> users = userMapper.selectList(queryWrapper);
    users.forEach(System.out::println);
}
```

#### 组装删除条件

```java
@Test
public void test03(){
    //删除email为空的用户
    //DELETE FROM t_user WHERE (email IS NULL)
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.isNull("email");
    //条件构造器也可以构建删除语句的条件
    int result = userMapper.delete(queryWrapper);
    System.out.println("受影响的行数：" + result);
}
```

#### 组装更新条件

```java
@Test
public void test04() {
QueryWrapper<User> queryWrapper = new QueryWrapper<>();
// 将（年龄大于20并且用户名中包含有a）或邮箱为null的用户信息修改
// UPDATE t_user SET age=?, email=? WHERE (username LIKE ? AND age > ? ORemail IS NULL)
    queryWrapper.like("username", "a").
        gt("age", 20).
        or().isNull("email");
    User user = new User();
    user.setAge(38);
    user.setEmail("kobe@qq.com");
    int result = userMapper.update(user, queryWrapper);
	System.out.println("受影响的行数：" + result);
}
```

#### 优先级

```java
@Test
public void test04() {
QueryWrapper<User> queryWrapper = new QueryWrapper<>();
//将用户名中包含有a并且（年龄大于20或邮箱为null）的用户信息修改
//UPDATE t_user SET age=?, email=? WHERE (username LIKE ? AND (age > ? ORemail IS NULL))
//lambda表达式内的逻辑优先运算
    queryWrapper.like("username", "a").
        and(i -> i.gt("age", 20).or().isNull("email"));
    User user = new User();
    user.setAge(18);
    user.setEmail("oscar@163.com");
    int result = userMapper.update(user, queryWrapper);
    System.out.println("受影响的行数：" + result);
}
```

#### 组装select子句

```java
@Test
public void test05() {
// 查询用户信息的username和age字段
// SELECT username,age FROM t_user
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.select("username", "age");
    List<Map<String, Object>> maps = userMapper.selectMaps(queryWrapper);
    maps.forEach(System.out::println);
}
```

子查询

```java
@Test
public void test06() {
//查询id小于等于3的用户信息
//SELECT id,username AS name,age,email,is_deleted FROM t_user WHERE (idIN(select id from t_user where id <= 3))
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    queryWrapper.inSql("id", "select id from t_user where id <= 3");
    List<User> list = userMapper.selectList(queryWrapper);
    list.forEach(System.out::println);
}
```

### UpdateWrapper

与QueryWrapper的组装更新条件相同

```java
@Test
public void test07() {
    // 将（年龄大于20或邮箱为null）并且用户名中包含有a的用户信息修改
    // 组装set子句以及修改条件
    UpdateWrapper<User> updateWrapper = new UpdateWrapper<>();
    // lambda表达式内的逻辑优先运算
    updateWrapper.set("age", 18).
        set("email", "user@qq.com").
        like("username", "a").
        and(i -> i.gt("age", 20).or().isNull("email"));
    // 这里必须要创建User对象，否则无法应用自动填充。如果没有自动填充，可以设置为null
    // UPDATE t_user SET username=?, age=?,email=? WHERE 
    //(username LIKE ? AND(age > ? OR email IS NULL))
    
    // User user = new User();
    // user.setName("张三");
    // int result = userMapper.update(user, updateWrapper);
    // UPDATE t_user SET age=?,email=? WHERE 
    //(username LIKE ? AND (age > ? ORemail IS NULL))
    
    int result = userMapper.update(null, updateWrapper);
    System.out.println(result);
}
```

### Condition

```java
@Test
public void test08UseCondition() {
    // 定义查询条件，有可能为null（用户未输入或未选择）
    String username = null;
    Integer ageBegin = 10;
    Integer ageEnd = 24;
    QueryWrapper<User> queryWrapper = new QueryWrapper<>();
    // StringUtils.isNotBlank()判断某字符串是否不为空且长度不为0
    //且不由空白(whitespace)构成
    queryWrapper.like(StringUtils.isNotBlank(username), "username", "a").
        ge(ageBegin != null, "age", ageBegin).
        le(ageEnd != null, "age", ageEnd);
    // SELECT id,username AS name,age,email,is_deleted 
    //FROM t_user WHERE (age >=? AND age <= ?)
    List<User> users = userMapper.selectList(queryWrapper);
    users.forEach(System.out::println);
}
```

### LambdaQueryWrapper

```java
@Test
public void test09() {
    // 定义查询条件，有可能为null（用户未输入）
    String username = "a";
    Integer ageBegin = 10;
    Integer ageEnd = 24;
    LambdaQueryWrapper<User> queryWrapper = new LambdaQueryWrapper<>();
    // 避免使用字符串表示字段，防止运行时错误
    queryWrapper.
        like(StringUtils.isNotBlank(username), User::getName, username).
        ge(ageBegin != null, User::getAge, ageBegin).
        le(ageEnd != null, User::getAge, ageEnd);
    List<User> users = userMapper.selectList(queryWrapper);
    users.forEach(System.out::println);
}
```

### LambdaQueryWrapper

```java
@Test
public void test10() {
// 组装set子句
    LambdaUpdateWrapper<User> updateWrapper = new LambdaUpdateWrapper<>();
    updateWrapper.set(User::getAge, 18).
        set(User::getEmail, "user@atguigu.com").
        like(User::getName, "a").
        and(i -> i.lt(User::getAge, 24).or().isNull(User::getEmail));
    User user = new User();
    int result = userMapper.update(user, updateWrapper);
    System.out.println("受影响的行数：" + result);
}
```

## 插件

### 分页插件

#### 配置类实现分页插件

```java
@Configuration
public class MybatisPlusConfig {
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        return interceptor;
    }
}
```

使用

```java
@Test
public void testPage(){
    //设置分页参数
    Page<User> page = new Page<>(1, 5);
    userMapper.selectPage(page, null);
    //获取分页数据
    List<User> list = page.getRecords();
    list.forEach(System.out::println);
    System.out.println("当前页："+page.getCurrent());
    System.out.println("每页显示的条数："+page.getSize());
    System.out.println("总记录数："+page.getTotal());
    System.out.println("总页数："+page.getPages());
    System.out.println("是否有上一页："+page.hasPrevious());
    System.out.println("是否有下一页："+page.hasNext());
}
```

#### xml自定义分页

```java
public interface UserMapper extends BaseMapper<User> {
/**
* 根据年龄查询用户列表，分页显示
* @param page 分页对象,xml中可以从里面进行取值,传递参数 Page 即自动分页,必须放在第一
位
* @param age 年龄
* @return
*/
    Page<User> selectPageVo(@Param("page") Page<User> page, @Param("age")
    Integer age);
}
```

实现

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.xq.mapper.UserMapper">
<!--SQL片段，记录基础字段-->
<sql id="BaseColumns">uid,name,age,email</sql>
    <!--IPage<User> selectPageVo(Page<User> page, Integer age);-->
<select id="selectPageVo" resultType="com.xq.pojo.User">
SELECT 
    <include refid="BaseColumns"></include> 
    FROM tb_user WHERE age > #{age}
</select>
</mapper>
```

### 乐观锁插件

引入插件

```java
@Configuration
public class MybatisPlusConfig {
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        interceptor.addInnerInterceptor(new OptimisticLockerInnerInterceptor());//乐观锁插件
        return interceptor;
    }
}
```





## 通用枚举

### 使用

```java
public enum SexEnum {
    Male(1,"男"),
    FeMale(2,"女");
    @EnumValue
    private Integer sex;
    private String sexName;

    SexEnum(Integer sex, String sexName) {
        this.sex = sex;
        this.sexName = sexName;
    }
}
```

修改实体类字段

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
@TableName("transfer")
public class User {
    @TableId()
    private String id;
    private String name;
    private double money;
    private String password;
    private SexEnum sex;
}

```

### 配置扫描通用枚举

```yml
mybatis-plus:
  type-enums-package: com.springboot.mybatisplus_start.pojo
```

测试

```java
@Test
public void testSexEnum(){
User user = new User();
user.setUserName("Enum");
user.setAge(20);
// 设置性别信息为枚举项，会将@EnumValue注解所标识的属性值存储到数据库
user.setSex(SexEnum.MALE);
// INSERT INTO t_user ( username, age, sex ) VALUES ( ?, ?, ? )
// Parameters: Enum(String), 20(Integer), 1(Integer)
userMapper.insert(user);
}
```



## AR模式

Active Record(活动记录)，是一种领域模型模式，特点是一个模型类对应关系型数据库中的一个表，而

模型类的一个实例对应表中的一行记录。

在Active Record模式中，对象中``既有持久存储的数据，也有针对数据的操作``，Active Record模式把数

据增删改查的逻辑作为对象的一部分，处理对象的用户知道如何读写数据，提升了开发效率。

其实底层仍然使用的是Mapper层在完成数据库操作。只不过由我们自己调用Mapper对象操作数据库，

变成了通过实体类对象来调用Mapper完成数据库操作。从代码的物理视图上我们是看不到实体类调用

Mapper的过程的。也就说，本质上仍然是Mapper层在操作数据库实体类型操作数据掩盖了底层的

mapper的方法的调用。

### 使用

```java
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Department extends Model<Department> {
    private Integer id;
    private String deptName;
    private String location;
}
```

继承Model类 `com.baomidou.mybatisplus.spring.activerecord.Model`

测试

```java
@SpringBootTest
public class ActiveRecordTest {
    //新增操作
    @Test
    public void test01(){
        Department department = new Department();
        department.setDeptName("人事部");
        department.setLocation("武汉");
        boolean result = department.insert();
        System.out.println("插入的结果是:" + result);
    }
    //查询操作
    @Test
    public void test02(){
        Department department = new Department();
        List<Department> departmentList = department.selectAll();
        departmentList.forEach(System.out::println);
    }
    //修改操作
    @Test
    public void test03(){
        Department department = new Department();
        department.setId(3);
        department.setLocation("南京");
        department.updateById();
    }
    //删除操作
    @Test
    public void test04(){
        Department department = new Department();
        department.deleteById(4);
    }
    //根据条件查询
    @Test
    public void test05(){
        Department department = new Department();
        QueryWrapper<Department> userQueryWrapper = new QueryWrapper<>();
        userQueryWrapper.eq("location","上海");
        List<Department> departmentList =
        department.selectList(userQueryWrapper);
        departmentList.forEach(System.out::println);
    }
}
```



### 注意

使用AR模式还是需要用mapper接口继承BeanMapper,AR模式底层仍是调用mapper





## 代码生成器

### 引入依赖

```java
<!--代码生成器-->
<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-generator</artifactId>
    <version>3.5.17</version>
</dependency>

<dependency>
    <groupId>org.freemarker</groupId>
    <artifactId>freemarker</artifactId>
    <version>2.3.31</version>
</dependency>
    
```

生成

```java
public static void main(String[] args) {
    FastAutoGenerator.create("url", "username", "password")
        .globalConfig(builder -> {
            builder.author("baomidou") // 设置作者
                .enableSwagger() // 开启 swagger 模式
                .outputDir("D://"); // 指定输出目录
        })
        .dataSourceConfig(builder ->
                          builder.typeConvertHandler((globalConfig, typeRegistry, metaInfo) -> {
                              int typeCode = metaInfo.getJdbcType().TYPE_CODE;
                              if (typeCode == Types.SMALLINT) {
                                  // 自定义类型转换
                                  return DbColumnType.INTEGER;
                              }
                          return typeRegistry.getColumnType(metaInfo);
                    })
            )
        .packageConfig(builder ->
                builder.parent("com.baomidou.mybatisplus.samples.generator") // 设置父包名
                        .moduleName("system") // 设置父包模块名
                        .pathInfo(Collections.singletonMap(OutputFile.xml, "D://")) // 设置mapperXml生成路径
            )
        .strategyConfig(builder ->
                builder.addInclude("t_simple") // 设置需要生成的表名
                        .addTablePrefix("t_", "c_") // 设置过滤表前缀
        )
        .templateEngine(new FreemarkerTemplateEngine()) // 使用Freemarker引擎模板，默认的是Velocity引擎模板
        .execute();
}
```

