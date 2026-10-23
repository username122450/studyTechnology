const TOKEN_KEY = "admin_token"
const USER_KEY = "admin_user"

export function getToken() {
  const token = localStorage.getItem(TOKEN_KEY)
  // 过滤历史遗留的脏数据("undefined"/"null" 等无效值),避免拼出 "Bearer undefined"
  if (!token || token === "undefined" || token === "null") {
    return ""
  }
  return token
}

export function setToken(token) {
  localStorage.setItem(TOKEN_KEY, token)
}

export function removeToken() {
  localStorage.removeItem(TOKEN_KEY)
  localStorage.removeItem(USER_KEY)
}

export function getUser() {
  const raw = localStorage.getItem(USER_KEY)
  if (!raw) return null
  try {
    return JSON.parse(raw)
  } catch (e) {
    // 本地缓存被写过脏数据(如字符串 "undefined")时,JSON.parse 会抛 SyntaxError。
    // 这里清除脏数据并返回 null,否则每次刷新页面都会在 store 初始化时崩溃 → 白屏
    localStorage.removeItem(USER_KEY)
    return null
  }
}

export function setUser(user) {
  // JSON.stringify(undefined) 返回 undefined,localStorage.setItem 会把它转成字符串
  // "undefined" 存进去,下次 getUser() 解析直接报错 —— 这是白屏的源头,必须拦截
  if (user === null || user === undefined) {
    localStorage.removeItem(USER_KEY)
    return
  }
  localStorage.setItem(USER_KEY, JSON.stringify(user))
}
