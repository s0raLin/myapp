package main

import (
	"log"
	"miku_music/router"

	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	// 全局 CORS（Flutter 调试时跨域用）
	r.Use(func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Headers", "Authorization, Content-Type")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}
		c.Next()
	})

	//把所有路由注册交给router包
	router.Setup(r)

	// 启动
	log.Println("Server running on :8080")
	if err := r.Run(":8080"); err != nil {
		log.Fatal(err)
	}
}
