#!/bin/bash


sites="https://www.notion.so/196f41b6979880fea5cdf7a7b6897113?v=196f41b69798818dbb23000c2007f122 https://calendar.google.com/calendar/u/4/r?pli=1 https://coda.io/d/Projects_dt5ItA6ol2F"

i3-msg "workspace self"
i3-msg "exec --no-startup-id google-chrome --new-window $(echo -e $sites)"
