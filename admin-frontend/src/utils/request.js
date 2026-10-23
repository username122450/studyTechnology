import axios from "axios"
import { ElMessage } from "element-plus"
import { getToken, removeToken } from "./auth"
import router from "@/router"

const service = axios.create({
  baseURL: "/api",
  timeout: 15000
})

// 请求拦截器
service.interceptors.request.use(
  (config) => {
    const token = getToken()
    if (token) {
      config.headers["Authorization"] = "Bearer " + token
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  (response) => {
    const res = response.data
    // 文件下载则直接返回
    if (response.config.responseType === "blob") {
      return res
    }
    // 统一响应码处理 (与后端约定 code=200 为成功)
    if (res.code !== 200) {
      ElMessage.error(res.message || "请求失败")
      // 401: token 过期或未登录
      if (res.code === 401) {
        removeToken()
        if (router.currentRoute.value.path !== "/login") {
          router.push("/login")
        }
      }
      return Promise.reject(new Error(res.message || "请求失败"))
    }
    return res
  },
  (error) => {
    const status = error.response?.status
    if (status === 401) {
      // 后端 JWT 过滤器直接返回的 HTTP 401:token 无效或已过期
      removeToken()
      if (router.currentRoute.value.path !== "/login") {
        ElMessage.error("登录状态已失效，请重新登录")
        router.push("/login")
      }
    } else if (error.response) {
      // 其他 HTTP 错误:弹一次后端返回的错误信息
      ElMessage.error(error.response.data?.message || `请求失败(${status})`)
    }
    // 网络错误(后端未启动等)不弹窗:由路由守卫/调用方处理,避免刷屏
    return Promise.reject(error)
  }
)

export default service
