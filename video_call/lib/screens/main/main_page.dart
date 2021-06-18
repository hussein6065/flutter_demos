import 'dart:async';

/// Copyright (c) 2011-2020, Zingaya, Inc. All rights reserved.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_call/screens/active_call/active_call.dart';
import 'package:video_call/screens/incoming_call/incoming_call.dart';
import 'package:video_call/utils/navigation_helper.dart';
import 'package:video_call/widgets/widgets.dart';

import 'bloc/main_bloc.dart';
import 'bloc/main_event.dart';
import 'bloc/main_state.dart';

class MainPage extends StatefulWidget {
  static const routeName = '/main';

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  MainBloc _bloc;

  var timeout = Duration(seconds: 3);
  var ms = Duration(milliseconds: 1);
  var calltime = Duration(seconds: 90);
  String timeLeft = '00:00';

  Timer startTimeout(int milliseconds) {
    var duration = Duration(seconds: 1);
    // var timer = Timer(duration, _handleTimeout);
    return Timer.periodic(duration, (timer) {
      int tim = calltime.inSeconds - timer.tick;
      var t = Duration(seconds: tim).toString().split(RegExp(r"[:.]"));
      tim == 0
          ? timer.cancel()
          : setState(() {
              timeLeft = "${t[1]}:${t[2]}";
            });
      // print(timer.tick);
    });
  }

  void _handleTimeout() {
    var time = DateTime.now().second;
    // print('Hussein $time');
    setState(() {
      _callToController.text = 'Hussein $time';
    });
  }

  final _callToController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<MainBloc>(context);
    WidgetsBinding.instance.addObserver(this);
    startTimeout(5000);
  }

  @override
  void dispose() {
    _callToController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _isInactive = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused && Platform.isIOS) {
      _isInactive = true;
    }

    if (state == AppLifecycleState.resumed && Platform.isIOS) {
      if (_isInactive) {
        _bloc.add(Reconnect());
        _isInactive = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void _makeVideoCall() {
      if (_callToController.text == '') {
        return;
      }
      _bloc.add(CheckPermissionsForCall());
    }

    void _logout() => _bloc.add(LogOut());

    void _showPermissionCheckError() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Permissions missing'),
            content: Text(
                'Please give "record audio" and "camera" permissions to make calls'),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }

    return BlocListener<MainBloc, MainState>(
      listener: (context, state) {
        if (state is LoggedOut) {
          if (state.networkIssues) {
            if (!_isInactive) {
              _bloc.add(Reconnect());
            }
          } else {
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          }
        }
        if (state is PermissionCheckSuccess) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.activeCall,
            arguments: ActiveCallPageArguments(
                isIncoming: false, endpoint: _callToController.text),
          );
        }
        if (state is PermissionCheckFail) {
          _showPermissionCheckError();
        }
        if (state is IncomingCall) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.incomingCall,
            arguments: IncomingCallPageArguments(endpoint: state.caller),
          );
        }
        if (state is ReconnectFailed) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        }
      },
      child: BlocBuilder<MainBloc, MainState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Voximplant'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: _logout,
                )
              ],
            ),
            body: SafeArea(
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Widgets.textWithPadding(text: timeLeft),
                          Widgets.timerLabel(text: timeLeft),
                          Widgets.textFormField(
                            controller: _callToController,
                            darkBackground: false,
                            labelText: 'user or number',
                          ),
                          Widgets.maxWidthRaisedButton(
                            text: 'Video call',
                            onPressed: _makeVideoCall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        state.myDisplayName != null &&
                                state.myDisplayName.isNotEmpty
                            ? 'Logged in as ${state.myDisplayName}'
                            : '',
                      ),
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
