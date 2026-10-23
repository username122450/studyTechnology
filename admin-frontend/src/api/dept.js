import request from "@/utils/request"

// ==================== 部门管理 ====================

// 获取部门树
export function getDeptTree(params) {
  return request({
    url: "/system/dept/tree",
    method: "get",
    params
  })
}

// 获取部门详情
export function getDeptById(id) {
  return request({
    url: `/system/dept/${id}`,
    method: "get"
  })
}

// 新增部门
export function addDept(data) {
  return request({
    url: "/system/dept",
    method: "post",
    data
  })
}

// 编辑部门
export function updateDept(data) {
  return request({
    url: "/system/dept",
    method: "put",
    data
  })
}

// 删除部门
export function deleteDept(id) {
  return request({
    url: `/system/dept/${id}`,
    method: "delete"
  })
}
