package feeling.events
{
    import feeling.display.DisplayObject;

    import flash.utils.Dictionary;

    public class EventDispatcher
    {
        private var _eventListeners:Dictionary;

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

        public function remomveEventLitener(type:String, listener:Function):void
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

        public function hasEventListener(type:String):Boolean
        {
            return _eventListeners != null && _eventListeners[type] != null;
        }

        public function dispatchEvent(event:Event):void
        {
            var listeners:Vector.<Function> = _eventListeners ? _eventListeners[event.type] : null;
            if (listeners == null && !event.bubbles)
                return;

            // if the event already has a current target, it was re-dispatched by user -> we change
            // the target to 'this' for now, but undo that later on (instead of creating a clone)

            var previousTarget:EventDispatcher = event.target;
            if (previousTarget == null || event.currentTarget != null)
                event.setTarget(this);
            event.setCurrentTarget(this);

            if (listeners != null && listeners.length != 0)
            {
                for each (var listener:Function in listeners)
                {
                    listener(event);
                }
            }

            var targetDisplayObject:DisplayObject = this as DisplayObject;
            event.setCurrentTarget(null); // to find out later if the event is redispatched

            if (event.bubbles && targetDisplayObject != null && targetDisplayObject.parent != null)
            {
                targetDisplayObject.parent.dispatchEvent(event);
            }

            if (previousTarget)
                event.setTarget(previousTarget);
        }
    }
}









