# main.nim: Collects the other nim files and turns them into a usable exporter
# @param Unzipped Slack export folder
# @param: Empty or nonexistent output folder
# @param: (optional) Name of output website

import os
import json
import htmlgen

let input = parseJSON(readFile(paramStr(1)))

assert input.kind == JArray
for i in input:
    echo input.kind

# let output = paramStr(2)
# assert paramCount() >= 2, "Missing parameters"

# let file = readFile(input)
# echo file

let username: string = "bob"
let time: string = "12:30"
let reactions: string = "yay"
let content: string = "yadda yadda"

# echo `div`(`div`(img(username)), `div`(strong(username), a(time), br(), p(content), span(reactions)))


echo `div`(class="message",
        `div`(class="image",
            img(src="assets/" & $username & ".jpg", alt="eat flaming death")),
        `div`(class="text",
            strong(class="username", username),
            a(class="time", time),
            br(),
            p(class="content", content),
            span(reactions)))

let
    five = 36743
    four = five + 2336
    six = five + 32436

echo five
echo four
echo six


# let
# let json = parseJson()

# existsOrCreateDir(generated)

# if output exists and is not empty
# 	fail
# else
# createDir(output)
# write files to output
# copy over css
