import { defineStore } from "pinia"
import { getRouters } from "@/api/menu"

export const usePermissionStore = defineStore("permission", {
  state: () => ({
    routes: [],
    addRoutes: []
  }),

  actions: {
    // 从后端获取动态路由
    async generateRoutes() {
      const res = await getRouters()
      const accessedRoutes = filterAsyncRoutes(res.data)
      this.addRoutes = accessedRoutes
      this.routes = [...constantRoutes, ...accessedRoutes]
      return accessedRoutes
    }
  }
})

// 静态路由（无需权限）
export const constantRoutes = [
  {
    path: "/login",
    name: "Login",
    component: () => import("@/views/login/Login.vue"),
    hidden: true
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
      }
    ]
  },
  {
    path: "/profile",
    name: "Profile",
    component: () => import("@/layout/Layout.vue"),
    hidden: true,
    children: [
      {
        path: "",
        name: "ProfileIndex",
        component: () => import("@/views/profile/Profile.vue"),
        meta: { title: "个人中心", icon: "User" }
      }
    ]
  }
]

// 将后端路由数据转为 Vue Router 格式
function filterAsyncRoutes(routes) {
  const res = []
  routes.forEach((route) => {
    const tmp = {
      path: route.path,
      name: route.name,
      component: route.component,
      hidden: route.hidden,
      meta: {
        title: route.meta?.title || "",
        icon: route.meta?.icon || ""
      }
    }
    if (route.children && route.children.length > 0) {
      tmp.children = filterAsyncRoutes(route.children)
    }
    res.push(tmp)
  })
  return res
}
