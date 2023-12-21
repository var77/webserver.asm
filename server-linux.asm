default rel
global _start

; SYSCALLS
%define SYS_exit 60
%define SYS_write 1
%define SYS_socket 41
%define SYS_bind 49
%define SYS_listen 50
%define SYS_accept 43
%define SYS_read 0
%define SYS_close 3
%define SYS_setsockopt 54

; SOCKET PARAMS
%define AF_INET 2
%define SOCK_STREAM 1
%define SOL_SOCKET 0xffff
%define SO_REUSEADDR 0x0004
%define SO_REUSEPORT 0x0200

; FILE DESCRIPTORS
%define STDOUT 1

%macro write 3 
    mov    rax, SYS_write 
    mov    rdi, %1
    mov    rsi, %2
    mov    rdx, %3
    syscall
%endmacro

%macro print 2 
    jmp %%code
    
    %%str: db %2
    %%str_len: equ $ - %%str

    %%code:
        mov    rax, SYS_write 
        mov    rdi, %1
        mov    rsi, %%str
        mov    rdx, %%str_len
        syscall
%endmacro

%macro log 1 
    %strcat log_msg %1,`\n`
    print STDOUT,log_msg
%endmacro

%macro info 1 
    %strcat log_msg "INFO: ",%1
    log log_msg
%endmacro

%macro error 1 
    %strcat log_msg "ERROR: ",%1
    log log_msg
%endmacro

%macro exit 1 
    mov rax, SYS_exit
    mov rdi, %1
    syscall
%endmacro

section .text

_start:
    sub rsp, 12
    info "Starting Webserver..."
    ; ========== CREATE SOCKET =============
    info "Creating socket"
    mov rax, SYS_socket
    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    mov rdx, 0
    syscall
    mov [socket_fd], rax
    ; check error
    jc .error
    info "Socket created"

    ; Enable address and port reuse for socket
    mov rax, SYS_setsockopt
    mov rdi, [socket_fd]
    mov rsi, SOL_SOCKET
    mov rdx, SO_REUSEADDR
    mov rcx, enable
    mov r8, size_int
    syscall
    
    mov rax, SYS_setsockopt
    mov rdi, [socket_fd]
    mov rsi, SOL_SOCKET
    mov rdx, SO_REUSEPORT
    mov rcx, enable
    mov r8, size_int
    syscall
    ; ======================================
    
    ; ========== BIND SOCKET =============
    info "Binding Socket"
    mov rax, SYS_bind
    mov rdi, [socket_fd]
    mov rsi, sin_struct
    mov rdx, sin_len
    syscall
    jc .error
    ; ======================================

    ; ========== LISTEN SOCKET =============
    info "Listening Socket"
    mov rax, SYS_listen
    mov rdi, [socket_fd]
    mov rsi, 10 ; TODO buf size limit
    mov rdx, 0
    syscall
    jc .error
    info "Server listening on http://localhost:8080"
    ; ======================================
    
    .accept:
    ; ========== ACCEPT SOCKET =============
    mov rax, SYS_accept
    mov rdi, [socket_fd]
    mov rsi, 0
    mov rdx, 0
    syscall
    mov [client_fd], rax
    jc .error
    
    ; Print client message
    info "Received Connection"
    jc .error
    
    ; Respond client
    write [client_fd], client_response_msg, client_response_msg_len

    ; Close connection
    mov rax, SYS_close
    mov rdi, [client_fd]
    syscall
    jc .error

    ; Accept loop
    jmp .accept
    ; ======================================
    exit 0
    .error:
        error "Error happened, exitting..."
        exit 1

section .data
; servaddr_in socket struct
enable: dd 1
size_int: equ $ - enable
socket_fd: dq 0
sin_struct:   dw AF_INET
sin_port:     dw 36895 ; 8080
sin_addr:     dd 0
sin_zero:     dq 0
sin_len:      equ $ - sin_struct
; client socket
client_fd: dq 0
client_response_msg: db "HTTP/1.1 200",10
                     db "Content-Type: text/html;",10,10
                     db "<h1>Hello World!</h1>"
client_response_msg_len: equ $ - client_response_msg
