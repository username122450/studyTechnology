import { createRouter, createWebHistory } from "vue-router"
import { useUserStore } from "@/store/user"
import { getToken, removeToken } from "@/utils/auth"
import { ElMessage } from "element-plus"

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: "/login",
      name: "Login",
      component: () => import("@/views/login/Login.vue")
    },
    {
      path: "/",
      name: "Layout",
      component: () => import("@/layout/Layout.vue"),
      redirect: "/dashboard",
      children: [
        {
          path: "dashboard",
          name: "Dashboard",
          component: () => import("@/views/dashboard/Dashboard.vue"),
          meta: { title: "首页", icon: "HomeFilled" }
        },
        {
          path: "system/user",
          name: "SystemUser",
          component: () => import("@/views/system/user/UserList.vue"),
          meta: { title: "用户管理", icon: "User" }
        },
        {
          path: "system/role",
          name: "SystemRole",
          component: () => import("@/views/system/role/RoleList.vue"),
          meta: { title: "角色管理", icon: "Avatar" }
        },
        {
          path: "system/menu",
          name: "SystemMenu",
          component: () => import("@/views/system/menu/MenuList.vue"),
          meta: { title: "菜单管理", icon: "Menu" }
        },
        {
          path: "system/dept",
          name: "SystemDept",
          component: () => import("@/views/system/dept/DeptList.vue"),
          meta: { title: "部门管理", icon: "OfficeBuilding" }
        },
        {
          path: "log/operlog",
          name: "OperLog",
          component: () => import("@/views/log/OperLog.vue"),
          meta: { title: "操作日志", icon: "Document" }
        },
        {
          path: "profile",
          name: "Profile",
          component: () => import("@/views/profile/Profile.vue"),
          meta: { title: "个人中心", icon: "User" },
          hidden: true
        }
      ]
    }
  ]
})

// 白名单（无需登录即可访问）
const whiteList = ["/login"]

router.beforeEach(async (to, from, next) => {
  const token = getToken()
  if (token) {
    if (to.path === "/login") {
      next("/dashboard")
    } else {
      try {
        const userStore = useUserStore()
        if (!userStore.userInfo?.id) {
          await userStore.getInfo()
        }
        next()
      } catch (error) {
        // 兜底:任何异常(接口失败、本地缓存脏数据导致 store 初始化崩溃等)
        // 都先清除 token 再跳登录页。若不清 token,会被上面
        // "有 token 访问 /login → 踢回 /dashboard" 的分支踢回来,形成无限循环;
        // 若异常直接冒出去,导航会被中止、router-view 什么都不渲染 → 白屏。
        // removeToken 同时会清掉损坏的 admin_user 缓存,实现自愈
        removeToken()
        console.error("[路由守卫] 获取用户信息异常:", error)
        ElMessage.error(error?.message || "登录状态异常，请重新登录")
        next("/login")
      }
    }
  } else {
    if (whiteList.includes(to.path)) {
      next()
    } else {
      next(`/login?redirect=${to.path}`)
    }
  }
})

export default router
