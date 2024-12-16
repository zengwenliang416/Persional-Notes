# 【Git】个人主页优化方案

## 一、创建个人主页仓库

1. 在 GitHub 上创建与用户名相同的仓库
   - 仓库名必须与你的 GitHub 用户名完全相同
   - 例如：用户名为 `Zengwenliang0416`，则仓库名也必须是 `Zengwenliang0416`

## 二、README 基础设置

1. 创建并编辑 `README.md`
2. 基础结构包含：
   - 个人介绍
   - 技能展示
   - 统计信息
   - 联系方式

## 三、美化与功能增强

### 1. 动态打字效果
```markdown
<div align="center">
    <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&pause=1000&center=true&vCenter=true&width=435&lines=Hello%2C+I'm+Your+Name+%F0%9F%91%8B;A+Passionate+Developer+%F0%9F%92%BB;Always+Learning+New+Things+%F0%9F%8C%B1" alt="Typing SVG" />
</div>
```

### 2. 技术栈展示
使用 shields.io 徽章，每个徽章都链接到对应技术的官方网站：
```markdown
<div align="center">
    <a href="https://www.typescriptlang.org/">
        <img src="https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white" />
    </a>
    <!-- 更多技术栈徽章 -->
</div>
```

### 3. GitHub 统计
```markdown
<div align="center">
    <img src="https://github-readme-stats.vercel.app/api?username=YOUR_USERNAME&show_icons=true&theme=tokyonight&hide_border=true&count_private=true" alt="GitHub Stats" />
</div>
```

## 四、WakaTime 统计设置

### 1. 配置 WakaTime
1. 安装 WakaTime
   - 在你的 IDE（如 VS Code）中安装 WakaTime 插件
   - 访问 https://wakatime.com 注册账号
   - 在设置中获取 API Key

### 2. 设置 GitHub Action
1. 创建 `.github/workflows/waka-readme.yml` 文件：
```yaml
name: Waka Readme

on:
  schedule:
    - cron: '30 18 * * *'
  workflow_dispatch:
jobs:
  update-readme:
    name: Update Readme with Metrics
    runs-on: ubuntu-latest
    steps:
      - uses: anmol098/waka-readme-stats@master
        with:
          WAKATIME_API_KEY: ${{ secrets.WAKATIME_API_KEY }}
          GH_TOKEN: ${{ secrets.GH_TOKEN }}
          SHOW_LINES_OF_CODE: "True"
          SHOW_PROFILE_VIEWS: "False"
          SHOW_COMMIT: "True"
          SHOW_DAYS_OF_WEEK: "True"
          SHOW_LANGUAGE: "True"
          SHOW_OS: "True"
          SHOW_PROJECTS: "True"
          SHOW_TIMEZONE: "True"
          SHOW_EDITORS: "True"
          SHOW_SHORT_INFO: "True"
```

### 3. 配置 GitHub Secrets
1. 创建 Personal Access Token
   - 访问 https://github.com/settings/tokens
   - 生成新的 token (classic)
   - 选择权限：`repo` 和 `user`
   - 复制生成的 token

2. 添加 Secrets
   - 仓库 Settings -> Secrets and variables -> Actions
   - 添加两个 secret：
     - `WAKATIME_API_KEY`: WakaTime 的 API key
     - `GH_TOKEN`: GitHub Personal Access Token

### 4. 在 README 中添加统计区域
```markdown
<!--START_SECTION:waka-->
<!--END_SECTION:waka-->
```

## 五、维护与更新

1. 定期更新技术栈
2. 保持统计信息实时性
3. 根据需要调整主题和样式
4. 确保所有链接和徽章都是有效的

## 六、注意事项

1. 确保所有 API Keys 和 Tokens 安全存储
2. 定期检查 GitHub Action 运行状态
3. 保持 README 内容的简洁和专业性
4. 适时更新个人介绍和项目展示
