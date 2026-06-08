<template>
  <div>
    <div class="page-card">
      <div class="card-title">我的通讯录信息</div>
      <el-form :model="form" label-width="100px" size="large">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="专业">
              <el-select v-model="form.majorId" placeholder="请选择专业" style="width: 100%" filterable>
                <el-option v-for="m in majorList" :key="m.id" :label="`${m.name} (${m.department})`" :value="m.id" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="班级">
              <el-input v-model="form.className" placeholder="如：计科2101班" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="入校年份">
              <el-date-picker v-model="form.enrollYear" type="year" placeholder="选择入校年份"
                              value-format="YYYY" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="毕业年份">
              <el-date-picker v-model="form.graduateYear" type="year" placeholder="选择毕业年份"
                              value-format="YYYY" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="就业单位">
              <el-input v-model="form.employer" placeholder="请输入就业单位" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="所在城市">
              <el-input v-model="form.city" placeholder="请输入所在城市" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="联系方式">
              <el-input v-model="form.phone" placeholder="请输入手机号码" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="电子邮箱">
              <el-input v-model="form.email" placeholder="请输入电子邮箱" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item>
          <el-button type="primary" size="large" :loading="loading" @click="handleSave">
            {{ isEdit ? '更新信息' : '保存信息' }}
          </el-button>
          <el-button size="large" @click="resetForm">重置</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue'
import request from '../utils/request'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const isEdit = ref(false)
const majorList = ref([])

const form = reactive({
  majorId: null,
  className: '',
  enrollYear: '',
  graduateYear: '',
  employer: '',
  city: '',
  phone: '',
  email: ''
})

onMounted(async () => {
  // 加载专业列表
  try {
    const res = await request.get('/major/list')
    majorList.value = res.data
  } catch (e) {}

  // 加载我的通讯录信息
  try {
    const res = await request.get('/contact/my')
    if (res.data) {
      Object.assign(form, res.data)
      isEdit.value = true
    }
  } catch (e) {}
})

async function handleSave() {
  loading.value = true
  try {
    await request.post('/contact/my', form)
    ElMessage.success(isEdit.value ? '更新成功' : '保存成功')
    isEdit.value = true
  } catch (e) {} finally {
    loading.value = false
  }
}

function resetForm() {
  Object.assign(form, {
    majorId: null, className: '', enrollYear: '', graduateYear: '',
    employer: '', city: '', phone: '', email: ''
  })
  isEdit.value = false
}
</script>
