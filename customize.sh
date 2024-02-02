#!/sbin/sh

SKIPUNZIP=1
ASH_STANDALONE=1

if [ "$BOOTMODE" ! = true ] ; then
  abort "Error: Please install in Magisk Manager or KernelSU Manager"
elif [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10670 ] ; then
  abort "Error: Please update your KernelSU and KernelSU Manager or KernelSU Manager"
fi

if [ "$KSU" = true ] && [ "$KSU_VER_CODE" -lt 10683 ] ; then
  service_dir="/data/adb/ksu/service.d"
else 
  service_dir="/data/adb/service.d"
fi

if [ ! -d "$service_dir" ] ; then
    mkdir -p $service_dir
fi

unzip -qo "${ZIPFILE}" -x 'META-INF/*' -d $MODPATH

if [ -d /data/adb/box_bll ] ; then
  cp /data/adb/box_bll/scripts/box.config /data/adb/box_bll/scripts/box.config.bak
  ui_print "- User configuration box.config has been backed up to box.config.bak"

  cat /data/adb/box_bll/scripts/box.config >> $MODPATH/box_bll/scripts/box.config
  cp -f $MODPATH/box_bll/scripts/* /data/adb/box_bll/scripts/
  ui_print "- User configuration box.config has been"
  ui_print "- attached to the module box.config,"
  ui_print "- please re-edit box.config"
  ui_print "- after the update is complete."

  awk '!x[$0]++' $MODPATH/box_bll/scripts/box.config > /data/adb/box_bll/scripts/box.config

  rm -rf $MODPATH/box_bll
else
  mv $MODPATH/box_bll /data/adb/
fi

if [ "$KSU" = true ] ; then
  sed -i 's/name=box5magisk/name=box5KernelSU/g' $MODPATH/module.prop
fi

mkdir -p /data/adb/box_bll/bin/
mkdir -p /data/adb/box_bll/run/

mv -f $MODPATH/box5_service.sh $service_dir/

rm -f customize.sh

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive /data/adb/box_bll/ 0 0 0755 0644
set_perm_recursive /data/adb/box_bll/scripts/ 0 0 0755 0700
set_perm_recursive /data/adb/box_bll/bin/ 0 0 0755 0700

set_perm $service_dir/box5_service.sh 0 0 0700

# fix "set_perm_recursive /data/adb/box_bll/scripts" not working on some phones.
chmod ugo+x /data/adb/box_bll/scripts/*

for pid in $(pidof inotifyd) ; do
  if grep -q box.inotify /proc/${pid}/cmdline ; then
    kill ${pid}
  fi
done

inotifyd "/data/adb/box_bll/scripts/box.inotify" "/data/adb/modules/box5" > /dev/null 2>&1 &
