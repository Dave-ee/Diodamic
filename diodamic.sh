#!/bin/bash

# Can only be used in switch2 or switch3
# Choose a payload by changing the switch position relative
# to the starting position. 
# E.g. Switch2 = PAYLOAD, Switch1 = LEFT, Switch3 = RIGHT
## LEFT = Decrement
## RIGHT = Increment
## BUTTON = Enter (choose the current payload, only works when you're on the payload position)

fs_PAYLOAD=$(dirname $(readlink -f "$0"))

INDEX=1
LED_1=M
LED_2=R
LED_3=Y
LED_4=G
LED_5=B
LED_6=C
LED_7=W

pos_INITIAL=$(SWITCH)
pos_CURRENT=$pos_CURRENT
pos_OLD=$pos_OLD
pos_INCREMENT=0
pos_DECREMENT=0
led_CURRENT=0

function setLED() {
	case "$1" in
		"1") LED $LED_1; led_CURRENT=$LED_1 ;;
		"2") LED $LED_2; led_CURRENT=$LED_2 ;;
		"3") LED $LED_3; led_CURRENT=$LED_3 ;;
		"4") LED $LED_4; led_CURRENT=$LED_4 ;;
		"5") LED $LED_5; led_CURRENT=$LED_5 ;;
		"6") LED $LED_6; led_CURRENT=$LED_6 ;;
		"7") LED $LED_7; led_CURRENT=$LED_7 ;;
		*) echo "Failure." >> $fs_PAYLOAD/log.txt;;
	esac
	echo "Changed to $1: $led_CURRENT" >> $fs_PAYLOAD/log.txt
}

function launch() {
	echo "Launching payload $1" >> $fs_PAYLOAD/log.txt
	LED $led_CURRENT 500
	case "$1" in
		"1") source "$fs_PAYLOAD/1\.sh" ;;
		"2") source "$fs_PAYLOAD/2\.sh" ;;
		"3") source "$fs_PAYLOAD/3\.sh" ;;
		"4") source "$fs_PAYLOAD/4\.sh" ;;
		"5") source "$fs_PAYLOAD/5\.sh" ;;
		"6") source "$fs_PAYLOAD/6\.sh" ;;
		"7") source "$fs_PAYLOAD/7\.sh" ;;
		*) echo "Failure." >> $fs_PAYLOAD/log.txt;;
	esac
}

function watch() {
	touch /tmp/button_wait
	while [ -f /tmp/button_wait ]; do
		CURRENT=$(SWITCH)
		echo "$CURRENT" >> $fs_PAYLOAD/log.txt
		if [ ! "$pos_CURRENT" = "$CURRENT" ]; then
			echo "Position: $CURRENT" >> $fs_PAYLOAD/log.txt
			pos_OLD=$pos_CURRENT
			pos_CURRENT=$CURRENT
			if [ ! "$pos_CURRENT" = "$pos_OLD" ]; then
				if [ "$pos_CURRENT" = "$pos_INCREMENT" ]; then
					if [ ! "$INDEX" = "6" ]; then
						INDEX=$((INDEX+1))
					fi
				elif [ "$pos_CURRENT" = "$pos_DECREMENT" ]; then
					if [ ! "$INDEX" = "1" ]; then
						INDEX=$((INDEX-1))
					fi
				fi
			fi
			echo "Index: $INDEX" >> $fs_PAYLOAD/log.txt
			setLED $INDEX
		fi
	done
	launch $INDEX
}

if [ "$pos_INITIAL" = "switch2" ]; then
	pos_INCREMENT="switch3"
	pos_DECREMENT="switch1"
elif [ "$pos_INITIAL" = "switch3" ]; then
	pos_INCREMENT="switch4"
	pos_DECREMENT="switch2"
else
	LED R 200
	sleep 3
	poweroff
fi
echo "$pos_CURRENT" >> $fs_PAYLOAD/log.txt
echo "$pos_DECREMENT" >> $fs_PAYLOAD/log.txt
echo "$pos_INCREMENT" >> $fs_PAYLOAD/log.txt
watch
