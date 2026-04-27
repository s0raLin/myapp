package model

import (
	"time"

	"gorm.io/gorm"
)

type MusicInfo struct {
	ID        uint           `gorm:"primaryKey"`
	CreatedAt time.Time      // 自动记录创建时间
	UpdatedAt time.Time      // 自动记录更新时间
	DeletedAt gorm.DeletedAt `gorm:"index"` // 软删除支持

	// 基础元数据
	Title    string `gorm:"size:255;not null;" form:"title"` // 歌曲标题，加索引方便搜索
	Artist   string `gorm:"size:255;" form:"artist"`          // 歌手/作者
	Album    string `gorm:"size:255" form:"album"`           // 专辑
	Duration int    `gorm:"comment:时长(秒)" form:"duration"`      // 时长：存整数（秒）

	// 资源路径 (建议存 OSS 的相对路径 ObjectKey)
	OssKey   string `gorm:"size:500;not null"`       // 音乐文件的 OSS 路径
	CoverUrl string `gorm:"size:500;comment:封面图URL"` // 封面图的 OSS 路径或完整URL
	LyricUrl    string `gorm:"size:500;comment:歌词文件路径"`
}
