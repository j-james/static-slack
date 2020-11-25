# find-and-replace.nim: Parses a set of HTML files for various values
# @param: A standard, parseable HTML file
# @param: Path to unzipped Slack export folder
# @param: Global workspace title
# @return: Parsed HTML file
# This program is also responsible for filling up the descriptions.

import os, re, json

proc far*(html, input: string): string =
    var html: string = html # XXX: probably bad

    # Note: this simple regex-replace approach has a _high_ possibility of missing tags
    # But, at least it won't mess up names

    # Bold text
    html = html.replace(re" \*", " <strong>")
    html = html.replace(re"\* ", "</strong> ")

    # Italics
    html = html.replace(re" _", " <i>")
    html = html.replace(re"_ ", "</i> ")

    #[
    # Channel replacement comes first as some users are inserted
    assert fileExists(joinPath(input, "channels.json"))
    let channels = parseJSON(readFile(joinPath(input, "channels.json")))
    assert channels.kind == JArray
    for channel in channels:
        let
            id: string = getStr(channel["id"])
            name: string = getStr(channel["id"])
            created: int = getInt(channel["name"])
            creator: string = getStr(channel["creator"])
            # members = @channel["members"]
            # pins: array[float] = channel["pins"]
            topic: string = getStr(channel["topic"]["value"])
            purpose: string = getStr(channel["purpose"]["value"])
    ]#

    # User replacement
    assert fileExists(joinPath(input, "users.json"))
    let users = parseJSON(readFile(joinPath(input, "users.json")))
    assert users.kind == JArray
    for user in users:
        let id: string = getStr(user["id"])
        let name: string = getStr(user["profile"]["display_name"]) # youtu.be/InZrivHcHDc?t=10
        let profile: string = getStr(user["profile"]["image_48"])
        html = html.replace(re "img src=\"" & id, "img src=\"" & profile)
        html = html.replace(re "@" & id, "@" & name)
        html = html.replace(re id, name)

    return html
