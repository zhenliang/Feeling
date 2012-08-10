package feeling.display
{
    import feeling.events.EnterFrameEvent;
    import feeling.events.Event;

    import flash.geom.Point;

    public class Stage extends DisplayObjectContainer
    {
        private var _width:Number;
        private var _height:Number;

        public function Stage(width:Number, height:Number)
        {
            _width = width;
            _height = height;
        }

        public override function set stageWidth(val:Number):void  { throw new Error(); }

        public override function set stageHeight(val:Number):void  { throw new Error(); }

        public override function get stageWidth():Number  { return _width; }

        public override function get stageHeight():Number  { return _height; }

        public function advanceTime(passedTime:Number):void
        {
            dispatchEventOnChildren(new EnterFrameEvent(Event.ENTER_FRAME, passedTime));
        }

        public function broadcastEvent(e:Event):void
        {
            if (e.bubbles)
                throw new ArgumentError("[FeelingStage] Broadcast of bubbling events is prohibited");

            dispatchEventOnChildren(e);
        }

        public override function hitTestPoint(localPoint:Point, forTouch:Boolean = false):DisplayObject
        {
            if (forTouch && (!visible || !touchable))
                return null;

            // if nothing else is hit, the stage returns itself as target
            var target:DisplayObject = super.hitTestPoint(localPoint, forTouch);
            return target ? target : this;
        }
    }
}
