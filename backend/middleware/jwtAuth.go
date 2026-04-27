package middleware

import (
	"miku_music/utils"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func JWTAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"code": 1, "msg": "请求未携带token,请先登录"})
			c.Abort() //终止后续操作
			return
		}
		// 2. 检查格式是否为 "Bearer <token>"
		parts := strings.SplitN(authHeader, " ", 2)
		if !(len(parts) == 2 && parts[0] == "Bearer") {
			c.JSON(http.StatusUnauthorized, gin.H{"code": 1, "msg": "Token格式错误"})
			c.Abort()
			return
		}

		// 3. 解析并验证 Token
		tokenString := parts[1]
		claims := &utils.Claims{} // 使用你定义的 Claims 结构体

		token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (any, error) {
			return []byte("your_secret_key"), nil // 必须和生成时的 key 一致
		})

		// 4. 判断 Token 是否有效
		if err != nil || !token.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{"code": 1, "msg": "无效的或已过期的Token"})
			c.Abort()
			return
		}

		// 5. 将解析出来的用户信息存入上下文 (Context)，方便后续 Handler 直接使用
		c.Set("userID", claims.UserID)
		c.Set("username", claims.Username) // 如果你在 Claims 里存了的话

		c.Next() // 验证通过，继续执行后续逻辑
	}
}
