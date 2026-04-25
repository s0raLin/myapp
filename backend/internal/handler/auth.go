package handler

import (
	"miku_music/internal/model"
	"net/http"

	"github.com/gin-gonic/gin"
	
)

type AuthHandler struct{}

func NewAuthHandler() *AuthHandler {
	return &AuthHandler{}
}

func (s *AuthHandler) Login(c *gin.Context) {
	var req struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 1, "msg": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code": 0,
		"msg":  "ok",
		"data": gin.H{"token": "jwt.token"},
	})
}

func (h *AuthHandler) Register(c *gin.Context) {

	var user model.User
	if err := c.ShouldBindJSON(&user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"code": 1,
			"msg": "用户绑定失败",
		})
	}



	c.JSON(http.StatusOK, gin.H{
		"code": 0,
		"msg":  "已注册",
	})
}

