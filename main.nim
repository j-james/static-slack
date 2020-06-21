# main.nim: Collects the other nim files and turns them into a usable exporter
# @param Unzipped Slack export folder
# @param: Empty or nonexistent output folder
# @param: (optional) Name of output website

import os, htmlgen
import gen, far, assets

# Make sure we're not missing parameters (param(3) is optional)
assert paramCount() >= 2, "Missing parameters"
let input: string = paramStr(1)
let output: string = paramStr(2)

# param(1): Check input directory is a Slack export
assert existsDir(input), "Input is not a directory!"
assert existsFile(joinPath(input, "users.json")), "Users.json does not exist! Are you sure this is a Slack export?"
assert existsFile(joinPath(input, "channels.json")), "Channels.json does not exist! Are you sure this is a Slack export?"

# param(2): Check output folder is non-empty
if existsFile(output):
    quit("Output path is a file!")
if existsDir(output):   # HACK: surprisingly the only real way to do this
    for file in walkDir(output):
        quit("Output folder exists and is non-empty!")
createDir(output)

# param(3): Set title
if paramCount() >= 3:
    let title: string = paramStr(3)
else:
    let title: string = "Static Slack"

var html: string
for channel in walkDir(input):
    html = gen(channel)
    html = far(html, joinPath(input, "channels.json"), joinPath(input, "users.json"), title)
    writeFile(joinPath(output, channel, ".html"), html) # !!!: Check this doesn't produce exported/exported/channel.html

var html: string
for file in walkDir(output):
    html = readFile(file)
    html = assets(html, joinPath(output, "assets")) # !!!: Check for similar wonkiness
    # html = attachments(html, joinPath(output, "assets/attachments"))

copyFile("style.css", "assets/css/style.css")

echo "Generation complete!"
echo "Your static Slack instance is available in " & output

# let file = readFile(input)
# echo file
