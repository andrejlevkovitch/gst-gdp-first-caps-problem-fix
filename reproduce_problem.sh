#!/bin/bash
# reproduce situation when producer not synchronized with consumer

prop_name="ignore-first-caps-problem"


producer_pid=
consumer_pid=
at_exit() {
  set +e

  kill -2 $producer_pid &> /dev/null
  kill -2 $consumer_pid &> /dev/null

  if [ -n "$producer_pid" ]; then
    wait $producer_pid
  fi
  if [ -n "$consumer_pid" ]; then
    wait $consumer_pid
  fi
}

trap at_exit EXIT


export GST_PLUGIN_PATH=$(pwd)/gst-plugins-bad/gst/gdp

gdp_fix_flag=
gst-inspect-1.0 -a | grep gdp | grep $prop_name > /dev/null
if [ $? -eq 0 ]; then
  gdp_fix_flag="$prop_name=TRUE"
  echo "problem fixed"
fi


set -e

export GST_DEBUG=2

sock=/tmp/shm-sock
if [ -f $sock ]; then
  rm $sock
fi


echo "start producer"
gst-launch-1.0 videotestsrc ! video/x-raw, format=BGRx, width=640, height=480, framerate=30/1 ! gdppay ! shmsink socket-path=$sock wait-for-connection=false &
producer_pid=$!

sleep 10

echo "start consumer"
# XXX set sync=FALSE for ximagesink, otherwise it start await time from first
# received timestamp
gst-launch-1.0 shmsrc socket-path=$sock ! gdpdepay $gdp_fix_flag ! video/x-raw, format=BGRx, width=640, height=480, framerate=30/1 ! timeoverlay ! ximagesink sync=false
consumer_pid=$!
