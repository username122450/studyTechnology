# studyDocker

## 是什么

Docker是基于Go语言实现的云开源项目。

Docker的主要目标是“Build，Ship and Run Any App,Anywhere”，也就是通过对应用组件的封装、分发、部署、运行等生命周期的管理，使用户的APP（可以是一个WEB应用或数据库应用等等）及其运行环境能够做到“一次镜像，处处运行”。

Docker容器是在操作系统层面上实现虚拟化，直接复用本地主机的操作系统。而传统虚拟机直接在硬件层面实现虚拟化。与传统的虚拟机相比，Docker体现的优势是启动速度快，占用体积小。



## 优势

- **更快速的应用交付和部署**：

    传统的应用开发完成后，需要提供一堆安装程序和配置说明文档，安装部署后需根据配置文档进行繁杂的配置才能正常运行。Docker化之后只需要交付少量容器镜像文件，在正式生产环境加载镜像并运行即可，应用安装配置在镜像里已经内置好，大大节省部署配置和测试验证时间。

- **更便捷的升级和扩缩容**

    随着微服务架构和Docker的发展，大量的应用会通过微服务方式架构，应用的开发构建将变成搭乐高积木一样，每个Docker容器将变成一块“积木”，应用的升级将变得非常容易。当现有的容器不足以支撑业务处理时，可通过镜像运行新的容器进行快速扩容，使应用系统的扩容从原先的天级变成分钟级甚至秒级。

- **更简单的系统运维**

    应用容器化运行后，生产环境运行的应用可与开发、测试环境的应用高度一致，容器会将应用程序相关的环境和状态完全封装起来，不会因为底层基础架构和操作系统的不一致性给应用带来影响，产生新的BUG。当出现程序异常时，也可以通过测试环境的相同容器进行快速定位和修复。

- **更高效的计算资源利用**

    Docker是内核级虚拟化，其不像传统的虚拟化技术一样需要额外的Hypervisor支持，所以在一台物理机上可以运行很多个容器实例，可大大提升物理服务器的CPU和内存的利用率。



## Docker的架构

- 镜像(image)

    Docker 镜像（Image）就是一个只读的模板。镜像可以用来创建 Docker 容器，一个镜像可以创建很多容器。它也相当于是一个root文件系统。

- 容器(container)

    1 从面向对象角度

    Docker 利用容器（Container）独立运行的一个或一组应用，应用程序或服务运行在容器里面，容器就类似于一个虚拟化的运行环境，容器是用镜像创建的运行实例。就像是Java中的类和实例对象一样，镜像是静态的定义，容器是镜像运行时的实体。容器为镜像提供了一个标准的和隔离的运行环境，它可以被启动、开始、停止、删除。每个容器都是相互隔离的、保证安全的平台。

    2 从镜像容器角度

    可以把容器看做是一个简易版的 Linux 环境（包括root用户权限、进程空间、用户空间和网络空间等）和运行在其中的应用程序。

- 仓库(repository)

    仓库（Repository）是集中存放镜像文件的场所。类似于Maven仓库，存放各种jar包的地方；github仓库，存放各种git项目的地方；Docker公司提供的官方registry被称为Docker Hub，存放各种镜像模板的地方。仓库分为公开仓库（Public）和私有仓库（Private）两种形式。最大的公开仓库是 Docker Hub(https://hub.docker.com/)，存放了数量庞大的镜像供用户下载。国内的公开仓库包括阿里云 、网易云等。

需要正确的理解仓库/镜像/容器这几个概念:

Docker 本身是一个容器运行载体或称之为管理引擎。我们把应用程序和配置依赖打包好形成一个可交付的运行环境，这个打包好的运行环境就是image镜像文件。只有通过这个镜像文件才能生成Docker容器实例(类似Java中new出来一个对象)。

image文件可以看作是容器的模板。Docker 根据 image 文件生成容器的实例。同一个 image 文件，可以生成多个同时运行的容器实例。

**镜像文件**

image 文件生成的容器实例，本身也是一个文件，称为镜像文件。

**容器实例**

一个容器运行一种服务，当我们需要的时候，就可以通过docker客户端创建一个对应的运行实例，也就是我们的容器。

**仓库**

就是放一堆镜像的地方，我们可以把镜像发布到仓库中，需要的时候再从仓库中拉下来就可以了。



## 部署

在centos7上

安装gcc环境

```bash
[root@shjava2202 ~]# yum -y install gcc
[root@shjava2202 ~]# yum -y install gcc-c++
```

安装需要的软件包

```bash
[root@shjava2202 ~]# yum install -y yum-utils
```

设置镜像仓库

```bash
[root@shjava2202 ~]# yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

更新yum软件包索引

```bash
[root@shjava2202 ~]# yum makecache fast
```

安装Docker

```bash
[root@shjava2202 ~]# yum -y install docker-ce docker-ce-cli containerd.io
```

启动Docker

```bash
[root@shjava2202 ~]# systemctl start docker
```



### 安装镜像加速器

1. 登录阿里云：aliyun.com
2. 选中控制台
3. 选中容器镜像服务
4. 获取加速器地址
5. 根据操作文档操作Linux
6. 验证是否成功`docker run hello-world`





## Docker命令

重启docker：`systemctl restart docker`

停止docker服务：`systemctl stop docker`

开启docker服务：`systemctl start docker`



