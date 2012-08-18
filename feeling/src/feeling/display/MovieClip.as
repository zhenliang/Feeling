package feeling.display
{
    import feeling.animation.IAnimatable;
    import feeling.events.Event;
    import feeling.textures.Texture;

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

        public function MovieClip(textures:Array, fps:Number = 12)
        {
            if (texture && textures.length)
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

        public function addFrame(texture:Texture, duration:Number = -1):void
        {
            addFrameAt(numFrames, texture, duration);
        }

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

        public function removeFrameAt(frameId:int):void
        {
            if ((frameId < 0) || (frameId >= numFrames))
                throw new Error();

            _textures.splice(frameId, 1);
            _durations.splice(frameId, 1);
        }

        public function getFrameTexture(frameId:int):Texture
        {
            if ((frameId < 0) || (frameId >= numFrames))
                throw new Error();
            return _textures[frameId];
        }

        public function setFrameTexture(frameId:int, texture:Texture):void
        {
            if ((frameId < 0) || (frameId >= numFrames))
                throw new Error();
            _textures[frameId] = texture;
        }

        public function getFrameDuration(frameId:int):Number
        {
            if ((frameId < 0) || (frameId >= numFrames))
                throw new Error();
            return _durations[frameId];
        }

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

        private function play():void
        {
            _playing = true;
        }

        public function pause():void
        {
            _playing = false;
        }

        public function stop():void
        {
            _playing = false;
            currentFrame = 0;
        }

        // IAnimatable

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

        public function get isComplete():Boolean
        {
            return false;
        }

        // properties

        public function get totalTime():Number  { return _totalTime; }
        public function get numFrames():int  { return _textures.length; }

        public function get loop():Boolean  { return _loop; }
        public function set loop(value:Boolean):void  { _loop = value; }

        public function get currentFrame():int  { return _currentFrame; }
        public function set currentFrame(value:int):void
        {
            _currentFrame = value;
            _currentTime = 0.0;

            for each (var duration:Number in _durations)
                _currentTime += duration;

            updateCurrentFrame();
        }

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

        public function get isPlaying():Boolean
        {
            if (_playing)
                return _loop || (_currentTime < _totalTime);
            else
                return false;
        }
    }
}
