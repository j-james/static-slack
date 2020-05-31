# main.nim: Collects the other nim files and turns them into a usable exporter
# @param Unzipped Slack export folder
# @param: Empty or nonexistent output folder
# @param: (optional) Name of output website

import os
import htmlgen

assert paramCount() >= 2, "Missing parameters"
let input = paramStr(1)
let output = paramStr(2)

if paramCount() >= 3:
    let title = paramStr(3)
else:
    let title = "Static Slack"

# let file = readFile(input)
# echo file

if existsFile(output):
    quit("Error: output path is a file!")
if existsDir(output):   # HACK: disgusting and probably won't even work
    for file in walkDir(output):
        quit("Error: output folder exists and is non-empty!")
createDir(output)

# if output exists and is not empty
# 	fail
# else
# createDir(output)
# write files to output
# copy over css
