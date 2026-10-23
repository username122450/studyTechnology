import request from "@/utils/request"

// ==================== 角色管理 ====================

// 分页查询角色列表
export function getRoleList(params) {
  return request({
    url: "/system/role/list",
    method: "get",
    params
  })
}

// 获取所有角色(下拉用)
export function getAllRoles() {
  return request({
    url: "/system/role/all",
    method: "get"
  })
}

// 获取角色详情
export function getRoleById(id) {
  return request({
    url: `/system/role/${id}`,
    method: "get"
  })
}

// 新增角色
export function addRole(data) {
  return request({
    url: "/system/role",
    method: "post",
    data
  })
}

// 编辑角色
export function updateRole(data) {
  return request({
    // 后端已改为 @PutMapping(""),映射 /system/role
    url: "/system/role",
    method: "put",
    data
  })
}

// 删除角色
export function deleteRole(ids) {
  return request({
    url: `/system/role/${ids}`,
    method: "delete"
  })
}

// 修改角色状态
export function changeRoleStatus(id, status) {
  return request({
    url: `/system/role/${id}/status`,
    method: "put",
    // 后端 @RequestBody 接收的是 byte 裸值,传 { status } 对象会 400;
    // 必须按 JSON 数字发送(否则没有能解析 text/plain 为 byte 的转换器,会 415)
    data: JSON.stringify(status),
    headers: { "Content-Type": "application/json" }
  })
}

// 获取角色已有的菜单权限ID列表
export function getRoleMenuIds(id) {
  return request({
    url: `/system/role/${id}/menus`,
    method: "get"
  })
}

// 分配角色菜单权限
export function assignRoleMenus(id, menuIds) {
  return request({
    url: `/system/role/${id}/menus`,
    method: "put",
    // 后端 @RequestBody 接收的是 List<Long> 裸数组,传 { menuIds } 对象会 400
    data: menuIds
  })
}
