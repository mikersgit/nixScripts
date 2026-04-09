ffmpeg='/home/20801921/ffmpeg/bin/ffmpeg'

${ffmpeg} -vcodec rawvideo -f rawvideo -pix_fmt bgra -s 800x480 -i apergy-800x480.fb -vcodec png -an -y wallpaper-480.png
${ffmpeg} -vcodec rawvideo -f rawvideo -pix_fmt rgb565 -s 800x600 -i apergy-800x600.fb -vcodec png -an -y wallpaper-600.png

