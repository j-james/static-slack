# find-and-replace.nim: Parses a set of HTML files for various values
# @param: A standard, parseable HTML file
# @param: Path to unzipped Slack export folder
# @param: Global workspace title
# @return: Parsed HTML file
# This program is also responsible for filling up the descriptions.

import os, re, json

assert paramCount() == 3, "Invalid parameters"

proc far*(html, input, title: string): string =
    var html: string = html # XXX: probably bad

    # Note: this simple regex-replace approach has a _high_ possibility of missing tags
    # But, at least it won't mess up names

    # Bold text
    html = html.replace(re" \*", " <strong>")
    html = html.replace(re"\* ", "</strong> ")

    # Italics
    html = html.replace(re" _", " <i>")
    html = html.replace(re"_ ", "</i> ")

    # Channel replacement comes first as some users are inserted
    assert existsFile(joinPath(input, "channels.json"))
    let channels = parseJSON(readFile(joinPath(input, "channels.json")))
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
    assert existsFile(joinPath(input, "users.json"))
    let users = parseJSON(readFile(joinPath(input, "users.json")))
    assert users.kind == JArray
    for user in users:
        let id: string = user["id"].getStr()
        let name: string = user["profile"]["display_name"].getStr() # youtu.be/InZrivHcHDc?t=10
        html = html.replace(re "@" & id, "@" & name)
        html = html.replace(re id, "@" & name)

    # Set the HTML title attribute
    html = html.replace(re"</title>", " - " & title & "</title>")

    # let list = li(class="example", a(href="channel-type-channels/channel-name", "channel-name"))
    # style.css?

    return html

echo far(paramStr(1), paramStr(2), paramStr(3))
