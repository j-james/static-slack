# assets.nim: Handles converting _all_ src-fetched assets
# @param: A standard (hopefully), parseable HTML file
# @param: Path to unzipped Slack export folder
# @param: Asset output location
# @return: Newly-generated HTML file with relative links

import os, htmlparser, xmltree, strtabs, httpclient, uri

proc assets*(html, output: string): string =
    var html = parseHTML(html)
    let client = newHTTPClient()

    createDir(joinPath(output, "img"))

    # Image embeds
    for img in html.findAll("img"):
        assert hasKey(img.attrs, "src"), "img " & $img & " lacks a src tag!"
        var url: string = img.attrs["src"]
        var name: string = extractFilename(parseUri(url).path)
        if not fileExists(joinPath(output, "img", name)) and not (name == "USLACKBOT"):
            downloadFile(client, url, joinPath(output, "img", name))
        img.attrs["src"] = joinPath("img", name)

    # Favicon
    downloadFile(client, "https://a.slack-edge.com/80588/marketing/img/meta/favicon-32.png", joinPath(output, "img", "favicon.png"))

    return $html
