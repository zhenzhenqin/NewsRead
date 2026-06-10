<template>
  <div class="spider-list">
    <div class="toolbar">
      <h3>新闻爬虫 — 百度热搜</h3>
      <div class="toolbar-right">
        <el-button type="primary" :loading="fetching" @click="doFetch">
          <el-icon><Download /></el-icon>
          抓取热搜
        </el-button>
      </div>
    </div>

    <el-table :data="list" v-loading="loading" stripe empty-text="点击「抓取热搜」获取数据">
      <el-table-column type="index" label="#" width="60" />
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
      <el-table-column prop="title" label="标题" min-width="250" show-overflow-tooltip />
      <el-table-column prop="summary" label="摘要" min-width="200" show-overflow-tooltip />
      <el-table-column label="抓取时间" width="170">
        <template #default="{ row }">
          {{ row.fetchTime ? row.fetchTime.replace('T', ' ').slice(0, 19) : '' }}
        </template>
      </el-table-column>
      <el-table-column label="分类" width="160">
        <template #default="{ row }">
          <el-select v-model="row.categoryId" placeholder="选择分类" size="small" style="width: 130px">
            <el-option
              v-for="cat in categories"
              :key="cat.id"
              :label="cat.name"
              :value="cat.id"
            />
          </el-select>
        </template>
      </el-table-column>
      <el-table-column label="操作" width="150" fixed="right">
        <template #default="{ row, $index }">
          <el-button type="primary" link @click="doPublish(row)" :loading="row._publishing">
            发布
          </el-button>
          <el-button type="danger" link @click="doDelete(row, $index)">
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import {
  fetchHotNews,
  getSpiderList,
  deleteSpiderArticle,
  publishArticle,
  SpiderArticle
} from '@/api/spider'
import { getAllCategories } from '@/api/category'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Download } from '@element-plus/icons-vue'

interface SpiderItem extends SpiderArticle {
  _publishing?: boolean
}

const loading = ref(false)
const fetching = ref(false)
const list = ref<SpiderItem[]>([])
const categories = ref<{ id: number; name: string }[]>([])

async function loadCategories() {
  try {
    categories.value = await getAllCategories()
  } catch (e) {
    console.error('加载分类失败', e)
  }
}

async function loadSaved() {
  loading.value = true
  try {
    const data = await getSpiderList()
    list.value = data.map(item => ({ ...item, _publishing: false }))
  } catch (e) {
    console.error('加载已保存数据失败', e)
  } finally {
    loading.value = false
  }
}

async function doFetch() {
  fetching.value = true
  try {
    const data = await fetchHotNews()
    list.value = data.map(item => ({ ...item, _publishing: false }))
    ElMessage.success('抓取成功，共 ' + list.value.length + ' 条')
  } catch (e) {
    ElMessage.error('抓取失败，请检查网络或后端服务')
  } finally {
    fetching.value = false
  }
}

async function doPublish(row: SpiderItem) {
  if (!row.categoryId) {
    ElMessage.warning('请先选择分类')
    return
  }
  row._publishing = true
  try {
    await publishArticle({
      title: row.title,
      summary: row.summary,
      coverImage: row.coverImage,
      sourceUrl: row.sourceUrl,
      categoryId: row.categoryId
    })
    ElMessage.success('发布成功: ' + row.title)
  } catch (e) {
    ElMessage.error('发布失败')
  } finally {
    row._publishing = false
  }
}

async function doDelete(row: SpiderItem, index: number) {
  try {
    await ElMessageBox.confirm('确认删除「' + row.title + '」？', '提示', { type: 'warning' })
    await deleteSpiderArticle(row.id)
    list.value.splice(index, 1)
    ElMessage.success('已删除')
  } catch (e) {
    // 用户取消
  }
}

onMounted(() => {
  loadCategories()
  loadSaved()
})
</script>

<style scoped>
.spider-list {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
}
.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}
.toolbar h3 {
  margin: 0;
  font-size: 16px;
}
.toolbar-right {
  display: flex;
  gap: 10px;
}
.no-image {
  color: #909399;
  font-size: 12px;
}
</style>
