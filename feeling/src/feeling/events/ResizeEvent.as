package feeling.events
{
    public class ResizeEvent extends Event
    {
        public static const RESIZE:String = "resize";

        private var _width:int;
        private var _height:int;

        public function ResizeEvent(type:String, width:int, height:int, bubbles:Boolean = false)
        {
            super(type, bubbles);
            _width = width;
            _height = height;
        }

        public function get width():int  { return _width; }
        public function get height():int  { return _height; }
    }
}
