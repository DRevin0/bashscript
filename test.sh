#!/bin/bash
current_directory=$(pwd)
USER_NAME="${SUDO_USER:-$USER}"
home_directory=$(eval echo "~${SUDO_USER:-$USER}")

download_directory=$(sudo -u "$USER_NAME" xdg-user-dir DOWNLOAD)
documents_directory=$(sudo -u "$USER_NAME" xdg-user-dir DOCUMENTS)
music_directory=$(sudo -u "$USER_NAME" xdg-user-dir MUSIC)
videos_directory=$(sudo -u "$USER_NAME" xdg-user-dir VIDEOS)
pictures_directory=$(sudo -u "$USER_NAME" xdg-user-dir PICTURES)

clean_downloads(){
    mkdir -p "$documents_directory/autosort" "$music_directory/autosort" "$videos_directory/autosort" "$pictures_directory/autosort" "$download_directory/archives"
    #tmp
    test_directory="$home_directory/Test"

    pics_count=0
    vids_count=0
    docs_count=0
    musics_count=0
    archives_count=0

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
            #Archives
            zip|rar|7z|tar|gz|bz2|xz)
                mv --backup=numbered "$file" "$download_directory/archives"
                ((archives_count++))
                ;;
            *)
                :
                ;;
        esac
    done < <(find "$download_directory" -maxdepth 1 -type f -print0)
    echo "Перемещено картинок: $pics_count"
    echo "Перемещено документов: $docs_count"
    echo "Перемещено видео: $vids_count"
    echo "Перемещено музыки: $musics_count"
    echo "Перемещено архивов: $archives_count"
}

clean_packages(){
    if [[ -d "$home_directory/.cache/yay/" ]]; then
        paccache -r -c "$home_directory/.cache/yay/" > /dev/null
    else
        echo "Кеш yay не найден, пропуск."
    fi
    if [[ -d "$home_directory/.cache/paru/clone/" ]]; then
        paccache -r -c "$home_directory/.cache/paru/clone/" > /dev/null
    else
        echo "Кеш paru не найден, пропуск."
    fi 
    sudo paccache -r > /dev/null
}

clean_logs(){
    sudo journalctl --vacuum-time=2d > /dev/null 2>&1
}

clean_trash(){
    rm -rf "$home_directory/.local/share/Trash"
}

clean_downloads
echo ""
clean_packages
echo ""
clean_logs
echo ""
clean_trash