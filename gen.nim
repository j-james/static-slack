# gen.nim: Generate an HTML file from a particular directory of JSON files
# @param: Path to JSON folder
# @return: Generated HTML file
# Do note that replacing user / channel mentions and images is handled exclusively in far.nim

import os, json, times, htmlgen

# * denotes an exposed method
proc gen*(dir: string): string =
    assert existsDir(dir), "Passed string doesn't point to a directory!"
    var messages: string
    for file in walkDir(dir): # nim's for loops are cool
        assert existsFile(file.path), "File " & file.path & " does not exist"
        let json = parseJSON(readFile(file.path))
        assert json.kind == JArray, "JSON file is not a JArray!"
        for node in json: # nim's for loops are Very Cool
            assert node.kind == JObject, "JSON node is not a JObject!"
            # TODO: this skips messages that aren't send by users like join/leave logs
            if node["type"].getStr() == "message" and hasKey(node, "user"):
                let
                    user: string = node["user"].getStr()
                    identifier: string = node["ts"].getStr()
                    time: string = fromUnixFloat(node["ts"].getFloat()).format("h':'mm' 'tt")   # FIXME: these times are wrong
                var text: string = node["text"].getStr()    # TODO: modify this to escape / process weird Slack formatting!
                let message: string =
                    `div`(class="message", id=identifier,
                    `div`(class="image",
                        img(src=user, class="profile", alt=user)),
                    `div`(class="text",
                        strong(class="user", user), a(class="time", href="#" & identifier, time),
                        br(), p(class="text", text), span("reactions")))
                messages &= message
        messages = messages & span(class="divider", splitFile(file.path).name)  # TODO: spans are probably not the best way of dividing days

    let content:string = `div`(id="content",
        `div`(id="banner",
        `div`(id="channel", h1(extractFilename(dir)), br(), p()),   # Channel descriptions are inserted by far.nim
        `div`(id="search")),                           # TODO: this needs actual functionality
        `div`(id="messages", messages))

    let head: string = head(
        title(extractFilename(dir)), meta(charset="utf-8"),     # The workspace title is inserted by far.nim
        link(rel="icon", href="assets/img/favicon.ico"),
        link(rel="stylesheet", href="assets/css/style.css"))

    let body: string = body(         # Channel lists are inserted by far.nim
        `div`(id="sidebar",          h1(id="title", extractFilename(dir)),
        `div`(id="public-channels",  h3("Public Channels"),  ul()),
        `div`(id="private-channels", h3("Private Channels"), ul()),
        `div`(id="group-dms",        h3("Group Messages"),   ul()),
        `div`(id="personal-dms",     h3("Direct Messages"),  ul())),
        content)

    return html(head, body)
