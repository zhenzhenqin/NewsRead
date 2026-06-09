<template>
  <div class="dashboard">
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #409EFF">
            <el-icon :size="32"><Document /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.totalArticles }}</div>
            <div class="stat-label">文章总数</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #67C23A">
            <el-icon :size="32"><View /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.totalViews }}</div>
            <div class="stat-label">总阅读量</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #E6A23C">
            <el-icon :size="32"><Star /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.totalLikes }}</div>
            <div class="stat-label">总点赞数</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-icon" style="background: #F56C6C">
            <el-icon :size="32"><ChatDotRound /></el-icon>
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.totalComments }}</div>
            <div class="stat-label">总评论数</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>分类文章统计</span>
          </template>
          <div ref="categoryChartRef" style="height: 300px"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>阅读量排行 TOP 10</span>
          </template>
          <el-table :data="topArticles" size="small">
            <el-table-column prop="title" label="标题" show-overflow-tooltip />
            <el-table-column prop="viewCount" label="阅读量" width="100" />
          </el-table>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Document, View, Star, ChatDotRound } from '@element-plus/icons-vue'
import * as echarts from 'echarts'
import { getStatistics, getCategoryStats, getTopArticles } from '@/api/statistics'

const categoryChartRef = ref()
const stats = ref({
  totalArticles: 0,
  totalViews: 0,
  totalLikes: 0,
  totalComments: 0
})
const topArticles = ref<Array<{title: string, viewCount: number}>>([])

const categoryData = ref<Array<{name: string, value: number}>>([])

const initChart = () => {
  if (categoryChartRef.value) {
    const chart = echarts.init(categoryChartRef.value)
    chart.setOption({
      tooltip: { trigger: 'item' },
      series: [{
        type: 'pie',
        radius: ['40%', '70%'],
        data: categoryData.value,
        label: { show: true, formatter: '{b}: {c}' }
      }]
    })
  }
}

const loadData = async () => {
  try {
    const [statistics, categoryStats, articles] = await Promise.all([
      getStatistics(),
      getCategoryStats(),
      getTopArticles(10)
    ])

    stats.value = {
      totalArticles: statistics.totalArticles || 0,
      totalViews: statistics.totalViews || 0,
      totalLikes: statistics.totalLikes || 0,
      totalComments: statistics.totalComments || 0
    }

    categoryData.value = categoryStats.map((item: any) => ({
      name: item.name,
      value: item.value
    }))

    topArticles.value = articles.map((article: any) => ({
      title: article.title,
      viewCount: article.viewCount || 0
    }))

    initChart()
  } catch (e) {
    console.error('加载数据失败', e)
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.dashboard {
  padding: 0;
}
.stat-card {
  display: flex;
  align-items: center;
  padding: 20px;
}
.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #fff;
  margin-right: 16px;
}
.stat-value {
  font-size: 28px;
  font-weight: 600;
  color: #303133;
}
.stat-label {
  font-size: 14px;
  color: #909399;
  margin-top: 4px;
}
</style>