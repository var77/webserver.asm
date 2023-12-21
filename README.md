# Webserver in nasm (macho64 and linux x86_64 assembly) for fun

## Run

You need `nasm` in order to build the application (`brew install nasm`)  
To build and run the application use `make run-osx` or `make run-linux`
You need to have installed command-line tools `xcode-select --install` as OS X Linker requres `libSystem.dylib`

The server will start listening on `localhost:8080` and there will be one route `/` which will answer with hello message

## Docker
```bash
docker build . -t server
docker run -p8080:8080 server
```

Now you can `curl http://localhost:8080` and get hello world! (or open it in browser)

**The docker image is only 9KB**
```bash
docker inspect server | jq .[0].Size
```

## Description

The code is creating a socket using syscalls (`socket`, `bind`, `listen`, `accept`) and `read`, `write` syscalls to read and answer requests
