#!/bin/bash
ffmpeg='/home/20801921/ffmpeg/bin/ffmpeg'

#${ffmpeg} -vcodec png -i ${1} -f rawvideo -pix_fmt bgra -y apergy-800x480.fb
${ffmpeg} -vcodec png -i ${1} -f rawvideo -pix_fmt rgb565 -y apergy-800x600.fb

