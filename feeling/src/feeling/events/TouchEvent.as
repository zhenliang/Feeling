package feeling.events
{
    import feeling.display.DisplayObject;
    import feeling.display.DisplayObjectContainer;

    public class TouchEvent extends Event
    {
        public static const TOUCH:String = "touch";

        private var _touches:Vector.<Touch>;
        private var _shiftKey:Boolean;
        private var _ctrlKey:Boolean;

        public function TouchEvent(type:String, touches:Vector.<Touch>, shiftKey:Boolean = false, ctrlKey:Boolean = false,
            bubbles:Boolean = true)
        {
            super(type, bubbles);
            _touches = touches;
            _shiftKey = shiftKey;
            _ctrlKey = ctrlKey;
        }

        public function getTouches(target:DisplayObject, phase:String = null):Vector.<Touch>
        {
            var touchesFound:Vector.<Touch> = new <Touch>[];
            for each (var touch:Touch in _touches)
            {
                var correctTarget:Boolean = (touch.target == target) || ((target is DisplayObjectContainer) && (target as
                    DisplayObjectContainer).contains(touch.target));
                if (!correctTarget)
                    continue;

                var correctPhase:Boolean = ((phase == null) || (phase == touch.phase));
                if (!correctPhase)
                    continue;

                touchesFound.push(touch);
            }

            return touchesFound;
        }

        public function getTouch(target:DisplayObject, phase:String = null):Touch
        {
            var touchesFound:Vector.<Touch> = getTouches(target, phase);
            if (touchesFound && touchesFound.length)
                return touchesFound[0];
            return null;
        }

        public function get touches():Vector.<Touch>  { return _touches.concat(); }

        public function get timestamp():Number
        {
            if (_touches && _touches.length)
                return _touches[0].timestamp;
            return -1.0;
        }

        public function get shiftKey():Boolean  { return _shiftKey; }
        public function get ctrlKey():Boolean  { return _ctrlKey; }
    }
}
