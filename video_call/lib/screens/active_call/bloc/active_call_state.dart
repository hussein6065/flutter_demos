/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
import 'package:equatable/equatable.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';
import 'package:meta/meta.dart';

@immutable
class ActiveCallState implements Equatable {
  final String callStatus;
  final String endpointName;
  final VIAudioDevice activeAudioDevice;
  final List<VIAudioDevice> availableAudioDevices;
  final String localVideoStreamID;
  final String remoteVideoStreamID;
  final VICameraType cameraType;
  final bool isOnHold;
  final bool isMuted;

  ActiveCallState({
    @required this.callStatus,
    @required this.endpointName,
    @required this.localVideoStreamID,
    @required this.remoteVideoStreamID,
    @required this.cameraType,
    @required this.isOnHold,
    @required this.isMuted,
    @required this.activeAudioDevice,
    @required this.availableAudioDevices,
  });

  ActiveCallState copyWith({
    String endpointName,
    String callStatus,
    VIAudioDevice activeAudioDevice,
    List<VIAudioDevice> availableAudioDevices,
    String localVideoStreamID,
    String remoteVideoStreamID,
    VICameraType cameraType,
    bool isOnHold,
    bool isMuted,
  }) =>
      ActiveCallState(
        endpointName: endpointName ?? this.endpointName,
        callStatus: callStatus ?? this.callStatus,
        localVideoStreamID: localVideoStreamID ?? this.localVideoStreamID,
        remoteVideoStreamID: remoteVideoStreamID ?? this.remoteVideoStreamID,
        activeAudioDevice: activeAudioDevice ?? this.activeAudioDevice,
        availableAudioDevices:
            availableAudioDevices ?? this.availableAudioDevices,
        cameraType: cameraType ?? this.cameraType,
        isOnHold: isOnHold ?? this.isOnHold,
        isMuted: isMuted ?? this.isMuted,
      );

  ActiveCallState copyWithLocalStream(String localVideoStreamID) =>
      ActiveCallState(
        callStatus: this.callStatus,
        endpointName: this.endpointName,
        localVideoStreamID: localVideoStreamID,
        remoteVideoStreamID: this.remoteVideoStreamID,
        cameraType: this.cameraType,
        isOnHold: this.isOnHold,
        isMuted: this.isMuted,
        activeAudioDevice: this.activeAudioDevice,
        availableAudioDevices: this.availableAudioDevices,
      );

  ActiveCallState copyWithRemoteStream(String remoteVideoStreamID) =>
      ActiveCallState(
        callStatus: this.callStatus,
        endpointName: this.endpointName,
        localVideoStreamID: this.localVideoStreamID,
        remoteVideoStreamID: remoteVideoStreamID,
        cameraType: this.cameraType,
        isOnHold: this.isOnHold,
        isMuted: this.isMuted,
        activeAudioDevice: this.activeAudioDevice,
        availableAudioDevices: this.availableAudioDevices,
      );

  @override
  List<Object> get props => [
        callStatus,
        localVideoStreamID,
        remoteVideoStreamID,
        isOnHold,
        isMuted,
        activeAudioDevice,
        availableAudioDevices,
      ];

  @override
  bool get stringify => true;
}

class ReadyActiveCallState extends ActiveCallState {
  ReadyActiveCallState()
      : super(
          endpointName: '',
          cameraType: VICameraType.Front,
          callStatus: '',
          localVideoStreamID: null,
          remoteVideoStreamID: null,
          isOnHold: false,
          isMuted: false,
          activeAudioDevice: null,
          availableAudioDevices: [],
        );
}

@immutable
class CallEndedActiveCallState extends ActiveCallState {
  final bool failed;
  final String reason;

  CallEndedActiveCallState({
    @required this.reason,
    @required this.failed,
    @required endpointName,
    @required VICameraType cameraType,
    @required activeAudioDevice,
    @required availableAudioDevices,
  }) : super(
          callStatus: failed ? 'Failed' : 'Disconnected',
          localVideoStreamID: null,
          remoteVideoStreamID: null,
          endpointName: endpointName,
          cameraType: cameraType,
          isOnHold: false,
          isMuted: false,
          availableAudioDevices: List.empty(),
          activeAudioDevice: activeAudioDevice,
        );

  @override
  List<Object> get props => [failed, failed, endpointName];
}
