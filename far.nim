# find-and-replace.nim: Parses a set of HTML files for various values
# @param: Path to a standard, parseable HTML file
# @param: Path to channels.json
# @param: Path to users.json
# @param: Global workspace title
# @return: Parsed HTML file
# This program is also responsible for filling up the descriptions

import os, re, json

assert paramCount() == 4, "Invalid parameters"

proc far(htmlPath, channelsPath, usersPath, title: string): string =
    assert existsFile(htmlPath), "Invalid file"
    var html: string = readFile(htmlPath)

    # Note: this simple regex-replace approach has a _high_ possibility of missing tags
    # But, at least it won't mess up names

    # Bold text
    html = html.replace(re" \*", " <strong>")
    html = html.replace(re"\* ", "</strong> ")

    # Italics
    html = html.replace(re" _", " <i>")
    html = html.replace(re"_ ", "</i> ")

    # Channel replacement comes first as some users are inserted
    assert existsFile(channelsPath)
    let channels = parseJSON(readFile(channelsPath))
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

    # User replacement
    assert existsFile(usersPath)
    let users = parseJSON(readFile(usersPath))
    assert users.kind == JArray
    for user in users:
        let id: string = user["id"].getStr()
        let name: string = user["profile"]["display_name"].getStr() # youtu.be/InZrivHcHDc?t=10
        html = html.replace(re "@" & id, "@" & name)
        html = html.replace(re id, "@" & name)

    # Set the HTML title attribute
    let channel: string = splitFile(htmlPath).name
    html = html.replace(re"<title></title>", "<title>" & channel & " - " & title & "</title>")

    # let list = li(class="example", a(href="channel-type-channels/channel-name", "channel-name"))
    # style.css?

    return html

echo far(paramStr(1), paramStr(2), paramStr(3), paramStr(4))
