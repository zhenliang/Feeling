package feeling.events
{
    import flash.events.KeyboardEvent;

    public class KeyboardEvent extends Event
    {
        public static const KEY_DOWN:String = flash.events.KeyboardEvent.KEY_DOWN;
        public static const KEY_UP:String = flash.events.KeyboardEvent.KEY_UP;

        private var _charCode:uint;
        private var _keyCode:uint;

        public function KeyboardEvent(type:String, charCode:uint = 0, keyCode:uint = 0)
        {
            super(type, false);

            _charCode = charCode;
            _keyCode = keyCode;
        }

        public function get charCode():uint  { return _charCode; }

        public function get keyCode():uint  { return _keyCode; }
    }
}
