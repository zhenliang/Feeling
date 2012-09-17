package feeling.events
{
    /** Event objects are passed as parameters to event listeners when an event occurs.
     *  This is Starling's version of the Flash Event class.
     *
     *  <p>EventDispatchers create instances of this class and send them to registered listeners.
     *  An event object contains information that characterizes an event, most importantly the
     *  event type and if the event bubbles. The target of an event is the object that
     *  dispatched it.</p>
     *
     *  <p>For some event types, this information is sufficient; other events may need additional
     *  information to be carried to the listener. In that case, you can subclass "Event" and add
     *  properties with all the information you require. The "EnterFrameEvent" is an example for
     *  this practice; it adds a property about the time that has passed since the last frame.</p>
     *
     *  <p>Furthermore, the event class contains methods that can stop the event from being
     *  processed by other listeners - either completely or at the next bubble stage.</p>
     *
     *  @see EventDispatcher
     */
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

        /** Creates an event object that can be passed to listeners. */
        public function Event(type:String, bubbles:Boolean = false)
        {
            _type = type;
            _bubbles = bubbles;
        }

        public function get type():String  { return _type; }

        /** Indicates if event will bubble. */
        public function get bubbles():Boolean  { return _bubbles; }

        /** The object that dispatched the event. */
        public function get target():EventDispatcher  { return _target; }

        /** The object the event is currently bubbling at. */
        public function get currentTarget():EventDispatcher  { return _currentTarget; }

        /** @private */
        internal function setTarget(target:EventDispatcher):void  { _target = target; }

        /** @private */
        internal function setCurrentTarget(currentTarget:EventDispatcher):void  { _currentTarget = currentTarget; }
    }
}
