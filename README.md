<p align="center">
  <img src="https://github.com/openpeeps/PKG/blob/main/.github/logo.png" width="90px"><br>
  Nim language 👑 bindings for Libdatachannel<br>A standalone WebRTC Data Channels, WebRTC Media Transport, and WebSockets
</p>

<p align="center">
  <code>nimble install libdatachannel</code>
</p>

<p align="center">
  <a href="https://openpeeps.github.io/libdatachannel-nim">API reference</a><br>
  <img src="https://github.com/openpeeps/libdatachannel/workflows/test/badge.svg" alt="Github Actions">  <img src="https://github.com/openpeeps/libdatachannel/workflows/docs/badge.svg" alt="Github Actions">
</p>

## 😍 Key Features
- [x] Lightweight WebRTC Data Channel/Media Transport
- [x] Fast Server/Client WebSockets

- [x] High-level API in Nim style!
- [x] Low-level bindings `libdatachannel`

## Build the library
First, you will need to build [libdatachannel](https://libdatachannel.org/) from [GitHub source](https://github.com/paullouisageneau/libdatachannel). See [Building instructions](https://github.com/paullouisageneau/libdatachannel/blob/master/BUILDING.md)

## Examples

### WebSocket Example

**WebSocket Server**
This is a simple WebSocket server that listens for incoming connections and echoes back any messages it receives.
```nim
from std/os implement sleep
import libdatachannel/websockets

proc connectionCallback(wsserver: cint, ws: cint, userPtr: pointer) {.cdecl.} =

  proc wsMessageCallback(ws: cint, msg: cstring, size: cint, userPtr: pointer) =
    echo "Message from client ", $msg    
    ws.message(msg) # echo the message back

  discard rtcSetMessageCallback(ws, wsMessageCallback)

  # send a welcome message
  ws.message("Welcome to WebSocket Server!")

let wss = newWebSocketServer(port = Port(1234))
wss.startServer(connectionCallback)

while true:
  sleep(1000)
```

**WebSocket Client**
```nim
from std/os implement sleep
import libdatachannel/websockets

let client = newWebSocketClient("ws://127.0.0.1:1234")
client.listen(onMessage) do(ws: cint, message: cstring, size: cint, userPtr: pointer):
  echo $message

sleep(500)
while true:
  wsclient.send("Hello from client!")
  sleep(1000)
```

### Peer Connection
_todo_

### ❤ Contributions & Support
- 🐛 Found a bug? [Create a new Issue](https://github.com/openpeeps/libdatachannel-nim/issues)
- 👋 Wanna help? [Fork it!](https://github.com/openpeeps/libdatachannel-nim/fork)
- 😎 [Get €20 in cloud credits from Hetzner](https://hetzner.cloud/?ref=Hm0mYGM9NxZ4)
- 🥰 [Donate via PayPal address](https://www.paypal.com/donate/?hosted_button_id=RJK3ZTDWPL55C)

### 🎩 License
MIT license. [Made by Humans from OpenPeeps](https://github.com/openpeeps).<br>
Copyright &copy; 2025 OpenPeeps & Contributors &mdash; All rights reserved.
