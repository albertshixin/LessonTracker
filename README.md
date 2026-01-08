# 课时小管家 Pro (LessonTracker Pro)

[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-blue)](https://flutter.dev)
[![Framework](https://img.shields.io/badge/Framework-Flutter%203.x-green)](https://flutter.dev)
[![Backend](https://img.shields.io/badge/Backend-Firebase-orange)](https://firebase.google.com/)

**课时小管家 Pro** 是一款专为家长和学生设计的跨平台课外辅导管理工具。通过自动化课时核算、多级智能提醒以及富媒体打卡功能，帮助用户在一个应用内精准统筹所有兴趣班与辅导课程。

## 核心功能

### 1. 课时资产管理
- **多科目支持**：自由创建钢琴、英语、足球、绘画等课程。
- **自动核算**：设置总课时，系统根据打卡记录自动计算“已上课时”与“剩余课时”。
- **有效期监控**：直观展示课程开始/结束日期，并对即将过期的课程进行预警。

### 2. 智能排课与缺勤规则
- **灵活周期**：支持每周固定频率、每月固定日期或自定义手动排课。
- **异常处理**：支持标记“请假、推迟、补课、错过不补”。仅“正常打卡”与“错过不补”会扣减课时余额。

### 3. 自定义多级提醒
- **多点提醒**：每门课可设置多个提醒时间点（如提前 1 天、提前 1 小时、提前 10 分钟）。
- **跨平台触达**：App 端系统级推送与 Web 端浏览器通知同步触发。

### 4. 视觉化打卡记录
- **影像存证**：打卡时支持调用摄像头拍照（环境、作品、软件界面等）。
- **学习时间轴**：所有打卡照片与备注按时间线排列，形成完整的学习成长记录。



---

## 技术架构

- **前端框架**: Flutter (Dart) - 负责全平台 UI 渲染与原生功能调用。
- **后端 BaaS**: Firebase / Supabase - 处理数据持久化、文件存储及推送通知。
- **本地存储**: SQLite (Mobile) / IndexedDB (Web) - 保证弱网环境下打卡数据的稳定性。
- **状态管理**: Provider / Riverpod。

---

## 项目结构 (核心目录)

```text
lib/
├── core/              # 通用配置、常量与工具类
├── data/              # 数据库模型 (Models) 及 数据持久化逻辑
├── providers/         # 业务逻辑与状态管理
├── ui/                # UI 界面
│   ├── widgets/       # 通用组件 (课程卡片、打卡按钮等)
│   ├── views/         # 功能页面 (首页、排课页、打卡页、记录页)
│   └── themes/        # 跨平台 UI 适配主题
└── main.dart          # 应用入口