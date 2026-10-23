import request from "@/utils/request"

// ==================== 数据统计 ====================

// 获取首页统计数据
export function getDashboardData() {
  return request({
    url: "/dashboard/statistics",
    method: "get"
  })
}

// ==================== 文件上传 ====================

// 通用文件上传
export function uploadFile(file) {
  const formData = new FormData()
  formData.append("file", file)
  return request({
    url: "/common/upload",
    method: "post",
    data: formData,
    headers: { "Content-Type": "multipart/form-data" }
  })
}
