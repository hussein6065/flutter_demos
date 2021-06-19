import 'package:flutter_voximplant/flutter_voximplant.dart';

/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
import 'package:meta/meta.dart';
import 'package:video_call/services/call/audio_device_event.dart';
import 'package:video_call/services/call/call_event.dart';

abstract class ActiveCallEvent {}

class ReadyToStartCallEvent implements ActiveCallEvent {
  final bool isIncoming;
  final String endpoint;

  ReadyToStartCallEvent({@required this.isIncoming, @required this.endpoint});
}

class AudioDevicesChanged implements ActiveCallEvent {
  final AudioDeviceEvent event;

  AudioDevicesChanged({
    @required this.event,
  });
}

class SelectAudioDevicePressedEvent implements ActiveCallEvent {
  final VIAudioDevice device;

  SelectAudioDevicePressedEvent({
    @required this.device,
  });
}

class CallChangedEvent implements ActiveCallEvent {
  final CallEvent event;

  CallChangedEvent({@required this.event});
}

class SendVideoPressedEvent implements ActiveCallEvent {
  final bool send;

  SendVideoPressedEvent({@required this.send});
}

class SwitchCameraPressedEvent implements ActiveCallEvent {}

class HoldPressedEvent implements ActiveCallEvent {
  final bool hold;

  HoldPressedEvent({@required this.hold});
}

class MutePressedEvent implements ActiveCallEvent {
  final bool mute;

  MutePressedEvent({@required this.mute});
}

class HangupPressedEvent implements ActiveCallEvent {}
