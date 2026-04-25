package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	DBDriver string
	DBSource string // MySql DSN
	Port     string
}

func Load() (*Config, error) {

	_ = godotenv.Load() //加载.env文件,不存在时忽略

	cfg := &Config{
		DBDriver: getEnv("DB_DRIVER", "mysql"),
		DBSource: getEnv("DB_SOURCE", ""),
		Port:     getEnv("PORT", "8080"),
	}

	if cfg.DBSource == "" {
		return nil, fmt.Errorf("缺少环境变量: DB_SOURCE")
	}
	return cfg, nil
}

func getEnv(key, defaultVal string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return defaultVal
}
