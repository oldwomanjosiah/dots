#/bin/bash

rtp=$(echo $PATH:$HOME/.cargo/bin/)

PATH=$rtp eww daemon
PATH=$rtp eww close-all
PATH=$rtp eww open-many bar-left bar-right
