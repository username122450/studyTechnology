<template>
  <div class="sidebar-container">
    <!-- Logo区域 -->
    <div class="sidebar-logo" :class="{ collapse: isCollapse }">
      <img src="@/assets/logo.svg" class="logo-img" alt="logo" />
      <span v-show="!isCollapse" class="logo-title">Admin 后台</span>
    </div>

    <!-- 菜单 -->
    <el-scrollbar>
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        :collapse-transition="false"
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
        router
        class="sidebar-menu"
      >
        <template v-for="route in menuRoutes" :key="route.path">
          <!-- 有子菜单 -->
          <el-sub-menu
            v-if="route.children && route.children.length > 0 && !route.hidden"
            :index="route.path"
          >
            <template #title>
              <el-icon><component :is="route.meta?.icon" /></el-icon>
              <span>{{ route.meta?.title }}</span>
            </template>
            <el-menu-item
              v-for="child in route.children.filter(c => !c.hidden)"
              :key="child.path"
              :index="joinPath(route.path, child.path)"
            >
              <el-icon><component :is="child.meta?.icon" /></el-icon>
              <span>{{ child.meta?.title }}</span>
            </el-menu-item>
          </el-sub-menu>

          <!-- 无子菜单 -->
          <el-menu-item
            v-else-if="!route.hidden"
            :index="route.path === '/' ? '/dashboard' : route.path"
          >
            <el-icon><component :is="route.meta?.icon" /></el-icon>
            <template #title>
              <span>{{ route.meta?.title }}</span>
            </template>
          </el-menu-item>
        </template>
      </el-menu>
    </el-scrollbar>
  </div>
</template>

<script setup>
import { computed } from "vue"
import { useRoute } from "vue-router"
import router from "@/router"

defineProps({
  isCollapse: {
    type: Boolean,
    default: false
  }
})

const route = useRoute()

// 拼接父子路由路径,避免出现 "//system/user" 这种双斜杠
function joinPath(base, child) {
  if (child.startsWith("/")) return child
  return base === "/" ? "/" + child : base + "/" + child
}

// 菜单路由（过滤掉 hidden 的顶层路由）
const menuRoutes = computed(() => {
  return router.options.routes.filter((r) => !r.hidden && r.path !== "/login")
})

// 当前激活的菜单
const activeMenu = computed(() => {
  const { path } = route
  const pathArr = path.split("/").filter(Boolean)
  if (pathArr.length >= 2) {
    return "/" + pathArr[0] + "/" + pathArr[1]
  }
  return path === "/" ? "/dashboard" : path
})
</script>

<style scoped>
.sidebar-container {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.sidebar-logo {
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  overflow: hidden;
}

.sidebar-logo.collapse {
  padding: 0;
}

.logo-img {
  width: 32px;
  height: 32px;
  flex-shrink: 0;
}

.logo-title {
  margin-left: 10px;
  font-size: 18px;
  font-weight: 600;
  color: #fff;
  white-space: nowrap;
}

.sidebar-menu {
  border-right: none;
}

.sidebar-menu .el-sub-menu .el-menu-item {
  min-width: auto;
}
</style>
