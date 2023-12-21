expand:
	nasm -E server.asm
	
build-linux:
	nasm -f elf64 server-linux.asm -o server.o && strip --strip-unneeded server.o && ld -o server server.o && chmod +x ./server && rm -rf server.o

run-linux: build-linux
	./server

build-osx:
	nasm -f macho64 server-osx.asm -o server.o && ld -lSystem  -L/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib -macosx_version_min 12.0.0  -o server server.o && chmod +x ./server && rm -rf server.o

run-osx: build-osx
	./server

build-docker:
	docker build . -t server
run-docker: build-docker
	docker run -p8080:8080 --rm server
