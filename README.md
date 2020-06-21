static-slack
============

A (not-yet) full-fledged Slack export viewer. 90% of the way to 90% there.

## Roadmap

- [ ] Generate HTML
  - [x] main.nim (ish)
  - [x] gen.nim
- [ ] Replace user / channel IDs with names
  - [x] far.nim (again, ish)
- [ ] Host assets locally
  - [ ] assets.nim
- [ ] Make the generated HTML look like an actual Slack workspace
  - [ ] Offer both Classic Slack and the redesign
- [ ] Support attachments
  - [ ] attachments.nim?
- [ ] Compile generator to C and as a binary for v1.0
- [ ] Offer as a webapp? Nim supports JS as a target platform

## Usage

### Compile with Nim
`git clone https://git.sr.ht/~j-james/static-slack`

`cd static-slack`

`nim compile --run main.nim slack_export_folder output_location`

### Run the binary (available under Releases)

`static-slack slack_export_folder output_location`

haha district bad brrr
