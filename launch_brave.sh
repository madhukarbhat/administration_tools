#!/bin/sh
err_logs='/tmp/brave_errors.log'
brave-browser --no-sandbox --disable-gpu-sandbox --disable-gpu --disable-software-rasterizer 2> ${err_logs}
