package feeling.animation
{
    import feeling.display.DisplayObject;

    public class Juggler
    {
        private var _objects:Array;
        private var _elapsedTime:Number;
        private var _displayObject:DisplayObject;

        public function Juggler()
        {
            _objects = [];
            _elapsedTime = 0.0;
        }

        public function add(object:IAnimatable):void
        {
            if (object != null)
                _objects.push(object);
        }

        public function remove(obejct:IAnimatable):void
        {
            _objects = _objects.filter(function(currentObj:Object, ... reset):Boolean
            {
                return obejct != currentObj;
            });
        }

        public function purge():void
        {
            _objects = [];
        }

        public function advanceTime(time:Number):void
        {
            _elapsedTime += time;
            var objectCopy:Array = _objects.concat();

            // since 'advanceTime' could modify the juggler (through a callback), we split
            // the logic in two loops.

            for each (var currentObject:IAnimatable in objectCopy)
                currentObject.advanceTime(time);

            _objects = _objects.filter(function(object:IAnimatable, ... rest):Boolean
            {
                return !object.isComplete;
            });
        }

        public function get isComplete():Boolean  { return false; }
        public function get elapsedTime():Number  { return _elapsedTime; }
    }
}
