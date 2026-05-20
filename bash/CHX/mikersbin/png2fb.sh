#!/bin/bash
ffmpeg='/home/20801921/ffmpeg/bin/ffmpeg'

#${ffmpeg} -vcodec png -i ${1} -f rawvideo -pix_fmt bgra -y apergy-800x480.fb
${ffmpeg} -vcodec png -i ${1} -f rawvideo -pix_fmt rgb565 -y apergy-800x600.fb
ffmpeg -hide_banner -y -i wallpaper-1280.png -pix_fmt bgra -f rawvideo apergy-1280x800.fb

ffmpeg -vcodec png -i splash-1280x800.png -f rawvideo -pix_fmt bgr24 -y splash-1280x800.fb
cat splash-1280x800.header splash-1280x800.fb > splash-1280x800.img
