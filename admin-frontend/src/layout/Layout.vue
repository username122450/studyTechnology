<template>
  <el-container class="layout-container">
    <!-- 侧边栏 -->
    <el-aside :width="isCollapse ? '64px' : '220px'" class="layout-aside">
      <Sidebar :is-collapse="isCollapse" />
    </el-aside>

    <el-container>
      <!-- 顶部导航 -->
      <el-header height="50px" class="layout-header">
        <Navbar :is-collapse="isCollapse" @toggle="toggleSidebar" />
      </el-header>

      <!-- 标签页 -->
      <div class="tags-view-container">
        <TagsView />
      </div>

      <!-- 主内容区 -->
      <el-main class="layout-main">
        <router-view v-slot="{ Component }">
          <transition name="fade-transform" mode="out-in">
            <keep-alive :include="cachedViews">
              <component :is="Component" />
            </keep-alive>
          </transition>
        </router-view>
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup>
import { ref, computed } from "vue"
import Sidebar from "./Sidebar.vue"
import Navbar from "./Navbar.vue"
import TagsView from "./TagsView.vue"

const isCollapse = ref(false)

function toggleSidebar() {
  isCollapse.value = !isCollapse.value
}

// 需要缓存的组件名
const cachedViews = computed(() => [])
</script>

<style scoped>
.layout-container {
  height: 100vh;
  overflow: hidden;
}

.layout-aside {
  background: #304156;
  transition: width 0.28s;
  overflow: hidden;
}

.layout-header {
  background: #fff;
  border-bottom: 1px solid #e6e6e6;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  padding: 0 15px;
  display: flex;
  align-items: center;
}

.layout-main {
  background: #f0f2f5;
  padding: 16px;
  height: calc(100vh - 50px - 34px);
  overflow-y: auto;
}

.tags-view-container {
  height: 34px;
  background: #fff;
  border-bottom: 1px solid #d8dce5;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.06);
}
</style>
