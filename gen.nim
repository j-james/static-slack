# gen.nim: Generate an HTML file from a particular directory of JSON files
# @param: Path to JSON folder
# @return: Generated HTML file
# Do note that replacing user / channel mentions is handled exclusively in far.nim

import os, json, times, htmlgen

assert paramCount() == 1, "Invalid arguments"
let directory: string = paramStr(1)
assert existsDir(directory), "Invalid directory"

var messages: string
for file in walkDir(directory):    # nim's for loops are cool
    assert existsFile(file.path)
    let json = parseJSON(readFile(file.path))
    assert json.kind == JArray, "JSON file is not a JArray!"
    for node in json:   # nim's for loops are Very Cool
        assert node.kind == JObject
        if node["type"].getStr() == "message":
            let
                user: string = node["user"].getStr()
                text: string = node["text"].getStr()
                identifier: string = node["ts"].getStr()
                time: string = fromUnixFloat(node["ts"].getFloat()).format("dddd', 'MMMM' 'd', 'h':'mm' 'tt")  # !!!: WINDOWS and UNIX times are different
            let message: string =
                `div`(class="message", id=identifier,
                `div`(class="image",
                    img(src="assets/" & user & ".jpg", alt="profile picture: " & user)),
                `div`(class="text",
                    strong(class="user", user), a(class="time", href=identifier, time),
                    br(), p(class="text", text), span("reactions")))
            messages = messages & message
    messages = messages & span(class="divider", $file)

let content:string = `div`(id="content",
    `div`(id="banner",
    `div`(id="channel", strong($directory), br(), p()),   # Channel descriptions are inserted by far.nim
    `div`(id="search")),                                  # TODO: this needs actual functionality
    `div`(id="messages", messages))

let head: string = head(
    title(), meta(charset="utf-8"),     # The workspace title is inserted by far.nim
    link(rel="icon", href="https://a.slack-edge.com/80588/marketing/img/meta/favicon-32.png"),
    link(rel="stylesheet"))             # The stylesheet href is inserted by far.nim

let body: string = body(                # Workspace title and channel lists are inserted by far.nim
    `div`(id="sidebar", h1(id="title"),
    `div`(id="public-channels",  h3("Public Channels"),  ul()),
    `div`(id="private-channels", h3("Private Channels"), ul()),
    `div`(id="group-dms",        h3("Group Messages"),   ul()),
    `div`(id="personal-dms",     h3("Direct Messages"),  ul())),
    content)

let html = html(head, body)  # potential issue: `let` may not 'let' `html` change when `head` and `body` do

echo html   # this shouldn't be done actually but I don't know how to return from a program
