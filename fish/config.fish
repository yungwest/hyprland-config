# Başlangıç mesajını kapat
set -g fish_greeting

# Her açılışta fastfetch çalıştır
if status is-interactive
    fastfetch
end

function fish_prompt
    set_color 808080
    echo -n '╭─'
    set_color 87afff
    echo -n ' yungwest '
    set_color normal
    echo
    set_color 808080
    echo -n '╰─'
    set_color 5fd7ff
    echo -n '❯ '
    set_color normal
end

