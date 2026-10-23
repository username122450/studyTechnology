<template>
  <div class="dashboard">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="stat-row">
      <el-col :xs="24" :sm="12" :lg="6">
        <div class="stat-card">
          <div class="stat-icon" style="background: #409EFF;">
            <el-icon :size="28"><User /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-label">用户总数</div>
            <div class="stat-value">{{ stats.userCount || 0 }}</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :lg="6">
        <div class="stat-card">
          <div class="stat-icon" style="background: #67C23A;">
            <el-icon :size="28"><Avatar /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-label">角色总数</div>
            <div class="stat-value">{{ stats.roleCount || 0 }}</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :lg="6">
        <div class="stat-card">
          <div class="stat-icon" style="background: #E6A23C;">
            <el-icon :size="28"><Menu /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-label">菜单总数</div>
            <div class="stat-value">{{ stats.menuCount || 0 }}</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :lg="6">
        <div class="stat-card">
          <div class="stat-icon" style="background: #F56C6C;">
            <el-icon :size="28"><Document /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-label">今日操作日志</div>
            <div class="stat-value">{{ stats.todayLogCount || 0 }}</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="20" class="chart-row">
      <el-col :xs="24" :lg="12">
        <el-card shadow="never">
          <template #header>
            <span>访问趋势</span>
          </template>
          <div ref="barChartRef" class="chart-container"></div>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="12">
        <el-card shadow="never">
          <template #header>
            <span>系统信息</span>
          </template>
          <div class="system-info">
            <el-descriptions :column="1" border size="small">
              <el-descriptions-item label="系统版本">v1.0.0</el-descriptions-item>
              <el-descriptions-item label="前端技术">Vue 3 + Element Plus</el-descriptions-item>
              <el-descriptions-item label="后端技术">Spring Boot 3 + MyBatis-Plus</el-descriptions-item>
              <el-descriptions-item label="数据库">MySQL 8.0</el-descriptions-item>
              <el-descriptions-item label="服务器">Tomcat</el-descriptions-item>
            </el-descriptions>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 最新日志 -->
    <el-row class="chart-row">
      <el-col :span="24">
        <el-card shadow="never">
          <template #header>
            <span>最新操作日志</span>
          </template>
          <el-table :data="recentLogs" size="small" stripe>
            <el-table-column prop="title" label="操作模块" width="180" />
            <el-table-column prop="operName" label="操作人员" width="120" />
            <el-table-column prop="method" label="请求方式" width="100" />
            <el-table-column prop="operUrl" label="请求URL" show-overflow-tooltip />
            <el-table-column prop="operIp" label="IP地址" width="140" />
            <el-table-column prop="operTime" label="操作时间" width="180" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, nextTick } from "vue"
import { getDashboardData } from "@/api/dashboard"
import * as echarts from "echarts"

const barChartRef = ref(null)
let barChart = null

const stats = reactive({
  userCount: 0,
  roleCount: 0,
  menuCount: 0,
  todayLogCount: 0
})

const recentLogs = ref([])

// 初始化柱状图
function initBarChart() {
  if (!barChartRef.value) return
  barChart = echarts.init(barChartRef.value)
  barChart.setOption({
    tooltip: { trigger: "axis" },
    xAxis: {
      type: "category",
      data: ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    },
    yAxis: { type: "value" },
    series: [
      {
        name: "访问量",
        type: "bar",
        data: [120, 200, 150, 80, 70, 110, 130],
        itemStyle: { color: "#409EFF", borderRadius: [4, 4, 0, 0] }
      }
    ]
  })
}

async function loadData() {
  try {
    const res = await getDashboardData()
    if (res.data) {
      Object.assign(stats, res.data.statistics || {})
      recentLogs.value = res.data.recentLogs || []
    }
  } catch (error) {
    console.error("加载首页数据失败:", error)
  }
}

onMounted(() => {
  loadData()
  nextTick(() => {
    initBarChart()
  })
  window.addEventListener("resize", () => {
    barChart?.resize()
  })
})
</script>

<style scoped>
.dashboard {
  padding: 0;
}

.stat-row {
  margin-bottom: 20px;
}

.stat-card {
  display: flex;
  align-items: center;
  background: #fff;
  border-radius: 6px;
  padding: 20px;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
  transition: transform 0.2s;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  flex-shrink: 0;
}

.stat-info {
  margin-left: 16px;
}

.stat-label {
  font-size: 13px;
  color: #999;
  margin-bottom: 4px;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
  color: #333;
}

.chart-row {
  margin-bottom: 20px;
}

.chart-container {
  height: 300px;
  width: 100%;
}

.system-info {
  padding: 10px 0;
}
</style>
