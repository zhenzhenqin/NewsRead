<template>
  <el-container class="layout-container">
    <el-aside width="220px" class="sidebar">
      <div class="logo">
        <h2>NewsRead</h2>
        <p>内容管理后台</p>
      </div>
      <el-menu
        :default-active="activeMenu"
        router
        background-color="#304156"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
      >
        <el-menu-item index="/dashboard">
          <el-icon><DataAnalysis /></el-icon>
          <span>数据看板</span>
        </el-menu-item>
        <el-menu-item index="/article">
          <el-icon><Document /></el-icon>
          <span>文章管理</span>
        </el-menu-item>
        <el-menu-item index="/category">
          <el-icon><Folder /></el-icon>
          <span>分类管理</span>
        </el-menu-item>
        <el-menu-item index="/user">
          <el-icon><User /></el-icon>
          <span>用户管理</span>
        </el-menu-item>
        <el-menu-item index="/admin">
          <el-icon><UserFilled /></el-icon>
          <span>管理员管理</span>
        </el-menu-item>
        <el-menu-item index="/comment">
          <el-icon><ChatDotRound /></el-icon>
          <span>评论管理</span>
        </el-menu-item>
        <el-menu-item index="/spider">
          <el-icon><Connection /></el-icon>
          <span>新闻爬虫</span>
        </el-menu-item>
        <el-menu-item index="/favorite">
          <el-icon><Star /></el-icon>
          <span>收藏统计</span>
        </el-menu-item>
      </el-menu>
    </el-aside>
    <el-container>
      <el-header class="header">
        <div class="header-left">
          <span class="breadcrumb">{{ route.meta.title }}</span>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="32" :src="userInfo?.avatar || 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'" />
              <span>{{ userInfo?.nickname || '管理员' }}</span>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">个人中心</el-dropdown-item>
                <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-main class="main-content">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { DataAnalysis, Document, Folder, User, UserFilled, ChatDotRound, Connection, Star } from '@element-plus/icons-vue'
import { ElMessageBox, ElMessage } from 'element-plus'

const route = useRoute()
const router = useRouter()
const activeMenu = computed(() => route.path)

const userInfo = ref<{nickname: string; avatar: string} | null>(null)

onMounted(() => {
  const userStr = localStorage.getItem('user')
  if (userStr) {
    userInfo.value = JSON.parse(userStr)
  }
})

const handleCommand = (command: string) => {
  if (command === 'logout') {
    ElMessageBox.confirm('确认退出登录？', '提示', {
      type: 'warning'
    }).then(() => {
      localStorage.removeItem('token')
      localStorage.removeItem('user')
      router.push('/login')
    }).catch(() => {})
  } else if (command === 'profile') {
    ElMessage.info('个人中心功能开发中...')
  }
}
</script>

<style scoped>
.layout-container {
  height: 100vh;
}
.sidebar {
  background-color: #304156;
  overflow: hidden;
}
.logo {
  height: 60px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  color: #fff;
}
.logo h2 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
}
.logo p {
  margin: 4px 0 0;
  font-size: 12px;
  color: #909399;
}
.header {
  background: #fff;
  box-shadow: 0 1px 4px rgba(0,21,41,.08);
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
}
.header-left {
  font-size: 16px;
  font-weight: 500;
}
.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}
.main-content {
  background: #f0f2f5;
  padding: 20px;
}
</style>