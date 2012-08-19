package feeling.display
{
    import feeling.events.EnterFrameEvent;
    import feeling.events.Event;

    import flash.geom.Point;

    public class Stage extends DisplayObjectContainer
    {
        private var _stageWidth:int;
        private var _stageHeight:int;
        private var _color:uint;

        public function Stage(width:Number, height:Number, color:uint = 0)
        {
            _stageWidth = width;
            _stageHeight = height;
        }

        public override function set x(value:Number):void  { throw new Error(); }
        public override function set y(value:Number):void  { throw new Error(); }
        public override function set z(value:Number):void  { throw new Error(); }
        public override function set scaleX(value:Number):void  { throw new Error(); }
        public override function set scaleY(value:Number):void  { throw new Error(); }
        public override function set scaleZ(value:Number):void  { throw new Error(); }
        public override function set rotationX(value:Number):void  { throw new Error(); }
        public override function set rotationY(value:Number):void  { throw new Error(); }
        public override function set rotationZ(value:Number):void  { throw new Error(); }
        public override function set pivotX(value:Number):void  { throw new Error(); }
        public override function set pivotY(value:Number):void  { throw new Error(); }
        public override function set pivotZ(value:Number):void  { throw new Error(); }
        public override function set width(val:Number):void  { throw new Error(); }
        public override function set height(val:Number):void  { throw new Error(); }

        public override function get width():Number  { throw new Error(); }
        public override function get height():Number  { throw new Error(); }

        public function get stageWidth():int  { return _stageWidth; }
        public function set stageWidth(value:int):void  { _stageWidth = value; }
        public function get stageHeight():int  { return _stageHeight; }
        public function set stageHeight(value:int):void  { _stageHeight = value; }

        public function get color():uint  { return _color; }
        public function set color(value:uint):void  { _color = value; }

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

        public override function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject
        {
            if (forTouch && (!visible || !touchable))
                return null;

            // if nothing else is hit, the stage returns itself as target
            var target:DisplayObject = super.hitTest(localPoint, forTouch);
            return target ? target : this;
        }
    }
}
