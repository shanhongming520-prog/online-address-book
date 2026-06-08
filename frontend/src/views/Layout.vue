<template>
  <div class="layout-container">
    <!-- 顶部导航 -->
    <header class="layout-header">
      <div class="logo">📇 网上通讯录系统</div>
      <div class="header-right">
        <el-tag :type="userStore.isAdmin ? 'danger' : 'success'" size="small">
          {{ userStore.isAdmin ? '管理员' : '学生' }}
        </el-tag>
        <span>{{ userStore.userInfo.realName }}</span>
        <el-button type="danger" size="small" @click="handleLogout">退出登录</el-button>
      </div>
    </header>

    <div class="layout-main">
      <!-- 侧边栏 -->
      <aside class="layout-sidebar">
        <el-menu :default-active="$route.path" background-color="#304156" text-color="#bfcbd9"
                 active-text-color="#409eff" :router="true" style="border-right: none">
          <el-menu-item index="/dashboard">
            <el-icon><HomeFilled /></el-icon>
            <span>首页</span>
          </el-menu-item>

          <el-sub-menu index="contact">
            <template #title>
              <el-icon><Notebook /></el-icon>
              <span>通讯录</span>
            </template>
            <el-menu-item index="/contact/my">我的通讯录</el-menu-item>
            <el-menu-item index="/contact/list">通讯录查询</el-menu-item>
          </el-sub-menu>

          <el-sub-menu index="admin" v-if="userStore.isAdmin">
            <template #title>
              <el-icon><Setting /></el-icon>
              <span>系统管理</span>
            </template>
            <el-menu-item index="/admin/users">用户管理</el-menu-item>
            <el-menu-item index="/admin/majors">专业管理</el-menu-item>
          </el-sub-menu>
        </el-menu>
      </aside>

      <!-- 主内容区 -->
      <main class="layout-content">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useUserStore } from '../stores/user'
import { ElMessageBox, ElMessage } from 'element-plus'

const router = useRouter()
const userStore = useUserStore()

function handleLogout() {
  ElMessageBox.confirm('确定要退出登录吗？', '提示', { type: 'warning' })
    .then(() => {
      userStore.logout()
      ElMessage.success('已退出登录')
      router.push('/login')
    })
    .catch(() => {})
}
</script>
