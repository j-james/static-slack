# assets.nim: Handles converting _all_ href-fetched assets
# @param: A parseable HTML file
# @param: Asset output location
# @return: Newly-generated HTML file with relative links

import os, re, htmlparser, htmlgen, uri

assert paramCount() == 2, "Invalid arguments"
assert existsFile(paramStr(1))

let example = parseUri("https://j-james.me/boogabooga/image.png")

echo example.username
echo example.password
echo example.hostname
echo example.port
echo example.path
echo example.anchor

var html = loadHTML(paramStr(1))

html = html.replace(re "<link rel=\"stylesheet\" />", "<link rel=\"stylesheet\" href=\"" & directory & "style.css\" />")


for a in html.findAll("a"):
    if a.attrs.hasKey "href":
        # check file type
        # endswith from strutils
        # if image:
            # if filename exists in assets
            # link to it
            # else download
        # else, break
