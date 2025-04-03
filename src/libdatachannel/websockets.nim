# High-level API for libdatachannel library
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/libdatachannel-nim


import std/[os, macros, strutils]
from std/net import Port, `$`

import ./bindings

#
# WebSocket Server API
# High-level API for libdatachannel WebSocket server
#
type
  WebSocketListener* = enum
    onOpened, onMessage, onClosed, onError

  WebSocketIdentifier* = cint
  WebSocketServer* = ref object
    id*: cint
    config*: rtcWsServerConfiguration

proc newWebSocketServer*(enableTls: bool = false; port: Port = Port(0)): WebSocketServer =
  ## Creates a new WebSocketServer. If there was no port specified,
  ## it will return the port assigned by the OS.
  result = WebSocketServer(config: rtcWsServerConfiguration(enableTls: enableTls, port: port.uint16))

proc startServer*(wsserver: WebSocketServer, callback: RTCWebSocketClientCallbackFunc): WebSocketIdentifier {.discardable.} =
  ## Start the WebSocket server. Libdatachannel runs the WebSocket server
  ## in a separate thread, so you don't need to worry about
  ## blocking the main thread.
  result = rtcCreateWebSocketServer(addr(wsserver.config), callback)
  assert result > 0
  wsserver.id = result

proc getPort*(wsserver: WebSocketServer): Port =
  ## Get the port of the WebSocket server.
  ## If there was no port specified, it will return
  ## the port assigned by the OS.
  if wsserver.config.port == 0.uint16:
    return Port(uint16(rtcGetWebSocketServerPort(wsserver.id)))
  Port(wsserver.config.port)

proc send*(id: cint, msg: string) =
  ## Send binary data using the WebSocket client.
  assert rtcSendMessage(id, cstring(msg), cint(msg.len)) == 0

proc message*(id: cint, msg: cstring) =
  ## Send binary data using the WebSocket client.
  assert rtcSendMessage(id, msg, cint(msg.len)) == 0

proc message*(id: cint, msg: string) =
  ## Send a text message
  assert rtcSendMessage(id, cstring(msg), cint(0 - msg.len)) == 0

proc close*(wsserver: WebSocketServer) =
  ## Close the WebSocket client
  assert wsserver.id.rtcDeleteWebSocket() == 0


#
# WebSocket Client API
# High-level API for libdatachannel WebSocket client
#
type
  WebSocketClient* = ref object
    id: cint
    config: ptr rtcWsConfiguration

proc newWebSocketClient*(url: string, disableTlsVerification: bool = true): WebSocketClient =
  ## Initialize a WebSocket client.
  ## If there was no port specified, it will return
  ## the port assigned by the OS.
  new(result)
  var config = rtcWsConfiguration(disableTlsVerification: disableTlsVerification)
  result.id = rtcCreateWebSocketEx(cstring(url), addr(config))
  result.config = addr(config)

proc send*(wsclient: WebSocketClient, message: string) =
  ## Send a message using the WebSocket client.
  assert rtcSendMessage(wsclient.id, cstring(message), cint(message.len)) == 0

proc message*(wsclient: WebSocketClient, msg: string): string {.inline.} =
  ## An alias for `send`. Send a message using the WebSocket client.
  wsclient.send(msg)

proc listen*(wsclient: WebSocketClient, event: WebSocketListener, callback: rtcOpenCallbackFunc|rtcClosedCallbackFunc) =
  ## Listen for open/closed events on the WebSocket client.
  if event == onOpened:
    assert rtcSetOpenCallback(wsclient.id, callback) == 0
  elif event == onClosed:
    assert rtcSetClosedCallback(wsclient.id, callback) == 0

proc listen*(wsclient: WebSocketClient, event: WebSocketListener, callback: rtcMessageCallbackFunc) =
  ## Listen for message events on the WebSocket client.
  assert rtcSetMessageCallback(wsclient.id, callback) == 0

proc listen*(wsclient: WebSocketClient, event: WebSocketListener, callback: rtcErrorCallbackFunc) =
  ## Listen for error events on the WebSocket client.
  assert rtcSetErrorCallback(wsclient.id, callback) == 0

proc close*(wsclient: WebSocketClient) =
  ## Close the WebSocket client
  assert wsclient.id.rtcDeleteWebSocket() == 0
