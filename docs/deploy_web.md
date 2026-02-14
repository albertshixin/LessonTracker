# Web 部署（双子域名）

本项目采用 **两个子域名** 部署中国版与国际版：

- 中国版：`cn.yourdomain.com`
- 国际版：`app.yourdomain.com` 或 `intl.yourdomain.com`

## 构建产物

- 中国版入口：`lib/main_cn.dart`
- 国际版入口：`lib/main_intl.dart`

建议分别构建并部署到对应子域名。

### 本地构建示例

```bash
flutter build web --release -t lib/main_cn.dart
flutter build web --release -t lib/main_intl.dart
```

## 部署建议（以 Vercel 为例）

- 建两个项目或同一项目的两个部署目标
- 每个子域名对应一个构建入口

示例：
- `cn.yourdomain.com` → Build Command: `flutter build web --release -t lib/main_cn.dart`
- `intl.yourdomain.com` → Build Command: `flutter build web --release -t lib/main_intl.dart`

> 注意：部署目录应指向 `build/web`（构建产物），不要直接部署 `web/` 目录。

## 路由配置（单页应用）

确保所有路径重写到 `/index.html`，否则深层路由会 404。
