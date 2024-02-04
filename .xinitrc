# programs i want to run every time i open X
xset r rate 300 50 # Set repeated keystroke rate.
setxkbmap -option ctrl:nocaps
xcape -e 'Control_L=Escape'

redshift & # nightshift stuff
sxhkd &  # hotkeys
unclutter &
$HOME/pwl-dotfiles/xrandr-do.sh # set up monitor layout
mkfifo /tmp/dwm.fifo
xinput disable "ELAN Touchscreen"

ret=0 # 
while [ $ret -eq 0 ]; do
    # sxhkd -c ~/.config/sxhkd/sxhkdrc-bspwm &
    # lemonbar &
    # bspwm
    # pkill -x sxhkd
    # pkill -x lemonbar
    # $HOME/pwl-dwm/dwm
    # /usr/local/bin/status_updater_dusk &
    # dusk >>.dusk.log 2>>~/.duskerr.log
    dwmblocks &
    dwm >>.dwm.log  2>> ~/.dwmerr.log 
    # dusk
    # twm
    # /home/paul/rust_x11_status_bar/target/debug/rust_x11_status_bar > ~/window.log
    ret=$?
    pkill -x dwmblocks
done
