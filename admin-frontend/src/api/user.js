import request from "@/utils/request"

// ==================== 用户管理 ====================

// 分页查询用户列表
export function getUserList(params) {
  return request({
    url: "/system/user/list",
    method: "get",
    params
  })
}

// 获取用户详情
export function getUserById(id) {
  return request({
    url: `/system/user/${id}`,
    method: "get"
  })
}

// 新增用户
export function addUser(data) {
  return request({
    // 后端已改为 @PostMapping(""),映射 /system/user
    url: "/system/user",
    method: "post",
    data
  })
}

// 编辑用户
export function updateUser(data) {
  return request({
    url: "/system/user",
    method: "put",
    data
  })
}

// 删除用户
export function deleteUser(ids) {
  return request({
    url: `/system/user/${ids}`,
    method: "delete"
  })
}

// 重置用户密码
export function resetPassword(id, password) {
  return request({
    url: `/system/user/${id}/password`,
    method: "put",
    // 后端 @RequestBody 接收的是 String 裸值,传 { password } 对象会 400
    data: password
  })
}

// 修改用户状态
export function changeUserStatus(id, status) {
  return request({
    url: `/system/user/${id}/status`,
    method: "put",
    // 后端 @RequestBody 接收的是 String 裸值,传 { status } 对象会 400
    data: String(status)
  })
}

// 导出用户
export function exportUser(params) {
  return request({
    url: "/system/user/export",
    method: "get",
    params,
    responseType: "blob"
  })
}

// 获取用户分配角色列表
export function getUserRoles(id) {
  return request({
    url: `/system/user/${id}/roles`,
    method: "get"
  })
}

// 分配用户角色
export function assignUserRoles(id, roleIds) {
  return request({
    url: `/system/user/${id}/roles`,
    method: "put",
    // 后端 @RequestBody 接收的是 List<Long> 裸数组,传 { roleIds } 对象会 400
    data: roleIds
  })
}
