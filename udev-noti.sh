#!/bin/bash

dev_files="/var/tmp/udev-noti/"
mkdir -p $dev_files

# ---- Get the dbus path to send the notifications
test_pid=$(pidof awesome)
udev_environ=$(grep -z "^DBUS_SESSION_BUS_ADDRESS=" /proc/$test_pid/environ)
export $udev_environ


# ---- Parse arguments
while getopts a:p:b:d: opt; do
  case $opt in
  a)
      action=$OPTARG
      ;;
  p)
      dev_path=$OPTARG
      ;;
  b)
      bus_num=$OPTARG
      ;;
  d)
      dev_num=$OPTARG
      ;;
  esac
done

case $action in
	"add" )
		# ---- PLUG

		# ---- Get interface details
		# make bus_num and dev_num have leading zeros
		if [[ "$bus_num" != "" && "$dev_num" != "" ]]; then
			bus_num=`printf %03d $bus_num`
			dev_num=`printf %03d $dev_num`


			# dev_title=`lsusb -D /dev/bus/usb/$bus_num/$dev_num | grep '^Device:\|bInterfaceClass\|bInterfaceSubClass\|bInterfaceProtocol'|sed 's/^\s*\([a-zA-Z]\+\):*\s*[0-9]*\s*/<b>\1:<\/b> /' | awk 1 ORS='###'`
			dev_name=`lsusb -D /dev/bus/usb/$bus_num/$dev_num | grep idProduct | tr -s ' ' | cut -s -d' ' -f4,5,6,7,8,9`

			if [ ! -z "$dev_name" -a "$dev_name" != " " ]; then
				su ayats -c "notify-send \"Device plugged\" \"$dev_name\" "
				filename=`echo -n $dev_path | md5sum | cut -d' ' -f1`
				echo "$dev_name" | tee "$dev_files$filename"
			fi

		fi
		;;

	"remove" )
        	# ---- UNPLUG
		filename=`echo -n $dev_path | md5sum | cut -d' ' -f1`
		# su ayats -c "notify-send $filename"
		if [[ -f "$dev_files$filename" ]]; then
			dev_name=`cat $dev_files$filename`	
			su ayats -c "notify-send \"Device unplugged\" \"$dev_name\" "
			rm "$dev_files$filename"
		fi
		;;
esac
