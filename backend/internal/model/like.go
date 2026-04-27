package model

import "time"

// 点赞表
type Like struct {
    UserID    uint `gorm:"primaryKey"`
    MusicID   uint `gorm:"primaryKey"`
    CreatedAt time.Time
}
