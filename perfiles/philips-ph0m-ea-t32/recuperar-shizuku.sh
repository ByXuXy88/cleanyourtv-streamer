#!/system/bin/sh

umask 077
tag=CleanYourTVShizuku

if [ "$1" = --home-if-live ] && dumpsys activity activities |
        grep -Eq 'mResumedActivity:.* com\.mediatek\.wwtv\.tvcenter/'; then
    if am start --user 0 -a android.intent.action.MAIN -c android.intent.category.HOME >/dev/null 2>&1; then
        log -t "$tag" 'Home requested after power-on'
    fi
fi

running() {
    ps -A -o USER,NAME | awk '
        $1 == "shell" && $2 == "shizuku_server" { found = 1 }
        END { exit !found }'
}

if running; then
    echo ready
    exit 0
fi

exec 9>/data/local/tmp/cyt-shizuku-recovery.lock
flock -n 3 3>&9 || exit 1
if running; then
    echo ready
    exit 0
fi

apk=$(pm path --user 0 moe.shizuku.privileged.api)
case "$apk" in
    package:/data/app/*/moe.shizuku.privileged.api-*/base.apk) ;;
    *) exit 1 ;;
esac
dir=${apk#package:}
starter=${dir%/base.apk}/lib/arm/libshizuku.so
if [ -x "$starter" ] && timeout 8 "$starter" 9>&- >/dev/null 2>&1; then
    for attempt in 1 2 3; do
        if running; then
            log -t "$tag" 'Shizuku recovered'
            echo ready
            exit 0
        fi
        sleep 1
    done
fi
log -t "$tag" 'Shizuku start unavailable'
exit 1
