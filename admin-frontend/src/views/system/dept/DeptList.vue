<template>
  <div class="page-card">
    <!-- 工具栏 -->
    <div class="toolbar">
      <div class="toolbar-left">
        <el-button type="primary" :icon="Plus" @click="handleAdd(null)">新增根部门</el-button>
        <el-button :icon="Sort" @click="toggleExpand">展开/折叠</el-button>
      </div>
    </div>

    <!-- 部门树表格 -->
    <el-table
      v-loading="loading"
      :data="deptTree"
      row-key="id"
      border
      stripe
      :default-expand-all="isExpandAll"
      :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
    >
      <el-table-column prop="name" label="部门名称" width="220" show-overflow-tooltip />
      <el-table-column prop="orderNum" label="排序" width="80" align="center" />
      <el-table-column prop="leader" label="负责人" width="120" />
      <el-table-column prop="phone" label="联系电话" width="140" />
      <el-table-column prop="email" label="邮箱" width="200" show-overflow-tooltip />
      <el-table-column prop="status" label="状态" width="100" align="center">
        <template #default="{ row }">
          <el-tag :type="row.status === 1 ? 'success' : 'danger'" size="small">
            {{ row.status === 1 ? "正常" : "禁用" }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="180" />
      <el-table-column label="操作" width="180" fixed="right" align="center">
        <template #default="{ row }">
          <div class="table-actions">
            <el-button type="primary" size="small" link :icon="Edit" @click="handleEdit(row)">编辑</el-button>
            <el-button type="success" size="small" link :icon="Plus" @click="handleAdd(row)">新增</el-button>
            <el-button type="danger" size="small" link :icon="Delete" @click="handleDelete(row)">删除</el-button>
          </div>
        </template>
      </el-table-column>
    </el-table>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="550px"
      :close-on-click-modal="false"
      @closed="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="100px">
        <el-form-item label="上级部门">
          <el-input :model-value="form.parentName" disabled />
        </el-form-item>
        <el-form-item label="部门名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入部门名称" />
        </el-form-item>
        <el-form-item label="排序" prop="orderNum">
          <el-input-number v-model="form.orderNum" :min="0" :max="999" />
        </el-form-item>
        <el-form-item label="负责人">
          <el-input v-model="form.leader" placeholder="请输入负责人" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="form.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="邮箱">
          <el-input v-model="form.email" placeholder="请输入邮箱" />
        </el-form-item>
        <el-form-item label="状态">
          <el-radio-group v-model="form.status">
            <el-radio :value="1">正常</el-radio>
            <el-radio :value="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue"
import { Plus, Sort, Edit, Delete } from "@element-plus/icons-vue"
import { ElMessage, ElMessageBox } from "element-plus"
import { getDeptTree, addDept, updateDept, deleteDept } from "@/api/dept"

const loading = ref(false)
const deptTree = ref([])
const isExpandAll = ref(true)

const dialogVisible = ref(false)
const dialogTitle = ref("")
const submitLoading = ref(false)
const formRef = ref(null)

const form = reactive({
  id: undefined,
  parentId: 0,
  parentName: "无（根部门）",
  name: "",
  orderNum: 0,
  leader: "",
  phone: "",
  email: "",
  status: 1
})

const formRules = {
  name: [{ required: true, message: "请输入部门名称", trigger: "blur" }],
  orderNum: [{ required: true, message: "请输入排序", trigger: "blur" }]
}

function toggleExpand() {
  isExpandAll.value = !isExpandAll.value
}

async function loadDeptTree() {
  loading.value = true
  try {
    const res = await getDeptTree()
    deptTree.value = res.data || []
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

function handleAdd(row) {
  dialogTitle.value = row ? `新增子部门（父：${row.name}）` : "新增根部门"
  form.parentId = row ? row.id : 0
  form.parentName = row ? row.name : "无（根部门）"
  dialogVisible.value = true
}

function handleEdit(row) {
  dialogTitle.value = "编辑部门"
  Object.assign(form, {
    ...row,
    parentName: row.parentId === 0 ? "无（根部门）" : (row.parentName || "")
  })
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitLoading.value = true
  try {
    if (form.id) {
      await updateDept(form)
      ElMessage.success("更新成功")
    } else {
      await addDept(form)
      ElMessage.success("新增成功")
    }
    dialogVisible.value = false
    loadDeptTree()
  } catch (error) {
    console.error(error)
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除部门 [${row.name}] 吗？`, "警告", {
    type: "warning"
  }).then(async () => {
    await deleteDept(row.id)
    ElMessage.success("删除成功")
    loadDeptTree()
  })
}

function resetForm() {
  Object.assign(form, {
    id: undefined, parentId: 0, parentName: "无（根部门）",
    name: "", orderNum: 0, leader: "", phone: "", email: "", status: 1
  })
  formRef.value?.clearValidate()
}

onMounted(() => {
  loadDeptTree()
})
</script>
