package feeling.events
{
    import flash.events.KeyboardEvent;

    /** A KeyboardEvent is dispatched in response to user input through a keyboard.
     *
     *  <p>This is Starling's version of the Flash KeyboardEvent class. It contains the same
     *  properties as the Flash equivalent.</p>
     *
     *  <p>To be notified of keyboard events, add an event listener to the Starling stage. Children
     *  of the stage won't be notified of keybaord input. Starling has no concept of a "Focus"
     *  like native Flash.</p>
     *
     *  @see starling.display.Stage
     */
    public class KeyboardEvent extends Event
    {
        /** Event type for a key that was pressed. */
        public static const KEY_DOWN:String = "keyDown";

        /** Event type for a key that was released. */
        public static const KEY_UP:String = "keyUp";

        private var _charCode:uint;
        private var _keyCode:uint;

        /** Creates a new KeyboardEvent. */
        public function KeyboardEvent(type:String, charCode:uint = 0, keyCode:uint = 0)
        {
            super(type, false);

            _charCode = charCode;
            _keyCode = keyCode;
        }

        /** Contains the character code of the key. */
        public function get charCode():uint  { return _charCode; }

        /** The key code of the key. */
        public function get keyCode():uint  { return _keyCode; }
    }
}
