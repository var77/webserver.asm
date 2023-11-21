expand:
	nasm -E server.asm
	
build:
	nasm -f macho64 server.asm && ld -lSystem  -L/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib -macosx_version_min 12.0.0  -o server server.o && chmod +x ./server && rm -rf server.o

run: build
	./server
