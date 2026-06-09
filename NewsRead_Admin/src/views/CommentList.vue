<template>
  <div class="comment-list">
    <div class="toolbar">
      <el-input
        v-model="keyword"
        placeholder="搜索评论内容"
        style="width: 200px"
        @keyup.enter="loadData"
      />
      <el-button type="primary" @click="loadData">搜索</el-button>
      <el-button @click="keyword = ''; loadData()">重置</el-button>
    </div>

    <el-table :data="comments" border style="margin-top: 20px">
      <el-table-column prop="id" label="ID" width="80" />
      <el-table-column prop="content" label="评论内容" min-width="200" show-overflow-tooltip />
      <el-table-column prop="nickname" label="用户" width="120" />
      <el-table-column prop="articleId" label="文章ID" width="100" />
      <el-table-column prop="likeCount" label="点赞数" width="80" />
      <el-table-column prop="status" label="状态" width="80">
        <template #default="{ row }">
          <el-tag :type="row.status === 1 ? 'success' : 'danger'">
            {{ row.status === 1 ? '显示' : '隐藏' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="createTime" label="时间" width="180" />
      <el-table-column label="操作" width="150" fixed="right">
        <template #default="{ row }">
          <el-button v-if="row.status === 1" size="small" @click="handleHideComment(row.id)">隐藏</el-button>
          <el-button v-else size="small" type="success" @click="handleShowComment(row.id)">显示</el-button>
          <el-button size="small" type="danger" @click="deleteComment(row.id)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-model:current-page="pageNum"
      v-model:page-size="pageSize"
      :total="total"
      layout="total, prev, pager, next"
      style="margin-top: 20px; justify-content: flex-end"
      @current-change="loadData"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getAllComments, deleteComment as deleteCommentApi, hideComment, showComment } from '@/api/comment'

const comments = ref<any[]>([])
const pageNum = ref(1)
const pageSize = ref(10)
const total = ref(0)
const keyword = ref('')

async function loadData() {
  try {
    const data = await getAllComments({
      pageNum: pageNum.value,
      pageSize: pageSize.value,
      keyword: keyword.value
    })
    comments.value = data.records || []
    total.value = data.total || 0
  } catch (e) {
    console.error(e)
  }
}

async function deleteComment(id: number) {
  try {
    await ElMessageBox.confirm('确定要删除这条评论吗？', '提示', {
      type: 'warning'
    })
    await deleteCommentApi(id)
    ElMessage.success('删除成功')
    loadData()
  } catch (e) {
    if (e !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

async function handleHideComment(id: number) {
  try {
    await hideComment(id)
    ElMessage.success('隐藏成功')
    loadData()
  } catch (e) {
    ElMessage.error('隐藏失败')
  }
}

async function handleShowComment(id: number) {
  try {
    await showComment(id)
    ElMessage.success('显示成功')
    loadData()
  } catch (e) {
    ElMessage.error('显示失败')
  }
}

onMounted(() => {
  loadData()
})
</script>

<style scoped>
.comment-list {
  padding: 20px;
}
.toolbar {
  display: flex;
  gap: 10px;
}
</style>