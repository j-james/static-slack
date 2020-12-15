# find-and-replace.nim: Parses a set of HTML files for various values
# @param: A standard, parseable HTML file
# @param: Path to unzipped Slack export folder
# @param: Global workspace title
# @return: Parsed HTML file
# This program is also responsible for filling up the descriptions.

import os, re, json, algorithm, strutils

proc far*(html, input, title: string): string =
    var html: string = html

    # Channel replacement
    assert fileExists(joinPath(input, "channels.json"))
    let channels = parseJSON(readFile(joinPath(input, "channels.json")))
    assert channels.kind == JArray, "channels.json is not an array!"
    var list: seq[string]
    for channel in channels:
        let name: string = replace(getStr(channel["name"]), '_', '-')
        if name == title:
            html = replace(html, re("id=\"purpose\">"), "id=\"purpose\">" & getStr(channel["purpose"]["value"]))
        list.add(name)
    var nav: string = "<nav><ul>"
    for name in sorted(list):
        if name == title:
            nav &= "<li id=\"current\"><a href=\"" & name & ".html\">" & name & "</a></li>"
        else:
            nav &= "<li><a href=\"" & name & ".html\">" & name & "</a></li>"
    nav &= "</ul></nav>"
    html = replace(html, re("<nav></nav>"), nav)

    # TODO: Mark pinned messages

    # User replacement
    assert fileExists(joinPath(input, "users.json"))
    let users = parseJSON(readFile(joinPath(input, "users.json")))
    assert users.kind == JArray, "users.json is not an array!"
    for user in users:
        let id: string = getStr(user["id"])
        let name: string = getStr(user["profile"]["real_name"]) # youtu.be/InZrivHcHDc?t=10
        let profile: string = getStr(user["profile"]["image_48"])
        html = replace(html, re("img src=\"" & id), "img src=\"" & profile)
        html = replace(html, re("<@" & id & ">"), "<span class=\"user\">@" & name & "</span>")
        html = replace(html, re(id), name)

    return html
