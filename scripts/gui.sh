#!/usr/bin/env bash


function KillRedundantProcess(){
    for i in "dbus" "com.termux.x11" "Xwayland" "pulseaudio" "virgl_test_server_android";
    do pkill -eif "${i}*";
    done
}


function supress_output(){
    "${@}" >/dev/null 2>&1
}


function _exit(){
    termux-wake-unlock
    KillRedundantProcess
}


function _start(){
    export DISPLAY=:0 XDG_RUNTIME_DIR=${TMPDIR}
    KillRedundantProcess
    termux-wake-lock && echo "WakeLock Acquired"
    echo "X11 is Listening for incoming connections"
    supress_output termux-x11 :0 -ac -xstartup "am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity ; i3"
}


trap _exit SIGINT

_start
_exit
