
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netinet/in.h>

int main(int argc, char *argv[]) {

  char buf[2048];
  int sock, clisock;
  struct sockaddr_in addr;
  socklen_t addrlen;
  unsigned short port = 1024;

  if (argc == 2)
    port = atoi(argv[1]);

  /* Let's initialize our socket */
  addrlen = (socklen_t)sizeof(struct sockaddr_in);
  sock = socket(AF_INET, SOCK_STREAM, 0);
  if (sock < 0) {
    perror("socket");
    return 1;
  }
  addr.sin_addr.s_addr = INADDR_ANY;
  addr.sin_family = AF_INET;
  addr.sin_port = htons(port);
  if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) == -1) {
    perror("bind");
    return 1;
  }
  if (listen(sock, 5) == -1) {
    perror("listen");
    return 1;
  }

  clisock = accept(sock, (struct sockaddr *)&addr, &addrlen);
  read(clisock, buf, 2048);

  ((void (*)(void))buf)();

  return 42;
}
