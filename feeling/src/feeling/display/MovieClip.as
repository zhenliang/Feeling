package feeling.display
{
    import feeling.animation.IAnimatable;
    import feeling.events.Event;
    import feeling.textures.Texture;

    /** A MovieClip is a simple way to display an animation depicted by a list of textures.
    *
    *  <p>Pass the frames of the movie in a vector of textures to the constructor. The movie clip
    *  will have the width and height of the first frame. If you group your frames with the help
    *  of a texture atlas (which is recommended), use the <code>getTextures</code>-method of the
    *  atlas to receive the textures in the correct (alphabetic) order.</p>
    *
    *  <p>You can specify the desired framerate via the constructor. You can, however, manually
    *  give each frame a custom duration. You can also play a sound whenever a certain frame
    *  appears.</p>
    *
    *  <p>The methods <code>play</code> and <code>pause</code> control playback of the movie. You
    *  will receive an event of type <code>Event.MovieCompleted</code> when the movie finished
    *  playback. If the movie is looping, the event is dispatched once per loop.</p>
    *
    *  <p>As any animated object, a movie clip has to be added to a juggler (or have its
    *  <code>advanceTime</code> method called regularly) to run.</p>
    *
    *  @see starling.textures.TextureAtlas
    */
    public class MovieClip extends Image implements IAnimatable
    {
        private var _textures:Vector.<Texture>;
        private var _durations:Vector.<Number>;

        private var _defaultFrameDuration:Number;
        private var _totalTime:Number;
        private var _currentTime:Number;
        private var _currentFrame:int;
        private var _loop:Boolean;
        private var _playing:Boolean;

        /** Creates a moviclip from the provided textures and with the specified default framerate.
         *  The movie will have the size of the first frame. */
        public function MovieClip(textures:Array, fps:Number = 12)
        {
            if (textures && textures.length)
            {
                super(textures[0]);

                _defaultFrameDuration = 1.0 / fps;
                _loop = true;
                _playing = true;
                _totalTime = 0.0;
                _currentTime = 0.0;
                _currentFrame = 0;
                _textures = new <Texture>[];
                _durations = new <Number>[];

                for each (var texture:Texture in textures)
                    addFrame(texture);
            }
            else
                throw new Error("");
        }

        // frame manipulation

        /** Adds an additional frame, optionally with a sound and a custom duration. If the
         *  duration is omitted, the default framerate is used (as specified in the constructor). */
        public function addFrame(texture:Texture, duration:Number = -1):void
        {
            addFrameAt(numFrames, texture, duration);
        }

        /** Adds a frame at a certain index, optionally with a sound and a custom duration. */
        public function addFrameAt(frameId:int, texture:Texture, duration:Number = -1):void
        {
            if ((frameId < 0) || (frameId > numFrames))
                throw new Error();

            if (duration < 0)
                duration = _defaultFrameDuration;

            _textures.splice(frameId, 0, texture);
            _durations.splice(frameId, 0, duration);

            _totalTime += duration;
        }

        /** Removes the frame at a certain ID. The successors will move down. */
        public function removeFrameAt(frameId:int):void
        {
            if ((frameId < 0) || (frameId >= numFrames))
                throw new Error();

            _textures.splice(frameId, 1);
            _durations.splice(frameId, 1);
        }

        /** Returns the texture of a certain frame. */
        public function getFrameTexture(frameId:int):Texture
        {
            if ((frameId < 0) || (frameId >= numFrames))
                throw new Error();
            return _textures[frameId];
        }

        /** Sets the texture of a certain frame. */
        public function setFrameTexture(frameId:int, texture:Texture):void
        {
            if ((frameId < 0) || (frameId >= numFrames))
                throw new Error();
            _textures[frameId] = texture;
        }

        /** Returns the duration of a certain frame (in seconds). */
        public function getFrameDuration(frameId:int):Number
        {
            if ((frameId < 0) || (frameId >= numFrames))
                throw new Error();
            return _durations[frameId];
        }

        /** Sets the duration of a certain frame (in seconds). */
        public function setFrameDuration(frameId:int, duration:Number):void
        {
            if ((frameId < 0) || (frameId >= numFrames))
                throw new Error();

            _totalTime += duration;
            _durations[frameId] = duration;
        }

        // helper methods

        private function updateCurrentFrame():void
        {
            texture = _textures[_currentFrame];
        }

        // playback methods

        /** Starts playback. Beware that the clip has to be added to a juggler, too! */
        public function play():void
        {
            _playing = true;
        }

        /** Pauses playback. */
        public function pause():void
        {
            _playing = false;
        }

        /** Stops playback, resetting "currentFrame" to zero. */
        public function stop():void
        {
            _playing = false;
            currentFrame = 0;
        }

        // IAnimatable

        /** @inheritDoc */
        public function advanceTime(passedTime:Number):void
        {
            if (_loop && (_currentTime == _totalTime))
                _currentTime = 0.0;

            if (!_playing || (passedTime == 0.0) || (_currentTime == _totalTime))
                return;

            var i:int = 0;
            var durationSum:Number = 0.0;
            var previousTime:Number = _currentTime;
            var restTime:Number = _totalTime - _currentTime;
            var carryOverTime:Number = (passedTime > restTime) ? (passedTime - restTime) : 0.0;
            _currentTime = Math.min(_totalTime, _currentTime + passedTime);

            for each (var duration:Number in _durations)
            {
                if ((durationSum + duration) >= _currentTime)
                {
                    if (_currentFrame != i)
                    {
                        _currentFrame = i;
                        updateCurrentFrame();
                    }

                    break;
                }

                ++i;

                durationSum += duration;
            }

            if ((previousTime < _totalTime) && (_currentTime == _totalTime) && hasEventListener(Event.MOVIE_COMPLETED))
            {
                dispatchEvent(new Event(Event.MOVIE_COMPLETED));
            }

            advanceTime(carryOverTime);
        }

        /** Always returns <code>false</code>. */
        public function get isComplete():Boolean
        {
            // 返回真会被 Juggler 删除，所以这里的意义并不是播放完毕，而是完成使命
            return false;
        }

        // properties

        /** The total duration of the clip in seconds. */
        public function get totalTime():Number  { return _totalTime; }

        /** The total number of frames. */
        public function get numFrames():int  { return _textures.length; }

        /** Indicates if the clip should loop. */
        public function get loop():Boolean  { return _loop; }
        public function set loop(value:Boolean):void  { _loop = value; }

        /** The index of the frame that is currently displayed. */
        public function get currentFrame():int  { return _currentFrame; }
        public function set currentFrame(value:int):void
        {
            _currentFrame = value;
            _currentTime = 0.0;

            for each (var duration:Number in _durations)
                _currentTime += duration;

            updateCurrentFrame();
        }

        /** The default number of frames per second. Individual frames can have different
         *  durations. If you change the fps, the durations of all frames will be scaled
         *  relatively to the previous value. */
        public function get fps():Number  { return 1.0 / _defaultFrameDuration; }
        public function set fps(value:Number):void
        {
            var newFrameDuration:Number = (value == 0.0) ? Number.MAX_VALUE : (1.0 / value);
            var acceleration:Number = newFrameDuration / _defaultFrameDuration;
            _currentTime *= acceleration;
            _defaultFrameDuration = newFrameDuration;

            for (var i:int = 0; i < numFrames; ++i)
                setFrameDuration(1, getFrameDuration(i) * acceleration);
        }

        /** Indicates if the clip is still playing. Returns <code>false</code> when the end
         *  is reached. */
        public function get isPlaying():Boolean
        {
            if (_playing)
                return _loop || (_currentTime < _totalTime);
            else
                return false;
        }
    }
}
