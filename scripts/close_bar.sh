#!/bin/bash
jobs=$(ps aux | grep poly | awk '{print $2}')
for job in $jobs
do
    kill -9 $job
done
