package handler

import (
	"log"
	"miku_music/internal/model"
	"miku_music/internal/repository"
	"miku_music/utils"
	"net/http"
	"path/filepath"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type MusicHandler struct{}

func NewMusicHandler() *MusicHandler {
	return &MusicHandler{}
}

func (s *MusicHandler) AddMusic(c *gin.Context) {
	var music model.MusicInfo
	if err := c.ShouldBind(&music); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 1, "msg": "参数错误"})
	}

	// 获取上传的文件
	file, err := c.FormFile("audio")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 1, "msg": "请上传音乐文件"})
		return
	}
	// 获取歌词文件(可选)
	lyricFile, err := c.FormFile("lyric")

	var lyricURL string
	if err == nil {
		//如果用户上传了歌词,放到oss的lyrics目录下
		lyricName := uuid.New().String() + ".lrc"
		lyricURL, _ = utils.OSSUpload(lyricFile, "lyrics/"+lyricName)
	}

	//提取文件后缀名
	ext := filepath.Ext(file.Filename)
	//生成uuid
	newUUID := uuid.New().String()

	fileName := newUUID + ext

	//上传音乐
	audioURL, err := utils.OSSUpload(file, fileName)
	if err != nil {
		log.Printf("OSS 报错详情: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"code": 1,
			"msg":  err,
		})
		return
	}
	//将地址填充到绑定的结构体中
	music.OssKey = audioURL
	music.LyricUrl = lyricURL

	//保存到数据库
	if err := repository.DB.Create(&music).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"code": 1,
			"msg":  "保存记录失败",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"code": 0,
		"msg":  "上传成功",
		"data": music,
	})
}
