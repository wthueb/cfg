#!/usr/bin/env bash

open() {
    sketchybar --animate tanh 30 --set volume slider.width=100
}

close() {
    sketchybar --animate tanh 30 --set volume slider.width=0
}

open
