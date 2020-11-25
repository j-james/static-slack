static-slack
============

A (not-yet) full-fledged Slack export viewer.

## Roadmap

- [x] Generate HTML
	- [x] main.nim
	- [x] gen.nim
		- [ ] issue: links are parsed weirdly
- [x] Replace user / channel IDs with names
	- [x] far.nim
- [ ] Make the generated HTML look like an actual Slack workspace
	- [ ] Offer both Classic Slack and the redesign
- [x] Host assets locally
	- [x] assets.nim
- [ ] Support attachments
	- [ ] attachments.nim?
- [ ] Compile generator to C and as a binary for v1.0
- [ ] Offer as a webapp? Nim supports JS as a target platform

## Usage

### Compile with Nim
`git clone https://git.sr.ht/~j-james/static-slack`

`cd static-slack`

`nim compile -d:ssl --run main.nim <slack_export_folder> <output_location>`

### Run the binary (will be available under Releases)

`static-slack <slack_export_folder> <output_location>`
