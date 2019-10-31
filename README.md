# youtube_downloader
A shell wrapper of 'youtube-dl' to download videos with subtitles and thumbnails

Dependencies:
* youtube-dl
* ffmpeg

How it works:
    Put the URLs of the youtube videos into file 'waitinglist', one URL per line
    Execute the script, which will in term:
       1. Get one URL from the waiting list
       2. Download it with 'youtube-dl', with subtitles(english), and thumbnail
       3. Add thumbnail to the video file with 'ffmpeg'

