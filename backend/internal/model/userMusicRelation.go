package model

import "time"

type UserMusicRelation struct {
    UserID    uint      `gorm:"primaryKey"`
    MusicID   uint      `gorm:"primaryKey"`
    CreatedAt time.Time // 上传时间
}



