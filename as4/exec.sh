#!/bin/sh
/c/cs421/bin/sml <<EOF 2> /dev/null | egrep -v '\- |val it = |val use = |Standard|\[(linking|library|loading|scanning)'  
    CM.make "sources.cm";
    PP.TS "$1";
EOF
