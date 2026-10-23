import request from "@/utils/request"

// ==================== 操作日志 ====================

// 分页查询操作日志
export function getOperLogList(params) {
  return request({
    url: "/system/log/list",
    method: "get",
    params
  })
}

// 删除操作日志
export function deleteOperLog(ids) {
  return request({
    url: `/system/log/${ids}`,
    method: "delete"
  })
}

// 清空操作日志
export function clearOperLog() {
  return request({
    url: "/system/log/clear",
    method: "delete"
  })
}

// 导出操作日志
export function exportOperLog(params) {
  return request({
    url: "/system/log/export",
    method: "get",
    params,
    responseType: "blob"
  })
}
