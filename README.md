# SMIL Apple

Generating your own SMIL animation is fairly easy. You just need the following:
* Python 3
* Node.js (for SVGO)
* svgo - install with `npm -g install svgo`
* [ffmpeg](https://ffmpeg.org/)
* [potrace](http://potrace.sourceforge.net/) (on your path or in your main folder)
* [youtube-dl](https://github.com/ytdl-org/youtube-dl) or [yt-dlp](https://github.com/yt-dlp/yt-dlp) (optional)
* smilapple.py from this repo in your main folder
* a text editor I guess I really hope you have one of those
* reading comprehension?

First, set up your workspace. You'll want a main folder (where you'll do all the work and run the commands) with two subfolders called `bmps` and `svgs`.

Now, get your video. For example, to download the original Bad Apple with yt-dlp:

```
yt-dlp https://www.nicovideo.jp/watch/sm8628149
```

However you get the video, you'll want to rename it to input.mp4 for the following command to work. This will split it into frames. If your video isn't 30fps, replace the fps in the command.

```
ffmpeg -i input.mp4 -vf fps=30 bmps/%d.bmp
```

You now have a folder with a bmp of each frame of your video. Unfortunately, we need BMPs because of potrace's limitations, which we'll use next.

We need to iterate potrace over each frame and generate an SVG for it in our `svgs` directory. First, make note of your total number of frames (the number of files or the highest number in the `bmps` directory. In these examples, it's 6573, so replace that number with yours.)

In Windows, the command for potrace is:

```
for /L %i in (1,1,6573) do potrace -s bmps/%i.bmp -o svgs/%i.svg
```

In Unix bash shell, it should be:

```
for i in {1..6573}; do potrace -s bmps/$i.bmp -o svgs/$i.svg; done
```

Now we want to optimize the SVGs, to reduce the final file size as well as simplify the work a little for our Python script.

```
svgo -f svgs --multipass
```

Before we run the Python script, we need to edit a couple hard-coded values. Change the `frames` and `framerate` variables to the values used in the previous steps. There's also a hardcoded width and height that appear twice in the multiline text at the beginning (512x384). I don't think those should technically need to be changed, but you may want to change them to match your video resolution anyway. Now we can run the script:

```
python smilapple.py
```

And that's it! You should now have a `smil.svg` which contains your animation!
