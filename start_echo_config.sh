#! /bin/bash

nohup bin/echo-config $@ > /echo_config.log 2>&1 &
echo $! > /echo_config.pid
tail -f /echo_config.log