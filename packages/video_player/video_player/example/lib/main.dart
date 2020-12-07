// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

import 'dart:developer' as dev;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoClip {
  int st;
  int end;
  String desc;

  VideoClip(this.st, this.end, this.desc);
}

class BaseVideoClipList {
  void addVideoClip(VideoClip clip) {}

  VideoClip next() {
    return null;
  }

  void increaseIndex() {}

  // Is it at the first index?
  bool isFirst() {
    return false;
  }

  // Is it at the last index?
  bool isLast() {
    return false;
  }
}

class IntroClipList implements BaseVideoClipList {
  int index;
  List<VideoClip> clips;

  IntroClipList() {
    this.index = -1;
    this.clips = List();
  }

  void addVideoClip(VideoClip clip) {
    this.clips.add(clip);
  }

  VideoClip getCurrent() {
    return this.clips[this.index];
  }

  void increaseIndex() {
    if (!this.isLast()) {
      this.index++;
    }
  }

  bool isFirst() {
    return this.index == -1 ? true : false;
  }

  bool isLast() {
    return this.index == this.clips.length - 1 ? true : false;
  }

  // IntroClipList.next() returns null if it's the end of the list.
  VideoClip next() {
    if (this.isLast()) {
      return null;
    }
    this.increaseIndex();
    return this.clips[this.index];
  }
}

class CountClipList implements BaseVideoClipList {
  int index;
  List<VideoClip> clips;

  CountClipList() {
    this.index = -1;
    this.clips = List();
  }

  void addVideoClip(VideoClip clip) {
    this.clips.add(clip);
  }

  void increaseIndex() {
    if (!this.isLast()) {
      this.index++;
    }
  }

  bool isFirst() {
    return this.index == -1 ? true : false;
  }

  bool isLast() {
    return this.index == this.clips.length - 1 ? true : false;
  }

  VideoClip next() {
    if (this.isLast()) {
      return null;
    }
    this.increaseIndex();
    return this.clips[this.index];
  }
}

class WaitClipList implements BaseVideoClipList {
  int index;
  List<VideoClip> clips;

  WaitClipList() {
    this.index = -1;
    this.clips = List();
  }

  void addVideoClip(VideoClip clip) {
    this.clips.add(clip);
  }

  // If _index is invalid, it returns null.
  VideoClip get(int _index) {
    return _index < this.clips.length ? this.clips[_index] : null;
  }

  // WaitClipList iterates repetitively.
  void increaseIndex() {
    this.index = (this.index + 1) % this.clips.length;
  }

  bool isFirst() {
    return this.index == -1 ? true : false;
  }

  bool isLast() {
    return this.index == this.clips.length - 1 ? true : false;
  }

  VideoClip next() {
    this.increaseIndex();
    return this.clips[this.index];
  }
}

class PokeClipList implements BaseVideoClipList {
  int index;
  List<VideoClip> clips;

  PokeClipList() {
    this.index = -1;
    this.clips = List();
  }

  void addVideoClip(VideoClip clip) {
    this.clips.add(clip);
  }

  VideoClip getCurrent() {
    if (this.index == -1) {
      return null;
    }
    return this.clips[this.index];
  }

  void increaseIndex() {
    this.index = (this.index + 1) % this.clips.length;
  }

  bool isFirst() {
    return this.index == -1 ? true : false;
  }

  bool isLast() {
    return this.index == this.clips.length - 1 ? true : false;
  }

  VideoClip next() {
    this.increaseIndex();
    return this.clips[this.index];
  }
}

class WellDoneClipList implements BaseVideoClipList {
  int index;
  List<VideoClip> clips;

  WellDoneClipList() {
    this.index = -1;
    this.clips = List();
  }

  void addVideoClip(VideoClip clip) {
    this.clips.add(clip);
  }

  VideoClip getCurrent() {
    if (this.index == -1) {
      return null;
    }
    return this.clips[this.index];
  }

  void increaseIndex() {
    if (!this.isLast()) {
      this.index++;
    }
  }

  bool isFirst() {
    return this.index == -1 ? true : false;
  }

  bool isLast() {
    return this.index == this.clips.length - 1 ? true : false;
  }

  VideoClip next() {
    if (this.isLast()) {
      return null;
    }
    this.increaseIndex();
    return this.clips[this.index];
  }
}

const int INTRO = 1;
const int WAIT = 2;
const int COUNT = 3;
const int POKE = 4;
const int DONE = 5;

class WorkOutCourse {
  IntroClipList introClips;
  WaitClipList waitClips;
  PokeClipList pokeClips;
  CountClipList countClips;
  WellDoneClipList wellDoneClips;

  VideoClip currentClip;
  int currentClipType;

  WorkOutCourse() {
    this.introClips = IntroClipList();
    this.waitClips = WaitClipList();
    this.pokeClips = PokeClipList();
    this.countClips = CountClipList();
    this.wellDoneClips = WellDoneClipList();

    this.currentClip = null;
    this.currentClipType = INTRO;
  }

  // Return null when it's done.
  VideoClip next(bool counted) {
    switch (this.currentClipType) {
      case INTRO:
        if (this.introClips.isLast()) {
          this.currentClipType = COUNT;
          return currentClip = this.countClips.next(); // intro to count
        }
        return currentClip = this.introClips.next(); // intro to intro

      case COUNT:
        if (!counted) {
          this.currentClipType = WAIT;
          return currentClip = this.waitClips.next(); // count to wait
        }
        // 여기부턴 counted
        if (this.countClips.isLast()) {
          this.currentClipType = DONE;
          return currentClip = this.wellDoneClips.next(); // count to done
        }
        return currentClip = this.countClips.next(); // count to count

      case WAIT:
        if (!counted) {
          // 기다리는데 카운트 안 들어옴.
          return currentClip = this.pokeClips.next(); // wait to poke
        }
        this.currentClipType = COUNT;
        return currentClip = this.countClips.next(); // wait to count

      case POKE:
        if (counted) {
          this.currentClipType = COUNT;
          return currentClip = this.countClips.next();
        }
        this.currentClipType = WAIT;
        return currentClip = this.waitClips.next();

      default: // DONE
        this.currentClipType = DONE;
        if (this.wellDoneClips.isLast()) {
          return currentClip = null;
        }
        return currentClip = this.wellDoneClips.next();
    }
  }
}

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
    );
  }
}

class _WorkoutDemoVideo extends StatefulWidget {
  @override
  _WorkoutDemoVideoState createState() => _WorkoutDemoVideoState();
}

class _WorkoutDemoVideoState extends State<_WorkoutDemoVideo> {
  WorkOutCourse workoutCourse;
  bool counted;
  bool isPlaying;
  bool isIntro;
  String playbackButton;
  int sizeOfSeq = 9;
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    initWorkOutCourse();

    isIntro = true;
    counted = false;
    isPlaying = false;
    playbackButton = "시작";
    _controller = VideoPlayerController.asset('assets/PushUpDemoEdited.mp4');
    _controller.addListener(() {
      if (isClipDone()) {
        var clip = workoutCourse.next(counted);
        if (clip == null) {
          _controller.pause(); // done
          return;
        }
        counted = false;
        _controller.seekTo(Duration(milliseconds: clip.st));
      }
    });
    _controller.setLooping(false);
    _controller.initialize().then((_) => setState(() {}));
  }

  bool isClipDone() {
    if (workoutCourse.currentClip == null) {
      return false;
    }

    return _controller.value.position.inMilliseconds >=
        workoutCourse.currentClip.end;
  }

  // Four things to init: Intro, Count, Poke, and Wait.
  void initWorkOutCourse() {
    workoutCourse = WorkOutCourse();
    workoutCourse.introClips.addVideoClip(VideoClip(0, 47000, 'Intro 1'));
    workoutCourse.currentClip = workoutCourse.introClips.next();

    workoutCourse.countClips.addVideoClip(VideoClip(47000, 51000, 'Count 1'));
    workoutCourse.countClips.addVideoClip(VideoClip(51000, 54000, 'Count 2'));
    workoutCourse.countClips.addVideoClip(VideoClip(54000, 58000, 'Count 3'));
    workoutCourse.countClips.addVideoClip(VideoClip(58000, 60000, 'Count 4'));
    workoutCourse.countClips.addVideoClip(VideoClip(60000, 64000, 'Count 5'));

    workoutCourse.pokeClips.addVideoClip(VideoClip(67000, 71000, 'Poke 1'));
    workoutCourse.pokeClips.addVideoClip(VideoClip(71000, 75000, 'Poke 2'));
    workoutCourse.pokeClips.addVideoClip(VideoClip(75000, 78000, 'Poke 3'));
    workoutCourse.pokeClips.addVideoClip(VideoClip(78000, 82000, 'Poke 4'));
    workoutCourse.pokeClips.addVideoClip(VideoClip(82000, 86000, 'Poke 5'));

    workoutCourse.waitClips.addVideoClip(VideoClip(64000, 66000, 'Wait'));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 20.0),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                ],
              ),
            ),
          ),
          Row(
            children: [
              FlatButton(
                onPressed: () {
                  counted = false;
                  workoutCourse.currentClipType = COUNT;
                  var tmp = workoutCourse.countClips.next();
                  dev.log('${tmp.st}, ${tmp.end}');
                  _controller.seekTo(Duration(milliseconds: tmp.st));
                },
                child: Center(
                  child: Text("인트로 스킵하기"),
                ),
              ),
              FlatButton(
                onPressed: () => {
                  dev.log("$playbackButton button touched."),
                  if (isPlaying)
                    {_controller.pause()}
                  else
                    {_controller.play()},
                  setState(() => {
                        isPlaying = isPlaying ? false : true,
                        playbackButton = isPlaying ? "정지" : "시작"
                      })
                },
                child: Center(
                  child: Text(playbackButton),
                ),
              ),
              FlatButton(
                onPressed: () => {setState(() => counted = true)},
                child: Center(
                  child: Text("카운트"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
