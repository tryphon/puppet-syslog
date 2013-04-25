#!/bin/sh

if [ $# -gt 0 ]; then
    command=$1
    shift
else
    command="tail"
fi

case $command in
    tail)
        if [ $# -gt 0 ]; then
            exec tail -F /var/log/syslog | grep --line-buffered $@    
        else
            exec tail -F /var/log/syslog
        fi
        ;;
    last)
        size=30
        if [ $# -gt 0 ]; then
            exec grep $@ /var/log/syslog | tail -${size}
        else
            exec tail -${size} /var/log/syslog
        fi
        ;;
    grep)
        exec egrep $@ /var/log/syslog
        ;;
esac
