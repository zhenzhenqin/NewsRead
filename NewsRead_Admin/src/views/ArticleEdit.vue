<template>
  <div class="article-edit">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>{{ isEdit ? '编辑文章' : '新增文章' }}</span>
        </div>
      </template>
      
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="文章标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入文章标题" maxlength="200" show-word-limit />
        </el-form-item>
        
        <el-form-item label="文章摘要" prop="summary">
          <el-input v-model="form.summary" type="textarea" :rows="2" placeholder="请输入文章摘要" maxlength="500" show-word-limit />
        </el-form-item>
        
        <el-form-item label="封面图" prop="coverImage">
          <el-upload
            class="cover-uploader"
            action="http://localhost:8080/api/upload"
            :show-file-list="false"
            :on-success="handleCoverSuccess"
            :before-upload="beforeCoverUpload"
            :headers="uploadHeaders"
          >
            <img v-if="form.coverImage" :src="form.coverImage" class="cover-preview" />
            <el-icon v-else class="uploader-icon"><Plus /></el-icon>
          </el-upload>
        </el-form-item>
        
        <el-form-item label="文章分类" prop="categoryId">
          <el-select v-model="form.categoryId" placeholder="请选择分类" style="width: 200px">
            <el-option v-for="cat in categories" :key="cat.id" :label="cat.name" :value="cat.id" />
          </el-select>
        </el-form-item>
        
        <el-form-item label="是否推荐" prop="isFeatured">
          <el-switch v-model="form.isFeatured" :active-value="1" :inactive-value="0" />
        </el-form-item>
        
        <el-form-item label="是否发布" prop="isPublished">
          <el-switch v-model="form.isPublished" :active-value="1" :inactive-value="0" />
        </el-form-item>
        
        <el-form-item label="文章内容" prop="content">
          <div class="editor-wrapper">
            <div class="editor-toolbar">
              <el-button size="small" @click="insertTag('**', '**')">加粗</el-button>
              <el-button size="small" @click="insertTag('*', '*')">斜体</el-button>
              <el-button size="small" @click="insertTag('\n## ', '')">标题</el-button>
              <el-button size="small" @click="insertTag('[', '](url)')">链接</el-button>
              <el-button size="small" @click="insertTag('![alt](', ')')">图片</el-button>
            </div>
            <textarea 
              v-model="form.content" 
              class="content-editor"
              placeholder="请输入文章内容，支持 Markdown 格式..."
            ></textarea>
          </div>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="handleSubmit(1)" :loading="submitting">发布</el-button>
          <el-button type="info" @click="handleSubmit(0)" :loading="submitting">保存草稿</el-button>
          <el-button @click="handleCancel">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { getArticleDetail, createArticle, updateArticle } from '@/api/article'
import { getAllCategories } from '@/api/category'
import { ElMessage, FormInstance, FormRules } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'

interface ArticleForm {
  title: string
  summary: string
  coverImage: string
  categoryId: number | null
  isFeatured: number
  isPublished: number
  content: string
}

const router = useRouter()
const route = useRoute()
const formRef = ref<FormInstance>()
const submitting = ref(false)
const isEdit = computed(() => !!route.params.id)

const categories = ref<{ id: number; name: string }[]>([])

const form = reactive<ArticleForm>({
  title: '',
  summary: '',
  coverImage: '',
  categoryId: null,
  isFeatured: 0,
  isPublished: 0,
  content: ''
})

const rules = reactive<FormRules<ArticleForm>>({
  title: [{ required: true, message: '请输入文章标题', trigger: 'blur' }],
  categoryId: [{ required: true, message: '请选择分类', trigger: 'change' }]
})

const uploadHeaders = ref({
  Authorization: localStorage.getItem('token') || ''
})

const handleCoverSuccess = (response: any) => {
  if (response.code === 200 || response.code === 201) {
    form.coverImage = 'http://localhost:8080' + response.data
  } else {
    ElMessage.error(response.message || '上传失败')
  }
}

const beforeCoverUpload = (file: File) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2
  if (!isImage) {
    ElMessage.error('只能上传图片文件')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB')
    return false
  }
  return true
}

const insertTag = (prefix: string, suffix: string) => {
  const textarea = document.querySelector('.content-editor') as HTMLTextAreaElement
  if (!textarea) return
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  const text = form.content
  const selectedText = text.substring(start, end)
  form.content = text.substring(0, start) + prefix + selectedText + suffix + text.substring(end)
}

const handleSubmit = async (publishStatus: number) => {
  // 草稿可以不验证内容
  let valid = true
  if (publishStatus === 1) {
    valid = await formRef.value?.validate().catch(() => false) as boolean
  } else {
    // 草稿只验证标题和分类
    await formRef.value?.validateField(['title', 'categoryId']).catch(() => {})
    valid = form.title.length > 0 && form.categoryId !== null
  }
  if (!valid) return
  
  submitting.value = true
  try {
    form.isPublished = publishStatus
    
    if (isEdit.value) {
      await updateArticle(form as any)
      ElMessage.success(publishStatus === 1 ? '发布成功' : '草稿已保存')
    } else {
      await createArticle(form as any)
      ElMessage.success(publishStatus === 1 ? '发布成功' : '草稿已保存')
    }
    router.push('/article')
  } catch (e) {
    console.error(e)
  } finally {
    submitting.value = false
  }
}

const handleCancel = () => {
  router.push('/article')
}

const loadDetail = async () => {
  if (!isEdit.value) return
  try {
    const data = await getArticleDetail(Number(route.params.id))
    Object.assign(form, data)
  } catch (e) {
    ElMessage.error('加载失败')
  }
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
  loadDetail()
})
</script>

<style scoped>
.article-edit {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
}
.card-header {
  font-size: 18px;
  font-weight: 600;
}
.cover-uploader {
  width: 180px;
  height: 120px;
  border: 1px dashed #d9d9d9;
  border-radius: 6px;
  cursor: pointer;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
}
.cover-uploader:hover {
  border-color: #409EFF;
}
.cover-preview {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.uploader-icon {
  font-size: 28px;
  color: #8c939d;
}
.editor-wrapper {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
}
.editor-toolbar {
  padding: 8px;
  border-bottom: 1px solid #dcdfe6;
  background: #f5f7fa;
}
.content-editor {
  width: 100%;
  min-height: 400px;
  padding: 12px;
  border: none;
  outline: none;
  resize: vertical;
  font-family: 'Consolas', monospace;
  font-size: 14px;
  line-height: 1.6;
}
</style>