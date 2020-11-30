# main.nim: Collects the other nim files and turns them into a usable exporter
# @param: Unzipped Slack export folder
# @param: Empty or nonexistent output folder / name of output website

import os
import gen, far, assets

# Make sure we're not missing parameters
assert paramCount() == 2, "Invalid parameters"
let input: string = paramStr(1)
let output: string = paramStr(2)

# param(1): Check input directory is a Slack export
assert dirExists(input), "Input is not a directory! Zipped exports are not currently supported." # TODO: support for zips
assert fileExists(joinPath(input, "users.json")), "users.json does not exist! Are you sure this is a Slack export?"
assert fileExists(joinPath(input, "channels.json")), "channels.json does not exist! Are you sure this is a Slack export?"

# param(2): Check output folder is empty
if fileExists(output):
    quit("Output path is a file!")
elif dirExists(output): # HACK: surprisingly the only real way to do this
    for file in walkDir(output):
        quit("Output folder exists and is non-empty!")
else:
    createDir(output)

# Create an HTML file for each channel JSON folder
var html: string
var path: string
for channel in walkDir(input):
    path = joinPath(output, tailDir(channel.path)) & ".html"
    if channel.kind == pcDir or channel.kind == pcLinkToDir: # ignore the three loose JSON files
        html = gen(channel.path)
        html = far(html, input)
        html = assets(html, output)
        # html = attachments(html, output)
        writeFile(path, html)

createDir(joinPath(output, "assets/css"))
copyFile("style.css", joinPath(output, "assets/css/style.css"))

echo "Generation complete!"
echo "Your static Slack instance is available in " & output & "."
