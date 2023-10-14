#!/bin/bash

# Define variables
current_dir=$(pwd)
video_url='https://www.nicovideo.jp/watch/sm8628149'
video_title='badapple.mp4'
fps=24
optimize_svgs=1
concurrency=768 # this is pretty important because svgo sucks, it will still nuke your CPU with this set. Adjust if needed.

# Check for Arch
if [ -f /etc/arch-release ]; then
  echo "Running Arch Linux"
else
  echo "This system is not running Arch Linux. This script may not work as expected."
fi

# Check for yay package manager
if ! command -v yay &> /dev/null
then
    echo "Error: yay package manager not found. Exiting."
    exit 1
fi

# Define the dependencies as an array
dependencies=(python3 ffmpeg potrace yt-dlp pv)

# Check if dependencies are already installed
for i in "${dependencies[@]}"; do
    if ! command -v "$i" &> /dev/null
    then
        dependencies_to_install+=("$i")
    fi
done

# Check for nodejs
if ! command -v node &> /dev/null
then
    dependencies_to_install+=(nodejs)
fi

# Check for imagemagick mogrify
if ! command -v mogrify &> /dev/null
then
    dependencies_to_install+=(imagemagick)
fi

# If there are any dependencies to install, install them with yay
if [ ${#dependencies_to_install[@]} -gt 0 ]; then
    yay -S "${dependencies_to_install[@]}"
else
    echo "All dependencies are already installed, skipping yay."
fi

# Create folders if they dont exist
if [ ! -d "svgs" ]; then
    mkdir svgs
fi

if [ ! -d "svgs_inverted" ]; then
    mkdir svgs_inverted
fi

if [ ! -d "bmps" ]; then
    mkdir bmps
fi

if [ ! -d "bmps_inverted" ]; then
    mkdir bmps_inverted
fi

# Clean Folders
if [ -d "bmps" ] && [ "$(ls -A bmps)" ]; then
	rm -r bmps/*
fi

if [ -d "bmps_inverted" ] && [ "$(ls -A bmps_inverted)" ]; then
	rm -r bmps_inverted/*
fi

if [ -d "svgs" ] && [ "$(ls -A svgs)" ]; then
	rm -r svgs/*
fi

if [ -d "svgs" ] && [ "$(ls -A svgs_inverted)" ]; then
	rm -r svgs_inverted/*
fi


# Download video using yt-dlp if it doesn't already exist
if [ ! -f $video_title ]; then
    yt-dlp -f best -o $video_title $video_url
    echo "Video downloaded and renamed to $video_title"
else
    echo "$video_title already exists in the working directory, skipping download."
fi

# Convert video to bmps using ffmpeg
ffmpeg -i $video_title -vf fps=$fps "bmps/%05d.bmp"

# Read the dictionary.txt file into an array
dictionary=()
while read -r line; do
    dictionary+=("$line")
done < dictionary.txt

# Iterate through the bmps and rename them with the corresponding prefix
count=0
total=$(find bmps -type f | wc -l)
for i in {0..9999}; do
    if [ -f "bmps/$(printf "%05d" "$i").bmp" ]; then
        mv "bmps/$(printf "%05d" "$i").bmp" "bmps/${dictionary[i]}_$(printf "%05d" "$i").bmp"
        count=$((count+1))
        echo -ne "Renaming bmps for stupid Blender sorting: $count/$total \r"
    fi
done

echo "Video converted to bmps with fps $fps and stored in the ./bmps folder, bmps are renamed with incrementing dictionary words after the conversion."

# Invert the bmps
mogrify -monitor -path ./bmps_inverted/ -negate ./bmps/*.bmp

# Iterate through the inverted bmps and append "_inverted" to the filename
for file in ./bmps_inverted/*.bmp; do
mv "$file" "${file%.bmp}_inverted.bmp"
done

echo "Inverted bmps are stored in the ./bmps_inverted folder and have _inverted appended to the filename"

# Convert bmps to svgs
echo "Converting BMPs to SVGs"
for file in "$current_dir"/bmps/*.bmp; do
    potrace -s "$file" -o "$current_dir/svgs/$(basename "$file" .bmp).svg"
done


# Convert inverted bmps to inverted svgs
echo "Converting inverted BMPs to SVGs"
for file in "$current_dir"/bmps_inverted/*.bmp; do
    potrace -s "$file" -o "$current_dir/svgs_inverted/$(basename "$file" .bmp).svg"
done


echo "bmps have been converted to svgs and stored in the ./svgs folder and inverted bmps have been converted to inverted svgs and stored in the ./svgs_inverted folder"

# Optimize with SVGO

if [ $optimize_svgs -eq 1 ]; then
    find svgs -name '*.svg' -print0 | xargs -0 -P $concurrency -n 1 svgo --multipass -i
    find svgs_inverted -name '*.svg' -print0 | xargs -0 -P $concurrency -n 1 svgo --multipass -i
    echo "svgs have been optimized"
else
    echo "svg optimization has been skipped"
fi

echo "Processing Done."