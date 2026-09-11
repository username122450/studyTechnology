# SpringBoot基础

## lombok插件

依赖导入

```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
</dependency>
```

用法:  

```java
@Data //完成get,set,toString方法

@NoArgsConstructor //完成无参数的构造函数

@AllArgsConstructor //完成定义所有参数的构造函数

```



### 日志注解

``` java
@Slf4j //开启对日志的支持
```

必须在Lombok环境下使用

``` java	
log.trace("追踪日志"); //最细粒度跟踪，生产环境关闭
log.debug("调试日志"); //开发调试信息
log.info("普通日志:{}",name); //业务正常操作记录（默认打印级别）
log.warn("警告日志"); //不影响流程的异常警告
log.error("异常日志", new RuntimeException("出错了")); //程序异常、错误

```





##  热部署插件

依赖引入

``` xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-devtools</artifactId>
	<optional>true</optional>
</dependency>
```

插件引入

``` xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
        <!--<fork>true</fork>在SpringBoot2.4以下可用-->
        <addResources>true</addResources>
    </configuration>
</plugin>
```

用法: 

File → Settings → Build → Compiler：勾选 `Build project automatically`

同页面点击右侧 `Advanced Settings`:勾选：`Allow auto-make to start even if developed application is currently running`

完成配置后,每次修改只需要`ctrl`+`F9`就可以重构项目





## yml文件书写

基本格式: `key`:(空格)`value`

定义对象的方法:

1. ``` yml
    animal1: 
    	name: dahuang
    	age: 2
    ```

2. ``` yml
    animal2: {name: xiaohuang,age: 1}
    ```

定义数组的方法:

1. ``` yml
    pets1:
    - cat
    - dog
    - fish
    ```

2. ``` yml
    pets2: [cat,dog,fish]
    ```

定义map集合的方法:

``` yml
map1: {k1: v1,k2: v2}
```





## 配置文件自动提示

导入依赖

``` xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-configuration-processor</artifactId>
    <optional>true</optional>
</dependency>
```







# SpringBootWeb

## 静态资源映射规则

静态资源可以存放在`/static`,`/resources`,`/public`,`/MATE-INF/resources`

目录下  

访问静态资源的路径是`根目录+资源名`如`/a.html`

如果与动态资源同名,优先加载动态资源



### 自定义映射规则(前缀匹配)

```yml
spring:
  mvc:
    static-path-pattern: /xxx/**
```

自定义静态资源映射规则后,静态资源的访问路径前都要加上`/xxx`才能访问



### 自定义存放规则

```yml
spring:
  web:
    resources:
      static-locations: [/xxx]
```

可以在[]内写入自定义路径,这些路径存放的静态资源可以被spring识别





## 欢迎页index.html与图标设置

### 欢迎页

将完成的index.html页面放入`/static`文件夹下,就可以在localhost:8080直接访问到欢迎页



### 图标设置

将图标文件设置为`favicon.ico`,将文件放在`/static`下,就可以重建为网页图标





## rest请求

springBoot的rest请求是需要通过一个过滤器(OrderdHiddenHttpMethodFilter)来处理的,但这个过滤器默认是不开启的

### 开启过滤器

``` yml
spring: 
	mvc:
		hiddenmethod:
			filter:
				enable: true
```

开启后,在前端页面中使用rest请求,但前端method只有两个值`get`和`post`,所以使用rest请求,我们需要在前端表单中添加一个隐藏参数:

``` html
<input type="hidden" name="_method" value="put"/>
```

这里的value就可以设置为get,post,put,delete等,到这里就可以被springboot识别,进入过滤器



### 简写标签

而在springboot的controller中,原本方法的标签应该这样写:

```java
@RequestMapping(value="/user",method=REQUESTMETHOD.POST)
```

在进行完上述操作后,这里可以简写为

```java
@GetMapping("/user")

@PostMapping("/user")

@PutMapping("/user")

@DeleteMapping("/user")
```





## SpringBoot常用参数注解

### @PathVariable

通过 @PathVariable 可以将 URL 中占位符参数绑定到控制器处理方法的入

参中：URL 中的www.xxx.com/user/{xxx}/num/{bbb} 占位符可以通过

@PathVariable(“xxx“)。

```java	
@RequestMapping("/aa/{userId}/mm/{num}")
public String testPathVariable(@PathVariable("userId") String userId,
                               @PathVariable("num") Integer num){
    sout(userId+" "+num);
    return "hello";
}
```

发送请求：http://localhost:8080/aa/789/mm/333

如果占位符名和参数名相同,可以省略@PathVariable的参数,如同

``` java	
@PathVariable String userId, @PathVariable Integer num
```



### @RequestParam

用户在前端拼接参数例如：key=value1&key2=value2参数列表。通过注解

@RequestParam可以将URL中的参数绑定到处理函数方法的变量中。

``` java
@RequestMapping("aa")
public String testRequestParam(@RequestParam String uu,
                               @RequestParam("user")String userID,
                               @RequestParam("num") String num){
	return uu + "--" + userID + "--" + num;
}
```

@RequestParam中的参数required默认为true

@RequestParam中的参数defaultValue设置默认值

发送请求:http://localhost:8080/aa?uu=22&user=44&num=55

有的时候匹配的参数没有，则需要进一步处理http://localhost:8088/aa?uu=22&user=44。缺少了参数num。如果不进行处理，则会后台报错。



### @RequestBody

在同步的状态下，接收前台表单提交的实体内容。

定义表单

``` html
<form action="getData" method="post">
    <input type="text" name="username"> <br>
    <input type="password" name="password"><br>
    <input type="submit" value="提交"/>
</form>
```

定义控制器方法

```java
@RequestMapping("getData")
public String getData(@RequestBody String data){
	return data;
}
```

得到的实例内容是:

`username=admin&password=admin`

@RequestBody中的参数required,默认为true



### @CookieValue

获取指定的cookie信息的值

定义控制器方法

``` java
@RequestMapping("getCookie")
public String getCookie(@CookieValue("Idea-10501acc")String cookie){
	return cookie;
}
```



@RequestHeader

获取指定请求头相关信息

定义控制器方法

```java
@RequestMapping("getHeader")
public String getHeader(@RequestHeader("Accept-Encoding")String header){
	return header;
}
```



###  @RequestAttribute

用来标注在接口的参数上，参数的值来源于 request 作用域。

我们使用test1转发，并在request作用域里面存储值。在test2里面的形式

参数里面获取的就是test1方法存储在Request作用域的值

```java
@Controller
public class ParamController {
    @RequestMapping("/demo1/test1")
    public String test1(HttpServletRequest request) {
        request.setAttribute("site", "hello,springboot");
        return "forward:/demo1/test2";
    }

    @RequestMapping(value = "/demo1/test2")
    @ResponseBody
    public String test2(@RequestAttribute("site") String site) {
        return site;
    }
}
```

注意：上面的是@Controller注解，千万不能写成@RestController。

### @Matrixvariable

我们的请求风格有三种方式：

- queryString请求方式(？拼接的方式)： /request?username=admin&password=123456&age=20

- rest风格请求：/request/admin/123456/20

- 矩阵变量请求风格：/request/path;username=admin;password=123456;age=20,21,22

定义控制器方法

```java
@RequestMapping("/test/{param}")
public String testMatrixVariable(
    @MatrixVariable(pathVar = "param",value ="color")String[] colors,
    @MatrixVariable(pathVar = "param",value = "car")String[] cars) {
    for(String color : colors) {
        System.out.println(color);
    }
    for(String car : cars) {
        System.out.println(car);
    }
    return "aaa";
}
```

这里需要注意矩阵变量的请求风格

你需要提供一个路径段作为 `{param}` 的值，比如：

`/test/abc;color=red,green,blue;car=benchi,baoma,xiaomi`


这里 `abc` 就是 `param` 的值，`color` 和 `car` 附着在这个路径变量上



## thymeleaf

为解决在springboot中不支持jsp,我们需要引入第三方模板引擎技术实现页面渲染,进行视图跳转(重定向、

转发)

引入启动器

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
```





## 拦截器

定义拦截器

```java
//interceptor.LoginInterceptor.java
public class LoginInterceptor implements HandlerInterceptor {
    @Override
    //前置拦截器
    public boolean preHandle(HttpServletRequest request, 
                             HttpServletResponse response, 
                             Object handler) throws Exception {
        if(request.getSession().getAttribute("loginUser")==null){
            request.setAttribute("msg","请先登录");
            request.getRequestDispatcher("/").forward(request, response);
            return false;
        }
        return true;
    }
}
```

注册拦截器(config/LoginConfig)

```java
//config.LoginConfig.java
@Configuration
public class LoginConfig implements WebMvcConfigurer {
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new LoginInterceptor())
                .addPathPatterns("/**")
            .excludePathPatterns("/login","/","/css/**",
                                 "/js/**","/fonts/**","/images/**");
        
    }
}
```



## 文件上传

定义文件上传页面控制器

```java
@GetMapping("/form_layouts")
public String form_layouts() {
    return "form/form_layouts";
}
```

定义文件上传后台服务接口与实现

```java
//service.FileService.java
public interface FileService {

    void FileUpload(String email,
                         String username,
                         MultipartFile headerImg,
                         MultipartFile[] photos) throws IOException;
}

//service.impl.FileServiceImpl.java
@Service
public class FileServiceImpl implements FileService {
    @Override
    public void FileUpload(String email,
                           String username,
                           MultipartFile headerImg,
                           MultipartFile[] photos) throws IOException {
        System.out.println(email+" "+username);
        String fileName;
        if (!headerImg.isEmpty()) {
            fileName = headerImg.getOriginalFilename();
            headerImg.transferTo(new File("D:\\images\\headerImgs\\"+fileName));
        }

        if (photos.length >=1) {
            for (MultipartFile photo : photos) {
                fileName = photo.getOriginalFilename();
                photo.transferTo(new File("D:\\images\\photos\\"+fileName));
            }
        }
    }
}

```

定义文件上传后台控制器

```java
@PostMapping("/upload")
public String upload(String email,
                     String username,
                     MultipartFile headerImg,
                     MultipartFile[] photos) throws IOException {
    fileService.FileUpload(email, username, headerImg, photos);
    return "redirect:/form_layouts";

}
```



## 默认异常处理机制

在thymeleaf环境下,将异常处理页面html定义在templates/error目录下,如

- templates
    - error
        - 4xx.html
        - 5xx.html
        - error.html



## 原生web组件

### @ServletRegistrationBean

定义原生webServlet方法

```java
//servlet.MainServlet
@WebServlet("/main")
public class MainServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, 
                         HttpServletResponse resp) 
        throws ServletException, IOException {
        req.getRequestDispatcher("main.html").forward(req, resp);
    }
}
```

注册原生servlet组件一一**ServletRegistrationBean**

```java
@Configuration
public class LoginConfig implements WebMvcConfigurer {

    @Bean
    public ServletRegistrationBean mainRegisterServlet() {
        ServletRegistrationBean registrationBean =
                new ServletRegistrationBean(new MainServlet(), "/main");
        return registrationBean;
    }

}
```



### @FilterRegistrationBean

定义原生Filter方法

这里Filter是jakarta.servlet.Filter,不是javax.servlet.Filter,javax包在springboot4.x后被弃用

```java
public class MyFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request,
                         ServletResponse response, FilterChain filterChain) throws
            IOException, ServletException {
        System.out.println("Filter执行了.....");
        filterChain.doFilter(request, response);
    }
}
```

注册原生Filter组件一一**FilterRegistrationBean**

```java
@Configuration
public class LoginConfig implements WebMvcConfigurer {

    @Bean
    public FilterRegistrationBean filterRegistrationBean() {
        FilterRegistrationBean registrationBean = new FilterRegistrationBean();
        registrationBean.setFilter(new MyFilter());
        registrationBean.addUrlPatterns("/filter");
        return registrationBean;
    }

}
```



### @ServletListenerRegistrationBean

定义原生Listener方法

```java
public class MyListener implements ServletContextListener
{
    //监听SerlvetContext对象的创建
    @Override
    /*使用ServletListenerRegistrationBean 注册监听器组件测试
    当启动springboot项目，监听器的监听servlet上下文对象的方法执行了：
    当销毁spring容器的时候，监听器销毁servlet上下文对象的方法执行了:*/
    public void contextInitialized(ServletContextEvent sce) {
    	System.out.println("ServletContext对象创建了.....");
    }
    //监听SerlvetContext对象的销毁
    @Override
    public void contextDestroyed(ServletContextEvent sce)
    {
        System.out.println("ServletContext对象销毁了.....");
    }
}
```

注册原生Listener组件一一**ServletListenerRegistrationBean**

```java
//注册Listener组件
@Bean
public ServletListenerRegistrationBean servletListenerRegistrationBean(){
	ServletListenerRegistrationBean<MyListener> registrationBean 
        = new ServletListenerRegistrationBean<> (new MyListener());
return registrationBean;
}
```



# SpringBoot整合数据持久层

## 整合jdbc

引入启动器

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jdbc</artifactId>
</dependency>
```

jdbc启动器默认不会引入数据库驱动

引入MySQL驱动

```xml
<dependency>
    <groupId>com.mysql</groupId>
    <artifactId>mysql-connector-j</artifactId>
</dependency>
```



## 整合druid数据源

引入启动器

```xml
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>druid-spring-boot-starter</artifactId>
    <version>1.2.18</version>
</dependency>
```

可选对druid配置

```properties
#配置数据源类型
spring.datasource.type=com.alibaba.druid.pool.DruidDataSource
#配置数据库用户名
spring.datasource.username=root
#配置数据库密码
spring.datasource.password=root123
#配置连接数据库的url
spring.datasource.url=jdbc:mysql://localhost:3306/mavenstart?serverTimezone=Asia/Shanghai
#配置驱动类
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
# 监控SpringBean
spring.datasource.druid.aop-patterns=com.example.*
# 开启stat（sql监控），wall（防火墙）
spring.datasource.druid.filters=stat,wall
# 配置监控页功能
spring.datasource.druid.stat-view-servlet.enabled=true
spring.datasource.druid.stat-view-servlet.login.username=admin
spring.datasource.druid.stat-view-servlet.login.password=admin
# 开启监控web
spring.datasource.druid.web-stat-filter.enabled=true
spring.datasource.druid.web-stat-filter.url-pattern=/*
spring.datasource.druid.web-stat.filter.exclusions='*.js,*.gif,*.jpg,*.png,*.css,*.ico,/druid/*'
# 对sql监控 防火墙的详细配置
spring.datasource.druid.filter.stat.enabled=true
spring.datasource.druid.filter.stat.slow-sql-millis=1000
spring.datasource.druid.filter.stat.log-slow-sql=true
spring.datasource.druid.filter.wall.enabled=true
spring.datasource.druid.filter.wall.config.delete.allow=false
```



## 整合mybatis

引入启动器

```xml
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>2.1.4</version>
</dependency>
```

定义mybaits核心配置类

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
"http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
</configuration>
```

在application.properties中定义mybatis配置文件

```properties
# 引入mybatis的核心配置文件
mybatis.config-location=classpath:mybatis/sqlMapConfig.xml
# 引入mybatis的mapper映射文件
mybatis.mapper-locations=classpath:mybatis/mapper/*.xml
```



# SpringBoot整合junit

## 引入junit5依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

## junit5常用注解

### @SpringBootTest

代替原生spring中的RunWith注解等麻烦的注解

### @DisplayName 

为测试类或者测试方法设置展示名称

```java
@DisplayName("junit5单元测试")
@SpringBootTest(classes = App.class)
public class TestJunit5 {
    @DisplayName("test01方法")
    @Test
    public void test01(){
    	System.out.println("这是test01方法");
}
}
```



### @BeforeEach

表示在每个单元测试之前执行

```java
@DisplayName("junit5单元测试")
@SpringBootTest(classes = App.class)
public class TestJunit5 {
    @BeforeEach
    public void beforeEach(){
    	System.out.println("这是beforeEach方法");
    }
}
```



### @AfterEach 

表示在每个单元测试之后执行

```java
@DisplayName("junit5单元测试")
@SpringBootTest(classes = App.class)
public class TestJunit5 {  
    @AfterEach
    public void afterEach(){
        System.out.println("这是afterEach方法");
    }
}
```



### @BeforeAll 

表示在所有单元测试之前执行

```java
@BeforeAll
public static void beforeAll(){ 
    //注意这个方法需要使用static关键字修饰
	System.out.println("这是beforeAll方法");
}
```



### @Disabled

表示测试类或测试方法不执行

```java
@Disabled 
@Test
public void test03(){
	System.out.println("这是test03方法");
}
```



### @Timeout

表示测试方法运行如果超过了指定时间将会返回错误

```java
@DisplayName("test02方法")
@Timeout(value = 500,unit = TimeUnit.MILLISECONDS)
@Test
public void test02(){
    try {
    	Thread.sleep(1000);
    } catch (InterruptedException e) {
    	e.printStackTrace();
    }
    System.out.println("这是test02方法");
}
```





## 断言机制

断言机制是用来对测试需要满足的条件进行验证。这些断言方法都是 

org.junit.jupiter.api.Assertions的静态方法。

所有的测试运行结束以后，会有一个详细的测试报告

### assertEquals

判断预期值和实际值是否相等，或者两个对象是否是同一个对象,也可以断言两个对象的内存地

址是否一致

```java
@SpringBootTest(classes = App.class)
public class TestAssert {
    public int getNum(int num1,int num2){
        return num1 + num2;
    }
    
    @Test
    public void test01(){
        /**
        * assertEquals 判断两个值是否相等
        * 参数1： 预期值
        * 参数2：实际值
        * 参数3：断言失败，输出的提示信息
        */
        Assertions.assertEquals(4,getNum(2,3),"断言失败，预期值和实际值不符合");
        System.out.println("test01方法执行了");
    }
}
```



### assertSame

判断两个对象是否是同一个对象

```java
@Test
public void test02(){
    Object o1 = new Object();
    Object o2 = new Object();
    //Assertions.assertSame(o1,o2,"两个对象不是同一个对象");
    Assertions.assertNotSame(o1,o2,"两个对象同一个对象");
    System.out.println("test02方法执行了");
}
```



### assertFalse和assertTrue

assertFalse 判断结果是否为false

assertTrue 判断结果是否为true

```java
@Test
public void test03(){
    //Assertions.assertTrue(2 > 1);
    Assertions.assertFalse(2 > 1,"结果为true");
    System.out.println("test03方法执行了");
}
```



### assertArrayEquals

判断两个对象或原始类型的数组是否相等

```java
@Test
public void test04(){
//Assertions.assertArrayEquals(new int[]{1, 2}, new int[] {1, 2});
    Assertions.assertArrayEquals(new int[]{1, 2},
                                 new int[] {1, 2,3},
                                 "数组内容不相等");
    System.out.println("test04方法执行了");
}
```



### assertAll

接受多个 org.junit.jupiter.api.Executable 函数式接口的实例作为要验证的断言，可以通过 

lambda 表达式提供这些断言

```java
@Test
public void test05(){
    Assertions.assertAll("Math",
        () -> Assertions.assertEquals(2,1 + 1,"预期值与实际值结果不符"),
        () -> Assertions.assertTrue(1 >8,"预期结果不为true")
    );
    System.out.println("test05方法执行了");
}
```



### assertTimeout

超时断言

```java
@Test
@DisplayName("超时测试")
public void test07() {
    //如果测试方法时间超过1s将会异常
    Assertions.assertTimeout(Duration.ofMillis(1000), 
                             () -> Thread.sleep(1500),"执行超时");
    System.out.println("test07方法执行了");
}
```

### assumeTrue

前置条件,类似于断言但不用于断言,断言会直接报错终止,前置条件会直接不执行

```java
@Test
public void test08(){
    Assumptions.assumeTrue(false,"预期结果不为true");
    System.out.println("test08方法执行了");
}
```



## 参数化设置

设置多个参数,在一次运行里,运行多次方法

### ValueSource

支持八大基础类以及String类型,Class类型

```java
```



