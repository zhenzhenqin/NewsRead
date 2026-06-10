<template>
  <div class="favorite-list">
    <div class="toolbar">
      <h3>收藏统计</h3>
    </div>

    <!-- 收藏 Top10 文章 -->
    <h4 class="section-title">收藏最多的文章 Top10</h4>
    <el-table :data="topArticles" v-loading="loading" stripe>
      <el-table-column type="index" label="排名" width="70">
        <template #default="{ $index }">
          <el-tag :type="$index < 3 ? 'danger' : 'info'" effect="dark" size="small">
            {{ $index + 1 }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="封面" width="100">
        <template #default="{ row }">
          <el-image
            v-if="row.coverImage"
            :src="row.coverImage"
            fit="cover"
            style="width: 60px; height: 40px; border-radius: 4px"
          />
          <span v-else class="no-image">暂无</span>
        </template>
      </el-table-column>
      <el-table-column prop="title" label="文章标题" min-width="250" show-overflow-tooltip />
      <el-table-column prop="categoryId" label="分类" width="120">
        <template #default="{ row }">
          <el-tag>{{ getCategoryName(row.categoryId) }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="favCount" label="收藏次数" width="120">
        <template #default="{ row }">
          <el-tag type="warning" effect="plain">{{ row.favCount }}</el-tag>
        </template>
      </el-table-column>
    </el-table>

    <!-- 收藏夹统计 -->
    <h4 class="section-title" style="margin-top: 30px">各用户收藏夹概览</h4>
    <el-table :data="folderStats" v-loading="folderLoading" stripe>
      <el-table-column type="index" label="#" width="60" />
      <el-table-column prop="userId" label="用户ID" width="100" />
      <el-table-column prop="username" label="用户名" width="120" />
      <el-table-column prop="folderName" label="收藏夹" width="150">
        <template #default="{ row }">
          <el-tag type="info">{{ row.folderName }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="count" label="收藏数量" width="120">
        <template #default="{ row }">
          <el-tag type="success">{{ row.count }}</el-tag>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getTopFavorited } from '@/api/favorite'
import { getAllCategories } from '@/api/category'

const loading = ref(false)
const folderLoading = ref(false)
const topArticles = ref<any[]>([])
const folderStats = ref<any[]>([])
const categories = ref<{ id: number; name: string }[]>([])

const getCategoryName = (categoryId: number) => {
  const cat = categories.value.find(c => c.id === categoryId)
  return cat ? cat.name : '未分类'
}

const loadCategories = async () => {
  try {
    categories.value = await getAllCategories()
  } catch (e) {
    console.error('加载分类失败', e)
  }
}

const loadTopArticles = async () => {
  loading.value = true
  try {
    topArticles.value = await getTopFavorited(10)
  } catch (e) {
    console.error('加载收藏排行失败', e)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadCategories()
  loadTopArticles()
})
</script>

<style scoped>
.favorite-list {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
}
.toolbar {
  margin-bottom: 20px;
}
.toolbar h3 {
  margin: 0;
  font-size: 16px;
}
.section-title {
  margin: 0 0 15px;
  font-size: 14px;
  color: #606266;
  font-weight: 600;
}
.no-image {
  color: #909399;
  font-size: 12px;
}
</style>
