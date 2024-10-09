#!/usr/bin/env bash

export DISPLAY=:0 XDG_RUNTIME_DIR=${TMPDIR}


function KillRedundantProcess(){
    for i in "dbus" "com.termux.x11" "Xwayland" "pulseaudio" "virgl_test_server_android";
    do pkill -qif "${i}*";
    done
}


KillRedundantProcess


function supress_output(){
    "$@" >/dev/null 2>&1
}


termux-wake-lock && echo "WakeLock Acquired"


echo "X11 is Listening for incoming connections"


supress_output \
    termux-x11 :0 -ac &


sleep 3


echo "Starting XFCE4"


supress_output \
    am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity

supress_output \
    pulseaudio \
        --start \
        --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
        --exit-idle-time=-1


supress_output \
    pacmd \
        load-module \
        module-native-protocol-tcp \
        auth-ip-acl=127.0.0.1 \
        auth-anonymous=1

supress_output \
    virgl_test_server_android &

supress_output \
    proot-distro login debian \
        --termux-home \
        --shared-tmp \
        -- bash -c "
            export DISPLAY=:0 PULSE_SERVER=tcp:127.0.0.1
            dbus-launch --exit-with-session wm_start_cmd"


termux-wake-unlock


KillRedundantProcess
