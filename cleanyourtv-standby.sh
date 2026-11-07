#!/system/bin/sh

umask 077
receiver=com.gathin.tvhome/.StandbyCleanupReceiver

candidate_apps() {
    {
        pm list packages -3 --user 0 -U
        dumpsys activity oom
    } | awk '
        /^package:/ {
            pkg = substr($1, 9)
            uid = substr($2, 5)
            packages[uid]++
            if (pkg != "com.gathin.tvhome" && pkg != "flar2.homebutton") apps[uid] = pkg
        }
        /^    Proc #[ 0-9]+:/ && match($0, /\/u0a[0-9]+ /) {
            uid = 10000 + substr($0, RSTART + 4, RLENGTH - 5)
            running[uid] = 1
            if ($3 !~ /^cch/) active[uid] = 1
        }
        END {
            for (uid in apps)
                if (packages[uid] == 1 && running[uid] && !active[uid]) print uid ":" apps[uid]
        }'
}

running_uids() {
    dumpsys activity oom | awk '
        /^    Proc #[ 0-9]+:/ && match($0, /\/u0a[0-9]+ /) {
            print 10000 + substr($0, RSTART + 4, RLENGTH - 5)
        }'
}

sleeping() {
    dumpsys power | grep -qE 'mWakefulness=(Asleep|Dozing)$'
}

available_kib() {
    awk '$1 == "MemAvailable:" {print $2}' /proc/meminfo
}

clean_background_apps() {
    sleeping || return
    am broadcast --user 0 --receiver-foreground -n "$receiver" \
        -a com.gathin.tvhome.standby.CHECK | grep -q 'Broadcast completed: result=1$' || return

    candidates=$(candidate_apps)
    before=$(available_kib)
    attempted=
    for candidate in $candidates; do
        sleeping || break
        if am kill --user 0 "${candidate#*:}"; then
            attempted="$attempted ${candidate%%:*}"
        fi
    done

    count=0
    if [ -n "$attempted" ]; then
        running=$(running_uids)
        # Empty output means the activity service could not be read, so the count cannot be verified.
        [ -n "$running" ] || return
        for uid in $attempted; do
            if ! printf '%s\n' "$running" | grep -Fxq "$uid"; then
                count=$((count + 1))
            fi
        done
    fi

    after=$(available_kib)
    recovered_mb=0
    if [ -n "$before" ] && [ -n "$after" ] && [ "$after" -gt "$before" ]; then
        recovered_mb=$(( (after - before) * 1024 / 1000000 ))
    fi
    am broadcast --user 0 --receiver-foreground -n "$receiver" \
        -a com.gathin.tvhome.standby.RESULT --ei closed_apps "$count" --ei recovered_mb "$recovered_mb"
    log -t CleanYourTVStandby "Closed $count apps, RAM available before/after ${before}/${after} KiB"
}

if [ "$1" = --inspect ]; then
    candidate_apps
    exit
fi

exec 9>/data/local/tmp/cleanyourtv-standby.lock
flock -n 3 3>&9 || exit 1
log -t CleanYourTVStandby 'Monitoring standby events'
logcat -b events -v raw -T "$(date +%s).000" -s screen_toggled:I | while IFS= read -r event; do
    case "$event" in
        0) clean_background_apps ;;
    esac
done
