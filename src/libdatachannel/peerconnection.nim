# High-level API for libdatachannel library
#
# (c) 2025 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/libdatachannel-nim

import std/options
import ./bindings

type
  PeerConnectionID* = cint
  DataChannelID* = cint

  DCDescriptionType* = enum
    descriptionOffer = "offer"
    descriptionAnswer = "answer"
    descriptionPrAnswer = "pranswer"
    descriptionRollback = "rollback"

  PeerConnection* = ref object
    id*: PeerConnectionID
    config: rtcConfiguration

  PeerConnectionError* = object of CatchableError

proc newPeerConnection*(config: rtcConfiguration): PeerConnection =
  ## Creates a new PeerConnection. If there was no port specified,
  ## it will return the port assigned by the OS.
  result = PeerConnection(config: config)
  result.id = rtcCreatePeerConnection(addr(result.config))
  if result.id < 0:
    raise newException(PeerConnectionError, "Failed to create a Peer Connection")

proc close*(pc: PeerConnection) =
  ## Close and delete a PeerConnection
  deallocCStringArray(pc.config.iceServers)
  assert pc.id.rtcClosePeerConnection() == 0
  assert pc.id.rtcDeletePeerConnection() == 0

proc setLocalDescriptionCallback*(pc: PeerConnection; callback: rtcDescriptionCallbackFunc) =
  ## Set the callback for when a new SDP description is received
  assert pc.id.rtcSetLocalDescriptionCallback(callback) == 0

proc setLocalCandidateCallback(pc: PeerConnection; callback: rtcCandidateCallbackFunc) =
  ## Set the callback for when a new local candidate is received
  assert pc.id.rtcSetLocalCandidateCallback(callback) == 0

proc setStateChangeCallback*(pc: PeerConnection; callback: rtcStateChangeCallbackFunc) =
  ## Set the callback for when the connection state changes
  assert pc.id.rtcSetStateChangeCallback(callback) == 0

proc setGatheringStateChangeCallback*(pc: PeerConnection; callback: rtcGatheringStateCallbackFunc) =
  ## Set the callback for when the ICE gathering state changes
  assert pc.id.rtcSetGatheringStateChangeCallback(callback) == 0

proc initDataChannel*(pc: PeerConnection; openCallback: rtcOpenCallbackFunc;
    messageCallback: rtcMessageCallbackFunc;
    descriptionType: Option[DCDescriptionType] = none(DCDescriptionType)): DataChannelID =
  ## Initialize a DataChannel on the PeerConnection
  let dc = pc.id.rtcCreateDataChannel(cstring("datachannel"))
  if dc < 0:
    raise newException(PeerConnectionError, "Failed to create DataChannel")
  assert rtcSetOpenCallback(dc, openCallback) == 0
  assert rtcSetMessageCallback(dc, messageCallback) == 0
  if descriptionType.isSome():
    var desc: cstring = cstring($(descriptionType.get()))
    assert rtcSetLocalDescription(pc.id, addr(desc)) == 0
  else:
    assert rtcSetLocalDescription(pc.id, nil) == 0
  result = dc
