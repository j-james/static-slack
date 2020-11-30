# assets.nim: Handles converting _all_ src-fetched assets
# @param: A standard (hopefully), parseable HTML file
# @param: Path to unzipped Slack export folder
# @param: Asset output location
# @return: Newly-generated HTML file with relative links

import os, strutils, strtabs, htmlparser, xmltree, httpclient, uri

proc assets*(html, output: string): string =
    var html: string = html
    var tree: XmlNode = parseHTML(html)
    let client = newHTTPClient()

    createDir(joinPath(output, "assets/img"))

    # Image embeds
    for img in tree.findAll("img"):
        assert hasKey(img.attrs, "src"), "img " & $img & " lacks a src tag!"
        var url: string = img.attrs["src"]
        var name: string = extractFilename(parseUri(url).path)
        if not fileExists(joinPath(output, "assets/img", name)) and not (name == "USLACKBOT"):
            downloadFile(client, url, joinPath(output, "assets/img", name))
        html = replace(html, img.attrs["src"], joinPath("assets/img", name)) # Not guaranteed to work

    # Favicon
    downloadFile(client, "https://a.slack-edge.com/80588/marketing/img/meta/favicon-32.png", joinPath(output, "assets/img/favicon.png"))

    return html
