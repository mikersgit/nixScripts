#!/bin/bash
#ResText="Moving Resolved 'fixed', not QA found, and current to 6 months old to Closed."
# 047   27    '’
# 052   2A    *
# 054   2C    ,
# 055   2D    -
# 056   2E    .
# 057   2F    /
# 133   5B    [
# 135   5D    ]

ResText="${@}"
echo ${ResText} | gawk '{gsub("[[:space:]]","%20")
                gsub(",","%2C")
                gsub("\047","%27")
                gsub("\057","%2F")
                gsub("\055","%2D")
                gsub("\052","%2A")
                gsub("\\[","%5B")
                gsub("\\]","%5D")
                gsub("\\.","%2E")
                print}'
