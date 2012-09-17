package feeling.events
{
    import feeling.display.DisplayObject;
    import feeling.display.DisplayObjectContainer;

    /** A TouchEvent is triggered either by touch or mouse input.
     *
     *  <p>In Starling, both touch events and mouse events are handled through the same class:
     *  TouchEvent. To process user input from a touch screen or the mouse, you have to register
     *  an event listener for events of the type <code>TouchEvent.TOUCH</code>. This is the only
     *  event type you need to handle; the long list of mouse event types as they are used in
     *  conventional Flash are mapped to so-called "TouchPhases" instead.</p>
     *
     *  <p>The difference between mouse input and touch input is that</p>
     *
     *  <ul>
     *    <li>only one mouse cursor can be present at a given moment and</li>
     *    <li>only the mouse can "hover" over an object without a pressed button.</li>
     *  </ul>
     *
     *  <strong>Which objects receive touch events?</strong>
     *
     *  <p>In Starling, any display object receives touch events, as long as the
     *  <code>touchable</code> property of the object and its parents is enabled. There
     *  is no "InteractiveObject" class in Starling.</p>
     *
     *  <strong>How to work with individual touches</strong>
     *
     *  <p>The event contains a list of all touches that are currently present. Each individual
     *  touch is stored in an object of type "Touch". Since you are normally only interested in
     *  the touches that occurred on top of certain objects, you can query the event for touches
     *  with a specific target:</p>
     *
     *  <code>var touches:Vector.&lt;Touch&gt; = touchEvent.getTouches(this);</code>
     *
     *  <p>This will return all touches of "this" or one of its children. When you are not using
     *  multitouch, you can also access the touch object directly, like this:</p>
     *
     *  <code>var touch:Touch = touchEvent.getTouch(this);</code>
     *
     *  @see Touch
     */
    public class TouchEvent extends Event
    {
        /** Event type for touch or mouse input. */
        public static const TOUCH:String = "touch";

        private var _touches:Vector.<Touch>;
        private var _shiftKey:Boolean;
        private var _ctrlKey:Boolean;

        /** Creates a new TouchEvent instance. */
        public function TouchEvent(type:String, touches:Vector.<Touch>, shiftKey:Boolean = false, ctrlKey:Boolean = false,
            bubbles:Boolean = true)
        {
            super(type, bubbles);
            _touches = touches;
            _shiftKey = shiftKey;
            _ctrlKey = ctrlKey;
        }

        /** Returns a list of touches that originated over a certain target. */
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

        /** Returns a touch that originated over a certain target. */
        public function getTouch(target:DisplayObject, phase:String = null):Touch
        {
            var touchesFound:Vector.<Touch> = getTouches(target, phase);
            if (touchesFound && touchesFound.length)
                return touchesFound[0];
            return null;
        }

        /** All touches that are currently available. */
        public function get touches():Vector.<Touch>  { return _touches.concat(); }

        /** The time the event occurred (in seconds since application launch). */
        public function get timestamp():Number
        {
            if (_touches && _touches.length)
                return _touches[0].timestamp;
            return -1.0;
        }

        /** Indicates if the shift key was pressed when the event occurred. */
        public function get shiftKey():Boolean  { return _shiftKey; }

        /** Indicates if the ctrl key was pressed when the event occurred. (Mac OS: Cmd or Ctrl) */
        public function get ctrlKey():Boolean  { return _ctrlKey; }
    }
}
