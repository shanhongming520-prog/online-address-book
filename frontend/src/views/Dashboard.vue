<template>
  <div>
    <!-- 统计卡片 -->
    <el-row :gutter="20" style="margin-bottom: 20px">
      <el-col :span="6">
        <div class="page-card stat-card">
          <div class="stat-number">{{ stats.totalUsers }}</div>
          <div class="stat-label">注册用户总数</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="page-card stat-card">
          <div class="stat-number" style="color: #e6a23c">{{ stats.pendingUsers }}</div>
          <div class="stat-label">待审核用户</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="page-card stat-card">
          <div class="stat-number" style="color: #67c23a">{{ stats.approvedUsers }}</div>
          <div class="stat-label">已通过用户</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="page-card stat-card">
          <div class="stat-number" style="color: #409eff">{{ stats.totalContacts }}</div>
          <div class="stat-label">通讯录记录数</div>
        </div>
      </el-col>
    </el-row>

    <!-- 快捷操作 -->
    <div class="page-card">
      <div class="card-title">快捷操作</div>
      <el-row :gutter="16">
        <el-col :span="6">
          <el-button type="primary" size="large" style="width: 100%" @click="$router.push('/contact/my')">
            <el-icon><Edit /></el-icon> 完善通讯录信息
          </el-button>
        </el-col>
        <el-col :span="6">
          <el-button type="success" size="large" style="width: 100%" @click="$router.push('/contact/list')">
            <el-icon><Search /></el-icon> 查询通讯录
          </el-button>
        </el-col>
        <el-col :span="6" v-if="userStore.isAdmin">
          <el-button type="warning" size="large" style="width: 100%" @click="$router.push('/admin/users')">
            <el-icon><User /></el-icon> 用户管理
          </el-button>
        </el-col>
        <el-col :span="6" v-if="userStore.isAdmin">
          <el-button type="info" size="large" style="width: 100%" @click="$router.push('/admin/majors')">
            <el-icon><Collection /></el-icon> 专业管理
          </el-button>
        </el-col>
      </el-row>
    </div>

    <!-- 个人信息 -->
    <div class="page-card">
      <div class="card-title">个人信息</div>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="用户名">{{ userInfo.username }}</el-descriptions-item>
        <el-descriptions-item label="姓名">{{ userInfo.realName }}</el-descriptions-item>
        <el-descriptions-item label="角色">
          <el-tag :type="userInfo.role === 'ADMIN' ? 'danger' : 'success'">
            {{ userInfo.role === 'ADMIN' ? '管理员' : '学生' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="登录次数">{{ userInfo.loginCount }}</el-descriptions-item>
        <el-descriptions-item label="最近登录">{{ userInfo.lastLoginTime || '暂无' }}</el-descriptions-item>
        <el-descriptions-item label="注册时间">{{ userInfo.createTime }}</el-descriptions-item>
      </el-descriptions>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useUserStore } from '../stores/user'
import request from '../utils/request'

const userStore = useUserStore()
const userInfo = ref({})
const stats = ref({
  totalUsers: 0,
  pendingUsers: 0,
  approvedUsers: 0,
  totalContacts: 0
})

onMounted(async () => {
  // 获取当前用户信息
  try {
    const res = await request.get('/auth/info')
    userInfo.value = res.data
  } catch (e) {}

  // 获取统计数据
  try {
    const statsRes = await request.get('/stats')
    stats.value = statsRes.data
  } catch (e) {}
})
</script>
