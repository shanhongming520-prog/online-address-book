<template>
  <div>
    <div class="page-card">
      <div class="card-title">用户管理</div>
      
      <!-- 搜索栏 -->
      <div class="search-bar">
        <el-input v-model="searchName" placeholder="搜索姓名" clearable style="width: 200px"
                  @keyup.enter="handleSearch" />
        <el-select v-model="searchStatus" placeholder="状态" clearable style="width: 150px"
                   @change="handleSearch">
          <el-option label="待审核" :value="0" />
          <el-option label="已通过" :value="1" />
          <el-option label="已禁用" :value="2" />
        </el-select>
        <el-button type="primary" @click="handleSearch">
          <el-icon><Search /></el-icon> 搜索
        </el-button>
        <el-button @click="resetSearch">重置</el-button>
      </div>

      <!-- 数据表格 -->
      <el-table :data="tableData" stripe border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="realName" label="姓名" width="100" />
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="statusType(row.status)">{{ statusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="loginCount" label="登录次数" width="100" align="center" />
        <el-table-column prop="lastLoginTime" label="最近登录" width="180" />
        <el-table-column prop="createTime" label="注册时间" width="180" />
        <el-table-column label="操作" min-width="280" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 0" type="success" size="small" @click="handleApprove(row)">
              通过审核
            </el-button>
            <el-button v-if="row.status === 1" type="warning" size="small" @click="handleDisable(row)">
              禁用
            </el-button>
            <el-button v-if="row.status === 2" type="success" size="small" @click="handleEnable(row)">
              启用
            </el-button>
            <el-button v-if="row.status !== 1" type="danger" size="small" @click="handleDelete(row)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div style="margin-top: 16px; text-align: right">
        <el-pagination
          v-model:current-page="pageNum"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50]"
          :total="total"
          layout="total, sizes, prev, pager, next"
          @size-change="loadData"
          @current-change="loadData"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import request from '../utils/request'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const pageNum = ref(1)
const pageSize = ref(10)
const searchName = ref('')
const searchStatus = ref(null)

function statusText(status) {
  return ['待审核', '已通过', '已禁用'][status] || '未知'
}

function statusType(status) {
  return ['warning', 'success', 'danger'][status] || 'info'
}

onMounted(() => loadData())

async function loadData() {
  loading.value = true
  try {
    const params = {
      pageNum: pageNum.value,
      pageSize: pageSize.value
    }
    if (searchName.value) params.realName = searchName.value
    if (searchStatus.value !== null && searchStatus.value !== '') params.status = searchStatus.value

    const res = await request.get('/admin/user/list', { params })
    tableData.value = res.data.records
    total.value = res.data.total
  } catch (e) {} finally {
    loading.value = false
  }
}

function handleSearch() {
  pageNum.value = 1
  loadData()
}

function resetSearch() {
  searchName.value = ''
  searchStatus.value = null
  pageNum.value = 1
  loadData()
}

async function handleApprove(row) {
  await ElMessageBox.confirm(`确定通过 ${row.realName} 的审核吗？`, '确认')
  await request.put(`/admin/user/approve/${row.id}`)
  ElMessage.success('审核通过')
  loadData()
}

async function handleDisable(row) {
  await ElMessageBox.confirm(`确定禁用 ${row.realName} 的账号吗？`, '确认', { type: 'warning' })
  await request.put(`/admin/user/disable/${row.id}`)
  ElMessage.success('已禁用')
  loadData()
}

async function handleEnable(row) {
  await request.put(`/admin/user/enable/${row.id}`)
  ElMessage.success('已启用')
  loadData()
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确定删除 ${row.realName} 的账号吗？此操作不可恢复！`, '警告', { type: 'error' })
  await request.delete(`/admin/user/delete/${row.id}`)
  ElMessage.success('删除成功')
  loadData()
}
</script>
