#!/bin/bash

# timestamp 2 date

t2d(){ echo ${1:-} |awk '{print strftime("%c",$1)}'; }

millitime(){ date +%s%N | cut -b1-13; }

microtime(){ date +%s%N | cut -b1-16; }

nanotime(){ date +%s%N; }
