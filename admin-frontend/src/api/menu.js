import request from "@/utils/request"

// ==================== 菜单管理 ====================

// 获取菜单树
export function getMenuTree(params) {
  return request({
    url: "/system/menu/tree",
    method: "get",
    params
  })
}

// 获取菜单详情
export function getMenuById(id) {
  return request({
    url: `/system/menu/${id}`,
    method: "get"
  })
}

// 新增菜单
export function addMenu(data) {
  return request({
    url: "/system/menu",
    method: "post",
    data
  })
}

// 编辑菜单
export function updateMenu(data) {
  return request({
    url: "/system/menu",
    method: "put",
    data
  })
}

// 删除菜单
export function deleteMenu(id) {
  return request({
    url: `/system/menu/${id}`,
    method: "delete"
  })
}

// 获取前端路由（按当前用户权限）
export function getRouters() {
  return request({
    url: "/system/menu/routers",
    method: "get"
  })
}
