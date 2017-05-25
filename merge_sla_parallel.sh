#!/bin/sh

path=`dirname $0`
sh $path/merge_general.sh $path/merge_parallel.awk $1 $2
