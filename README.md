# Rubberverse Containerfile(s)

Just random stuff I threw up mostly for myself but may be useful to anyone else. That's all.

## What is this one about?

It's a generic Wine runner that...

- Runs as shell-less `wine-runner` (`1100:1100`) user
- Uses `"null"` display driver added via `wine reg add` during build time
- Gracefully stops processes inside with `wineserver -k2` (probably)
- Uses `winetricks` to install some DLLs - mainly Visual C++ Redistributables - to minimize potential issues
- Makes use of `tini` to handle `SIGTERM` / `SIGINT`
- Can launch any executable mounted at `/srv/app`
- Near instantenous launch of your executable with wine (which is normal behavior but just highlighting how simple entrypoint script is)

It's purpose is to run Windows-only game servers and CLI applications in a container.<br>

It pulls `winehq-stable` from WineHQ repositories and `winetricks` from author's GitHub repository.
Winetricks gets removed off the image later so it's not usable as a base later.

> [!WARNING]
>  If you experience issues with networking then you should run this under `host` network mode.

This is due to rootless networking not handling UDP pretty well so large packets may arrive back mangled or corrupt.

## File size

Final size for the image after building will be `3.87GB`. You'll need `~6-7GB` to build this image.
