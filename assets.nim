# assets.nim: Handles converting _all_ href-fetched assets
# @param: A parseable HTML file
# @param: Asset output location
# @return: Newly-generated HTML file with relative links

import os
import htmlgen

assert paramCount() == 2
