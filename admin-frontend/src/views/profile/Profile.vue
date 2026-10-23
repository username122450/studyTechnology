<template>
  <div class="page-card">
    <el-row :gutter="20">
      <!-- 左侧：基本信息 -->
      <el-col :xs="24" :md="8">
        <el-card shadow="never">
          <template #header>
            <span>个人信息</span>
          </template>
          <div class="profile-avatar">
            <el-avatar :size="80" icon="UserFilled" />
            <h3 class="profile-name">{{ userStore.userInfo?.nickName || userStore.userInfo?.username || "管理员" }}</h3>
            <p class="profile-role">{{ userStore.roles?.join(" / ") || "超级管理员" }}</p>
          </div>
          <el-divider />
          <el-descriptions :column="1" size="small" border>
            <el-descriptions-item label="用户名">{{ userStore.userInfo?.username || "-" }}</el-descriptions-item>
            <el-descriptions-item label="昵称">{{ userStore.userInfo?.nickName || "-" }}</el-descriptions-item>
            <el-descriptions-item label="手机号">{{ userStore.userInfo?.phone || "-" }}</el-descriptions-item>
            <el-descriptions-item label="邮箱">{{ userStore.userInfo?.email || "-" }}</el-descriptions-item>
            <el-descriptions-item label="部门">{{ userStore.userInfo?.deptName || "-" }}</el-descriptions-item>
            <el-descriptions-item label="创建时间">{{ userStore.userInfo?.createTime || "-" }}</el-descriptions-item>
          </el-descriptions>
        </el-card>
      </el-col>

      <!-- 右侧：修改密码 + 编辑资料 -->
      <el-col :xs="24" :md="16">
        <!-- 修改密码 -->
        <el-card shadow="never" class="profile-card">
          <template #header>
            <span>修改密码</span>
          </template>
          <el-form ref="pwdFormRef" :model="pwdForm" :rules="pwdRules" label-width="100px" style="max-width: 450px;">
            <el-form-item label="旧密码" prop="oldPassword">
              <el-input v-model="pwdForm.oldPassword" type="password" show-password placeholder="请输入旧密码" />
            </el-form-item>
            <el-form-item label="新密码" prop="newPassword">
              <el-input v-model="pwdForm.newPassword" type="password" show-password placeholder="请输入新密码" />
            </el-form-item>
            <el-form-item label="确认密码" prop="confirmPassword">
              <el-input v-model="pwdForm.confirmPassword" type="password" show-password placeholder="请再次输入新密码" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" :loading="pwdLoading" @click="handleUpdatePassword">保存修改</el-button>
            </el-form-item>
          </el-form>
        </el-card>

        <!-- 编辑资料 -->
        <el-card shadow="never" class="profile-card">
          <template #header>
            <span>编辑资料</span>
          </template>
          <el-form ref="infoFormRef" :model="infoForm" :rules="infoRules" label-width="100px" style="max-width: 450px;">
            <el-form-item label="昵称" prop="nickName">
              <el-input v-model="infoForm.nickName" placeholder="请输入昵称" />
            </el-form-item>
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="infoForm.phone" placeholder="请输入手机号" />
            </el-form-item>
            <el-form-item label="邮箱" prop="email">
              <el-input v-model="infoForm.email" placeholder="请输入邮箱" />
            </el-form-item>
            <el-form-item label="性别">
              <el-radio-group v-model="infoForm.sex">
                <el-radio :value="0">男</el-radio>
                <el-radio :value="1">女</el-radio>
                <el-radio :value="2">未知</el-radio>
              </el-radio-group>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" :loading="infoLoading" @click="handleUpdateInfo">保存修改</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive } from "vue"
import { useUserStore } from "@/store/user"
import { updatePassword, getUserInfo } from "@/api/auth"
import { ElMessage } from "element-plus"
import { setUser } from "@/utils/auth"

const userStore = useUserStore()

// ========== 修改密码 ==========
const pwdFormRef = ref(null)
const pwdLoading = ref(false)
const pwdForm = reactive({
  oldPassword: "",
  newPassword: "",
  confirmPassword: ""
})

const validateConfirmPwd = (rule, value, callback) => {
  if (value !== pwdForm.newPassword) {
    callback(new Error("两次输入的密码不一致"))
  } else {
    callback()
  }
}

const pwdRules = {
  oldPassword: [{ required: true, message: "请输入旧密码", trigger: "blur" }],
  newPassword: [
    { required: true, message: "请输入新密码", trigger: "blur" },
    { min: 6, max: 20, message: "密码长度6-20位", trigger: "blur" }
  ],
  confirmPassword: [
    { required: true, message: "请再次输入新密码", trigger: "blur" },
    { validator: validateConfirmPwd, trigger: "blur" }
  ]
}

async function handleUpdatePassword() {
  const valid = await pwdFormRef.value.validate().catch(() => false)
  if (!valid) return
  pwdLoading.value = true
  try {
    await updatePassword({
      oldPassword: pwdForm.oldPassword,
      newPassword: pwdForm.newPassword
    })
    ElMessage.success("密码修改成功，请重新登录")
    // 清空表单
    Object.assign(pwdForm, { oldPassword: "", newPassword: "", confirmPassword: "" })
  } catch (error) {
    console.error(error)
  } finally {
    pwdLoading.value = false
  }
}

// ========== 编辑资料 ==========
const infoFormRef = ref(null)
const infoLoading = ref(false)
const infoForm = reactive({
  nickName: userStore.userInfo?.nickName || "",
  phone: userStore.userInfo?.phone || "",
  email: userStore.userInfo?.email || "",
  sex: userStore.userInfo?.sex ?? 0
})

const infoRules = {
  nickName: [{ required: true, message: "请输入昵称", trigger: "blur" }],
  phone: [{ pattern: /^1[3-9]\d{9}$/, message: "手机号格式不正确", trigger: "blur" }],
  email: [{ type: "email", message: "邮箱格式不正确", trigger: "blur" }]
}

async function handleUpdateInfo() {
  const valid = await infoFormRef.value.validate().catch(() => false)
  if (!valid) return
  infoLoading.value = true
  try {
    // 这里需要后端提供更新当前用户信息的接口
    // await updateUserInfo(infoForm)
    // 暂时只更新本地
    const updated = { ...userStore.userInfo, ...infoForm }
    userStore.userInfo = updated
    setUser(updated)
    ElMessage.success("资料更新成功")
    await userStore.getInfo()
  } catch (error) {
    console.error(error)
  } finally {
    infoLoading.value = false
  }
}
</script>

<style scoped>
.profile-avatar {
  text-align: center;
  padding: 10px 0;
}

.profile-name {
  margin: 12px 0 4px;
  font-size: 18px;
}

.profile-role {
  color: #999;
  font-size: 13px;
}

.profile-card {
  margin-bottom: 20px;
}
</style>
