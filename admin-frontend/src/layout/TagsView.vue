<template>
  <div class="tags-view">
    <el-scrollbar>
      <div class="tags-wrapper">
        <el-tag
          v-for="tag in visitedViews"
          :key="tag.path"
          :closable="tag.path !== '/dashboard'"
          :effect="isActive(tag) ? 'dark' : 'plain'"
          :type="isActive(tag) ? '' : 'info'"
          size="default"
          class="tag-item"
          @click="navigateTo(tag)"
          @close="closeTag(tag)"
        >
          {{ tag.meta?.title || tag.name }}
        </el-tag>
      </div>
    </el-scrollbar>

    <!-- 右键菜单 -->
    <div
      v-show="contextMenuVisible"
      class="context-menu"
      :style="{ left: contextMenuLeft + 'px', top: contextMenuTop + 'px' }"
    >
      <div class="menu-item" @click="closeCurrentTag">关闭当前</div>
      <div class="menu-item" @click="closeOtherTags">关闭其他</div>
      <div class="menu-item" @click="closeAllTags">关闭所有</div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount } from "vue"
import { useRoute, useRouter } from "vue-router"
import { useAppStore } from "@/store/app"

const route = useRoute()
const router = useRouter()
const appStore = useAppStore()

const visitedViews = ref([])
const contextMenuVisible = ref(false)
const contextMenuLeft = ref(0)
const contextMenuTop = ref(0)
const selectedTag = ref({})

// 添加当前路由到标签页
function addView() {
  const view = {
    path: route.path,
    name: route.name,
    meta: { ...route.meta }
  }
  const exist = visitedViews.value.find((v) => v.path === view.path)
  if (!exist) {
    visitedViews.value.push(view)
    appStore.addTagView(view)
  }
}

// 是否当前激活的路由
function isActive(tag) {
  return tag.path === route.path
}

// 跳转到标签
function navigateTo(tag) {
  router.push(tag.path)
}

// 关闭标签
function closeTag(tag) {
  const index = visitedViews.value.findIndex((v) => v.path === tag.path)
  visitedViews.value.splice(index, 1)
  appStore.removeTagView(tag.path)
  // 如果关闭的是当前页面，跳转到最后一个标签
  if (isActive(tag) && visitedViews.value.length > 0) {
    const last = visitedViews.value[visitedViews.value.length - 1]
    router.push(last.path)
  }
}

function closeCurrentTag() {
  closeTag(selectedTag.value)
  contextMenuVisible.value = false
}

function closeOtherTags() {
  visitedViews.value = visitedViews.value.filter(
    (v) => v.path === selectedTag.value.path || v.path === "/dashboard"
  )
  contextMenuVisible.value = false
  if (!isActive(selectedTag.value)) {
    router.push(selectedTag.value.path)
  }
}

function closeAllTags() {
  visitedViews.value = visitedViews.value.filter((v) => v.path === "/dashboard")
  contextMenuVisible.value = false
  router.push("/dashboard")
}

// 右键菜单
function handleContextMenu(e, tag) {
  e.preventDefault()
  selectedTag.value = tag
  contextMenuVisible.value = true
  contextMenuLeft.value = e.clientX
  contextMenuTop.value = e.clientY
}

// 点击空白关闭右键菜单
function closeContextMenu() {
  contextMenuVisible.value = false
}

onMounted(() => {
  document.addEventListener("click", closeContextMenu)
})

onBeforeUnmount(() => {
  document.removeEventListener("click", closeContextMenu)
})

// 监听路由变化，自动添加标签
watch(
  () => route.path,
  () => {
    addView()
  },
  { immediate: true }
)
</script>

<style scoped>
.tags-view {
  height: 34px;
  background: #fff;
  display: flex;
  align-items: center;
}

.tags-wrapper {
  display: flex;
  align-items: center;
  padding: 0 8px;
  gap: 4px;
  height: 100%;
  white-space: nowrap;
}

.tag-item {
  cursor: pointer;
  border-radius: 2px;
  font-size: 12px;
  height: 26px;
  line-height: 26px;
}

.context-menu {
  position: fixed;
  z-index: 9999;
  background: #fff;
  border-radius: 4px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  padding: 4px 0;
  min-width: 120px;
}

.menu-item {
  padding: 6px 16px;
  font-size: 13px;
  cursor: pointer;
  color: #333;
}

.menu-item:hover {
  background: #f5f7fa;
  color: #409EFF;
}
</style>
