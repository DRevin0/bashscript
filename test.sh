#!/bin/bash
#This is comment
current_directory=$(pwd)
home_directory="$HOME"

download_directory=$(xdg-user-dir DOWNLOAD)
documents_directory=$(xdg-user-dir DOCUMENTS)
music_directory=$(xdg-user-dir MUSIC)
videos_directory=$(xdg-user-dir VIDEOS)
pictures_directory=$(xdg-user-dir PICTURES)

mkdir -p "$documents_directory/autosort" "$music_directory/autosort" "$videos_directory/autosort" "$pictures_directory/autosort"
#tmp
test_directory="$home_directory/Test"

pics_count=0
vids_count=0
docs_count=0
musics_count=0

while IFS= read -r -d '' file; do
    extension="${file##*.}"
    ext_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    case "$ext_lower" in
        #Pictures
        jpg|png|jpeg|gif|webp|bmp)
            mv --backup=numbered "$file" "$pictures_directory/autosort"
            ((pics_count++))
            ;;
        #Documents
        pdf|docx|doc|txt|odt|xlsx|md|csv|docs)
            mv --backup=numbered "$file" "$documents_directory/autosort"
            ((docs_count++))
            ;;
        #Videos
        mp4|avi|mkv|mov|flv)
            mv --backup=numbered "$file" "$videos_directory/autosort"
            ((vids_count++))
            ;;
        #Musics
        mp3|flac|aac|m4a|ogg|oga|wav|wma|ape)
            mv --backup=numbered "$file" "$music_directory/autosort"
            ((musics_count++))
            ;;
        *)
            :
            ;;
    esac
done < <(find "$test_directory" -maxdepth 1 -type f -print0)
echo "Перемещено картинок: $pics_count"
echo "Перемещено документов: $docs_count"
echo "Перемещено видео: $vids_count"
echo "Перемещено музыки: $musics_count"
