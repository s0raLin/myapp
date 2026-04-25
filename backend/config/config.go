package config

import "os"

type Config struct {
	DBDriver string
	DBSource string // MySql DSN
	Port     string
}

func Load() *Config {
	driver := os.Getenv("DB_DRIVER")
	if driver == "" {
		driver = "mysql"
	}
	source := os.Getenv("DB_SOURCE")
	if source == "" {
		source = "root:123456@tcp(127.0.0.1:3306)/music_app?charset=utf8mb4&parseTime=True&loc=Local"
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	return &Config{
		DBDriver: driver,
		DBSource: source,
		Port:     port,
	}
}
