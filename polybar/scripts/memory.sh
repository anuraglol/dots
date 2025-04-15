#!/bin/sh

free --mebi | awk 'NR==2 {printf "%.2fGB", $3/1024}'
