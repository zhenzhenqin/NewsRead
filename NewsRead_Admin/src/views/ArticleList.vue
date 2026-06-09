<template>
  <div class="article-list">
    <div class="toolbar">
      <el-button type="primary" @click="handleAdd">
        <el-icon><Plus /></el-icon>
        新增文章
      </el-button>
      <div class="filters">
        <el-select v-model="query.isPublished" placeholder="发布状态" clearable style="width: 120px">
          <el-option label="全部" :value="undefined" />
          <el-option label="已发布" :value="1" />
          <el-option label="草稿" :value="0" />
        </el-select>
        <el-button :icon="Search" circle @click="loadData" />
      </div>
    </div>

    <el-table :data="tableData" v-loading="loading" stripe>
      <el-table-column prop="id" label="ID" width="80" />
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
      <el-table-column prop="title" label="标题" min-width="200" show-overflow-tooltip />
      <el-table-column prop="categoryId" label="分类" width="100">
        <template #default="{ row }">
          {{ getCategoryName(row.categoryId) }}
        </template>
      </el-table-column>
      <el-table-column prop="viewCount" label="阅读" width="80" />
      <el-table-column prop="likeCount" label="点赞" width="80" />
      <el-table-column prop="isPublished" label="状态" width="80">
        <template #default="{ row }">
          <el-tag :type="row.isPublished === 1 ? 'success' : 'info'">
            {{ row.isPublished === 1 ? '已发布' : '草稿' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="创建时间" width="170" />
      <el-table-column label="操作" width="180" fixed="right">
        <template #default="{ row }">
          <el-button type="primary" link @click="handleEdit(row.id)">编辑</el-button>
          <el-button type="danger" link @click="handleDelete(row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-model:current-page="pagination.pageNum"
      v-model:page-size="pagination.pageSize"
      :total="pagination.total"
      :page-sizes="[10, 20, 50]"
      layout="total, sizes, prev, pager, next"
      @change="loadData"
      style="margin-top: 20px; justify-content: flex-end"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { getArticleList, deleteArticle } from '@/api/article'
import { getAllCategories } from '@/api/category'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Search } from '@element-plus/icons-vue'

interface Article {
  id: number
  title: string
  coverImage: string
  categoryId: number
  viewCount: number
  likeCount: number
  isPublished: number
  createTime: string
}

const router = useRouter()
const route = useRoute()
const loading = ref(false)
const tableData = ref<Article[]>([])
const categories = ref<{ id: number; name: string }[]>([])

const query = reactive({
  isPublished: undefined as number | undefined
})

const pagination = reactive({
  pageNum: 1,
  pageSize: 10,
  total: 0
})

const getCategoryName = (categoryId: number) => {
  const cat = categories.value.find(c => c.id === categoryId)
  return cat ? cat.name : '未分类'
}

const loadData = async () => {
  loading.value = true
  try {
    const data = await getArticleList({
      pageNum: pagination.pageNum,
      pageSize: pagination.pageSize,
      isPublished: query.isPublished
    })
    tableData.value = data.records || []
    pagination.total = data.total || 0
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

const handleAdd = () => {
  router.push('/article/edit')
}

const handleEdit = (id: number) => {
  router.push(`/article/edit/${id}`)
}

const handleDelete = (id: number) => {
  ElMessageBox.confirm('确认删除该文章？', '提示', {
    type: 'warning'
  }).then(async () => {
    await deleteArticle(id)
    ElMessage.success('删除成功')
    loadData()
  }).catch(() => {})
}

const loadCategories = async () => {
  try {
    categories.value = await getAllCategories()
  } catch (e) {
    console.error('加载分类失败', e)
  }
}

onMounted(() => {
  loadCategories()
  loadData()
})
</script>

<style scoped>
.article-list {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
}
.toolbar {
  display: flex;
  justify-content: space-between;
  margin-bottom: 20px;
}
.filters {
  display: flex;
  gap: 10px;
}
.no-image {
  color: #909399;
  font-size: 12px;
}
</style>