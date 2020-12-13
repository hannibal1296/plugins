// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'dart:developer' as dev;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'cliplist.dart' as clip;

void main() {
  runApp(
    MaterialApp(
      home: _App(),
    ),
  );
}

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _WorkoutDemoVideo(),
      backgroundColor: Colors.black,
    );
  }
}

class _WorkoutDemoVideo extends StatefulWidget {
  @override
  _WorkoutDemoVideoState createState() => _WorkoutDemoVideoState();
}

class _WorkoutDemoVideoState extends State<_WorkoutDemoVideo> {
  clip.WorkOutCourse workoutCourse;
  bool counted;
  bool isPlaying;
  bool isIntroSkipped;
  bool clipInSeeking;
  String playbackButton;
  int sizeOfSeq = 9;
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    // no status bar in android
    SystemChrome.setEnabledSystemUIOverlays([]);

    initProgram();
  }

  // initProgram initiates the program.
  // Set up course variables and controller.
  void initProgram() {
    isIntroSkipped = false;
    counted = false;
    clipInSeeking = false;
    isPlaying = false;
    playbackButton = "시작";

    initWorkOutCourse();
    initController();
  }

  void videoControllerListener() {
    if (isClipDone(workoutCourse)) {
      if (clipInSeeking) {
        dev.log('[INFO | isClipDone] In seek now');
        return;
      }
      setState(() {
        clipInSeeking = true;
        var clip = workoutCourse.next(counted);
        if (clip == null) {
          return;
        }
        counted = false;
        dev.log('[${DateTime.now()} | seek] ${clip.st} msec',
            time: DateTime.now());
        _controller.seekTo(Duration(milliseconds: clip.st));
        clipInSeeking = false;
      });
    } else if (workoutCourse.getCurrentClipType() == clip.WAIT && counted) {
      clipInSeeking = true;
      // dev.log('[${DateTime.now()} | Listener] clip done');
      var clip = workoutCourse.next(counted);

      if (clip != null) {
        counted = false;
        dev.log('[${DateTime.now()} | seek] ${clip.st} msec',
            time: DateTime.now());
        _controller.seekTo(Duration(milliseconds: clip.st));
        clipInSeeking = false;
      }
    }
  }

  void initController() {
    _controller = VideoPlayerController.asset('assets/PushUpEditedLow.mp4');
    _controller.addListener(videoControllerListener);

    _controller.setLooping(false);
    _controller.initialize().then((_) => setState(() {}));
  }

  bool isClipDone(clip.WorkOutCourse workoutCourse) {
    if (workoutCourse.getCurrentClip() == null) {
      dev.log('currentClip null');
      return false;
    }
    int pos = _controller.value.position.inMilliseconds;
    int end = workoutCourse.getCurrentClip().end;
    // dev.log('[pos vs end] $pos vs $end');
    return (pos - end).abs() <= 500;
  }

  // Four things to init: Intro, Count, Poke, and Wait.
  // This is only for testing.
  void initWorkOutCourse() {
    workoutCourse = clip.WorkOutCourse();
    workoutCourse.addClip(clip.INTRO, 0, 47000, 'intro');

    workoutCourse.addClip(clip.COUNT, 47000, 51200, 'count 1');
    workoutCourse.addClip(clip.COUNT, 51200, 54450, 'count 2');
    workoutCourse.addClip(clip.COUNT, 54450, 57700, 'count 3');
    workoutCourse.addClip(clip.COUNT, 57700, 61000, 'count 4');
    workoutCourse.addClip(clip.COUNT, 61000, 65000, 'count 5');

    workoutCourse.addClip(clip.POKE, 67000, 71000, 'poke 1');
    workoutCourse.addClip(clip.POKE, 71000, 75000, 'poke 2');
    workoutCourse.addClip(clip.POKE, 75000, 78000, 'poke 3');
    workoutCourse.addClip(clip.POKE, 78000, 82000, 'poke 4');
    workoutCourse.addClip(clip.POKE, 82000, 88000, 'poke 5');

    workoutCourse.addClip(clip.DONE, 88000, 93000, 'welldone');

    workoutCourse.addClip(clip.WAIT, 65000, 67000, 'wait');

    workoutCourse.readyIntro();
  }

  void rewindCourse() {
    clipInSeeking = true;
    isIntroSkipped = false;
    counted = false;
    workoutCourse.rewind();
    _controller.seekTo(Duration(microseconds: 0));
    clipInSeeking = false;
    return;
  }

  /// Column > AspectRatio > Stack > {VideoPlayer, Container}
  /// > Row > {4 * Expanded > FlatButton > Center > Text > TextStyle }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: _contentLayer(),
          ),
        ),
      ],
    );
  }

  Stack _contentLayer() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        VideoPlayer(_controller),

        // Control panel
        _controlPanel(),
      ],
    );
  }

  Container _controlPanel() {
    return Container(
      height: 50,
      child: _controlPanelRow(),
    );
  }

  Row _controlPanelRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _backToStartButton(),
        ),
        Expanded(
          child: _introSkipButton(),
        ),
        Expanded(
          child: _startButton(),
        ),
        Expanded(
          child: _countButton(),
        ),
      ],
    );
  }

  FlatButton _backToStartButton() {
    return FlatButton(
      onPressed: () {
        setState(() => {
              rewindCourse(),
            });
      },
      child: Center(
        child: _whiteCenterAlignedText('처음부터'),
      ),
    );
  }

  FlatButton _introSkipButton() {
    return FlatButton(
      // skip button
      onPressed: () {
        if (isIntroSkipped) {
          dev.log('Already skipped.');
          return;
        }
        isIntroSkipped = true;
        counted = false;
        workoutCourse.skipIntro();
        var tmp = workoutCourse.next(counted);

        setState(() {
          if (!clipInSeeking) {
            clipInSeeking = true;
            dev.log('[${DateTime.now()} | seek] ${tmp.st} msec',
                time: DateTime.now());
            _controller.seekTo(Duration(milliseconds: tmp.st));
            clipInSeeking = false;
          }
        });
      },
      child: Center(
        child: _whiteCenterAlignedText('인트로\n스킵하기'),
      ),
    );
  }

  FlatButton _startButton() {
    return FlatButton(
      onPressed: () => {
        dev.log("$playbackButton button touched."),
        setState(() => {
              if (isPlaying) {_controller.pause()} else {_controller.play()},
              isPlaying = isPlaying ? false : true,
              playbackButton = isPlaying ? "정지" : "시작"
            })
      },
      child: Center(
        child: _whiteCenterAlignedText(playbackButton),
      ),
    );
  }

  FlatButton _countButton() {
    return FlatButton(
      onPressed: () => {
        setState(() => {
              counted = true,
              print('\a'),
            })
      },
      child: Center(
        child: _whiteCenterAlignedText("카운트"),
      ),
    );
  }

  Text _whiteCenterAlignedText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
