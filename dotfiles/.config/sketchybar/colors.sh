#!/usr/bin/env bash

export TRANSPARENT=0x00000000

nord() {
    NORD0=0xff2e3440
    NORD1=0xff3b4252
    NORD2=0xff434c5e
    NORD3=0xff4c566a
    NORD4=0xffd8dee9
    NORD5=0xffe5e9f0
    NORD6=0xffeceff4
    NORD7=0xff8fbcbb
    NORD8=0xff88c0d0
    NORD9=0xff81a1c1
    NORD10=0xff5e81ac
    NORD11=0xffbf616a
    NORD12=0xffd08770
    NORD13=0xffebcb8b
    NORD14=0xffa3be8c
    NORD15=0xffb48ead

    export COLOR_BG=$NORD0
    export COLOR_MODAL_BG=$NORD1
    export COLOR_MODAL_BORDER=$NORD3
    export COLOR_TEXT=$NORD6
    export COLOR_ICON=$NORD5
    export COLOR_PRIMARY=$NORD8
    export COLOR_WARN=$NORD12
    export COLOR_DANGER=$NORD11
}

catppuccin-mocha() {
    CTP_BASE=0xff1e1e2e
    CTP_TEXT=0xffcdd6f4
    CTP_OVERLAY0=0xff6c7086
    CTP_SURFACE0=0xff313244
    CTP_BLUE=0xff89b4fa
    CTP_YELLOW=0xfff9e2af
    CTP_RED=0xfff38ba8

    export COLOR_BG=$CTP_BASE
    export COLOR_MODAL_BG=$CTP_SURFACE0
    export COLOR_MODAL_BORDER=$CTP_OVERLAY0
    export COLOR_TEXT=$CTP_TEXT
    export COLOR_ICON=$CTP_TEXT
    export COLOR_PRIMARY=$CTP_BLUE
    export COLOR_WARN=$CTP_YELLOW
    export COLOR_DANGER=$CTP_RED
}

catppuccin-mocha
