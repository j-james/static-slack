# assets.nim: Handles converting _all_ src-fetched assets
# @param: A standard (hopefully), parseable HTML file
# @param: Path to unzipped Slack export folder
# @param: Asset output location
# @return: Newly-generated HTML file with relative links

import os, json
import htmlparser, xmltree, strtabs
import httpclient, uri

proc assets*(html, input, output: string): string =
    var html = parseHTML(html)
    let users = parseJSON(readFile(joinPath(input, "users.json")))
    let client = newHTTPClient()

    createDir(joinPath(output, "img"))
    # Image embeds
    for img in html.findAll("img"):
        assert img.attrs.hasKey "src"

        # User pictures
        if img.attrs["class"] == "profile":
            for node in users:
                if getStr(node["id"]) == img.attrs["src"]:
                    img.attrs["src"] = getStr(node["profile"]["image_48"])

        var url: string = img.attrs["src"]
        var name: string = extractFilename(parseUri(url).path)
        if not fileExists(joinPath(output, "img", name)) and not (name == "USLACKBOT"):
            downloadFile(client, url, joinPath(output, "img", name))
        img.attrs["src"] = joinPath("img", name)

    return $html
