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

if [ -d /data/adb/tpclash ] ; then
  cp /data/adb/tpclash/scripts/box.config /data/adb/tpclash/scripts/box.config.bak
  ui_print "- User configuration box.config has been backed up to box.config.bak"

  cat /data/adb/tpclash/scripts/box.config >> $MODPATH/tpclash/scripts/box.config
  cp -f $MODPATH/tpclash/scripts/* /data/adb/tpclash/scripts/
  ui_print "- User configuration box.config has been"
  ui_print "- attached to the module box.config,"
  ui_print "- please re-edit box.config"
  ui_print "- after the update is complete."

  awk '!x[$0]++' $MODPATH/tpclash/scripts/box.config > /data/adb/tpclash/scripts/box.config

  rm -rf $MODPATH/tpclash
else
  mv $MODPATH/tpclash /data/adb/
fi

if [ "$KSU" = true ] ; then
  sed -i 's/name=tpclash4androidmagisk/name=tpclash4androidKernelSU/g' $MODPATH/module.prop
fi

mkdir -p /data/adb/tpclash/bin/
mkdir -p /data/adb/tpclash/run/

mv -f $MODPATH/tpclash4android_service.sh $service_dir/

rm -f customize.sh

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm_recursive /data/adb/tpclash/ 0 0 0755 0644
set_perm_recursive /data/adb/tpclash/scripts/ 0 0 0755 0700
set_perm_recursive /data/adb/tpclash/bin/ 0 0 0755 0700

set_perm $service_dir/tpclash4android_service.sh 0 0 0700

# fix "set_perm_recursive /data/adb/tpclash/scripts" not working on some phones.
chmod ugo+x /data/adb/tpclash/scripts/*

for pid in $(pidof inotifyd) ; do
  if grep -q box.inotify /proc/${pid}/cmdline ; then
    kill ${pid}
  fi
done

inotifyd "/data/adb/tpclash/scripts/box.inotify" "/data/adb/modules/tpclash4android" > /dev/null 2>&1 &
