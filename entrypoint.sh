#!/bin/bash

# first ensure it works
/backup.sh

# start crond in foreground
exec crond -f
