static-slack
============

A full-fledged Slack export viewer.

## Roadmap

- [ ] Generate HTML
  - [ ] main.nim
  - [x] gen.nim
- [ ] Replace user / channel IDs with names
  - [ ] far.nim
- [ ] Host assets locally
  - [ ] assets.nim
- [ ] Make the generated HTML look like an actual Slack workspace
  - [ ] Offer both Classic Slack and the redesign
- [ ] Offer as a webapp?

## History

haha district bad brrr

## Usage

### Run the Nim app
`git clone https://git.sr.ht/~j-james/static-slack`
`cd static-slack`
`nim c -r --verbosity:0 main.nim slack_export_folder output_location`

### Run the C app
This will also be available compiled to C and as an x86_64 binary.
