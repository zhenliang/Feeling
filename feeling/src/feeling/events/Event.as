package feeling.events
{

    public class Event
    {
        /** Event type for a display object that is added to a parent. */
        public static const ADDED:String = "added";
        /** Event type for a display object that is removed from its parent. */
        public static const REMOVED:String = "removed";
        /** Event type for a display object that is added to the stage */
        public static const ADDED_TO_STAGE:String = "addedToStage";
        /** Event type for a display object that is removed from the stage. */
        public static const REMOVED_FROM_STAGE:String = "removedFromStage";
        /** Event type for a display object that is entering a new frame. */
        public static const ENTER_FRAME:String = "enterFrame";
        /** Event type for a movie that has reached the last frame. */
        public static const MOVIE_COMPLETED:String = "movieCompleted";
        /** Event type for a resized Flash Player. */
        public static const RESIZE:String = "resize";

        private var _type:String;
        private var _bubbles:Boolean;
        private var _target:EventDispatcher;
        private var _currentTarget:EventDispatcher;

        public function Event(type:String, bubbles:Boolean = false)
        {
            _type = type;
            _bubbles = bubbles;
        }

        public function get type():String  { return _type; }

        public function get bubbles():Boolean  { return _bubbles; }

        public function get target():EventDispatcher  { return _target; }

        public function get currentTarget():EventDispatcher  { return _currentTarget; }

        internal function setTarget(target:EventDispatcher):void  { _target = target; }

        internal function setCurrentTarget(currentTarget:EventDispatcher):void  { _currentTarget = currentTarget; }
    }
}
