# Claude Code 常用斜杠命令

> **版本核对提示**：本文档基于 Claude Code 当前版本的稳定命令整理。最权威的核对方法——在输入框敲 `/` 会弹出当前版本全部命令，`/help <命令名>` 可查看单个命令的详细说明。文档入口：https://code.claude.com/docs

---

## 一、会话与续作（"第二天接着干"最相关）

| 命令 | 用途 |
|---|---|
| `/resume` | 列出历史会话并恢复，隔天继续工作的最佳入口（命令行等价：`claude --continue` 直接续上次） |
| `/export` | 把当前对话导出为 Markdown 存档 |
| `/compact` | 把长对话压缩成摘要后继续，上下文快用尽时保住进度 |
| `/clear` | 清空当前对话、释放上下文，开新任务 |
| `/rewind` | 回退到之前的对话节点，聊偏了或改坏了可以倒回去重来 |
| `/status` | 查看当前会话状态 |
| `/cost` | 查看 token 用量和花费 |
| `/model` | 切换模型（如 `/model sonnet`），复杂诊断可临时换更强模型 |

## 二、诊断 → 修复 → 验证（日常流程核心）

| 命令 | 用途 |
|---|---|
| `/diagnose` | 只读诊断模式，与项目 CLAUDE.md 里"说诊断即进入"的约定配套 |
| `/debug` | 打开调试日志，定位疑难 bug 时先开它 |
| `/doctor` | 检查 Claude Code 安装/配置健康度 |
| `/verify` | 改完代码后端到端验证真实行为（不只是编译过） |
| `/code-review` | 审查当前改动/PR 的正确性问题 |
| `/security-review` | 对改动做安全审查 |
| `/simplify` | 只做重构简化，不找 bug（与 code-review 分工） |
| `/run` | 实际启动项目跑起来看效果 |
| `/fewer-permission-prompts` | 把常用只读命令加白名单，减少 Windows 下的权限弹窗 |

## 三、配置与权限

| 命令 | 用途 |
|---|---|
| `/config` | 查看/修改设置（主题、模型、环境变量等） |
| `/permissions` | 查看和调整命令权限 |
| `/mcp` | 管理 MCP 服务器（添加、查看、移除） |
| `/agents` | 创建和管理子代理（subagents） |
| `/update-config` | 配置 hooks（"每次 X 之后自动 Y"这类自动化）、权限规则、env 变量 |
| `/feedback` | 反馈 bug 或功能建议 |

## 四、项目与文档

| 命令 | 用途 |
|---|---|
| `/init` | 生成/更新 CLAUDE.md 项目规则 |
| `/keybindings-help` | 自定义快捷键 |
| `/claude-api` | Claude API 参考（模型、定价、参数、MCP 等） |

---

## 五、实战建议

1. **续作方法**：每天结束时用 `/resume`（或 `claude --continue`）第二天无缝续上；想要留档分析结论就 `/export`。
2. **固定循环**：`/diagnose` → 人工确认 → 修复 → `/verify`，与项目 CLAUDE.md 工作规则完全对齐。
3. **版本核对**：遇到命令相关疑问，直接敲 `/` 看当前版本真实命令列表，不要死记本文档。
