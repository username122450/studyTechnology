import { defineStore } from "pinia"

export const useAppStore = defineStore("app", {
  state: () => ({
    sidebarOpened: true,
    tagsViewList: []
  }),

  actions: {
    toggleSidebar() {
      this.sidebarOpened = !this.sidebarOpened
    },

    // 添加标签页
    addTagView(tag) {
      const exist = this.tagsViewList.find((t) => t.path === tag.path)
      if (!exist) {
        this.tagsViewList.push({ ...tag })
      }
    },

    // 删除标签页
    removeTagView(path) {
      const index = this.tagsViewList.findIndex((t) => t.path === path)
      if (index > -1) {
        this.tagsViewList.splice(index, 1)
      }
    },

    // 关闭其他标签页
    closeOtherTags(path) {
      this.tagsViewList = this.tagsViewList.filter((t) => t.path === path)
    },

    // 关闭所有标签页
    closeAllTags() {
      this.tagsViewList = []
    }
  }
})
