package model

import "time"

// 收藏表
type Favorite struct {
    UserID    uint `gorm:"primaryKey"`
    MusicID   uint `gorm:"primaryKey"`
    CreatedAt time.Time
}
