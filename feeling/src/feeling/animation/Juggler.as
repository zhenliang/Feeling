package feeling.animation
{
    import feeling.display.DisplayObject;

    /** The Juggler takes objects that implement IAnimatable (like Tweens) and executes them.
     *
     *  <p>A juggler is a simple object. It does no more than saving a list of objects implementing
     *  "IAnimatable" and advancing their time if it is told to do so (by calling its own
     *  "advanceTime"-method). When an animation is completed, it throws it away.</p>
     *
     *  <p>There is a default juggler available at the Starling class:</p>
     *
     *  <pre>
     *  var juggler:Juggler = Starling.juggler;
     *  </pre>
     *
     *  <p>You can create juggler objects yourself, just as well. That way, you can group
     *  your game into logical components that handle their animations independently. All you have
     *  to do is call the "advanceTime" method on your custom juggler once per frame.</p>
     *
     *  <p>Another handy feature of the juggler is the "delayCall"-method. Use it to
     *  execute a function at a later time. Different to conventional approaches, the method
     *  will only be called when the juggler is advanced, giving you perfect control over the
     *  call.</p>
     *
     *  <pre>
     *  juggler.delayCall(object.removeFromParent, 1.0);
     *  juggler.delayCall(object.addChild, 2.0, theChild);
     *  juggler.delayCall(function():void { doSomethingFunny(); }, 3.0);
     *  </pre>
     *
     *  @see Tween
     *  @see DelayedCall
     */
    public class Juggler
    {
        private var _objects:Vector.<Object>;
        private var _elapsedTime:Number;
        private var _displayObject:DisplayObject;

        /** Create an empty juggler. */
        public function Juggler()
        {
            _elapsedTime = 0.0;
            _objects = new <Object>[];
        }

        /** Adds an object to the juggler. */
        public function add(object:IAnimatable):void
        {
            if (object != null)
                _objects.push(object);
        }

        /** Removes an object from the juggler. */
        public function remove(obejct:IAnimatable):void
        {
            _objects = _objects.filter(function(currentObj:Object, ... reset):Boolean
            {
                return obejct != currentObj;
            });
        }

        /** Removes all objects at once. */
        public function purge():void
        {
            _objects = new <Object>[];
        }

        /** Advanced all objects by a certain time (in seconds). Objects with a positive
         *  'isComplete'-property will be removed. */
        public function advanceTime(time:Number):void
        {
            _elapsedTime += time;
            var objectCopy:Vector.<Object> = _objects.concat();

            // since 'advanceTime' could modify the juggler (through a callback), we split
            // the logic in two loops.

            for each (var currentObject:IAnimatable in objectCopy)
                currentObject.advanceTime(time);

            _objects = _objects.filter(function(object:IAnimatable, ... rest):Boolean
            {
                return !object.isComplete;
            });
        }

        /** Always returns 'false'. */
        public function get isComplete():Boolean  { return false; }

        /** The total life time of the juggler. */
        public function get elapsedTime():Number  { return _elapsedTime; }
    }
}
