<template>
  <div class="page-card">
    <!-- 搜索区域 -->
    <div class="search-form">
      <el-input v-model="queryParams.title" placeholder="操作模块" clearable @keyup.enter="loadData" />
      <el-input v-model="queryParams.operName" placeholder="操作人员" clearable @keyup.enter="loadData" />
      <el-select v-model="queryParams.status" placeholder="操作状态" clearable>
        <el-option label="成功" :value="1" />
        <el-option label="失败" :value="0" />
      </el-select>
      <el-date-picker
        v-model="dateRange"
        type="daterange"
        range-separator="至"
        start-placeholder="开始日期"
        end-placeholder="结束日期"
        value-format="YYYY-MM-DD"
      />
      <el-button type="primary" :icon="Search" @click="handleSearch">搜索</el-button>
      <el-button :icon="Refresh" @click="handleReset">重置</el-button>
    </div>

    <!-- 工具栏 -->
    <div class="toolbar">
      <div class="toolbar-left">
        <el-button type="danger" :icon="Delete" :disabled="selectedIds.length === 0" @click="handleBatchDelete">
          批量删除
        </el-button>
        <el-button type="warning" :icon="Delete" @click="handleClear">清空日志</el-button>
        <el-button :icon="Download" @click="handleExport">导出</el-button>
      </div>
    </div>

    <!-- 表格 -->
    <el-table
      v-loading="loading"
      :data="tableData"
      border
      stripe
      @selection-change="handleSelectionChange"
    >
      <el-table-column type="selection" width="45" align="center" />
      <el-table-column prop="id" label="ID" width="70" align="center" />
      <el-table-column prop="title" label="操作模块" width="150" show-overflow-tooltip />
      <el-table-column prop="operName" label="操作人员" width="120" />
      <el-table-column prop="requestMethod" label="请求方式" width="90" align="center">
        <template #default="{ row }">
          <el-tag :type="methodTag(row.requestMethod)" size="small">
            {{ row.requestMethod }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="operUrl" label="请求URL" show-overflow-tooltip />
      <el-table-column prop="operIp" label="IP地址" width="140" />
      <el-table-column prop="operLocation" label="操作地点" width="140" show-overflow-tooltip />
      <el-table-column prop="status" label="状态" width="80" align="center">
        <template #default="{ row }">
          <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
            {{ row.status === 1 ? "成功" : "失败" }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="costTime" label="耗时(ms)" width="90" align="center">
        <template #default="{ row }">
          <span v-if="row.costTime" :style="{ color: row.costTime > 1000 ? '#F56C6C' : '#67C23A' }">
            {{ row.costTime }}
          </span>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column prop="operTime" label="操作时间" width="180" />

      <el-table-column label="操作" width="100" fixed="right" align="center">
        <template #default="{ row }">
          <el-button type="primary" size="small" link :icon="View" @click="handleDetail(row)">详情</el-button>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <div class="pagination-container">
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="loadData"
        @current-change="loadData"
      />
    </div>

    <!-- 详情对话框 -->
    <el-dialog v-model="detailVisible" title="操作日志详情" width="700px">
      <el-descriptions :column="2" border size="small">
        <el-descriptions-item label="操作模块">{{ detail.title }}</el-descriptions-item>
        <el-descriptions-item label="操作人员">{{ detail.operName }}</el-descriptions-item>
        <el-descriptions-item label="请求方式">{{ detail.requestMethod }}</el-descriptions-item>
        <el-descriptions-item label="请求URL">{{ detail.operUrl }}</el-descriptions-item>
        <el-descriptions-item label="IP地址">{{ detail.operIp }}</el-descriptions-item>
        <el-descriptions-item label="操作地点">{{ detail.operLocation }}</el-descriptions-item>
        <el-descriptions-item label="操作状态">
          <el-tag :type="detail.status === 1 ? 'success' : 'danger'" size="small">
            {{ detail.status === 1 ? "成功" : "失败" }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="耗时">{{ detail.costTime }}ms</el-descriptions-item>
        <el-descriptions-item label="操作方法" :span="2">{{ detail.method }}</el-descriptions-item>
        <el-descriptions-item label="请求参数" :span="2">
          <div class="json-content">{{ formatJson(detail.operParam) }}</div>
        </el-descriptions-item>
        <el-descriptions-item label="返回结果" :span="2">
          <div class="json-content">{{ formatJson(detail.jsonResult) }}</div>
        </el-descriptions-item>
        <el-descriptions-item label="错误信息" :span="2" v-if="detail.errorMsg">
          <span style="color: #F56C6C;">{{ detail.errorMsg }}</span>
        </el-descriptions-item>
        <el-descriptions-item label="操作时间">{{ detail.operTime }}</el-descriptions-item>
        <el-descriptions-item label="消耗时间">{{ detail.costTime }}ms</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue"
import { Search, Refresh, Delete, Download, View } from "@element-plus/icons-vue"
import { ElMessage, ElMessageBox } from "element-plus"
import { getOperLogList, deleteOperLog, clearOperLog, exportOperLog } from "@/api/log"

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const selectedIds = ref([])
const dateRange = ref([])

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  title: "",
  operName: "",
  status: 1,
  beginTime: "",
  endTime: ""
})

const detailVisible = ref(false)
const detail = ref({})

function methodTag(method) {
  const map = { GET: "", POST: "success", PUT: "warning", DELETE: "danger" }
  return map[method] || ""
}

function formatJson(str) {
  if (!str) return "-"
  try {
    return JSON.stringify(JSON.parse(str), null, 2)
  } catch {
    return str
  }
}

async function loadData() {
  loading.value = true
  try {
    if (dateRange.value && dateRange.value.length === 2) {
      queryParams.beginTime = dateRange.value[0]
      queryParams.endTime = dateRange.value[1]
    } else {
      queryParams.beginTime = ""
      queryParams.endTime = ""
    }
    const res = await getOperLogList(queryParams)
    tableData.value = res.data.records || res.data.list || []
    total.value = res.data.total || 0
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  queryParams.pageNum = 1
  loadData()
}

function handleReset() {
  Object.assign(queryParams, {
    pageNum: 1, pageSize: 10, title: "", operName: "",
    status: 1, beginTime: "", endTime: ""
  })
  dateRange.value = []
  loadData()
}

function handleSelectionChange(selection) {
  selectedIds.value = selection.map((item) => item.id)
}

function handleBatchDelete() {
  if (selectedIds.value.length === 0) return ElMessage.warning("请至少选择一条数据")
  ElMessageBox.confirm(`确定要删除选中的 ${selectedIds.value.length} 条日志吗？`, "警告", { type: "warning" }).then(async () => {
    await deleteOperLog(selectedIds.value.join(","))
    ElMessage.success("删除成功")
    loadData()
  })
}

function handleClear() {
  ElMessageBox.confirm("确定要清空所有操作日志吗？此操作不可恢复！", "危险操作", {
    type: "error",
    confirmButtonText: "确定清空",
    cancelButtonText: "取消"
  }).then(async () => {
    await clearOperLog()
    ElMessage.success("清空成功")
    loadData()
  })
}

function handleDetail(row) {
  detail.value = row
  detailVisible.value = true
}

async function handleExport() {
  try {
    const res = await exportOperLog(queryParams)
    const blob = new Blob([res])
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement("a")
    link.href = url
    link.download = "操作日志.xlsx"
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success("导出成功")
  } catch (error) {
    console.error(error)
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.json-content {
  max-height: 200px;
  overflow-y: auto;
  white-space: pre-wrap;
  word-break: break-all;
  font-family: "Courier New", monospace;
  font-size: 12px;
  background: #f5f7fa;
  padding: 8px;
  border-radius: 4px;
}
</style>
