import { defineStore } from "pinia"
import { login, logout, getUserInfo } from "@/api/auth"
import { getToken, setToken, removeToken, setUser, getUser } from "@/utils/auth"

export const useUserStore = defineStore("user", {
  state: () => ({
    token: getToken() || "",
    userInfo: getUser() || {},
    roles: [],
    permissions: []
  }),

  actions: {
    // 登录
    async loginAction(loginForm) {
      const res = await login(loginForm)
      // 拦截器已把响应体 {code, message, data} 返回,data 就是 token 字符串本身
      const token = res.data
      if (!token) {
        throw new Error("登录失败:未返回令牌")
      }
      this.token = token
      setToken(token)
      return res
    },

    // 获取用户信息
    async getInfo() {
      const res = await getUserInfo()
      const data = res.data || {}
      // 兼容两种后端返回格式:
      //  新格式: { user, roles, permissions }
      //  旧格式: 平铺的 user 对象 { id, username, ... }(旧版后端 /auth/info 直接返回 User)
      // 若按新格式解构旧响应,user 会是 undefined → setUser(undefined) 会把字符串
      // "undefined" 写进 localStorage,下次刷新 JSON.parse 直接崩溃 → 白屏
      const user = data.user ?? (data.id ? data : null)
      if (!user || !user.id) {
        throw new Error("获取用户信息失败:响应中缺少用户数据")
      }
      // 旧格式会把 password(密码哈希)一起带回来,绝不能存入本地缓存
      const { password, ...safeUser } = user
      this.userInfo = safeUser
      this.roles = data.roles || []
      this.permissions = data.permissions || []
      setUser(safeUser)
      return res
    },

    // 退出登录
    async logoutAction() {
      try {
        await logout()
      } catch (e) {
        // 后端不可用/token 已失效时接口会失败,本地状态仍要清理
      } finally {
        this.token = ""
        this.userInfo = {}
        this.roles = []
        this.permissions = []
        removeToken()
      }
    }
  }
})
