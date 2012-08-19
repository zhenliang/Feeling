package feeling.events
{
    public class EnterFrameEvent extends Event
    {
        public static const ENTER_FRAME:String = "enterFrame";

        private var _passedTime:Number;

        public function EnterFrameEvent(type:String, passedTime:Number, bubbles:Boolean = false)
        {
            super(type, bubbles);
            _passedTime = passedTime;
        }

        public function get passedTime():Number  { return _passedTime; }
    }
}
