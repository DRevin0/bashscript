#!/bin/bash
current_directory=$(pwd)
USER_NAME="${SUDO_USER:-$USER}"
home_directory=$(eval echo "~${SUDO_USER:-$USER}")

download_directory=$(sudo -u "$USER_NAME" xdg-user-dir DOWNLOAD)
documents_directory=$(sudo -u "$USER_NAME" xdg-user-dir DOCUMENTS)
music_directory=$(sudo -u "$USER_NAME" xdg-user-dir MUSIC)
videos_directory=$(sudo -u "$USER_NAME" xdg-user-dir VIDEOS)
pictures_directory=$(sudo -u "$USER_NAME" xdg-user-dir PICTURES)

get_free_space(){
    df -k "$home_directory" | awk 'NR==2 {print $4}'
}
format_size(){
    local kb=$1
    kb=${kb:-0}
    if(( kb >= 1048576 )); then
        awk "BEGIN {printf \"%.2f GB\", $kb/1048576}"
    elif(( kb >= 1024 )); then
        awk "BEGIN {printf \"%.2f MB\", $kb/1024}"
    else
        echo "${kb} KB"
    fi
}
free_kb=$(get_free_space)
echo "$(format_size $free_kb)"

clean_downloads(){
    mkdir -p "$documents_directory/autosort" "$music_directory/autosort" "$videos_directory/autosort" "$pictures_directory/autosort" "$download_directory/archives" "$home_directory/installers" "$download_directory/torrent" "$home_directory/Projects/autosort"
    #tmp
    test_directory="$home_directory/Test"

    pics_count=0
    vids_count=0
    docs_count=0
    musics_count=0
    archives_count=0
    installers_count=0
    torrent_count=0
    code_count=0

    while IFS= read -r -d '' file; do
        extension="${file##*.}"
        ext_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
        case "$ext_lower" in
            #Pictures
            jpg|png|jpeg|gif|webp|bmp|svg|tiff|ico|heic|raw)
                mv --backup=numbered "$file" "$pictures_directory/autosort"
                ((pics_count++))
                ;;
            #Documents
            pdf|docx|doc|txt|odt|xlsx|md|csv|docs|pptx|ppt|xls|rtf|epub|djvu|log)
                mv --backup=numbered "$file" "$documents_directory/autosort"
                ((docs_count++))
                ;;
            #Videos
            mp4|avi|mkv|mov|flv|webm|wmv|m4v)
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
            #Installers
            iso|img|AppImage|deb|rpm|pkg.tar.zst|exe|msi)
                mv --backup=numbered "$file" "$home_directory/installers"
                ((installers_count++))
                ;;
            #Torrent
            torrent)
                mv --backup=number "$file" "$download_directory/torrent"
                ((torrent_count++))
                ;;
            #Code
            c|cpp|py|html|h|css)
                mv --backup=numbered "$file" "$home_directory/Projects/autosort"
                ((code_count++))
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
    echo "Перемещено установщиков: $installers_count"
    echo "Перемещено торрент файлов: $torrent_count"
    echo "Перемещено файлов кода: $code_count"
}

clean_packages(){
    if command -v paru &> /dev/null; then
        echo "paru"
        sudo -u "$USER_NAME" paru -Sc --noconfirm > /dev/null 2>&1
    fi
    sudo paccache -r > /dev/null 
    orphans=$(pacman -Qdtq)
    if [[ -n "$orphans" ]]; then
        echo "paccahe"
        sudo pacman -Rns $orphans --noconfirm > /dev/null 2>&1
    fi
}

clean_logs(){
    sudo journalctl --vacuum-time=2d > /dev/null 2>&1
}

clean_trash(){
    rm -rf "$home_directory/.local/share/Trash/*"
}
free_kb=$(get_free_space)
echo "$(format_size $free_kb)"

#clean_downloads
#clean_packages
#clean_logs
#clean_trash