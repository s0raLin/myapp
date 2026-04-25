# 后端

## 目录结构

```tree
backend/
├── cmd/server/main.go        # 启动入口
├── internal/
│   ├── handler/              # HTTP handler，对应 Flutter 的 service 调用
│   ├── service/              # 业务逻辑
│   ├── repository/           # 数据库操作（GORM 或 sqlx）
│   └── model/                # 数据结构 + JSON tag
├── middleware/                # JWT 验证、CORS、日志
├── router/                   # 路由注册（Gin / Chi / Fiber）
├── pkg/                      # 可复用工具（jwt生成、统一响应结构）
├── config/                   # 配置文件读取
├── go.mod
└── Dockerfile
```
