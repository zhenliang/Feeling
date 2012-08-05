package feeling.events
{
    import feeling.display.DisplayObject;

    import flash.geom.Matrix;
    import flash.geom.Point;

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

        public function Touch(id:int, globalX:Number, globalY:Number, phase:String, target:DisplayObject)
        {
            _id = id;
            _globalX = _previousGlobalX = globalX;
            _globalY = _previousGlobalY = globalY;
            _tapCount = 0;
            _phase = phase;
            _target = target;
        }

        public function getLocationInSpace(space:DisplayObject):Point
        {
            var point:Point = new Point(_globalX, _globalY);
            var transformationMatrix:Matrix = _target.root.getTransformationMatrixToSpace(space);
            return transformationMatrix.transformPoint(point);
        }

        public function getPreviousLocationInSpace(space:DisplayObject):Point
        {
            var point:Point = new Point(_previousGlobalX, _previousGlobalY);
            var transformationMatrix:Matrix = _target.root.getTransformationMatrixToSpace(space);
            return transformationMatrix.transformPoint(point);
        }

        public function clone():Touch
        {
            var clone:Touch = new Touch(_id, _globalX, _globalY, _phase, _target);
            clone._previousGlobalX = _previousGlobalX;
            clone._previousGlobalY = _previousGlobalY;
            clone._tapCount = _tapCount;
            clone._timestamp = _timestamp;
            return clone;
        }

        public function get id():int  { return _id; }

        public function get globalX():Number  { return _globalX; }

        public function get globalY():Number  { return _globalY; }

        public function get previousGlobalX():Number  { return _previousGlobalX; }

        public function get previousGlobalY():Number  { return _previousGlobalY; }

        public function get tapCount():int  { return _tapCount; }

        public function get phase():String  { return _phase; }

        public function get target():DisplayObject  { return _target; }

        public function get timestamp():Number  { return _timestamp; }

        // internal methods

        internal function setPosition(globalX:Number, globalY:Number):void
        {
            _previousGlobalX = globalX;
            _previousGlobalY = globalY;
            _globalX = globalX;
            _globalY = globalY;
        }

        internal function setPhase(value:String):void  { _phase = value; }

        internal function setTapCount(value:int):void  { _tapCount = value; }

        internal function setTarget(value:DisplayObject):void  { _target = value; }

        internal function setTimestamp(value:Number):void  { _timestamp = value; }
    }
}
