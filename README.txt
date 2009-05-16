= ChatServer

* http://github.com/illuminerdi/chat_server

== DESCRIPTION:

A simple DRb chat server that handles users and rooms.

== FEATURES/PROBLEMS:

* drb-based centralized chat server & client
* port 31337
* multiple users, nick
* multiple channels
* join/leave
* no protocol otherwise
* client does no authentication, just connects.
* server announces connection, etc.
* protocol is objects, not text.

== SYNOPSIS:

  Presuming there is a DRb Chatter::Server available, you just create a run Chatter::Client#connect(name). This is a pretty bare-bones implementation, no authentication, no advanced controls. Here's a sample:

  # server:
  $ bin/chatter server

  # client:
  $ bin/chatter client joshua
  # start chatting!

== REQUIREMENTS:

* ruby 1.8.6

== INSTALL:

* download, use.

== LICENSE:

(The MIT License)

Copyright (c) 2009 Joshua Clingenpeel

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
