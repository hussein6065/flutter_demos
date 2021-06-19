/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_voximplant/flutter_voximplant.dart';
import 'package:video_call/screens/active_call/active_call.dart';
import 'package:video_call/screens/active_call/bloc/active_call_event.dart';
import 'package:video_call/screens/active_call/bloc/active_call_state.dart';
import 'package:video_call/screens/call_failed/call_failed.dart';
// import 'package:video_call/services/call/call_service.dart';
import 'package:video_call/theme/voximplant_theme.dart';
import 'package:video_call/utils/navigation_helper.dart';
import 'package:video_call/widgets/widgets.dart';

class ActiveCallPage extends StatefulWidget {
  static const routeName = '/activeCall';

  @override
  State<StatefulWidget> createState() => _ActiveCallPageState();
}

class _ActiveCallPageState extends State<ActiveCallPage> {
  ActiveCallBloc _bloc;

  VIVideoViewController _localVideoViewController = VIVideoViewController();
  VIVideoViewController _remoteVideoViewController = VIVideoViewController();

  double _localVideoAspectRatio = 1.0;
  double _remoteVideoAspectRatio = 1.0;

  _ActiveCallPageState();

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<ActiveCallBloc>(context);
    _localVideoViewController.addListener(_localVideoHasChanged);
    _remoteVideoViewController.addListener(_remoteVideoHasChanged);
    _timeLeft = _formatTime(timeD: _callTime);
  }

  @override
  void dispose() {
    _localVideoViewController.removeListener(_localVideoHasChanged);
    _remoteVideoViewController.removeListener(_remoteVideoHasChanged);
    _localVideoViewController.dispose();
    _remoteVideoViewController.dispose();
    super.dispose();
  }

  void _localVideoHasChanged() => setState(
      () => _localVideoAspectRatio = _localVideoViewController.aspectRatio);

  void _remoteVideoHasChanged() => setState(
      () => _remoteVideoAspectRatio = _remoteVideoViewController.aspectRatio);

  var _timeout = Duration(seconds: 1);
  var _callTime = Duration(seconds: 30);
  String _timeLeft = "00:00";

  String _formatTime({Duration timeD}) {
    var time = timeD.toString().split(RegExp(r"[:.]"));
    return "${time[1]}:${time[2]}";
  }

  dynamic callTimeOut() {
    return Timer.periodic(_timeout, (timer) {
      int timeLeft = _callTime.inSeconds - timer.tick;

      if (timeLeft == 0) {
        _bloc.add(HangupPressedEvent());
        timer.cancel();
      }
      setState(() {
        _timeLeft = _formatTime(timeD: Duration(seconds: timeLeft));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    void _hangup() => _bloc.add(HangupPressedEvent());

    void _hold(bool hold) => _bloc.add(HoldPressedEvent(hold: hold));

    void _mute(bool mute) => _bloc.add(MutePressedEvent(mute: mute));

    void _sendVideo(bool send) => _bloc.add(SendVideoPressedEvent(send: send));

    void _switchCamera() => _bloc.add(SwitchCameraPressedEvent());
    // void _selectAudioDevice(VIAudioDevice device) => _bloc.add(
    //       SelectAudioDevicePressedEvent(device: device),
    //     );
    // IconData _getIconForDevice(VIAudioDevice device) {
    //   switch (device) {
    //     case VIAudioDevice.Bluetooth:
    //       return Icons.bluetooth_audio;
    //     case VIAudioDevice.Speaker:
    //       return Icons.volume_up;
    //     case VIAudioDevice.WiredHeadset:
    //       return Icons.headset;
    //     default:
    //       return Icons.hearing;
    //   }
    // }

    // String _getNameForDevice(VIAudioDevice device) {
    //   List<String> splitted = device.toString().split('.');
    //   if (splitted != null && splitted.length >= 2) {
    //     return splitted[1];
    //   } else {
    //     return device.toString();
    //   }
    // }

    // _showAvailableAudioDevices(List<VIAudioDevice> devices) {
    //   return showDialog<void>(
    //     context: context,
    //     barrierDismissible: true,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         title: Text('Select audio device'),
    //         content: SingleChildScrollView(
    //           child: Container(
    //             width: 100,
    //             height: 100,
    //             child: ListView.builder(
    //               itemCount: devices.length,
    //               itemBuilder: (_, int index) {
    //                 return FlatButton(
    //                   child: Text(
    //                     _getNameForDevice(devices[index]),
    //                     style: TextStyle(fontSize: 16),
    //                   ),
    //                   onPressed: () {
    //                     _selectAudioDevice(devices[index]);
    //                   },
    //                 );
    //               },
    //             ),
    //           ),
    //         ),
    //       );
    //     },
    //   );
    // }

    return BlocListener<ActiveCallBloc, ActiveCallState>(
      listener: (context, state) {
        if (state is CallEndedActiveCallState) {
          state.failed
              ? Navigator.of(context).pushReplacementNamed(
                  AppRoutes.callFailed,
                  arguments: CallFailedPageArguments(
                    failureReason: state.callStatus,
                    endpoint: state.endpointName,
                  ),
                )
              : Navigator.of(context).pushReplacementNamed(AppRoutes.main);
        } else {
          _localVideoViewController.streamId = state.localVideoStreamID;
          _remoteVideoViewController.streamId = state.remoteVideoStreamID;
        }
        state.callStatus == 'Connected'
            ? callTimeOut()
            : print(
                'HUsssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss ${state.callStatus}');
      },
      child: BlocBuilder<ActiveCallBloc, ActiveCallState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: VoximplantColors.grey,
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topCenter,
                            child: Widgets.timerLabel(text: _timeLeft),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: AspectRatio(
                              aspectRatio: _remoteVideoAspectRatio,
                              child: VIVideoView(_remoteVideoViewController),
                            ),
                          ),
                          Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  height:
                                      MediaQuery.of(context).size.height / 4,
                                  child: Align(
                                    child: AspectRatio(
                                      aspectRatio: _localVideoAspectRatio,
                                      child: VIVideoView(
                                          _localVideoViewController),
                                    ),
                                  ),
                                ),
                              )),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 20, top: 20),
                              child: Widgets.iconButton(
                                icon: Icons.switch_camera,
                                color: VoximplantColors.button,
                                tooltip: 'Switch camera',
                                onPressed: _switchCamera,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              state.callStatus,
                              style: TextStyle(color: VoximplantColors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Widgets.iconButton(
                                icon: state.isMuted ? Icons.mic : Icons.mic_off,
                                color: VoximplantColors.button,
                                tooltip: state.isMuted ? 'Unmute' : 'Mute',
                                onPressed: () {
                                  _mute(!state.isMuted);
                                }),
                            Widgets.iconButton(
                                icon: state.isOnHold
                                    ? Icons.play_arrow
                                    : Icons.pause,
                                color: VoximplantColors.button,
                                tooltip: state.isOnHold ? 'Resume' : 'Hold',
                                onPressed: () {
                                  _hold(!state.isOnHold);
                                }),
                            Widgets.iconButton(
                                icon: state.localVideoStreamID != null
                                    ? Icons.videocam_off
                                    : Icons.videocam,
                                color: VoximplantColors.button,
                                tooltip: 'Send video',
                                onPressed: () {
                                  _sendVideo(state.localVideoStreamID == null);
                                }),
                            Widgets.iconButton(
                                icon: Icons.call_end,
                                color: VoximplantColors.red,
                                tooltip: 'Hang up',
                                onPressed: _hangup),
                            // Padding(
                            //   padding: const EdgeInsets.only(
                            //     bottom: 20,
                            //   ),
                            //   child: Ink(
                            //     decoration: ShapeDecoration(
                            //       color: VoximplantColors.white,
                            //       shape: CircleBorder(
                            //         side: BorderSide(
                            //           width: 2,
                            //           color: VoximplantColors.button,
                            //           style: BorderStyle.solid,
                            //         ),
                            //       ),
                            //     ),
                            //     child: IconButton(
                            //       onPressed: () {
                            //         print(state.availableAudioDevices);
                            //         _showAvailableAudioDevices(
                            //           state.availableAudioDevices,
                            //         );
                            //       },
                            //       iconSize: 40,
                            //       icon: Icon(
                            //         _getIconForDevice(state.activeAudioDevice),
                            //         color: VoximplantColors.button,
                            //       ),
                            //       tooltip: 'Select audio device',
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
