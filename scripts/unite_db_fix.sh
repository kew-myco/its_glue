#!/usr/bin/env bash

### Make sure SH code is at the end of every header so sintax etc don't give misleading output

cat $1 | \
    awk 'BEGIN {FS = "[|;]"}
         {if (/^>/) {
              if (! index($3, $2)) {$3 = $3"_"$2}
              print $1"|"$2";"$3";"
              }
          else {print $0}
        }' \
> $2
