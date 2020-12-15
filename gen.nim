# gen.nim: Generate an HTML file from a particular directory of JSON files
# @param: Path to JSON folder
# @return: Generated HTML file

import os, json, algorithm, sequtils, strutils, times, htmlgen, re
from regex import nil

# There's some transformations that really should be done within the block itself
func transform(text: string): string =
    var text: string = text

    # Newline characters are safe to regex replace with a self-closing <br />
    text = replace(text, re("\n"), "<br />")

    # Slack exports enjoy wrapping links with <>, complicating parsing
    # ensure we're using the regex type from re here to not throw garbage strings
    for url in re.findAll(text, re("<http\\S+>")):
        var a: seq[string] = split(strip($url, chars = {'<', '>'}), '|')
        a.add(a[0])
        text = text.replace($url, "<a href=\"" & a[0] & "\">" & a[1] & "</a>")

    # Additionally, clean up and link to mentioned channels
    for channel in re.findAll(text, re("<#\\S+>")):
        var a: seq[string] = split(strip($channel, chars = {'<', '#', '>'}), '|')
        a.add(a[0])
        a[1] = replace(a[1], '_', '-') # Underscores in channel names are not allowed to prevent messing up italics
        text = replace(text, $channel, "<a class=\"channel\" href=\"" & a[1] & ".html\">" & "#" & a[1] & "</a>")

    # Replace Markdown indentifiers one at a time while ensuring a closing tag
    # The regex package provides selective replacement, which is not in re
    while len(findAll(text, re("\\*"))) > 1:
        text = regex.replace(text, regex.re("\\*"), "<strong>", 1)
        text = regex.replace(text, regex.re("\\*"), "</strong>", 1)
    while len(findAll(text, re("_"))) > 1:
        text = regex.replace(text, regex.re("_"), "<em>", 1)
        text = regex.replace(text, regex.re("_"), "</em>", 1)
    while len(findAll(text, re("```"))) > 1:
        text = regex.replace(text, regex.re("```"), "<code>", 1)
        text = regex.replace(text, regex.re("```"), "</code>", 1)

    return text

# * denotes an exposed method
proc gen*(dir: string): string =
    assert dirExists(dir), "Passed string doesn't point to a directory!"
    var messages: string
    for file in sorted(toSeq(walkDir(dir))): # nim's for loops are cool
        assert fileExists(file.path), "File " & file.path & " does not exist!"
        let json = parseJSON(readFile(file.path))
        assert json.kind == JArray, "JSON file is not an array!"
        messages = messages & `div`(class="divider", `div`(), span(splitFile(file.path).name), `div`())
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
                            span(class="user", user),
                            a(class="time", href="#" & timestamp, time),
                            p(class="text", text),
                            span(class="reactions") # TODO: this needs actual functionality
                        )
                    )
                messages &= message

    let html: string = html(
        head(
            title("Slack - " & extractFilename(dir)), meta(charset="utf-8"),
            link(rel="icon", href="assets/img/favicon.png"),
            link(rel="stylesheet", href="assets/css/style.css")
        ),
        body( # Channel lists and descriptions are inserted by far.nim
            nav(),
            main(
                `div`(id="banner",
                    `div`(id="channel",
                        h1(replace(extractFilename(dir), '_', '-')),
                        p(id="purpose")
                    )
                ), `div`(id="messages", messages)
            )
        )
    )

    return html
