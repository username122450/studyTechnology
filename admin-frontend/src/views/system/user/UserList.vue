<template>
  <div class="page-card">
    <!-- 搜索区域 -->
    <div class="search-form">
      <el-input
        v-model="queryParams.username"
        placeholder="用户名"
        clearable
        @keyup.enter="handleSearch"
      />
      <el-input
        v-model="queryParams.phone"
        placeholder="手机号"
        clearable
        @keyup.enter="handleSearch"
      />
      <el-select v-model="queryParams.status" placeholder="状态" clearable>
        <el-option label="正常" :value="1" />
        <el-option label="禁用" :value="0" />
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
        <el-button type="primary" :icon="Plus" @click="handleAdd">新增</el-button>
        <el-button type="danger" :icon="Delete" :disabled="selectedIds.length === 0" @click="handleBatchDelete">
          批量删除
        </el-button>
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
      <el-table-column prop="username" label="用户名" width="120" />
      <el-table-column prop="nickName" label="昵称" width="120" />
      <el-table-column prop="deptName" label="部门" width="140" show-overflow-tooltip />
      <el-table-column prop="phone" label="手机号" width="130" />
      <el-table-column prop="email" label="邮箱" width="180" show-overflow-tooltip />
      <el-table-column prop="status" label="状态" width="80" align="center">
        <template #default="{ row }">
          <el-switch
            :model-value="row.status"
            :active-value="1"
            :inactive-value="0"
            @change="(val) => handleStatusChange(row, val)"
          />
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="180" />
      <el-table-column label="操作" width="260" fixed="right" align="center">
        <template #default="{ row }">
          <div class="table-actions">
            <el-button type="primary" size="small" link :icon="Edit" @click="handleEdit(row)">编辑</el-button>
            <el-button type="warning" size="small" link :icon="Key" @click="handleResetPwd(row)">重置密码</el-button>
            <el-button type="success" size="small" link :icon="Avatar" @click="handleAssignRole(row)">分配角色</el-button>
            <el-button type="danger" size="small" link :icon="Delete" @click="handleDelete(row)">删除</el-button>
          </div>
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
        @size-change="handleSearch"
        @current-change="handleSearch"
      />
    </div>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="550px"
      :close-on-click-modal="false"
      @closed="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="80px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" :disabled="!!form.id" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="昵称" prop="nickName">
          <el-input v-model="form.nickName" placeholder="请输入昵称" />
        </el-form-item>
        <el-form-item label="密码" prop="password" v-if="!form.id">
          <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" />
        </el-form-item>
        <el-form-item label="部门" prop="deptId">
          <el-tree-select
            v-model="form.deptId"
            :data="deptTree"
            :props="{ label: 'name', value: 'id' }"
            placeholder="请选择部门"
            check-strictly
            clearable
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="手机号" prop="phone">
          <el-input v-model="form.phone" placeholder="请输入手机号" />
        </el-form-item>
        <el-form-item label="邮箱" prop="email">
          <el-input v-model="form.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="性别" prop="sex">
          <el-radio-group v-model="form.sex">
            <el-radio :value="0">男</el-radio>
            <el-radio :value="1">女</el-radio>
            <el-radio :value="2">未知</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">正常</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>

    <!-- 重置密码对话框 -->
    <el-dialog v-model="pwdDialogVisible" title="重置密码" width="400px">
      <el-form ref="pwdFormRef" :model="pwdForm" :rules="pwdFormRules" label-width="80px">
        <el-form-item label="新密码" prop="password">
          <el-input v-model="pwdForm.password" type="password" show-password placeholder="请输入新密码" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="pwdDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleConfirmResetPwd">确定</el-button>
      </template>
    </el-dialog>

    <!-- 分配角色对话框 -->
    <el-dialog v-model="roleDialogVisible" title="分配角色" width="450px">
      <el-checkbox-group v-model="selectedRoleIds">
        <el-checkbox
          v-for="role in allRoles"
          :key="role.id"
          :label="role.id"
          :value="role.id"
        >
          {{ role.roleName }}
        </el-checkbox>
      </el-checkbox-group>
      <template #footer>
        <el-button @click="roleDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleConfirmAssignRole">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue"
import {
  Search, Refresh, Plus, Delete, Download, Edit, Key, Avatar
} from "@element-plus/icons-vue"
import { ElMessage, ElMessageBox } from "element-plus"
import {
  getUserList, addUser, updateUser, deleteUser,
  resetPassword, changeUserStatus, exportUser, getUserRoles
} from "@/api/user"
import { getAllRoles } from "@/api/role"
import { getDeptTree } from "@/api/dept"
import { assignUserRoles } from "@/api/user"

// ========== 搜索参数 ==========
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  username: "",
  phone: "",
  status: 1,
  beginTime: "",
  endTime: ""
})
const dateRange = ref([])

// ========== 表格 ==========
const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const selectedIds = ref([])

// ========== 新增/编辑 ==========
const dialogVisible = ref(false)
const dialogTitle = ref("")
const submitLoading = ref(false)
const formRef = ref(null)
const form = reactive({
  id: undefined,
  username: "",
  nickName: "",
  password: "",
  deptId: undefined,
  phone: "",
  email: "",
  sex: 0,
  status: 1,
  remark: ""
})
const formRules = {
  username: [
    { required: true, message: "请输入用户名", trigger: "blur" },
    { pattern: /^[a-zA-Z][a-zA-Z0-9_]{3,19}$/, message: "以字母开头，4-20位字母数字下划线", trigger: "blur" }
  ],
  nickName: [{ required: true, message: "请输入昵称", trigger: "blur" }],
  password: [
    { required: true, message: "请输入密码", trigger: "blur" },
    { min: 6, max: 20, message: "密码长度6-20位", trigger: "blur" }
  ],
  phone: [{ pattern: /^1[3-9]\d{9}$/, message: "手机号格式不正确", trigger: "blur" }],
  email: [{ type: "email", message: "邮箱格式不正确", trigger: "blur" }]
}

// ========== 部门树 ==========
const deptTree = ref([])

// ========== 重置密码 ==========
const pwdDialogVisible = ref(false)
const pwdFormRef = ref(null)
const currentUserId = ref(null)
const pwdForm = reactive({ password: "" })
const pwdFormRules = {
  password: [
    { required: true, message: "请输入新密码", trigger: "blur" },
    { min: 6, max: 20, message: "密码长度6-20位", trigger: "blur" }
  ]
}

// ========== 分配角色 ==========
const roleDialogVisible = ref(false)
const selectedRoleIds = ref([])
const allRoles = ref([])
const currentAssignUserId = ref(null)

// ========== 加载表格数据 ==========
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
    const params = { ...queryParams }
    // 状态被清空时,后端 int 会默认成 0(只查禁用),这里兜底回"正常"
    if (params.status === "" || params.status == null) params.status = 1
    const res = await getUserList(params)
    tableData.value = res.data.records || res.data.list || []
    total.value = res.data.total || 0
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

// ========== 加载部门树 ==========
async function loadDeptTree() {
  try {
    const res = await getDeptTree()
    deptTree.value = res.data || []
  } catch (error) {
    console.error(error)
  }
}

// ========== 搜索 ==========
function handleSearch() {
  queryParams.pageNum = 1
  loadData()
}

function handleReset() {
  Object.assign(queryParams, {
    pageNum: 1,
    pageSize: 10,
    username: "",
    phone: "",
    status: 1,
    beginTime: "",
    endTime: ""
  })
  dateRange.value = []
  loadData()
}

// ========== 勾选 ==========
function handleSelectionChange(selection) {
  selectedIds.value = selection.map((item) => item.id)
}

// ========== 新增 ==========
function handleAdd() {
  dialogTitle.value = "新增用户"
  dialogVisible.value = true
}

// ========== 编辑 ==========
function handleEdit(row) {
  dialogTitle.value = "编辑用户"
  Object.assign(form, row, { password: "" })
  dialogVisible.value = true
}

// ========== 提交 ==========
async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitLoading.value = true
  try {
    if (form.id) {
      await updateUser(form)
      ElMessage.success("更新成功")
    } else {
      await addUser(form)
      ElMessage.success("新增成功")
    }
    dialogVisible.value = false
    loadData()
  } catch (error) {
    console.error(error)
  } finally {
    submitLoading.value = false
  }
}

// ========== 删除 ==========
function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除用户 [${row.username}] 吗？`, "警告", {
    type: "warning"
  }).then(async () => {
    await deleteUser(row.id)
    ElMessage.success("删除成功")
    loadData()
  })
}

function handleBatchDelete() {
  if (selectedIds.value.length === 0) {
    ElMessage.warning("请至少选择一条数据")
    return
  }
  ElMessageBox.confirm(`确定要删除选中的 ${selectedIds.value.length} 条数据吗？`, "警告", {
    type: "warning"
  }).then(async () => {
    await deleteUser(selectedIds.value.join(","))
    ElMessage.success("删除成功")
    loadData()
  })
}

// ========== 状态切换 ==========
async function handleStatusChange(row, val) {
  try {
    await changeUserStatus(row.id, val)
    row.status = val
    ElMessage.success("状态更新成功")
  } catch (error) {
    console.error(error)
  }
}

// ========== 重置密码 ==========
function handleResetPwd(row) {
  currentUserId.value = row.id
  pwdForm.password = ""
  pwdDialogVisible.value = true
}

async function handleConfirmResetPwd() {
  const valid = await pwdFormRef.value.validate().catch(() => false)
  if (!valid) return
  try {
    await resetPassword(currentUserId.value, pwdForm.password)
    ElMessage.success("密码重置成功")
    pwdDialogVisible.value = false
  } catch (error) {
    console.error(error)
  }
}

// ========== 分配角色 ==========
async function handleAssignRole(row) {
  currentAssignUserId.value = row.id
  try {
    // 获取所有角色
    const res1 = await getAllRoles()
    allRoles.value = res1.data || []
    // 获取用户已有角色
    const res2 = await getUserRoles(row.id)
    selectedRoleIds.value = res2.data || []
    roleDialogVisible.value = true
  } catch (error) {
    console.error(error)
  }
}

async function handleConfirmAssignRole() {
  try {
    await assignUserRoles(currentAssignUserId.value, selectedRoleIds.value)
    ElMessage.success("角色分配成功")
    roleDialogVisible.value = false
  } catch (error) {
    console.error(error)
  }
}

// ========== 导出 ==========
async function handleExport() {
  try {
    const res = await exportUser(queryParams)
    const blob = new Blob([res])
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement("a")
    link.href = url
    link.download = "用户数据.xlsx"
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success("导出成功")
  } catch (error) {
    console.error(error)
  }
}

// ========== 重置表单 ==========
function resetForm() {
  Object.assign(form, {
    id: undefined, username: "", nickName: "", password: "",
    deptId: undefined, phone: "", email: "", sex: 0, status: 1, remark: ""
  })
  formRef.value?.clearValidate()
}

onMounted(() => {
  loadData()
  loadDeptTree()
})
</script>
