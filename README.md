# static-slack

A efficient, extendable, and easy-to-use Slack export viewer.

[Transform your Slack archive into a series of lightweight static web pages.](https://j-james.me/spartronics-slack)

## Usage

### Compile with Nim
`git clone https://github.com/j-james/static-slack`

`cd static-slack`

`nim compile -d:ssl --run main.nim <slack_export_folder> <output_location>`

### Run the binary next to style.css (available under Releases)

`static-slack <slack_export_folder> <output_location>`

## Roadmap

- [x] Generate HTML
	- [x] main.nim
	- [x] gen.nim
		- [x] issue: links are parsed weirdly
- [x] Replace user / channel IDs with names
	- [x] far.nim
- [x] Make the generated HTML look like an actual Slack workspace
- [x] Host assets locally
	- [x] assets.nim
- [ ] Support for attachments
	- [ ] attachments.nim?
- [ ] Support for (custom) emojis
- [ ] Offer as a webapp?
