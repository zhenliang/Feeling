package feeling.events
{
    import feeling.display.DisplayObject;

    import flash.utils.Dictionary;

    /** The EventDispatcher class is the base class for all classes that dispatch events.
     *  This is the Starling version of the Flash class with the same name.
     *
     *  <p>The event mechanism is a key feature of Starling's architecture. Objects can communicate
     *  with each other through events. Compared the the Flash event system, Starling's event system
     *  was simplified. The main difference is that Starling events have no "Capture" phase.
     *  They are simply dispatched at the target and may optionally bubble up. They cannot move
     *  in the opposite direction.</p>
     *
     *  <p>As in the conventional Flash classes, display objects inherit from EventDispatcher
     *  and can thus dispatch events. Beware, though, that the Starling event classes are
     *  <em>not compatible with Flash events:</em> Starling display objects dispatch
     *  Starling events, which will bubble along Starling display objects - but they cannot
     *  dispatch Flash events or bubble along Flash display objects.</p>
     *
     *  @see Event
     *  @see starling.display.DisplayObject DisplayObject
     */
    public class EventDispatcher
    {
        private var _eventListeners:Dictionary;

        /** Creates an EventDispatcher. */
        public function EventDispatcher()
        {
        }

        /** Registers an event listener at a certain object. */
        public function addEventListener(type:String, listener:Function):void
        {
            if (_eventListeners == null)
                _eventListeners = new Dictionary();

            var listeners:Vector.<Function> = _eventListeners[type];
            if (listeners == null)
                _eventListeners[type] = new <Function>[listener];
            else
                _eventListeners[type] = listeners.concat(new <Function>[listener]);
        }

        /** Removes an event listener from the object. */
        public function removeEventListener(type:String, listener:Function):void
        {
            var listeners:Vector.<Function> = _eventListeners[type];
            if (listeners == null)
                return;

            listeners = listeners.filter(function(item:Function, ... rest):Boolean
            {
                return item != listener;
            });
            if (listeners.length == 0)
                delete _eventListeners[type];
            else
                _eventListeners[type] = listeners;
        }

        /** Returns if there are listeners registered for a certain event type. */
        public function hasEventListener(type:String):Boolean
        {
            return (_eventListeners != null) && (_eventListeners[type] != null);
        }

        /** Removes all event listeners with a certain type, or all of them if type is null.
         *  Be careful when removing all event listeners: you never know who else was listening. */
        public function removeEventListeners(type:String = null):void
        {
            if (type)
                delete _eventListeners[type];
            else
                _eventListeners = null;
        }

        /** Dispatches an event to all objects that have registered for events of the same type. */
        public function dispatchEvent(event:Event):void
        {
            var listeners:Vector.<Function> = _eventListeners ? _eventListeners[event.type] : null;
            if ((listeners == null) && !event.bubbles)
                return;

            // if the event already has a current target, it was re-dispatched by user -> we change
            // the target to 'this' for now, but undo that later on (instead of creating a clone)

            var previousTarget:EventDispatcher = event.target;
            if (!previousTarget || event.currentTarget)
                event.setTarget(this);

            if (listeners && listeners.length)
            {
                event.setCurrentTarget(this);

                // we can enumerate directly over the vector, since "add"- and "removeEventListener" 
                // won't change it, but instead always create a new vector.
                for each (var listener:Function in listeners)
                {
                    listener(event);
                }
            }

            if (event.bubbles && (this is DisplayObject))
            {
                var targetDisplayObject:DisplayObject = this as DisplayObject;
                if (targetDisplayObject.parent != null)
                {
                    event.setCurrentTarget(null); // to find out later if the event was redispatched
                    targetDisplayObject.parent.dispatchEvent(event);
                }
            }

            if (previousTarget)
                event.setTarget(previousTarget);
        }
    }
}









