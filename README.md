# wormhole

A small Go file server with a built-in browser. One binary. No extra runtime.

You point it at a directory and it serves it. Browse files, stream video, look at pictures and PDFs, take notes, upload if you want. Keyboard navigation is there. Read-only mode is there if you only want people to look.

HTTPS and logins stay with a reverse proxy. wormhole does the files.

## Build

```sh
make
./wormhole --help
./wormhole -h 127.0.0.1 ~/storage
```

`make install` copies the binary to `/usr/local/bin`.

## Docker

```sh
mkdir ~/LocalDirToShare
docker build -t wormhole .
docker run -v ~/LocalDirToShare:/shared -p 8001:8001 wormhole
```

See `support/` for compose, a systemd unit, and Caddy examples for more than one user.

## Shortcuts

`Ctrl/Cmd + h` lists the UI keys.

## License

MIT.
