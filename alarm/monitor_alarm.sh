#!/bin/sh
data_path=~/tmp/alarm_data
tmp_path=~/tmp/alarm_data.tmp
template_path=/Users/guzuchao/3/code_mine/MyUtilities/alarm
mkdir -p $tmp_path
cd $template_path
nohup python -m SimpleHTTPServer 8000 &
while true
do
    for f in `ls -1 $data_path/`
    do
        mv $data_path/$f $tmp_path/$f
        ret=$?
        if [ $ret -eq 0 ]
        then
            open "http://localhost:8000?`cat $tmp_path/$f`"
        fi
    done
    sleep 0.1
done
