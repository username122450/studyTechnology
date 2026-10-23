// 常用表单校验规则

export const validatePhone = (rule, value, callback) => {
  if (!value) callback()
  else if (!/^1[3-9]\d{9}$/.test(value)) callback(new Error("手机号格式不正确"))
  else callback()
}

export const validateEmail = (rule, value, callback) => {
  if (!value) callback()
  else if (!/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/.test(value))
    callback(new Error("邮箱格式不正确"))
  else callback()
}

export const validatePassword = (rule, value, callback) => {
  if (!value) callback()
  else if (value.length < 6 || value.length > 20) callback(new Error("密码长度应为6-20位"))
  else callback()
}

export const validateUsername = (rule, value, callback) => {
  if (!value) callback()
  else if (!/^[a-zA-Z][a-zA-Z0-9_]{3,19}$/.test(value))
    callback(new Error("用户名须以字母开头，4-20位字母数字下划线"))
  else callback()
}
