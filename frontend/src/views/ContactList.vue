<template>
  <div>
    <!-- 搜索栏 -->
    <div class="page-card">
      <div class="card-title">通讯录查询</div>
      <div class="search-bar">
        <el-input v-model="query.realName" placeholder="姓名" clearable style="width: 150px"
                  @keyup.enter="handleSearch" />
        <el-select v-model="query.majorId" placeholder="专业" clearable style="width: 180px" filterable>
          <el-option v-for="m in majorList" :key="m.id" :label="m.name" :value="m.id" />
        </el-select>
        <el-input v-model="query.className" placeholder="班级" clearable style="width: 130px" />
        <el-input v-model="query.enrollYear" placeholder="入校年份" clearable style="width: 110px" />
        <el-input v-model="query.city" placeholder="城市" clearable style="width: 130px" />
        <el-input v-model="query.employer" placeholder="就业单位" clearable style="width: 150px" />
        <el-button type="primary" @click="handleSearch">
          <el-icon><Search /></el-icon> 搜索
        </el-button>
        <el-button @click="resetQuery">重置</el-button>
      </div>
    </div>

    <!-- 数据表格 -->
    <div class="page-card">
      <el-table :data="tableData" stripe border style="width: 100%" v-loading="loading"
                @row-click="showDetail">
        <el-table-column prop="realName" label="姓名" width="100" />
        <el-table-column prop="majorName" label="专业" width="160" />
        <el-table-column prop="className" label="班级" width="120" />
        <el-table-column prop="enrollYear" label="入校年份" width="90" align="center" />
        <el-table-column prop="graduateYear" label="毕业年份" width="90" align="center" />
        <el-table-column prop="employer" label="就业单位" min-width="180" show-overflow-tooltip />
        <el-table-column prop="city" label="城市" width="100" />
        <el-table-column prop="phone" label="联系方式" width="130" />
        <el-table-column prop="email" label="邮箱" width="180" show-overflow-tooltip />
      </el-table>

      <div style="margin-top: 16px; text-align: right">
        <el-pagination
          v-model:current-page="query.pageNum"
          v-model:page-size="query.pageSize"
          :page-sizes="[10, 20, 50]"
          :total="total"
          layout="total, sizes, prev, pager, next"
          @size-change="handleSearch"
          @current-change="handleSearch"
        />
      </div>
    </div>

    <!-- 详情弹窗 -->
    <el-dialog v-model="dialogVisible" title="通讯录详情" width="600px">
      <el-descriptions :column="2" border v-if="currentRow">
        <el-descriptions-item label="姓名">{{ currentRow.realName }}</el-descriptions-item>
        <el-descriptions-item label="专业">{{ currentRow.majorName }}</el-descriptions-item>
        <el-descriptions-item label="学院">{{ currentRow.department }}</el-descriptions-item>
        <el-descriptions-item label="班级">{{ currentRow.className }}</el-descriptions-item>
        <el-descriptions-item label="入校年份">{{ currentRow.enrollYear }}</el-descriptions-item>
        <el-descriptions-item label="毕业年份">{{ currentRow.graduateYear }}</el-descriptions-item>
        <el-descriptions-item label="就业单位" :span="2">{{ currentRow.employer }}</el-descriptions-item>
        <el-descriptions-item label="所在城市">{{ currentRow.city }}</el-descriptions-item>
        <el-descriptions-item label="联系方式">{{ currentRow.phone }}</el-descriptions-item>
        <el-descriptions-item label="电子邮箱" :span="2">{{ currentRow.email }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue'
import request from '../utils/request'

const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const majorList = ref([])
const dialogVisible = ref(false)
const currentRow = ref(null)

const query = reactive({
  realName: '',
  majorId: null,
  className: '',
  enrollYear: '',
  graduateYear: '',
  city: '',
  employer: '',
  pageNum: 1,
  pageSize: 10
})

onMounted(async () => {
  const res = await request.get('/major/list')
  majorList.value = res.data
  handleSearch()
})

async function handleSearch() {
  loading.value = true
  try {
    const res = await request.post('/contact/list', {
      ...query,
      enrollYear: query.enrollYear ? parseInt(query.enrollYear) : null,
      graduateYear: query.graduateYear ? parseInt(query.graduateYear) : null
    })
    tableData.value = res.data.records
    total.value = res.data.total
  } catch (e) {} finally {
    loading.value = false
  }
}

function resetQuery() {
  Object.assign(query, {
    realName: '', majorId: null, className: '', enrollYear: '',
    graduateYear: '', city: '', employer: '', pageNum: 1, pageSize: 10
  })
  handleSearch()
}

function showDetail(row) {
  currentRow.value = row
  dialogVisible.value = true
}
</script>
