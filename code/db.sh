#!/bin/sh

mysql db --max_allowed_packet=100M -h${HOST:-db} -u${USER:-user} -p${PASSWORD:-password}
