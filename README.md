# Rubberverse Containerfiles

These are assortments of my own hand-made containerfiles that you can use as a base for your own projects or ideas.

## What is this one about?

It's a generic Wine runner that...

- Runs as shell-less `wine-runner` (`1100:1100`) user
- Uses `"null"` display driver added via `wine reg add` during build time
- Gracefully stops processes inside with `wineserver -k2`.
- Uses `winetricks` to install some DLLs - mainly Visual C++ Redistributables - to minimize potential issues
- Makes use of `tini` to handle SIGTERM / SIGINT
- Can launch any executable mounted at `/srv/app`

It's purpose is to run game servers and CLI applications in a container.<br>
If you experience issues with networking then you should run this under `host` network mode.
This is due to rootless networking not handling UDP pretty well so large packets may arrive back mangled or corrupt.

It pulls `winehq-stable` from WineHQ repositories and `winetricks` from author's GitHub repository.
Winetricks gets removed off the image later so it's not usable as a base later.

Final size for the image after building will be `3.87GB`.
