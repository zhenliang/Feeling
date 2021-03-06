package feeling.events
{
    import feeling.display.DisplayObject;
    import feeling.display.DisplayObjectContainer;
    import feeling.display.Stage;

    import flash.geom.Point;

    /** @private
     *  The TouchProcessor is used internally to convert mouse and touch events of the conventional
     *  Flash stage to Starling's TouchEvents. */
    public class TouchProcessor
    {
        private static const MULTITAP_TIME:Number = 0.3;
        private static const MULTITAP_DISTANCE:Number = 25;

        private var _stage:Stage;
        private var _elapsedTime:Number;
        private var _touchMarker:TouchMarker;

        private var _currentTouches:Vector.<Touch>;
        private var _queue:Vector.<Array>;
        private var _lastTaps:Vector.<Touch>;

        private var _shiftDown:Boolean = false;
        private var _ctrlDown:Boolean = false;

        public function TouchProcessor(stage:Stage)
        {
            _stage = stage;
            _elapsedTime = 0.0;
            _currentTouches = new <Touch>[];
            _queue = new <Array>[];
            _lastTaps = new <Touch>[];

            _stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
            _stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
        }

        public function dispose():void
        {
            _stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKey);
            _stage.removeEventListener(KeyboardEvent.KEY_UP, onKey);
            if (_touchMarker)
                _touchMarker.dispose();
        }

        public function advanceTime(passedTime:Number):void
        {
            _elapsedTime += passedTime;

            // remove old taps
            if (_lastTaps.length)
            {
                _lastTaps = _lastTaps.filter(function(touch:Touch, ... rest):Boolean
                {
                    return ((_elapsedTime - touch.timestamp) <= MULTITAP_TIME);
                });
            }

            while (_queue.length)
            {
                var processedTouchIds:Vector.<int> = new <int>[];
                var touchId:int;
                var touch:Touch;
                var hoverTouch:Touch = null;
                var hoverTarget:DisplayObject = null;

                // update existing touches
                for each (var currentTouch:Touch in _currentTouches)
                {
                    // set touches that were moving to phase 'stationary'
                    if (currentTouch.phase == TouchPhase.MOVED)
                        currentTouch.setPhase(TouchPhase.STATIONARY);

                    // check if target is still connected to stage, otherwise find new target
                    if (currentTouch.target && (currentTouch.target.stage == null))
                        currentTouch.setTarget(_stage.hitTest(new Point(currentTouch.globalX, currentTouch.globalY), true));
                }

                // process new touches, but each ID only once
                while (_queue.length && (processedTouchIds.indexOf(_queue[_queue.length - 1][0]) == -1))
                {
                    var touchArgs:Array = _queue.pop();
                    touchId = touchArgs[0] as int;
                    touch = getCurrentTouch(touchId);

                    // hovering touches need special handling (see below)
                    if (touch && (touch.phase == TouchPhase.HOVER))
                    {
                        hoverTouch = touch;
                        hoverTarget = touch.target;
                    }

                    processTouch.apply(this, touchArgs);
                    processedTouchIds.push(touchId);
                }

                // if the target of a hovering touch changed, we dispatch an event to the previous
                // target to notify it that it's no longer being hovered over.
                if (hoverTarget && (hoverTouch.target != hoverTarget))
                {
                    hoverTarget.dispatchEvent(new TouchEvent(TouchEvent.TOUCH, _currentTouches, _shiftDown, _ctrlDown));
                }

                // dispatch events
                for each (touchId in processedTouchIds)
                {
                    touch = getCurrentTouch(touchId);
                    if (touch.target)
                        touch.target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH, _currentTouches, _shiftDown, _ctrlDown));
                }

                // remove ended touches
                _currentTouches = _currentTouches.filter(function(currentTouch:Touch, ... rest):Boolean
                {
                    return (currentTouch.phase != TouchPhase.ENDED);
                });

                // timestamps must differ for remaining touches
                if (_queue.length)
                    _elapsedTime += 0.00001;
            }
        }

        public function enqueue(touchId:int, phase:String, globalX:Number, globalY:Number):void
        {
            _queue.unshift(arguments);

            // multitouch simulation (only with mouse)
            if (_ctrlDown && simulateMultitouch && (touchId == 0))
            {
                _touchMarker.moveMarker(globalX, globalY, _shiftDown);

                // only mouse can hover
                if (phase != TouchPhase.HOVER)
                    _queue.unshift([1, phase, _touchMarker.mockX, _touchMarker.mockY]);
            }
        }

        private function processTouch(touchId:int, phase:String, globalX:Number, globalY:Number):void
        {
            var position:Point = new Point(globalX, globalY);
            var touch:Touch = getCurrentTouch(touchId);

            if (touch == null)
            {
                touch = new Touch(touchId, globalX, globalY, phase, null);
                addCurrentTouch(touch);
            }

            touch.setPosition(globalX, globalY);
            touch.setPhase(phase);
            touch.setTimestamp(_elapsedTime);

            if ((phase == TouchPhase.HOVER) || (phase == TouchPhase.BEGAN))
                touch.setTarget(_stage.hitTest(position, true));

            if (phase == TouchPhase.BEGAN)
                processTap(touch);
        }

        private function onKey(e:KeyboardEvent):void
        {
            if (e.keyCode == KeyCode.CTRL)
            {
                var wasCtrlDown:Boolean = _ctrlDown;
                _ctrlDown = (e.type == KeyboardEvent.KEY_DOWN);

                if (simulateMultitouch && (wasCtrlDown != _ctrlDown))
                {
                    _touchMarker.visible = _ctrlDown;
                    // 原来的代码
                    // _touchMarker.moveCenter(_stage.stageWidth / 2, _stage.stageHeight / 2);
                    // 我们的中心就是 (0, 0)
                    _touchMarker.moveCenter(0.0, 0.0);

                    var mouseTouch:Touch = getCurrentTouch(0);
                    var mockedTouch:Touch = getCurrentTouch(1);

                    if (mouseTouch)
                        _touchMarker.moveMarker(mouseTouch.globalX, mouseTouch.globalY);

                    // end active touch or start new one
                    if (wasCtrlDown && mockedTouch && (mockedTouch.phase != TouchPhase.ENDED))
                        _queue.unshift([1, TouchPhase.ENDED, mockedTouch.globalX, mockedTouch.globalY]);
                    else if (_ctrlDown && mouseTouch && (mouseTouch.phase != TouchPhase.ENDED || mouseTouch.phase != TouchPhase.
                        HOVER))
                        _queue.unshift([1, TouchPhase.BEGAN, _touchMarker.mockX, _touchMarker.mockY]);

                }
                else if (e.keyCode == KeyCode.SHIFT)
                {
                    _shiftDown = (e.type == KeyboardEvent.KEY_DOWN);
                }
            }
        }

        private function processTap(touch:Touch):void
        {
            var nearbyTap:Touch = null;
            var minSqDist:Number = MULTITAP_DISTANCE * MULTITAP_DISTANCE;

            for each (var tap:Touch in _lastTaps)
            {
                var sqDist:Number = Math.pow(tap.globalX - touch.globalX, 2) + Math.pow(tap.globalY - touch.globalY, 2);
                if (sqDist <= minSqDist)
                {
                    nearbyTap = tap;
                    break;
                }
            }

            if (nearbyTap)
            {
                touch.setTapCount(nearbyTap.tapCount + 1);
                _lastTaps.splice(_lastTaps.indexOf(nearbyTap), 1);
            }
            else
            {
                touch.setTapCount(1);
            }

            _lastTaps.push(touch.clone());
        }

        private function addCurrentTouch(touch:Touch):void
        {
            _currentTouches = _currentTouches.filter(function(existingTouch:Touch, ... rest):Boolean
            {
                return (existingTouch.id != touch.id);
            });

            _currentTouches.push(touch);
        }

        private function getCurrentTouch(touchId:int):Touch
        {
            for each (var touch:Touch in _currentTouches)
            {
                if (touch.id == touchId)
                    return touch;
            }

            return null;
        }

        public function get simulateMultitouch():Boolean  { return _touchMarker != null; }

        public function set simulateMultitouch(value:Boolean):void
        {
            if (simulateMultitouch == value)
                return;

            if (value)
            {
                _touchMarker = new TouchMarker();
                _touchMarker.visible = false;
                _stage.addChild(_touchMarker);
            }
            else
            {
                _touchMarker.removeFromParent(true);
                _touchMarker = null;
            }
        }
    }
}
