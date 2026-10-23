import request from "@/utils/request"

// ==================== 认证模块 ====================

// 登录
export function login(data) {
  return request({
    url: "/auth/login",
    method: "post",
    data
  })
}

// 退出登录
export function logout() {
  return request({
    url: "/auth/logout",
    method: "post"
  })
}

// 获取当前用户信息
export function getUserInfo() {
  return request({
    url: "/auth/info",
    method: "get"
  })
}

// 刷新 Token
export function refreshToken() {
  return request({
    url: "/auth/refresh",
    method: "post"
  })
}

// 修改密码
export function updatePassword(data) {
  return request({
    url: "/auth/password",
    method: "put",
    data
  })
}
