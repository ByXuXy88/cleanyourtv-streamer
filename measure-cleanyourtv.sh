set -eu

launcher=com.gathin.tvhome
home_activity="$launcher/.MainActivity"

open_home() {
    am start -W --user 0 -a android.intent.action.MAIN -c android.intent.category.HOME -n "$home_activity"
}

open_settings() {
    am start -W --user 0 --activity-reorder-to-front -a android.settings.SETTINGS >/dev/null
    sleep 0.4
}

focus_is_home() {
    dumpsys window | grep -E 'mCurrentFocus=.*com\.gathin\.tvhome/.*MainActivity' >/dev/null
}

[ "$(getprop ro.product.device)" = kirkwood ]
[ "$(cmd role get-role-holders --user 0 android.app.role.HOME)" = "$launcher" ]
focus_is_home

trap 'open_home >/dev/null' EXIT
for run in 1 2 3; do
    open_settings
    am force-stop --user 0 "$launcher"
    sleep 0.6
    echo "===COLD $run==="
    open_home | grep -E '^(Status:|LaunchState:|TotalTime:|WaitTime:)'
    focus_is_home
    sleep 0.45
done

for run in 1 2 3 4 5; do
    open_settings
    echo "===RETURN $run==="
    open_home | grep -E '^(Status:|LaunchState:|TotalTime:|WaitTime:)'
    focus_is_home
    sleep 0.3
done

sleep 0.6
dumpsys gfxinfo "$launcher" reset >/dev/null
for run in 1 2 3 4; do
    for key in 22 22 22 21 21 21 20 22 22 21 21 19; do
        input keyevent "$key"
        sleep 0.18
    done
done
sleep 0.75
focus_is_home
echo '===NAVIGATION==='
dumpsys gfxinfo "$launcher" | grep -E '^(Total frames rendered:|Janky frames:|50th percentile:|95th percentile:|99th percentile:)'
echo '===LAUNCHER_MEMORY==='
dumpsys meminfo "$launcher" | grep 'TOTAL PSS:'
trap - EXIT
