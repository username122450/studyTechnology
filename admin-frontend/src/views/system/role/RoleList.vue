<template>
  <div class="page-card">
    <!-- 搜索区域 -->
    <div class="search-form">
      <el-input v-model="queryParams.roleName" placeholder="角色名称" clearable @keyup.enter="loadData" />
      <el-input v-model="queryParams.roleKey" placeholder="权限标识" clearable @keyup.enter="loadData" />
      <el-select v-model="queryParams.status" placeholder="状态" clearable>
        <el-option label="正常" :value="1" />
        <el-option label="禁用" :value="0" />
      </el-select>
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
      <el-table-column prop="roleName" label="角色名称" width="150" />
      <el-table-column prop="roleKey" label="权限标识" width="180" />
      <el-table-column prop="roleSort" label="排序" width="80" align="center" />
      <el-table-column prop="status" label="状态" width="100" align="center">
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
      <el-table-column prop="remark" label="备注" show-overflow-tooltip />
      <el-table-column label="操作" width="220" fixed="right" align="center">
        <template #default="{ row }">
          <div class="table-actions">
            <el-button type="primary" size="small" link :icon="Edit" @click="handleEdit(row)">编辑</el-button>
            <el-button type="success" size="small" link :icon="Menu" @click="handleAssignMenu(row)">分配权限</el-button>
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
        @size-change="loadData"
        @current-change="loadData"
      />
    </div>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="500px"
      :close-on-click-modal="false"
      @closed="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="80px">
        <el-form-item label="角色名称" prop="roleName">
          <el-input v-model="form.roleName" placeholder="请输入角色名称" />
        </el-form-item>
        <el-form-item label="权限标识" prop="roleKey">
          <el-input v-model="form.roleKey" placeholder="请输入权限标识" />
        </el-form-item>
        <el-form-item label="排序" prop="roleSort">
          <el-input-number v-model="form.roleSort" :min="0" :max="999" />
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

    <!-- 分配权限对话框 -->
    <el-dialog v-model="menuDialogVisible" title="分配菜单权限" width="450px">
      <el-tree
        ref="menuTreeRef"
        :data="menuTree"
        :props="{ label: 'name', children: 'children' }"
        node-key="id"
        show-checkbox
        default-expand-all
        check-strictly
      />
      <template #footer>
        <el-button @click="menuDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleConfirmAssignMenu">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from "vue"
import { Search, Refresh, Plus, Delete, Edit, Menu } from "@element-plus/icons-vue"
import { ElMessage, ElMessageBox } from "element-plus"
import {
  getRoleList, addRole, updateRole, deleteRole,
  changeRoleStatus, getRoleMenuIds, assignRoleMenus
} from "@/api/role"
import { getMenuTree } from "@/api/menu"

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const selectedIds = ref([])

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  roleName: "",
  roleKey: "",
  status: 1
})

// ========== 新增/编辑 ==========
const dialogVisible = ref(false)
const dialogTitle = ref("")
const submitLoading = ref(false)
const formRef = ref(null)
const form = reactive({
  id: undefined,
  roleName: "",
  roleKey: "",
  roleSort: 0,
  status: 1,
  remark: ""
})
const formRules = {
  roleName: [{ required: true, message: "请输入角色名称", trigger: "blur" }],
  roleKey: [{ required: true, message: "请输入权限标识", trigger: "blur" }],
  roleSort: [{ required: true, message: "请输入排序", trigger: "blur" }]
}

// ========== 权限分配 ==========
const menuDialogVisible = ref(false)
const menuTreeRef = ref(null)
const menuTree = ref([])
const currentRoleId = ref(null)

async function loadData() {
  loading.value = true
  try {
    const params = { ...queryParams }
    // 状态被清空时,后端 byte 会默认成 0(只查禁用),这里兜底回"正常"
    if (params.status === "" || params.status == null) params.status = 1
    const res = await getRoleList(params)
    const data = res.data
    if (Array.isArray(data)) {
      // 后端 /system/role/list 目前直接返回数组(没有 records/total),这里做兼容
      tableData.value = data
      // 后端不返回总条数,只能用当前页长度估算翻页;数据量超过一页时可能不准确
      total.value = data.length < params.pageSize
        ? (params.pageNum - 1) * params.pageSize + data.length
        : params.pageNum * params.pageSize + 1
    } else {
      tableData.value = data?.records || data?.list || []
      total.value = data?.total || 0
    }
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
  Object.assign(queryParams, { pageNum: 1, pageSize: 10, roleName: "", roleKey: "", status: 1 })
  loadData()
}

function handleSelectionChange(selection) {
  selectedIds.value = selection.map((item) => item.id)
}

function handleAdd() {
  dialogTitle.value = "新增角色"
  dialogVisible.value = true
}

function handleEdit(row) {
  dialogTitle.value = "编辑角色"
  Object.assign(form, row)
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitLoading.value = true
  try {
    if (form.id) {
      await updateRole(form)
      ElMessage.success("更新成功")
    } else {
      await addRole(form)
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

function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除角色 [${row.roleName}] 吗？`, "警告", { type: "warning" }).then(async () => {
    await deleteRole(row.id)
    ElMessage.success("删除成功")
    loadData()
  })
}

function handleBatchDelete() {
  if (selectedIds.value.length === 0) return ElMessage.warning("请至少选择一条数据")
  ElMessageBox.confirm(`确定要删除选中的 ${selectedIds.value.length} 条数据吗？`, "警告", { type: "warning" }).then(async () => {
    await deleteRole(selectedIds.value.join(","))
    ElMessage.success("删除成功")
    loadData()
  })
}

async function handleStatusChange(row, val) {
  await changeRoleStatus(row.id, val)
  row.status = val
  ElMessage.success("状态更新成功")
}

// ========== 分配权限 ==========
async function handleAssignMenu(row) {
  currentRoleId.value = row.id
  try {
    const [menuRes, roleMenuRes] = await Promise.all([
      getMenuTree(),
      getRoleMenuIds(row.id)
    ])
    menuTree.value = menuRes.data || []
    await nextTick()
    menuTreeRef.value?.setCheckedKeys(roleMenuRes.data || [])
  } catch (error) {
    console.error(error)
  }
  menuDialogVisible.value = true
}

async function handleConfirmAssignMenu() {
  const checkedKeys = menuTreeRef.value?.getCheckedKeys() || []
  const halfCheckedKeys = menuTreeRef.value?.getHalfCheckedKeys() || []
  const menuIds = [...checkedKeys, ...halfCheckedKeys]
  try {
    await assignRoleMenus(currentRoleId.value, menuIds)
    ElMessage.success("权限分配成功")
    menuDialogVisible.value = false
  } catch (error) {
    console.error(error)
  }
}

function resetForm() {
  Object.assign(form, { id: undefined, roleName: "", roleKey: "", roleSort: 0, status: 1, remark: "" })
  formRef.value?.clearValidate()
}

onMounted(() => {
  loadData()
})
</script>
