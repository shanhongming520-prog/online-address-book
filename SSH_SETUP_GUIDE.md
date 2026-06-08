# SSH 公钥配置说明

## 步骤 1: 将公钥添加到 GitHub

1. 登录 https://github.com/settings/keys
2. 点击 "New SSH key"
3. Title 填写: `contact-system-ncu`
4. Key type 选择: **Authentication Key**
5. 粘贴以下公钥内容:

```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgavKR5EVM4TxsjLAq/AhHM3izduhwxnCp54g25AOooYJGgP3Kw4NSNAIMLlN9qbvtls8RplH1GKvLWEm7u0woPB+7bRg8YjJRrM5lhzonMve7Wh9G3j2v796jxJoyT5L11cMB796aPtyg08wQDxUO06yFbpj16z3cs5azTPV4TSSbK4S2tUrmmGFvHO7VEKiTw+UE8fRYNjVPBagMqXxzOlpdKUHmcdy4XOC/yiuTJjswUW12fh4YXmA8bstdlFj6CwpSdH8dSJI+2zJxdd9fkmj7E0/jC0wS5MexhV9WPclO3CYIAWghlhkbNoqxhWrDE1CUzMglC2fgvmrLnE6+M/8aBeQqCXonitS+KUFRuU63PuZ2ZiaE/w4kwY9RsGIWGk8RbEYqLBsW6VQtwAVcTLez4ahHwh7F1j3U8TCe3ZYqF/VZFG4l/i+xVHgUa0L0a4v+RtbAJGicJc4SQdRZT4oTuibAQUI7wG5UAI1NYckTr5DTg7xqcggTu2/9kOk0qiqGLEEx/1IdNaXy+nKp20lnMAnxraTGuf8jMVinfu5GCM+q3WYOubR9VtdDBncmFKmgQHzFgKCzssGlI+k1diMSQemOlZYLZrC+WrWWWgnjN31jgNQbyAn57jo2ZuXzgrDItrjTlx0tC3dUrqbwc4/vxQaWEQC008B3r4kuuQ== online-address-book@ncu
```

6. 点击 "Add SSH key"

## 生成的密钥文件位置

- 私钥: `E:\py\1\contact-system\ssh-keys\id_rsa`
- 公钥: `E:\py\1\contact-system\ssh-keys\id_rsa.pub`
