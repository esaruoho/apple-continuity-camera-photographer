# apple-continuity-camera-photographer 📱

**Let your AI agent ask to *see* things — and take a photo for it with your iPhone.**

> *"This coil gets hot and I don't know why."*
> Agent: *"Show me how it's wired."* → the camera opens on your iPhone → you shoot → the agent sees the photo, in the same conversation.

Three pieces, all Apple-native with no dependencies:

| Piece | What it does |
|---|---|
| **iPhoneLatest.app** | A 📱 menu-bar app. Click it and your iPhone's camera opens (Continuity Camera). Take the shot, tap **Use Photo**, and you get a draggable thumbnail to drop into any chat. |
| **`bin/iphone-snap`** | CLI: opens the camera via `iphonelatest://take`, waits for your shot, prints the JPEG path. Any agent with a shell can use it. |
| **`bin/iphone-snap-mcp`** | MCP server with the tool **`take_iphone_photo`**. It returns the photo *as an image* to Claude Code, Codex, Gemini CLI, GitHub Copilot CLI, Antigravity, or any MCP client. |

## Install

```bash
git clone https://github.com/esaruoho/apple-continuity-camera-photographer
cd apple-continuity-camera-photographer
./build.sh          # → /Applications/iPhoneLatest.app (registers Open at Login on first run)
./install-mcp.sh    # registers the `iphone` MCP server with every agent CLI it finds
```

**Requirements:** macOS 13+, Xcode command-line tools (`xcrun swiftc`), and an iPhone signed in to the **same Apple ID** with **Wi-Fi and Bluetooth** on. That's the standard Continuity Camera setup. No cable needed.

## Use

**By hand:**

| Action | Result |
|---|---|
| Click **📱** | iPhone camera opens. Shoot, tap **Use Photo**, and the thumbnail appears. |
| **Drag** the thumbnail | Drops the JPEG into Terminal, Claude, Mail, Messages… |
| Click **📱** with the thumbnail open | Closes it. |
| **📂 Open iPhone-Latest folder** | All your shots. They're never overwritten. |
| **Right-click 📱** | Help · Open folder · **Open at Login** · Quit |

**From an agent:** it calls `take_iphone_photo` on its own when seeing would help. You can also just say *"take a photo of …"*. The photo lands in the current conversation, so the agent keeps the context it already has.

To make agents reach for it more, add one line to their global instructions:

> When seeing something physical would help (a circuit, wiring, a device, a screen, a document), use the `take_iphone_photo` tool instead of guessing from a description.

## Where photos go

- Originals: `~/Pictures/iPhone-Latest/Continuity-<yyyyMMdd-HHmmss>.jpg`, kept permanently.
- The MCP server sends the model a 1600 px copy (`$TMPDIR/iphone-snap-mcp.jpg`, overwritten on each call).
- The agent's own session transcript holds the image it saw.

## How it works

It uses the same Continuity Camera mechanism as Finder's *Import from iPhone ▸ Take Photo*:

- `NSMenuItem.importFromDeviceIdentifier` has to live in the app's **main menu**. In pop-up menus AppKit never enables it (we checked with a probe app).
- AppKit only populates the device submenu once the menu has been opened, so the first use opens it and cancels it after 0.4 s, then fires **Take Photo** programmatically.
- The shot comes back through `NSServicesMenuRequestor.readSelection(from:)` and is saved as JPEG.
- `iphonelatest://take` triggers the same flow, so the CLI and the MCP server just open that URL and wait for the new file.

**Why not the USB cable?** That's what we tried first. Over USB, iOS publishes new photos to ImageCaptureCore late and unreliably: 15–60 s after the shot, with stale catalogs. The details are in [`FINDINGS.md`](FINDINGS.md).

## Files

```
App/main.swift          the menu-bar app
App/SupportHelp.swift   shared Help + support panel
App/make-icon.swift     renders App/AppIcon.icns
bin/iphone-snap         CLI: ask for a photo, print the path
bin/iphone-snap-mcp     MCP server (stdio, Python 3 stdlib only)
build.sh                build + sign + install
install-mcp.sh          register/unregister the MCP server with agent CLIs
```

## Support

If this is useful to you, see Help ▸ Support in the app (GitHub Sponsors, Ko-fi, Patreon, Bandcamp…).

Also part of [esaruoho/apple](https://github.com/esaruoho/apple), Esa's Apple automation workbench. This standalone repo is the canonical copy.

License: MIT.
