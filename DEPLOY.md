# F1 Database Editor - 构建和部署指南

## 📋 目录
- [快速开始](#快速开始)
- [环境准备](#环境准备)
- [构建项目](#构建项目)
- [部署到服务器](#部署到服务器)
- [常见问题](#常见问题)

---

## 🚀 快速开始

### 一键构建和部署

```bash
# 1. 双击运行构建脚本
build.bat

# 2. 修改配置文件
# 编辑 deploy-config.txt，填入服务器信息

# 3. 双击运行部署脚本
deploy.bat
```

---

## 💻 环境准备

### 必需软件

1. **Node.js** (必须)
   - 版本: 16.x 或更高
   - 下载: https://nodejs.org/
   - 安装后重启命令行

2. **Git** (可选，用于版本管理)
   - 下载: https://git-scm.com/

3. **OpenSSH客户端** (用于部署，Windows 10/11自带)
   - 检查: 打开CMD，输入 `ssh -V`
   - 如果没有，在"设置 → 应用 → 可选功能"中安装

### 验证安装

```bash
# 检查Node.js
node -v
# 应该显示: v18.x.x 或更高

# 检查npm
npm -v
# 应该显示: 8.x.x 或更高

# 检查SSH
ssh -V
# 应该显示: OpenSSH_for_Windows 8.x
```

---

## 🔨 构建项目

### 方法一：使用批处理脚本（推荐）

```bash
# 双击运行
build.bat
```

脚本会自动：
- ✅ 检查Node.js环境
- ✅ 安装依赖包（如果需要）
- ✅ 构建项目
- ✅ 显示构建报告
- ✅ 打开构建产物目录

### 方法二：手动构建

```bash
# 1. 进入项目目录
cd F:\ModFans\DatabaseEditor\F1-Database-Editor-CN

# 2. 安装依赖（首次或依赖更新时）
npm install

# 3. 构建项目
npm run build

# 4. 查看构建产物
dir dist
```

### 构建产物说明

构建完成后会生成 `dist` 或 `build` 目录：

```
dist/
├── index.html          # 主页面
├── js/                 # JavaScript文件（已压缩）
│   └── main.xxxxx.js
├── css/                # CSS文件（已压缩）
│   └── main.xxxxx.css
└── assets/             # 图片等资源文件
```

**注意**: 部署时上传的是 `dist/` 目录的**内容**，不是整个目录！

---

## 📦 部署到服务器

### 方法一：使用部署脚本（推荐）

#### 1. 配置服务器信息

编辑 `deploy-config.txt`:

```ini
SERVER_IP=你的服务器IP
SERVER_USER=root
SERVER_PATH=/www/wwwroot/www.modfans.cc/f1-editor
```

#### 2. 运行部署脚本

```bash
# 双击运行
deploy.bat
```

脚本会自动：
- ✅ 检查构建产物
- ✅ 备份服务器现有文件
- ✅ 上传新文件
- ✅ 验证部署结果
- ✅ 打开浏览器测试

### 方法二：使用宝塔面板上传

1. **登录宝塔面板**
   - 访问: `http://服务器IP:8888`

2. **进入文件管理**
   - 导航到: `/www/wwwroot/www.modfans.cc/f1-editor/`

3. **上传文件**
   - 删除旧文件（如果有）
   - 点击"上传"
   - 选择 `dist/` 目录的所有文件
   - 等待上传完成

### 方法三：使用FTP工具

1. **使用FileZilla连接服务器**
   - 主机: 服务器IP
   - 用户名: root
   - 密码: 你的密码
   - 端口: 22

2. **上传文件**
   - 本地站点: 打开 `dist/` 目录
   - 远程站点: `/www/wwwroot/www.modfans.cc/f1-editor/`
   - 拖拽上传所有文件

### 方法四：使用SCP命令

```bash
# Windows CMD或PowerShell
scp -r dist\* root@服务器IP:/www/wwwroot/www.modfans.cc/f1-editor/

# 或使用rsync（更高效）
rsync -avz --delete dist/ root@服务器IP:/www/wwwroot/www.modfans.cc/f1-editor/
```

---

## 🌐 服务器配置

### Nginx配置（宝塔面板）

如果使用子域名 `f1-editor.modfans.cc`:

```nginx
server {
    listen 80;
    server_name f1-editor.modfans.cc;
    
    root /www/wwwroot/f1-editor.modfans.cc;
    index index.html;
    
    # Gzip压缩
    gzip on;
    gzip_types text/plain text/css application/javascript application/json image/svg+xml;
    gzip_min_length 1000;
    
    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
    
    # SPA路由支持
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # 安全头
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
}
```

### 申请SSL证书

1. 宝塔面板 → 网站 → 设置
2. SSL → Let's Encrypt
3. 勾选域名 → 申请
4. 开启"强制HTTPS"

---

## ✅ 部署验证

### 检查清单

部署完成后，逐项检查：

- [ ] 访问首页正常显示
- [ ] 浏览器控制台无404错误
- [ ] JS文件正常加载
- [ ] CSS样式正常
- [ ] 图片正常显示
- [ ] 可以加载存档文件
- [ ] 编辑功能正常
- [ ] 下载功能正常
- [ ] HTTPS正常工作
- [ ] 移动端显示正常

### 测试命令

```bash
# 测试HTTP响应
curl -I https://www.modfans.cc/f1-editor/

# 检查文件是否存在
curl https://www.modfans.cc/f1-editor/ | grep -E "js|css"

# 测试加载速度
curl -w "@curl-format.txt" -o /dev/null -s https://www.modfans.cc/f1-editor/
```

---

## ❓ 常见问题

### Q1: 构建时提示"找不到webpack"

**解决方法:**
```bash
# 重新安装依赖
npm install

# 或清除缓存后重装
rm -rf node_modules package-lock.json
npm install
```

### Q2: 构建成功但服务器显示空白页

**可能原因:**
1. 路径配置错误
2. JS文件404
3. 浏览器缓存

**解决方法:**
```bash
# 1. 检查webpack.config.js中的publicPath
output: {
    publicPath: '/f1-editor/',  # 子目录部署
    // 或
    publicPath: '/',             # 独立域名
}

# 2. 浏览器强制刷新
Ctrl + F5

# 3. 检查浏览器控制台错误
F12 → Console
```

### Q3: 上传后访问404

**解决方法:**
```bash
# 1. 确认文件上传到正确位置
ls -la /www/wwwroot/www.modfans.cc/f1-editor/

# 2. 确认有index.html
ls -la /www/wwwroot/www.modfans.cc/f1-editor/index.html

# 3. 检查Nginx配置
cat /www/server/panel/vhost/nginx/你的域名.conf

# 4. 重载Nginx
nginx -t
nginx -s reload
```

### Q4: SSH连接失败

**解决方法:**
```bash
# 1. 检查SSH服务
ssh root@服务器IP

# 2. 检查防火墙
# 服务器端执行:
systemctl status sshd

# 3. 检查端口
# 默认是22，如果修改了需要指定端口:
scp -P 端口号 -r dist/* root@服务器IP:/path/
```

### Q5: 部署后功能异常

**排查步骤:**
```bash
# 1. 检查浏览器控制台
F12 → Console → 查看错误信息

# 2. 检查网络请求
F12 → Network → 查看404请求

# 3. 检查文件完整性
# 对比本地dist目录和服务器文件
dir dist
ssh root@服务器IP "ls -la /www/wwwroot/www.modfans.cc/f1-editor/"

# 4. 回滚到备份
ssh root@服务器IP "rm -rf /www/wwwroot/www.modfans.cc/f1-editor/* && cp -r /www/wwwroot/www.modfans.cc/f1-editor.backup.*/* /www/wwwroot/www.modfans.cc/f1-editor/"
```

---

## 🔄 更新流程

### 日常更新

```bash
# 1. 拉取最新代码
git pull origin zh-CN-hack

# 2. 安装新依赖（如果有）
npm install

# 3. 构建
build.bat

# 4. 部署
deploy.bat
```

### 大版本更新

```bash
# 1. 同步原项目更新
git fetch upstream
git checkout release
git merge upstream/release

# 2. 合并到汉化分支
git checkout zh-CN-hack
git merge release

# 3. 解决冲突（如果有）
# 手动编辑冲突文件

# 4. 提交
git add .
git commit -m "merge: 同步原项目更新"
git push origin zh-CN-hack

# 5. 重新构建和部署
build.bat
deploy.bat
```

---

## 📞 获取帮助

如果遇到问题：

1. **查看日志**
   - 构建日志: 运行build.bat时的输出
   - 部署日志: deploy.bat的输出
   - 服务器日志: 宝塔面板 → 网站 → 日志

2. **提交Issue**
   - GitHub: https://github.com/Shaoxinxi/F1-Database-Editor-CN/issues

3. **联系支持**
   - ModFans社区: https://www.modfans.cc

---

## 📝 版本历史

- **v1.0.0** (2026-05-12)
  - 初始版本
  - 自动化构建和部署脚本
  - 完整的文档

---

**ModFans Team** - 让游戏模组更简单！
