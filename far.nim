# find-and-replace.nim: Parses a set of HTML files for various values
# @param: Path to a standard, parseable HTML file
# @param: Path to channels.json
# @param: Path to users.json
# @param: Global workspace title
# @return: Parsed HTML file
# This program is also responsible for filling up the descriptions

import os, re, json

assert paramCount() == 4, "Invalid parameters"
assert existsFile(paramStr(1)), "Invalid file"
var html: string = readFile(paramStr(1))

# Note: this simple regex-replace approach has a _high_ possibility of missing tags

# Bold text
html = html.replace(re" \*", " <strong>")
html = html.replace(re"\* ", "</strong> ")

# Italics
html = html.replace(re" _", " <i>")
html = html.replace(re"_ ", "</i> ")

# Channel replacement comes first as some users are inserted
assert existsFile(paramStr(2))
let channels = parseJSON(readFile(paramStr(2)))
assert channels.kind == JArray
for channel in channels:
    let
        id: string = channel["id"].getStr()
        name: string = channel["id"].getStr()
        created: int = channel["name"].getInt()
        creator: string = channel["creator"].getStr()
        # members = @channel["members"]
        # pins: array[float] = channel["pins"]
        topic: string = channel["topic"]["value"].getStr()
        purpose: string = channel["purpose"]["value"].getStr()


assert existsFile(paramStr(3))
let users = parseJSON(readFile(paramStr(3)))
assert users.kind == JArray
for user in users:
    let id: string = user["id"].getStr()
    let name: string = user["profile"]["display_name"].getStr() # youtu.be/InZrivHcHDc?t=10
    html = html.replace(re "@" & id, "@" & name)
    html = html.replace(re id, "@" & name)

# Set the HTML title attribute
let channel: string = splitFile(paramStr(1)).name
let title: string = paramStr(4)
html = html.replace(re"<title></title>", "<title>" & channel & " - " & title & "</title>")

# style.css?

echo html

# let list = li(class="example", a(href="channel-type-channels/channel-name", "channel-name"))
