package feeling.events
{
    /** An EnterFrameEvent is triggered once per frame and is dispatched to all objects in the
     *  display tree.
     *
     *  It contains information about the time that has passed since the last frame. That way, you
     *  can easily make animations that are independet of the frame rate, taking the passed time
     *  into account.
     */
    public class EnterFrameEvent extends Event
    {
        /** Event type for a display object that is entering a new frame. */
        public static const ENTER_FRAME:String = "enterFrame";

        private var _passedTime:Number;

        /** Creates an enter frame event with the passed time. */
        public function EnterFrameEvent(type:String, passedTime:Number, bubbles:Boolean = false)
        {
            super(type, bubbles);
            _passedTime = passedTime;
        }

        /** The time that has passed since the last frame (in seconds). */
        public function get passedTime():Number  { return _passedTime; }
    }
}
