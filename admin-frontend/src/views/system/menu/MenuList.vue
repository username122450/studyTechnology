<template>
  <div class="page-card">
    <!-- 工具栏 -->
    <div class="toolbar">
      <div class="toolbar-left">
        <el-button type="primary" :icon="Plus" @click="handleAdd(null)">新增根菜单</el-button>
        <el-button :icon="Sort" @click="toggleExpand">展开/折叠</el-button>
      </div>
      <div class="toolbar-right">
        <el-tooltip content="菜单显示">
          <el-switch
            v-model="menuVisible"
            active-text="显示"
            inactive-text="隐藏"
            :active-value="true"
            :inactive-value="false"
            @change="loadMenuTree"
          />
        </el-tooltip>
      </div>
    </div>

    <!-- 菜单树表格 -->
    <el-table
      v-loading="loading"
      :data="menuTree"
      row-key="id"
      border
      stripe
      :default-expand-all="isExpandAll"
      :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
    >
      <el-table-column prop="name" label="菜单名称" width="200" show-overflow-tooltip />
      <el-table-column prop="icon" label="图标" width="80" align="center">
        <template #default="{ row }">
          <el-icon v-if="row.icon"><component :is="row.icon" /></el-icon>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column prop="orderNum" label="排序" width="70" align="center" />
      <el-table-column prop="perms" label="权限标识" width="180" show-overflow-tooltip />
      <el-table-column prop="path" label="路由地址" width="180" show-overflow-tooltip />
      <el-table-column prop="component" label="组件路径" width="200" show-overflow-tooltip />
      <el-table-column prop="menuType" label="类型" width="80" align="center">
        <template #default="{ row }">
          <el-tag :type="typeTag(row.menuType)" size="small">
            {{ typeText(row.menuType) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="visible" label="可见" width="70" align="center">
        <template #default="{ row }">
          <span :style="{ color: row.visible ? '#67C23A' : '#F56C6C' }">
            {{ row.visible ? "是" : "否" }}
          </span>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="180" fixed="right" align="center">
        <template #default="{ row }">
          <div class="table-actions">
            <el-button type="primary" size="small" link :icon="Edit" @click="handleEdit(row)">编辑</el-button>
            <el-button type="success" size="small" link :icon="Plus" @click="handleAdd(row)" v-if="row.menuType !== 2">
              新增
            </el-button>
            <el-button type="danger" size="small" link :icon="Delete" @click="handleDelete(row)">删除</el-button>
          </div>
        </template>
      </el-table-column>
    </el-table>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="650px"
      :close-on-click-modal="false"
      @closed="resetForm"
    >
      <el-form ref="formRef" :model="form" :rules="formRules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="24">
            <el-form-item label="上级菜单" prop="parentName">
              <el-input :model-value="form.parentName" disabled placeholder="无（根菜单）" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="菜单类型" prop="menuType">
              <el-radio-group v-model="form.menuType" @change="onMenuTypeChange">
                <el-radio :value="0">目录</el-radio>
                <el-radio :value="1">菜单</el-radio>
                <el-radio :value="2">按钮</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="菜单名称" prop="name">
              <el-input v-model="form.name" placeholder="请输入菜单名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="排序" prop="orderNum">
              <el-input-number v-model="form.orderNum" :min="0" :max="999" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.menuType !== 2">
            <el-form-item label="图标">
              <el-input v-model="form.icon" placeholder="请输入Element图标名" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.menuType !== 2">
            <el-form-item label="路由地址" prop="path">
              <el-input v-model="form.path" placeholder="请输入路由地址" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.menuType === 1">
            <el-form-item label="组件路径">
              <el-input v-model="form.component" placeholder="请输入组件路径" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="权限标识" v-if="form.menuType !== 0">
              <el-input v-model="form.perms" placeholder="请输入权限标识" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.menuType !== 2">
            <el-form-item label="是否可见">
              <el-radio-group v-model="form.visible">
                <el-radio :value="true">显示</el-radio>
                <el-radio :value="false">隐藏</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.menuType !== 2">
            <el-form-item label="是否缓存">
              <el-radio-group v-model="form.cache">
                <el-radio :value="true">缓存</el-radio>
                <el-radio :value="false">不缓存</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
        </el-row>
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
import { getMenuTree, addMenu, updateMenu, deleteMenu } from "@/api/menu"

const loading = ref(false)
const menuTree = ref([])
const isExpandAll = ref(true)
const menuVisible = ref(true)

const dialogVisible = ref(false)
const dialogTitle = ref("")
const submitLoading = ref(false)
const formRef = ref(null)

const form = reactive({
  id: undefined,
  parentId: 0,
  parentName: "",
  name: "",
  menuType: 0,
  icon: "",
  orderNum: 0,
  path: "",
  component: "",
  perms: "",
  visible: true,
  isCache: false
})

const formRules = {
  name: [{ required: true, message: "请输入菜单名称", trigger: "blur" }],
  path: [{ required: true, message: "请输入路由地址", trigger: "blur" }],
  menuType: [{ required: true, message: "请选择菜单类型", trigger: "change" }],
  orderNum: [{ required: true, message: "请输入排序", trigger: "blur" }]
}

function typeTag(type) {
  return { 0: "", 1: "success", 2: "warning" }[type]
}

function typeText(type) {
  return { 0: "目录", 1: "菜单", 2: "按钮" }[type]
}

function toggleExpand() {
  isExpandAll.value = !isExpandAll.value
}

function onMenuTypeChange(val) {
  if (val === 2) {
    form.path = ""
    form.component = ""
    form.icon = ""
    form.visible = true
    form.isCache = false
  }
}

async function loadMenuTree() {
  loading.value = true
  try {
    const res = await getMenuTree({ visible: menuVisible.value })
    menuTree.value = res.data || []
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

function handleAdd(row) {
  dialogTitle.value = row ? `新增子菜单（父：${row.name}）` : "新增根菜单"
  form.parentId = row ? row.id : 0
  form.parentName = row ? row.name : "无（根菜单）"
  dialogVisible.value = true
}

function handleEdit(row) {
  dialogTitle.value = "编辑菜单"
  Object.assign(form, row, {
    parentName: row.parentId === 0 ? "无（根菜单）" : (row.parentName || "")
  })
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value.validate().catch(() => false)
  if (!valid) return
  submitLoading.value = true
  try {
    if (form.id) {
      await updateMenu(form)
      ElMessage.success("更新成功")
    } else {
      await addMenu(form)
      ElMessage.success("新增成功")
    }
    dialogVisible.value = false
    loadMenuTree()
  } catch (error) {
    console.error(error)
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除菜单 [${row.name}] 吗？若存在子菜单也将一并删除。`, "警告", {
    type: "warning"
  }).then(async () => {
    await deleteMenu(row.id)
    ElMessage.success("删除成功")
    loadMenuTree()
  })
}

function resetForm() {
  Object.assign(form, {
    id: undefined, parentId: 0, parentName: "", name: "", menuType: 0,
    icon: "", orderNum: 0, path: "", component: "", perms: "",
    visible: true, isCache: false
  })
  formRef.value?.clearValidate()
}

onMounted(() => {
  loadMenuTree()
})
</script>
