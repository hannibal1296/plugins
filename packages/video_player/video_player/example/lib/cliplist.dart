import 'dart:developer' as dev;

///
const int INTRO = 1;

///
const int WAIT = 2;

///
const int COUNT = 3;

///
const int POKE = 4;

///
const int DONE = 5;

var _clipTypeList = ['', 'Intro', 'WAIT', 'COUNT', 'POKE', 'DONE'];

class _VideoClip {
  int st;
  int end;
  String desc;

  _VideoClip(this.st, this.end, this.desc);
}

class _BaseVideoClipList {
  void addVideoClip(_VideoClip clip) {}

  _VideoClip next() {
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

class _IntroClipList implements _BaseVideoClipList {
  int index;
  List<_VideoClip> clips;

  _IntroClipList() {
    this.index = -1;
    this.clips = List();
  }

  void addVideoClip(_VideoClip clip) {
    this.clips.add(clip);
  }

  void skip() {
    this.index = this.clips.length - 1;
    if (this.index == -1) {
      dev.log('The length of intro clips is 0.');
      return;
    }
  }

  _VideoClip getCurrent() {
    if (this.isFirst()) {
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

  // _IntroClipList.next() returns null if it's the end of the list.
  _VideoClip next() {
    if (this.isLast()) {
      return null;
    }
    this.increaseIndex();
    return this.clips[this.index];
  }
}

class _CountClipList implements _BaseVideoClipList {
  int index;
  List<_VideoClip> clips;

  _CountClipList() {
    this.index = -1;
    this.clips = List();
  }

  void addVideoClip(_VideoClip clip) {
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

  _VideoClip next() {
    if (this.isLast()) {
      return null;
    }
    this.increaseIndex();
    return this.clips[this.index];
  }
}

class _WaitClipList implements _BaseVideoClipList {
  int index;
  List<_VideoClip> clips;

  _WaitClipList() {
    this.index = -1;
    this.clips = List();
  }

  void addVideoClip(_VideoClip clip) {
    this.clips.add(clip);
  }

  // If _index is invalid, it returns null.
  _VideoClip get(int _index) {
    return _index < this.clips.length ? this.clips[_index] : null;
  }

  // _WaitClipList iterates repetitively.
  void increaseIndex() {
    this.index = (this.index + 1) % this.clips.length;
  }

  bool isFirst() {
    return this.index == -1 ? true : false;
  }

  bool isLast() {
    return this.index == this.clips.length - 1 ? true : false;
  }

  _VideoClip next() {
    this.increaseIndex();
    return this.clips[this.index];
  }
}

class _PokeClipList implements _BaseVideoClipList {
  int index;
  List<_VideoClip> clips;

  _PokeClipList() {
    this.index = -1;
    this.clips = List();
  }

  void addVideoClip(_VideoClip clip) {
    this.clips.add(clip);
  }

  _VideoClip getCurrent() {
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

  _VideoClip next() {
    this.increaseIndex();
    return this.clips[this.index];
  }
}

class _WellDoneClipList implements _BaseVideoClipList {
  int index;
  List<_VideoClip> clips;

  _WellDoneClipList() {
    this.index = -1;
    this.clips = List();
  }

  void addVideoClip(_VideoClip clip) {
    this.clips.add(clip);
  }

  _VideoClip getCurrent() {
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

  _VideoClip next() {
    if (this.isLast()) {
      return null;
    }
    this.increaseIndex();
    return this.clips[this.index];
  }
}

/// WorkOutCourse
class WorkOutCourse {
  _IntroClipList _introClips;
  _WaitClipList _waitClips;
  _PokeClipList _pokeClips;
  _CountClipList _countClips;
  _WellDoneClipList _wellDoneClips;

  _VideoClip _currentClip;
  int _currentClipType;

  ///
  int getCurrentClipType() {
    return this._currentClipType;
  }

  /// Initialization
  WorkOutCourse() {
    this._introClips = _IntroClipList();
    this._waitClips = _WaitClipList();
    this._pokeClips = _PokeClipList();
    this._countClips = _CountClipList();
    this._wellDoneClips = _WellDoneClipList();

    this._currentClip = null;
    this._currentClipType = INTRO;
  }

  ///
  _VideoClip getCurrentClip() {
    return this._currentClip;
  }

  /// Set up the first intro to currentClip.
  void readyIntro() {
    // this._currentClipType = INTRO;
    // this._introClips.index = -1;
    // this._currentClip = null;
    // this.next(false);

    this._currentClipType = INTRO;
    this._introClips.index = -1;
    this._currentClip = this._introClips.next();
  }

  /// Skip the intro.
  void skipIntro() {
    this._introClips.skip();
    this._countClips.index = -1;
  }

  /// Add a videoClip
  void addClip(int clipType, int st, int end, String desc) {
    switch (clipType) {
      case INTRO:
        this._introClips.addVideoClip(_VideoClip(st, end, desc));
        break;
      case WAIT:
        this._waitClips.addVideoClip(_VideoClip(st, end, desc));
        break;
      case COUNT:
        this._countClips.addVideoClip(_VideoClip(st, end, desc));
        break;
      case POKE:
        this._pokeClips.addVideoClip(_VideoClip(st, end, desc));
        break;

      default:
        this._wellDoneClips.addVideoClip(_VideoClip(st, end, desc));
        break;
    }
  }

  /// Reset indice of clips.
  void rewind() {
    this._waitClips.index = -1;
    this._pokeClips.index = -1;
    this._countClips.index = -1;
    this._wellDoneClips.index = -1;

    this._introClips.index = -1;
    this._currentClipType = INTRO;
    this._currentClip = null;
    this._currentClip = this._introClips.clips[0];

    // this.readyIntro();
    // this._currentClipType = INTRO;
    // this._introClips.index = -1;
    // this._currentClip = null;
  }

  /// Return null when it's done.
  _VideoClip next(bool counted) {
    dev.log(
        '[Start] _VideoClip.next | type: ${_clipTypeList[this._currentClipType]} | counted: $counted');

    switch (this._currentClipType) {
      case INTRO:
        if (this._introClips.isLast()) {
          this._currentClipType = COUNT;

          // not null; intro to count
          return this._currentClip = this._countClips.next();
        }
        dev.log('[next] intro to intro');
        return this._currentClip = this._introClips.next(); // intro to intro

      case COUNT:
        if (this._currentClip == null) {
          // DONE
          return this._currentClip = this._wellDoneClips.next();
        }
        if (!counted) {
          this._currentClipType = WAIT;
          dev.log('[next] count to wait');
          return this._currentClip = this._waitClips.next(); // count to wait
        }
        if (this._countClips.isLast()) {
          dev.log('[INFO] count is done');
          this._currentClipType = DONE;
          return this._currentClip =
              this._wellDoneClips.next(); // count to done
        }
        dev.log('[next] count to count');
        return this._currentClip = this._countClips.next(); // count to count

      case WAIT:
        if (!counted) {
          // 기다리는데 카운트 안 들어옴.
          this._currentClipType = POKE;
          this._currentClip = this._pokeClips.next();
          assert(this._currentClip != null);

          dev.log('[next] wait to poke');
          return this._currentClip; // wait to poke
        }

        this._currentClipType = COUNT;
        this._currentClip = this._countClips.next();
        if (_areCountClipsDone()) {
          dev.log('[next] wait to done');
          this._currentClipType = DONE;
          this.next(false);
        }
        dev.log('[next] wait to count');
        return this._currentClip; // wait to count

      case POKE:
        if (counted) {
          this._currentClipType = COUNT;
          dev.log('[next] poke to count');
          this._currentClip = this._countClips.next();

          if (_areCountClipsDone()) {
            // DONE
            this._currentClipType = DONE;
            return this.next(false);
          }
          return this._currentClip;
        }
        this._currentClipType = WAIT;
        dev.log('[next] poke to wait');
        return this._currentClip = this._waitClips.next();

      default: // DONE
        if (this._wellDoneClips.isLast()) {
          return this._currentClip = null;
        }
        dev.log('[next] done to done');
        return this._currentClip = this._wellDoneClips.next();
    }
  }

  bool _areCountClipsDone() {
    return this._currentClip == null;
  }
}
