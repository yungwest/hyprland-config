#!/bin/bash
# Gelişmiş Screenshot Aracı - Swappy Entegrasyonlu
# Kullanım: screenshot.sh [full|window|area] [edit]

# Yapılandırma
SCREENSHOT_DIR="$HOME/Resimler/SS"
CACHE_DIR="$HOME/.cache/screenshot-preview"
NOTIFY_TIMEOUT=5000

# Debug modunu aktifleştir
DEBUG=false

# Log fonksiyonu
log_debug() {
    if [ "$DEBUG" = true ]; then
        echo "[DEBUG] $1" >> "$HOME/.cache/screenshot-debug.log"
    fi
}

# Dizinleri oluştur
mkdir -p "$SCREENSHOT_DIR"
mkdir -p "$CACHE_DIR"

# Mod ve Edit kontrolü
MODE="area"
EDIT_MODE=false

for arg in "$@"; do
    case $arg in
        "full") MODE="full" ;;
        "window") MODE="window" ;;
        "area") MODE="area" ;;
        "edit"|"-e") EDIT_MODE=true ;;
    esac
done

log_debug "Mod: $MODE, Edit Modu: $EDIT_MODE"

# Dosya adını oluştur
FILENAME="$(date +'%Y%m%d_%H%M%S').png"
FILEPATH="$SCREENSHOT_DIR/$FILENAME"
PREVIEW_PATH="$CACHE_DIR/${FILENAME}"

# Screenshot alma fonksiyonu
take_screenshot() {
    case "$MODE" in
        "area")
            notify-send "Screenshot" "Alan seçin..." -t 1000
            # slurp ile alan seçimi
            GEOMETRY=$(slurp)
            if [ -z "$GEOMETRY" ]; then return 1; fi
            grim -g "$GEOMETRY" "$FILEPATH"
            ;;
        "window")
            # Hyprland aktif pencere
            ACTIVE_WINDOW=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
            grim -g "$ACTIVE_WINDOW" "$FILEPATH"
            ;;
        "full")
            grim "$FILEPATH"
            ;;
    esac
}

# İşlemi başlat
if take_screenshot; then
    
    # Eğer Edit modu aktifse Swappy'i aç
    if [ "$EDIT_MODE" = true ] && command -v swappy &> /dev/null; then
        notify-send "Düzenleniyor" "Görüntü Swappy ile açılıyor..." -t 2000
        # Swappy dosyayı düzenler ve çıktıyı yönetir
        swappy -f "$FILEPATH" -o "$FILEPATH"
        # Not: Swappy içinde CTRL+C yaparsanız panoya kopyalar, Save yaparsanız dosyaya yazar.
    fi

    # Dosya var mı tekrar kontrol et (Swappy iptal edebilir)
    if [ -f "$FILEPATH" ]; then
        # Panoya kopyala (Edit modunda değilse veya Swappy sonrası)
        wl-copy < "$FILEPATH"
        
        # Önizleme oluştur (bildirim için)
        if command -v convert &> /dev/null; then
            convert "$FILEPATH" -resize "250x200" "$PREVIEW_PATH" 2>/dev/null
            ICON_PATH="$PREVIEW_PATH"
        else
            ICON_PATH="$FILEPATH"
        fi

        notify-send "Screenshot Alındı" "Kaydedildi: $FILENAME" \
            -i "$ICON_PATH" \
            -t $NOTIFY_TIMEOUT
    fi
else
    notify-send "İptal" "Screenshot alınamadı." -i dialog-error
fi
