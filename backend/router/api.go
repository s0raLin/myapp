package router

import (
	"miku_music/internal/handler"

	"github.com/gin-gonic/gin"
)

func Setup(r *gin.Engine) *gin.Engine {
	authHandler := handler.NewAuthHandler()

	//公开路由
	public := r.Group("/api")
	{

		auth := public.Group("/auth")
		{
			auth.POST("/login", authHandler.Login)
			auth.POST("/register", authHandler.Register)
		}
	}

	// 需要鉴权的路由
	// ...
	return r
}
