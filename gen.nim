# gen.nim: Generate an HTML file from a particular directory of JSON files
# @param: Path to JSON folder
# @return: Generated HTML file
# Do note that replacing user / channel mentions is handled exclusively in far.nim

import os, json, strutils, times, htmlgen, regex

# There's some transformations that really should be done within the block itself
func transform(text: string): string =
    var text = text

    # Newline characters are safe to regex replace with a self-closing <br />
    text = replace(text, re("\n"), "<br />")

    # Slack exports enjoy starting links with <http rather than http, complicating parsing
    text = replace(text, re("<http"), "http")

    # Replace Markdown indentifiers one at a time while ensuring a closing tag
    while len(findAll(text, re("\\*"))) > 1:
        text = replace(text, re("\\*"), "<strong>", 1)
        text = replace(text, re("\\*"), "</strong>", 1)
    while len(findAll(text, re("_"))) > 1:
        text = replace(text, re("_"), "<em>", 1)
        text = replace(text, re("_"), "</em>", 1)
    while len(findAll(text, re("```"))) > 1:
        text = replace(text, re("```"), "<code>", 1)
        text = replace(text, re("```"), "</code>", 1)

    return text

# * denotes an exposed method
proc gen*(dir: string): string =
    assert dirExists(dir), "Passed string doesn't point to a directory!"
    var messages: string
    for file in walkDir(dir): # nim's for loops are cool
        assert fileExists(file.path), "File " & file.path & " does not exist!"
        let json = parseJSON(readFile(file.path))
        assert json.kind == JArray, "JSON file is not an array!"
        for node in json: # nim's for loops are Very Cool
            assert node.kind == JObject, "JSON node is not an object!"
            if getStr(node["type"]) == "message" and hasKey(node, "user"):
                let
                    user: string = getStr(node["user"])
                    timestamp: string = intToStr(toInt(parseFloat(getStr(node["ts"]))))
                    time: string = fromUnix(parseInt(timestamp)).format("h':'mm' 'tt")
                    text: string = transform(getStr(node["text"]))
                let message: string =
                    `div`(class="message", id=timestamp,
                        `div`(class="image",
                            img(src=user, class="profile", alt=user)
                        ), `div`(class="content",
                            strong(class="user", user),
                            a(class="time", href="#" & timestamp, time),
                            p(class="text", text),
                            span("reactions") # TODO: this needs actual functionality
                        )
                    )
                messages &= message # XXX: This is a likely source of message mixups
        messages = messages & span(class="divider", splitFile(file.path).name)

    let html: string = html(
        head(
            title("Slack - " & extractFilename(dir)), meta(charset="utf-8"),
            link(rel="icon", href="assets/img/favicon.png"),
            link(rel="stylesheet", href="assets/css/style.css")
        ),
        body(
            nav(
                # Channel lists are inserted by far.nim
                h1(id="title", extractFilename(dir)),
                `div`(id="public-channels",  h3("Public Channels"),  ul()),
                `div`(id="private-channels", h3("Private Channels"), ul()),
                `div`(id="group-dms",        h3("Group Messages"),   ul()),
                `div`(id="personal-dms",     h3("Direct Messages"),  ul())
            ),
            main(
                `div`(id="banner",
                    # Channel descriptions are inserted by far.nim
                    `div`(id="channel",
                        h1(extractFilename(dir)),
                        br(),
                        p()
                    ),
                    `div`(id="search") # TODO: this needs actual functionality
                ), `div`(id="messages", messages)
            )
        )
    )

    return html
