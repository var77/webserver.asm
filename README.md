# Webserver in nasm (macho64 assembly) for fun

## Run

You need `nasm` in order to build the application (`brew install nasm`)  
To build and run the application use `make run`  
You need to have installed command-line tools `xcode-select --install` as OS X Linker requres `libSystem.dylib`

The server will start listening on `localhost:8080` and there will be one route `/` which will answer with hello message

## Description

The code is creating a socket using syscalls (`socket`, `bind`, `listen`, `accept`) and `read`, `write` syscalls to read and answer requests
