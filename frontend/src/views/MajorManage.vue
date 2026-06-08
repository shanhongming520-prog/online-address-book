<template>
  <div>
    <div class="page-card">
      <div class="card-title">
        专业管理
        <el-button type="primary" size="small" @click="showAddDialog" style="float: right">
          <el-icon><Plus /></el-icon> 新增专业
        </el-button>
      </div>

      <el-table :data="tableData" stripe border style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="专业名称" width="200" />
        <el-table-column prop="department" label="所属学院" />
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="showEditDialog(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="isEdit ? '编辑专业' : '新增专业'" width="500px">
      <el-form :model="form" label-width="100px">
        <el-form-item label="专业名称" required>
          <el-input v-model="form.name" placeholder="请输入专业名称" />
        </el-form-item>
        <el-form-item label="所属学院" required>
          <el-input v-model="form.department" placeholder="请输入所属学院" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="submitLoading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue'
import request from '../utils/request'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const submitLoading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const isEdit = ref(false)

const form = reactive({
  id: null,
  name: '',
  department: ''
})

onMounted(() => loadData())

async function loadData() {
  loading.value = true
  try {
    const res = await request.get('/major/list')
    tableData.value = res.data
  } catch (e) {} finally {
    loading.value = false
  }
}

function showAddDialog() {
  isEdit.value = false
  form.id = null
  form.name = ''
  form.department = ''
  dialogVisible.value = true
}

function showEditDialog(row) {
  isEdit.value = true
  form.id = row.id
  form.name = row.name
  form.department = row.department
  dialogVisible.value = true
}

async function handleSubmit() {
  if (!form.name || !form.department) {
    ElMessage.warning('请填写完整信息')
    return
  }
  submitLoading.value = true
  try {
    if (isEdit.value) {
      await request.put('/major', form)
      ElMessage.success('修改成功')
    } else {
      await request.post('/major', form)
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    loadData()
  } catch (e) {} finally {
    submitLoading.value = false
  }
}

async function handleDelete(row) {
  await ElMessageBox.confirm(`确定删除专业 "${row.name}" 吗？`, '警告', { type: 'warning' })
  await request.delete(`/major/${row.id}`)
  ElMessage.success('删除成功')
  loadData()
}
</script>
