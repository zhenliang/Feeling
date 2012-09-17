package feeling.events
{
    import feeling.display.DisplayObject;

    import flash.geom.Matrix;
    import flash.geom.Point;

    /** A Touch object contains information about the presence or movement of a finger
     *  or the mouse on the screen.
     *
     *  <p>You receive objects of this type from a TouchEvent. When such an event is triggered, you can
     *  query it for all touches that are currently present on the screen. One Touch object contains
     *  information about a single touch. A touch object always moves through a series of
     *  TouchPhases. Have a look at the TouchPhase class for more information.</p>
     *
     *  <strong>The position of a touch</strong>
     *
     *  <p>You can get the current and previous position in stage coordinates with the corresponding
     *  properties. However, you'll want to have the position in a different coordinate system
     *  most of the time. For this reason, there are methods that convert the current and previous
     *  touches into the local coordinate system of any object.</p>
     *
     *  @see TouchEvent
     *  @see TouchPhase
     */
    public class Touch
    {
        private var _id:int;
        private var _globalX:Number;
        private var _globalY:Number;
        private var _previousGlobalX:Number;
        private var _previousGlobalY:Number;
        private var _tapCount:int;
        private var _phase:String;
        private var _target:DisplayObject;
        private var _timestamp:Number;

        /** Creates a new Touch object. */
        public function Touch(id:int, globalX:Number, globalY:Number, phase:String, target:DisplayObject)
        {
            _id = id;
            _globalX = _previousGlobalX = globalX;
            _globalY = _previousGlobalY = globalY;
            _tapCount = 0;
            _phase = phase;
            _target = target;
        }

        /** Converts the current location of a touch to the local coordinate system of a display
         *  object. */
        public function getLocation(space:DisplayObject):Point
        {
            var point:Point = new Point(_globalX, _globalY);
            var transformationMatrix:Matrix = _target.root.getTransformationMatrixToSpace(space);
            return transformationMatrix.transformPoint(point);
        }

        /** Converts the previous location of a touch to the local coordinate system of a display
         *  object. */
        public function getPreviousLocation(space:DisplayObject):Point
        {
            var point:Point = new Point(_previousGlobalX, _previousGlobalY);
            var transformationMatrix:Matrix = _target.root.getTransformationMatrixToSpace(space);
            return transformationMatrix.transformPoint(point);
        }

        /** Creates a clone of the Touch object. */
        public function clone():Touch
        {
            var clone:Touch = new Touch(_id, _globalX, _globalY, _phase, _target);
            clone._previousGlobalX = _previousGlobalX;
            clone._previousGlobalY = _previousGlobalY;
            clone._tapCount = _tapCount;
            clone._timestamp = _timestamp;
            return clone;
        }

        /** The identifier of a touch. '0' for mouse events, an increasing number for touches. */
        public function get id():int  { return _id; }

        /** The x-position of the touch in stage coordinates. */
        public function get globalX():Number  { return _globalX; }

        /** The y-position of the touch in stage coordinates. */
        public function get globalY():Number  { return _globalY; }

        /** The previous x-position of the touch in stage coordinates. */
        public function get previousGlobalX():Number  { return _previousGlobalX; }

        /** The previous y-position of the touch in stage coordinates. */
        public function get previousGlobalY():Number  { return _previousGlobalY; }

        /** The number of taps the finger made in a short amount of time. Use this to detect
         *  double-taps / double-clicks, etc. */
        public function get tapCount():int  { return _tapCount; }

        /** The current phase the touch is in. @see TouchPhase */
        public function get phase():String  { return _phase; }

        /** The display object at which the touch occurred. */
        public function get target():DisplayObject  { return _target; }

        /** The moment the touch occurred (in seconds since application start). */
        public function get timestamp():Number  { return _timestamp; }

        // internal methods

        /** @private */
        internal function setPosition(globalX:Number, globalY:Number):void
        {
            _previousGlobalX = globalX;
            _previousGlobalY = globalY;
            _globalX = globalX;
            _globalY = globalY;
        }

        /** @private */
        internal function setPhase(value:String):void  { _phase = value; }

        /** @private */
        internal function setTapCount(value:int):void  { _tapCount = value; }

        /** @private */
        internal function setTarget(value:DisplayObject):void  { _target = value; }

        /** @private */
        internal function setTimestamp(value:Number):void  { _timestamp = value; }
    }
}
