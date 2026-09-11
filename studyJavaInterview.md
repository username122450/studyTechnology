# Java 校招八股手册(详细版)

> 使用方法:先看题**口头作答**,再对照答案查漏;答不上的标记,三轮复习法过。
> ★ = 高频,★★ = 极高频必背。并发/Redis/MQ 与 studyConcurrencyDistributed.md 交叉学习。
> 答案按"面试怎么答"组织:先结论,再展开原理,最后可以带一句项目关联。

---

# 1. Java 基础

#### ★★ == 和 equals 区别?hashCode 与 equals 的约定?

- **==**:比较的是栈中的值。基本类型比数值;引用类型比地址(是否指向同一对象)。
- **equals**:Object 的方法,默认实现就是 ==;String、Integer 等重写后比较内容。
- **hashCode 约定**:两个对象 equals 相等,hashCode 必须相等;hashCode 相等,equals 不一定相等。
- **为什么要这个约定**:HashMap 先按 hashCode 定位桶,再在桶内用 equals 比较。如果只重写 equals 不重写 hashCode,两个"相等"的对象会散列到不同桶,put 进去 get 不出来。
- **重写 equals 的原则**:自反性、对称性、传递性、一致性、与 null 比较返回 false。
- 面试加分句:重写 equals 必须同时重写 hashCode;IDEA 自动生成即可。

#### i++是原子性的吗

- 不是，java是**多线程**的，线程之间会被打断
- 

#### ★★ String 为什么不可变?StringBuilder 和 StringBuffer 区别?

- **不可变的实现**:String 是 final 类,底层 JDK8 是 final char[] value,JDK9 改为 final byte[] value + coder 标识(压缩存储,Latin-1 用 1 字节)。
- **设计成不可变的原因**:
  1. 字符串常量池复用(同样内容的字符串共享,省内存);
  2. hash 值可缓存,HashMap 的 key 常用 String;
  3. 线程安全,天然不可变;
  4. 安全:类加载器、文件路径等场景不可被篡改。
- **"修改"操作**(replace、substring、toUpperCase)都不是改原对象,而是返回新对象。
- **拼接的坑**:循环里用 + 拼接,每次循环都 new 一个 StringBuilder(JDK9 后编译器优化为 invokedynamic + 动态拼接,单次拼接无差别,但循环里仍建议显式用 StringBuilder)。
- **StringBuilder**:非线程安全,初始容量 16,扩容为原长度 ×2+2。
- **StringBuffer**:所有方法加 synchronized,线程安全但性能低,基本被 StringBuilder 替代。

#### ★ 接口和抽象类的区别?

| 对比项 | 抽象类 | 接口 |
|--------|--------|------|
| 继承 | 单继承 | 可多实现 |
| 成员 | 可有构造器、成员变量、普通方法 | 常量(public static final)+ 抽象方法;JDK8 支持 default/static 方法,JDK9 支持私有方法 |
| 语义 | is-a(是什么) | can-do(能做什么) |
| 选择 | 需要复用实现代码、有公共状态 | 只定义行为契约、需要多实现 |

面试记忆点:抽象类是"模板",接口是"契约"。

#### ★ 多态的实现原理?

- **静态分派(编译期)**:方法重载,编译器根据参数静态类型决定调用哪个方法。
- **动态分派(运行期)**:方法重写,invokevirtual 指令执行时,先找操作数栈顶对象**实际类型**的方法,找不到沿继承链向上查找。
- **JVM 优化**:用虚方法表(vtable,类中方法的入口地址表)缓存结果,避免每次全链查找;接口方法调用用 itable。
- 注意:**字段不参与多态**,字段访问按静态类型决定,所以尽量用 getter。

#### ★ 异常体系?finally 和 return 的执行顺序?

- **体系**:Throwable 分两支——Error(OutOfMemoryError、StackOverflowError,程序无法处理)和 Exception。
- **Exception 分两类**:受检异常(IOException 等,编译期强制 try-catch 或 throws)与非受检异常(RuntimeException 及子类)。
- **finally 与 return 顺序**:
  1. finally 在 return 之前执行,但 return 的表达式会先求值保存;
  2. 若 finally 中也有 return,会覆盖原来的返回值;
  3. 若 finally 中抛异常,原异常会被吞掉——所以 finally 里不要写 return。
- **try-with-resources**(JDK7):实现 AutoCloseable 的资源自动关闭,比 finally 手动 close 更优雅。

#### 反射的原理和应用?

- **原理**:运行时获取 Class 对象(类名 Class.forName、对象 getClass、类字面量 .class),然后拿到 Field / Method / Constructor 对象进行访问和调用;setAccessible(true) 可以突破私有权限。
- **应用**:Spring 依赖注入、JDK 动态代理、MyBatis 结果集映射、注解解析(几乎所有框架的地基)。
- **缺点**:绕过编译期类型检查(容易运行时才报错)、性能略低(有 JIT 优化后差距不大)、破坏封装。
- 面试加分句:反射是框架的灵魂,业务代码少用。

#### 泛型类型擦除?通配符?

- **类型擦除**:泛型只在编译期检查,编译后擦除——无界泛型擦成 Object,有界泛型擦成边界类型,使用处插入强转;编译器还会生成桥接方法保证重写的多态性。
- **后果**:运行时拿不到泛型类型信息(所以 ArrayList<String> 和 ArrayList<Integer> 是同一个 Class)。
- **通配符 PECS**:生产者(? extends T,只能读)用于取数据;消费者(? super T,只能写)用于存数据。

#### Java 8 新特性?

- **Lambda**:匿名函数的语法糖,底层 invokedynamic + LambdaMetafactory 动态生成;要求目标是函数式接口(只有一个抽象方法)。
- **Stream**:惰性求值——中间操作(map/filter)不触发计算,终止操作(collect/forEach)才执行;可链式、可并行(parallelStream,底层 ForkJoinPool,注意线程安全)。
- **Optional**:包装可能为 null 的值,防 NPE;注意 orElse(无论如何都构造默认值)与 orElseGet(仅 null 时构造)的区别。
- **新日期时间 API**:LocalDate / LocalDateTime,不可变、线程安全,替代 Date/SimpleDateFormat(后者线程不安全)。

#### 深拷贝和浅拷贝?

- **浅拷贝**:复制对象本身,内部引用类型成员仍指向原对象(共享)。
- **深拷贝**:递归复制所有引用对象。
- **实现方式**:clone() 默认浅拷贝;深拷贝可以序列化/反序列化,或手动逐层复制。
- 面试补充:BeanUtils.copyProperties 是浅拷贝。

#### 装箱拆箱和缓存池?

- **装箱**调 valueOf,拆箱调 intValue;三目运算符、泛型、集合等场景会自动装箱。
- **Integer 缓存池**:valueOf 对 -128~127 走 IntegerCache(上限 -XX:AutoBoxCacheMax 可调);new Integer 永远是新对象。
- **坑**:两个 Integer 用 == 比较,在缓存范围内为 true,范围外为 false——所以包装类比较一律用 equals。

---

# 2. 集合

#### ★★ HashMap 的底层原理?(重点,展开讲)

- **数据结构**:JDK8 是数组 + 链表 + 红黑树;JDK7 只有数组 + 链表。
- **put 流程**:
  1. 对 key 的 hashCode 做扰动(h 与 h>>>16 异或,让高位参与运算);
  2. (n-1) & hash 定位桶下标(等价取模,位运算更快);
  3. 桶为空直接放;不为空遍历链表/树,key 相同(equals)则覆盖,否则尾插;
  4. 链表长度 ≥ 8 且数组长度 ≥ 64 时,链表树化为红黑树(退化阈值 6);
  5. size 超过阈值(容量 × 0.75)触发扩容。
- **为什么容量是 2 的幂**:用位运算代替取模;扩容时元素只可能留在原位或移动"原位置 + 旧容量",便于迁移。
- **为什么负载因子 0.75**:时间与空间折中——过高冲突多、查询变慢,过低浪费空间。
- **为什么树化阈值是 8**:按泊松分布,链表长度到 8 的概率约千万分之一,属于极端冲突才树化。
- **JDK7 的死循环问题**:JDK7 头插法 + 并发扩容会导致链表成环、get 时 CPU 100%;JDK8 改为尾插解决环问题,但 HashMap 依然不是线程安全的(并发可能丢数据),并发场景用 ConcurrentHashMap。
- **get 流程**:同样的扰动 + 定位,链表 equals 遍历,树按红黑树查找。

#### ★★ ConcurrentHashMap 原理?

- **JDK7**:Segment 分段锁,默认 16 段,每段一个 ReentrantLock,锁粒度大。
- **JDK8**:Node 数组 + CAS + synchronized。put 时:桶为空用 CAS 插入(无锁);桶非空则 synchronized 锁住桶的头节点;链表树化为红黑树,桶内放 TreeBin(锁 TreeBin 而非根节点)。
- **为什么 get 不用加锁**:Node 的 val 和 next 都是 volatile,读操作直接可见最新值。
- **size 统计**:baseCount + CounterCell[] 分段计数,CAS 失败时落到不同 Cell,汇总时累加,避免高并发下 size 成为瓶颈。
- **扩容**:多线程协助扩容(helpTransfer),迁移中的桶用 ForwardingNode 标记,读请求会转发到新数组。

#### ★ ArrayList 和 LinkedList 区别?ArrayList 扩容机制?

- **结构**:ArrayList 是 Object[] 数组;LinkedList 是双向链表。
- **复杂度**:ArrayList 随机访问 O(1)、中间增删 O(n);LinkedList 头尾增删 O(1)、按索引访问 O(n)(即使是"中间插入",定位也要 O(n) 遍历)。
- **扩容**:默认容量 10(JDK8 后懒初始化),扩容为原容量 1.5 倍,Arrays.copyOf 复制。
- **遍历方式**:ArrayList 用索引 for;LinkedList 用迭代器(否则每次 get 都从头遍历)。

#### HashSet 去重原理?

内部就是 HashMap,元素作为 key,value 是统一常量 PRESENT;去重依赖 hashCode + equals。

#### fail-fast 和 fail-safe?

- **fail-fast**:集合内部有 modCount 记录结构修改次数,迭代器创建时记录 expectedModCount,迭代中两者不等就抛 ConcurrentModificationException。单线程删除要用 iterator.remove()。
- **fail-safe**:基于副本遍历,如 CopyOnWriteArrayList(写时复制:写操作加锁并复制整个数组,读完全无锁),适合读多写少;ConcurrentHashMap 不抛异常但不保证弱一致性。

#### HashMap 和 Hashtable 区别?

Hashtable 所有方法 synchronized(锁整表,性能差)、不允许 null 键和值、继承自 Dictionary 类;已过时,需要线程安全用 ConcurrentHashMap。

#### LinkedHashMap 和 TreeMap?

- **LinkedHashMap**:Entry 增加 before/after 指针维护双向链表,保证遍历顺序 = 插入顺序;accessOrder=true 时,get 会把元素移到链表尾部,配合重写 removeEldestEntry 可实现 **LRU 缓存**。
- **TreeMap**:红黑树实现,key 有序(Comparable 或 Comparator),操作 O(logn),用于需要排序的场景。

---

# 3. JVM

#### ★★ JVM 内存结构?

- **线程私有**:
  1. **程序计数器**:记录当前线程执行到哪条字节码指令,不会 OOM;
  2. **虚拟机栈**:每个方法一个栈帧(局部变量表、操作数栈、动态链接、返回地址);递归过深抛 StackOverflowError;
  3. **本地方法栈**:native 方法。
- **线程共享**:
  1. **堆**:对象实例,分新生代(Eden + 两个 Survivor)和老年代,垃圾回收主战场;
  2. **方法区(JDK8 元空间)**:类信息、常量、静态变量、即时编译后的代码;元空间用本地内存,默认不设上限(受物理内存限制)。
- 面试加分句:JDK8 用元空间替代永久代,解决了 PermGen OOM;字符串常量池和静态变量移到了堆里。

#### ★★ 垃圾回收算法?分代回收?

- **标记-清除**:标记存活对象,清除未标记。快,但产生内存碎片。
- **复制**:内存分两半,存活对象复制到另一半,整块清理。无碎片但浪费一半空间,适合存活率低的新生代(Eden:S0:S1 = 8:1:1,每次只用 90%)。
- **标记-整理**:标记后把存活对象向一端移动。无碎片,适合老年代。
- **分代回收**:新对象进 Eden,Minor GC 后存活对象进入 Survivor,年龄计数器每熬过一次 GC +1,到 15(默认)晋升老年代;大对象直接进老年代;老年代满触发 Full GC(Stop The World,尽量少发生)。
- **为什么分代**:对象"朝生夕死"和"长期存活"两类,用不同算法各取所长。

#### ★★ 如何判断对象可回收?四种引用?

- **可达性分析**:从 GC Roots 出发,不可达的对象判定可回收。**GC Roots 包括**:虚拟机栈引用、静态变量、常量池引用、JNI 引用、synchronized 持有的对象等。
- **引用计数法**有循环引用问题,JVM 不用。
- **四种引用**:
  1. 强引用:new 出来的,永不回收;
  2. 软引用(SoftReference):内存不足时才回收,适合缓存;
  3. 弱引用(WeakReference):下次 GC 必回收(ThreadLocal 的 key 就是弱引用);
  4. 虚引用(PhantomReference):仅用于跟踪对象回收,配合引用队列(如堆外内存 DirectByteBuffer 的回收)。

#### ★ 类加载过程和双亲委派机制?

- **五阶段**:加载(读取字节码生成 Class)→ 验证(字节码合法性)→ 准备(静态变量赋默认值)→ 解析(符号引用转直接引用)→ 初始化(执行 clinit,静态变量赋代码里的值)。
- **双亲委派**:类加载请求先给父加载器——AppClassLoader → ExtClassLoader(JDK9 后 Platform)→ BootstrapClassLoader;父加载不了才自己加载。
- **为什么**:避免核心类被篡改(如自定义 java.lang.String 不会被加载)、保证类加载的一致性。
- **打破场景**:SPI 机制(JDBC 的 DriverManager 用线程上下文类加载器加载第三方驱动)、Tomcat 多应用隔离(每个应用独立 WebAppClassLoader)。

#### ★ CMS 和 G1?

- **CMS**:标记-清除,分初始标记(STW)→ 并发标记 → 重新标记(STW)→ 并发清除四步;优点低停顿,缺点有碎片、浮动垃圾,JDK9 起废弃。
- **G1**:把堆划分为大小相等的 Region(逻辑上分 Eden/Survivor/Old),可预测停顿(-XX:MaxGCPauseMillis);回收价值最高的 Region(混合回收);JDK9 起默认收集器。
- 记忆点:CMS 追求低停顿但碎片化;G1 在停顿和吞吐间平衡,还解决了碎片。

#### OOM 排查思路?

- 步骤:jps 找进程 → jmap -dump 导出堆快照 → MAT/JProfiler 分析大对象和引用链;或用 jstat 看 GC 频率、jstack 看线程状态。
- 常见原因:集合/静态成员持有对象不释放(内存泄漏)、大对象一次性创建、元空间 OOM(类太多)、线程创建过多(无法创建 native 线程)。
- 面试加分句:先看是泄漏还是确实不够用——泄漏看引用链,不够用调大堆或优化。

#### 对象的创建过程?

1. 类加载检查 → 2. 分配内存(指针碰撞/空闲列表,TLAB 线程本地缓冲减少竞争)→ 3. 内存零值初始化 → 4. 设置对象头(hash、GC 分代年龄、锁状态)→ 5. 执行 init 构造方法。

---

# 4. 并发编程(→ 学习线三第一阶段)

#### ★★ volatile 的原理?

- **可见性**:写 volatile 变量会立即刷回主内存,并让其他线程的本地副本失效;底层是 lock 前缀指令 + 缓存一致性协议(MESI)。
- **有序性**:插入内存屏障,禁止屏障两侧的指令重排序。
- **不能保证原子性**:i++ 是"读-改-写"三步复合操作,volatile 管不了。
- **经典应用**:双重检查锁的单例模式,instance 必须 volatile(防止"分配内存 → 返回引用 → 初始化"重排序导致拿到半初始化对象)。
- 对比 synchronized:volatile 轻量、不阻塞、只保证可见有序;synchronized 保证原子 + 可见 + 有序,但有锁开销。

#### ★★ synchronized 的原理?和 Lock 的区别?

- **锁升级过程(JDK6 优化)**:
  1. 无锁 → 2. 偏向锁(单线程反复获取,Mark Word 记线程 ID)→ 3. 轻量级锁(竞争时 CAS 自旋获取)→ 4. 重量级锁(自旋失败,内核态互斥量,线程阻塞)。
- **锁信息存在对象头 Mark Word** 里,所以 synchronized 锁的是对象。
- **和 ReentrantLock 区别**:Lock 可中断(lockInterruptibly)、可超时(tryLock)、支持多条件变量、支持公平锁;必须手动 unlock;synchronized 自动释放、代码简单。
- 加分句:JDK6 之后两者性能差距很小,优先 synchronized,需要高级特性再用 Lock。

#### ★★ CAS 的原理?ABA 问题?

- **Compare And Swap**:预期值 + 新值 + 内存地址;内存值等于预期值才更新,否则失败。底层是 CPU 的原子指令(cmpxchg),无锁不阻塞。
- **ABA 问题**:值从 A 变成 B 又变回 A,CAS 无法感知。解决:加版本号(AtomicStampedReference)。
- **缺点**:自旋消耗 CPU(竞争激烈时);只能保证一个变量的原子操作。
- 应用:AtomicInteger、ConcurrentHashMap 的 CAS 插入、AQS 的 state 更新。

#### ★★ AQS 的原理?

- **AbstractQueuedSynchronizer**,并发包的地基(ReentrantLock、CountDownLatch、Semaphore、ReentrantReadWriteLock 都基于它)。
- **核心组成**:state(volatile int 同步状态)+ CLH 变体队列(等待线程组成双向链表)+ 模板方法(acquire/release 定义骨架,子类实现 tryAcquire/tryRelease)。
- **流程**:获取锁失败 → 包装成 Node 入队 → 前驱是头节点则再尝试,否则 park 阻塞;释放锁时唤醒后继。
- **公平锁 vs 非公平锁**:公平锁先检查队列有没有等待者;非公平直接 CAS 抢,吞吐更高。
- 加分句:CountDownLatch 用 state 做计数器,await 在 state≠0 时入队阻塞,countDown 到 0 时唤醒所有。

#### ★★ 线程池的七个参数?执行流程?为什么不用 Executors?

- **七参数**:corePoolSize(核心线程数)、maximumPoolSize(最大线程数)、keepAliveTime + unit(非核心线程空闲存活时间)、workQueue(任务队列)、threadFactory、handler(拒绝策略)。
- **执行流程**:任务来了 → 核心线程没满,创建核心线程执行 → 满了进队列 → 队列满了创建非核心线程(到最大线程数)→ 都满了执行拒绝策略。核心线程数不空闲也常驻(allowCoreThreadTimeOut 可改)。
- **拒绝策略四种**:AbortPolicy(抛异常,默认)、CallerRunsPolicy(调用者线程执行)、DiscardPolicy(丢弃)、DiscardOldestPolicy(丢弃最老的)。
- **为什么不用 Executors**:newFixedThreadPool / newSingleThreadExecutor 的队列是 LinkedBlockingQueue(Integer.MAX_VALUE),newCachedThreadPool 的最大线程数是 Integer.MAX_VALUE,都会 OOM——必须自己 new ThreadPoolExecutor。
- **参数怎么定**:CPU 密集 = CPU 核数 ±1;IO 密集 = 核数 × 2 或核数 / (1 - 阻塞系数)。

#### ★★ ThreadLocal 的原理?内存泄漏?

- **结构**:每个 Thread 有一个 ThreadLocalMap,key 是 ThreadLocal 对象(弱引用),value 是线程自己的值。
- **泄漏原因**:ThreadLocal 被 GC 后,key 变 null,但 value 还被 Entry 强引用;线程池的线程长期存活,value 永远不会被清理。
- **解决**:用完必须 remove();ThreadLocalMap 的 set/get 也会顺带清理 key 为 null 的 Entry,但依赖这个不保险。
- **应用**:Spring 事务的数据库连接、登录用户上下文、SimpleDateFormat 线程隔离。

#### 死锁的四个条件?如何排查?

- **四条件**:互斥、持有并等待、不可剥夺、循环等待——破坏任意一个即可防死锁。
- **排查**:jstack 看线程状态(Blocked + 互相持有的锁)、jconsole 检测死锁;日志里看请求卡住的位置。
- **预防**:锁顺序一致、加锁超时(tryLock)、减小锁粒度。

#### sleep 和 wait 的区别?

- sleep 是 Thread 静态方法,不释放锁,到时间自动醒;wait 是 Object 方法,必须持有锁且会**释放锁**,等待 notify/notifyAll 唤醒,必须在同步块里用。
- notify 随机唤醒一个等待者,notifyAll 唤醒全部。

#### 乐观锁悲观锁?可重入锁?

- 乐观锁:不阻塞,先操作再校验(CAS、版本号),适合读多写少;悲观锁:先加锁再操作,适合写多。
- 可重入锁:同一线程重复获取同一把锁不会死锁,内部有计数器;synchronized 和 ReentrantLock 都可重入,Lock 要记得 unlock 次数匹配。

#### CompletableFuture 的作用?

异步任务编排:supplyAsync 提交任务,thenApply/thenCompose 串行,thenCombine/allOf 聚合多个异步结果,exceptionally 处理异常;解决回调地狱,比 Future.get 阻塞好用。

---

# 5. MySQL

#### ★★ 为什么 InnoDB 用 B+ 树做索引?

- **磁盘 IO 决定性能**:索引存在磁盘上,一次节点访问就是一次 IO。B+ 树多叉矮胖,3~4 层就能存千万级数据(一页 16KB 放上千个 key),IO 次数少。
- **叶子节点有序链表**:范围查询(order by、between)直接顺着链表扫,不用回溯。
- **非叶子节点只存 key**:一页能放更多索引项,树更矮。
- **对比哈希索引**:等值查询快,但不支持范围、排序、最左前缀匹配。
- **对比 B 树**:B 树非叶子也存数据,树更高,且范围查询要中序遍历。

#### ★★ 聚簇索引和非聚簇索引?回表?覆盖索引?

- **聚簇索引**:叶子节点存的是**整行数据**;InnoDB 每张表只有一个,默认用主键(没有主键用唯一键,再没有生成隐藏 rowid)。
- **二级索引(非聚簇)**:叶子存索引列 + 主键值。
- **回表**:二级索引查到主键后,还要回聚簇索引查整行——多一次 IO,所以推荐用主键或覆盖索引。
- **覆盖索引**:查询需要的列全在索引里(索引覆盖了查询),不用回表,explain 里 Extra 显示 Using index。
- 加分句:建议主键自增(顺序插入,避免页分裂和随机 IO)。

#### ★★ 最左前缀原则?索引失效的场景?

- **最左前缀**:联合索引 (a,b,c) 相当于建了 (a)、(a,b)、(a,b,c) 三个索引;查询从最左列开始连续匹配才走索引。跳过 a 直接查 b 不走。
- **失效场景**:
  1. like 'x%' 走索引,like '%x' 不走;
  2. 索引列上做函数、运算、隐式类型转换(如字符串列传数字);
  3. or 连接的两边有一边没索引;
  4. 范围查询右边的列失效(如 a=1 and b>2 and c=3,c 不走)。
- 归根结底一句话:**索引列不能被"加工",查询条件要和索引列直接比较**。

#### ★★ 事务隔离级别?脏读/不可重复读/幻读?

| 隔离级别 | 脏读 | 不可重复读 | 幻读 |
|---------|------|-----------|------|
| 读未提交 | 有 | 有 | 有 |
| 读已提交 | 无 | 有 | 有 |
| 可重复读(InnoDB 默认) | 无 | 无 | 靠 MVCC + 间隙锁解决 |
| 串行化 | 无 | 无 | 无 |

- **脏读**:读到别的事务未提交的数据;不可重复读:同一事务两次读结果不同(别的事务改了);幻读:同一范围查询,行数变了(别的事务插入了)。
- **为什么默认 RR 不用 RC**:RR 配合间隙锁(Next-Key Lock)能解决幻读,保证主从 binlog 顺序一致。

#### ★★ MVCC 的原理?

- **多版本并发控制**,核心两件套:**undo log 版本链 + ReadView**。
- 每行数据有隐藏列 trx_id(最近修改它的事务 ID)和 roll_pointer(指向 undo log 的上一个版本);undo log 记录每次修改前的数据,形成版本链。
- **ReadView** 记录:当前活跃事务列表、最小/最大事务 ID;判断版本可见性:版本 trx_id 比所有活跃事务都小(已提交)则可见,是自己在改则可见,否则不可见沿链回溯。
- **RC 和 RR 的区别**:RC 每次查询生成新 ReadView(所以能读到别的事务已提交的修改);RR 复用第一次生成的 ReadView(所以可重复读)。
- **快照读 vs 当前读**:普通 select 是快照读走 MVCC;update/delete/select ... for update 是当前读,永远读最新版本,加锁保证。

#### ★★ redo log / undo log / binlog 的区别?两阶段提交?

- **redo log**:InnoDB 引擎层,物理日志(哪个页改了什么),循环写,用于**崩溃恢复**——WAL 先写日志再刷盘。
- **undo log**:逻辑日志,记录修改前的值,用于**事务回滚**和 MVCC 版本链。
- **binlog**:Server 层,逻辑日志(SQL 或行),追加写,用于**主从复制和数据恢复**。
- **两阶段提交**:事务提交时先写 redo(prepare)→ 写 binlog → redo commit。保证 redo 和 binlog 一致,否则主从数据不一致或崩溃恢复后数据丢失。

#### ★ explain 关键字段怎么看?

- **type**:访问类型,从好到差:const(主键/唯一等值)→ eq_ref → ref(普通索引等值)→ range → index(全索引扫描)→ all(全表扫描);至少要到 range。
- **key**:实际用的索引;rows:预估扫描行数;filtered:过滤比例。
- **Extra**:Using index(覆盖索引)、Using filesort(需要额外排序,优化点)、Using temporary(临时表,优化点)、Using where。

#### SQL 优化思路?

1. explain 定位慢查询(type=all、rows 大、filesort);
2. 按最左前缀加索引,尽量覆盖索引;
3. 避免 select *,大字段拆表;
4. 深分页(limit 100000,10)用"上一次最大 id"游标或延迟关联;
5. 小表驱动大表、避免子查询改 join、批量插入。

#### 主从复制的原理?延迟怎么办?

- master 写 binlog → slave 的 IO 线程拉取写到中继日志 relay log → SQL 线程回放。
- **延迟原因**:从库单线程回放、大事务、从库负载高。
- 解决:并行复制、半同步复制(至少一个从库确认)、读写分离时对强一致读走主库。

---

# 6. Redis(→ 学习线一)

#### ★★ Redis 为什么快?

1. **纯内存操作**,数据都在内存里;
2. **单线程处理命令**,避免多线程锁竞争和上下文切换(6.0 后网络 IO 多线程,命令执行仍单线程);
3. **IO 多路复用**(epoll),一个线程管理大量连接,网络不是瓶颈;
4. **高效数据结构**:SDS(简单动态字符串)、跳表、压缩列表/listpack、哈希表渐进式 rehash。
- 加分句:快是相对的,大 key 删除、大量过期键集中过期也会阻塞(所以有 lazy free 和过期键分散策略)。

#### ★ 五种数据结构的底层和使用场景?

- **String**:SDS(带长度和预留空间,二进制安全,避免 C 字符串的 O(n) 和溢出);场景:缓存、计数器、分布式锁。
- **Hash**:列表压缩 + 哈希表渐进式 rehash;场景:对象存储、购物车。
- **List**:双向链表 + listpack;场景:最新消息列表、简单队列。
- **Set**:哈希表(intset 小集合);场景:去重、共同好友(交集)。
- **ZSet**:跳表 + 哈希表,按分值排序;场景:排行榜、延迟队列(分数为时间戳)。
- 加分句:跳表查询/插入 O(logn) 且实现比红黑树简单,支持范围查询。

#### ★★ 缓存穿透 / 击穿 / 雪崩?

- **穿透**:请求查一个根本不存在的数据,每次穿透到数据库。解决:**布隆过滤器**(提前拦掉不存在的 key)+ 缓存空值(短过期)。
- **击穿**:热点 key 过期瞬间,大量请求打到数据库。解决:互斥锁(第一个请求重建缓存,其余等待)、逻辑过期(旧值续用,后台异步刷新)。
- **雪崩**:大量 key 同时过期或 Redis 宕机。解决:过期时间加随机值、多级缓存(本地 + Redis)、集群 + 限流降级。
- 记忆法:穿透是"查不到",击穿是"一个点",雪崩是"一大片"。

#### ★★ 缓存与数据库一致性?

- **先更新数据库,再删除缓存**(Cache Aside 常用):缓存里是旧数据的话,更新库后删缓存,下次读重建。
- **延迟双删**:删缓存 → 更新库 → 延迟再删一次,兜底更新期间的并发读。
- **为什么先更库后删缓存,而不是先删缓存**:先删缓存,其他线程马上读到旧库数据又写回脏缓存;先更库,期间读旧缓存只是短暂不一致,删掉后自愈。
- **兜底方案**:canal 订阅 binlog 异步删除缓存、给缓存设过期时间(最终一致性保底)。
- 加分句:强一致场景不如让请求直接走数据库或加分布式读写锁。

#### ★ RDB 和 AOF 的区别?

- **RDB**:定时生成内存快照(fork 子进程 + 写时复制),文件小、恢复快,但两次快照之间丢数据。
- **AOF**:追加写每条写命令,everysec 最多丢 1 秒数据,文件大、重写机制压缩;恢复慢。
- **混合持久化**(4.0+):RDB 快照 + 期间的增量 AOF,兼顾速度和数据量。
- 对比记忆:RDB 是"定期拍照",AOF 是"写日记"。

#### ★ 过期删除策略和内存淘汰策略?

- **过期删除**:惰性删除(访问时检查)+ 定期删除(随机抽查一批);两者结合防止过期键堆积。
- **内存淘汰(8 种)**:默认 noeviction(满了直接报错);常用 allkeys-lru(全体 LRU)、volatile-lru(只淘汰设了过期的)、allkeys-lfu、volatile-lfu、volatile-ttl、volatile-random、allkeys-random。
- 加分句:LFU 比 LRU 多记录访问频率,防止偶发访问的历史数据挤掉热点。

#### ★★ 分布式锁用 Redis 怎么实现?有什么坑?

- **基本版**:SET key value NX EX 30(NX 互斥 + EX 过期防死锁,两个操作原子)。
- **释放的坑**:必须校验 value 是自己加的锁再删(否则误删别人的锁),用 Lua 脚本保证"判断 + 删除"原子。
- **续期问题**:业务执行超过锁的过期时间,锁自动释放导致并发——Redisson 的**看门狗**(默认 30 秒,每 10 秒续期)解决。
- **主从切换丢锁**:主节点挂了锁没同步到从节点 → 别人也能拿到锁。红锁(RedLock,向多个独立节点加锁,过半成功)缓解,但业界有争议。
- 加分句:Redis 分布式锁是 AP 模型,要求强一致用 ZooKeeper/etcd(CP 模型)。

#### 主从 / 哨兵 / 集群?

- **主从**:主写从读,全量 + 增量同步(偏移量断点续传)。
- **哨兵**:监控主从、主观/客观下线判断、自动故障转移(选新主、通知客户端)。
- **集群**:16384 个哈希槽分片,key 按 CRC16 对 16384 取模落槽;支持水平扩容,槽在节点间迁移。

#### 大 key / 热 key 问题?

- **大 key**:单 key 过大导致阻塞(网络传输、删除阻塞)——异步删除(unlink)、分批读写、拆分成多个小 key。
- **热 key**:单 key 访问量过大,单节点 CPU 打满——本地缓存、读写分离分摊、key 复制多份随机访问。

---

# 7. Spring / Spring Boot

#### ★★ IoC 和 DI?Bean 的生命周期?

- **IoC(控制反转)**:对象创建和依赖关系交给 Spring 容器管理,不再由代码 new;DI(依赖注入)是 IoC 的实现方式。
- **好处**:解耦、易测试、单例复用、AOP 的基础。
- **Bean 生命周期**:
  实例化(构造器)→ 属性填充(依赖注入)→ Aware 接口(BeanNameAware、ApplicationContextAware)→ BeanPostProcessor 前置处理 → @PostConstruct / InitializingBean → BeanPostProcessor 后置处理(AOP 代理在此生成)→ 使用 → @PreDestroy / DisposableBean → 销毁。
- 加分句:BeanPostProcessor 是 Spring 的扩展灵魂,AOP、事务、注解解析都靠它。

#### ★★ AOP 的原理?应用场景?

- **面向切面编程**,把横切逻辑(日志、事务、权限、限流)从业务代码抽出来。
- **实现**:动态代理——被代理类有接口用 JDK 动态代理(基于接口),无接口用 CGLIB(生成子类);Spring Boot 2.x 默认 CGLIB。
- **相关概念**:切面、切点、通知(前置/后置/环绕/异常/返回)。
- **坑**:同类内部方法自调用不会走代理(因为调用的是 this 而不是代理对象),事务失效的常见原因之一。
- 加分句:JDK 代理只能代理接口方法;final 方法 CGLIB 也代理不了。

#### ★★ Spring 事务的传播行为?失效场景?

- **传播行为(7 种)**:REQUIRED(默认,有则加入无则新建)、REQUIRES_NEW(挂起当前,新开事务)、SUPPORTS、NOT_SUPPORTED、MANDATORY、NEVER、NESTED(保存点)。
- **失效场景**:
  1. 同类自调用(this.method(),不经过代理);
  2. 方法不是 public;
  3. 异常被 try-catch 吞掉(默认只回滚 RuntimeException 和 Error);
  4. 数据库引擎不支持事务(MyISAM);
  5. 传播行为配错(如 REQUIRES_NEW 场景理解错)。
- 加分句:失效的根因就一个——事务是通过代理对象开启的,绕过代理就失效。

#### ★★ 循环依赖?三级缓存?

- **问题**:A 依赖 B,B 依赖 A,直接构造会死循环。Spring 用三级缓存解决(仅限单例 + 属性注入;构造器注入无法解决)。
- **三级缓存**:
  1. singletonObjects:成品 Bean;
  2. earlySingletonObjects:提前暴露的半成品;
  3. singletonFactories:ObjectFactory,能提前生成代理对象。
- **流程**:A 实例化后半成品放进三级缓存 → 发现依赖 B → B 实例化时依赖 A,从三级缓存拿到 A 的半成品注入 → B 完成 → A 拿到 B 完成。
- **为什么需要三级(而不是两级)**:AOP 代理——提前暴露的对象可能最终是代理对象,ObjectFactory 保证拿到的是"最终形态"的引用。

#### ★★ Spring Boot 自动配置的原理?

- **入口**:@SpringBootApplication 里的 @EnableAutoConfiguration → @Import(AutoConfigurationImportSelector)。
- **机制**:启动时读取 classpath 下 META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports(2.7 前是 spring.factories),加载所有自动配置类。
- **条件装配**:每个自动配置类上用 @ConditionalOnClass(有依赖才生效)、@ConditionalOnMissingBean(用户自定义了就不装配)、@ConditionalOnProperty(配置文件开关)等。
- **自定义 starter 套路**:写自动配置类 + 属性类(@ConfigurationProperties)+ imports 文件。
- 加分句:理解自动配置 = 条件装配,就能解释"为什么引了 starter 就自动有 DataSource"。

#### ★ SpringMVC 的执行流程?

浏览器请求 → DispatcherServlet → HandlerMapping 找到处理器(Controller 方法)→ HandlerAdapter 适配执行 → 参数解析(@RequestBody 等消息转换器)→ 返回 ModelAndView → 视图解析(或 @ResponseBody 直接 JSON 写出)。
- 加分句:DispatcherServlet 是核心,所有请求都要过它。

#### ★ Bean 的作用域?

singleton(默认,容器内单例)、prototype(每次获取新实例)、request(一次请求)、session(一个会话)、application、websocket。
- 坑:singleton 里注入 prototype,prototype 不会每次都新——需要 @Lookup 或 ObjectProvider。

#### ★ Spring Security 的过滤链?JWT 怎么接入?(关联 star-admin)

- **过滤链**:所有请求先过 FilterChainProxy 管理的一串过滤器——认证过滤器(读取凭证、AuthenticationManager 认证)、授权过滤器(检查权限)、异常处理过滤器等。
- **JWT 接入方式**:自定义 OncePerRequestFilter,从 Authorization 头解析 token,校验通过后构造 UsernamePasswordAuthenticationToken 放入 SecurityContextHolder,再用 addFilterBefore 插在 UsernamePasswordAuthenticationFilter 之前。
- **无状态**:sessionCreationPolicy 设为 STATELESS,禁用 CSRF(JWT 在请求头,不依赖 Cookie)。
- 加分句:认证(你是谁)在过滤器里做,授权(你能做什么)靠 @PreAuthorize 或 URL 规则。

---

# 8. 计算机网络

#### ★★ TCP 三次握手和四次挥手?

- **三次握手**:客户端 SYN → 服务端 SYN+ACK → 客户端 ACK。**为什么三次**:两次无法确认双方收发能力都正常,也防历史连接请求(服务端收到迟到的旧 SYN 会误建连接)。
- **四次挥手**:主动方 FIN → 被动方 ACK → 被动方 FIN → 主动方 ACK。**为什么四次**:全双工,双方独立关闭;FIN 只表示"我不再发数据",对方可能还要发剩余数据。
- **TIME_WAIT**:主动关闭方等待 2MSL,确保最后的 ACK 送达 + 旧连接报文消失;服务端大量 TIME_WAIT 要调内核参数,大量 CLOSE_WAIT 说明应用没关连接。
- 加分句:SYN 泛洪攻击:只发 SYN 不回复,服务端半连接队列被打满——SYN Cookie 防御。

#### ★ TCP 和 UDP 的区别?

- TCP:面向连接、可靠(确认重传、序号、滑动窗口、流量控制、拥塞控制)、字节流、慢;UDP:无连接、不可靠、报文、快、支持广播多播。
- 场景:TCP = HTTP、数据库;UDP = 视频直播、DNS、游戏、语音。

#### ★ HTTPS 的加密流程?

1. 客户端请求,服务端返回证书(含公钥,CA 签名);
2. 客户端用内置 CA 根证书验证证书链,防中间人;
3. 用非对称加密(ECDHE/RSA)协商出对称密钥;
4. 之后通信都用对称加密(快)。
- 一句话:非对称加密交换密钥,对称加密传输数据。
- 加分句:HTTP/2 多路复用解决队头阻塞(HTTP 层),HTTP/3 换 QUIC(UDP)解决 TCP 层队头阻塞。

#### ★ 输入 URL 到页面展示的全过程?

1. DNS 解析域名(缓存 → 递归查询);
2. TCP 三次握手建立连接;
3. HTTPS 则先 TLS 握手;
4. 发送 HTTP 请求,服务端处理返回响应;
5. 浏览器解析 HTML 构建 DOM、解析 CSS 构建 CSSOM、合成渲染树;
6. 布局(layout)计算位置 → 绘制(paint)→ 合成显示;
7. 断开连接(TCP 四次挥手,keep-alive 则复用)。

#### ★★ Cookie / Session / JWT 的区别?(关联 star-admin)

| 对比项 | Cookie | Session | JWT |
|--------|--------|---------|-----|
| 存储位置 | 浏览器 | 服务端(内存/Redis) | 客户端(请求头) |
| 状态 | 无状态载体 | 有状态 | 无状态 |
| 扩展性 | 好 | 需共享 Session(Redis/粘性) | 天然好 |
| 主动失效 | 可 | 可 | 不能(黑名单补) |
| 安全风险 | CSRF | 会话固定 | 泄露后到期前有效 |

- 面试话术:JWT 适合前后端分离、多服务;代价是无法主动踢人,用 Redis 黑名单或短过期 + refresh token 缓解。

#### GET 和 POST 的区别?

- 语义:GET 获取,POST 提交(新增);GET 参数在 URL(长度受限、会留痕),POST 在请求体;GET 可缓存、幂等。
- 加分句:本质都是 HTTP 请求,区别是约定而不是安全(HTTPS 下请求体同样加密)。

#### 常见状态码?

200 成功;301 永久重定向、302 临时重定向;304 缓存未修改;400 参数错误;401 未认证;403 无权限;404 不存在;500 服务器错误;502 网关错误;503 服务不可用。

---

# 9. 操作系统(简要)

#### 进程和线程的区别?

进程是资源分配的最小单位(独立地址空间),线程是 CPU 调度的最小单位(共享进程资源);线程切换开销小但一个线程崩溃可能拖垮进程;进程间通信(管道/消息队列/共享内存)比线程同步重。

#### 虚拟内存?

每个进程有独立虚拟地址空间,页表映射到物理内存;访问缺页触发缺页中断换入;好处:内存隔离、按需加载、可运行超过物理内存的程序。

#### 用户态和内核态?

权限级别隔离,CPU 指令分特权/非特权;用户态访问硬件、修改关键寄存器要系统调用(陷入内核),上下文切换有开销。

#### 死锁四个条件?

互斥、持有并等待、不可剥夺、循环等待;破坏任一即可(如资源排序打破循环等待)。

---

# 10. 项目追问(star-admin 专项,按自己的话改述)

#### 为什么选 JWT 而不是 Session?

前后端分离,后端无状态好水平扩展;Session 要存服务端还得做共享(Redis/粘性会话),JWT 天然适合。代价是主动失效难,后续可用 Redis 黑名单弥补。

#### 你的 JWT 过滤器是怎么接入 Spring Security 的?

自定义 OncePerRequestFilter 继承重写 doFilterInternal:读 Authorization 头 → 截取 Bearer 后的 token → 校验 → 通过 UserDetailsService 加载用户 → 构造 UsernamePasswordAuthenticationToken 放进 SecurityContextHolder;SecurityConfig 里 addFilterBefore 插在 UsernamePasswordAuthenticationFilter 之前;会话策略 STATELESS,关闭 CSRF 和默认登录页。

#### token 过期前端怎么处理?

axios 响应拦截器:收到 401(后端过滤器对过期/无效 token 返回结构化 JSON)时清除本地 token,跳转登录页;路由守卫也做无 token 拦截。

#### 密码怎么存的?BCrypt 为什么安全?

BCryptPasswordEncoder 加盐 + 多次迭代,不可逆;同一个密码每次加密结果不同(盐随机);登录用 matches 比对,修改密码时先校验旧密码。

#### 无状态 JWT 怎么退出登录?缺陷是什么?

目前前端清除 token,服务端无状态无法主动失效;token 被盗在到期前一直有效——改进方向:Redis 黑名单(登出时把 token 加入黑名单,过滤器里查黑名单)+ 短过期时间。

#### RBAC 权限模型怎么设计的?

用户-角色-菜单三层:sys_user、sys_role、sys_menu 三张主表 + sys_user_role、sys_role_menu 两张中间表;用户分配角色,角色分配菜单权限,登录后返回角色和权限标识,前端据此渲染。

#### 说说你修过的最难的一个 bug?

(用自己的真实案例,按结构讲:现象 → 排查过程 → 根因 → 修复 → 验证。比如"修改密码接口 500":现象是必现报错;排查日志发现 Expected one result but found 2;根因是 Mapper 的 SQL 少了 WHERE 条件查出了所有用户的密码;修复加 WHERE username;验证接口回归通过。讲的时候突出"用日志和接口实测定位根因"的排查思路。)

#### 为什么用 MyBatis-Plus?

单表 CRUD 免写 SQL、分页插件、条件构造器;复杂多表查询仍用 XML 自定义 SQL;对比 JPA:SQL 可控、学习成本低。

---

## 复习节奏建议

1. **每天一个模块**,先口述再对答案,答不上的标记,用自己话重写一遍答案
2. 一轮结束后只复习标记题,三轮后基本脱稿
3. 第 4 章并发、第 6 章 Redis 配合 studyConcurrencyDistributed.md 的进度,边学边背
4. 第 10 章项目题必须用自己的项目事实改述,面试官一听背模板就减分
5. 上机验证优先:HashMap 扩容、线程池参数、MVCC 这类,写个小 demo 跑一遍记得最牢
