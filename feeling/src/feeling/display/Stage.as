package feeling.display
{
    import feeling.events.EnterFrameEvent;
    import feeling.events.Event;

    import flash.geom.Point;

    /** A Stage represents the root of the display tree.
     *  Only objects that are direct or indirect children of the stage will be rendered.
     *
     *  <p>This class represents the Starling version of the stage. Don't confuse it with its
     *  Flash equivalent: while the latter contains objects of the type
     *  <code>flash.display.DisplayObject</code>, the Starling stage contains only objects of the
     *  type <code>starling.display.DisplayObject</code>. Those classes are not compatible, and
     *  you cannot exchange one type with the other.</p>
     *
     *  <p>A stage object is created automatically by the <code>Starling</code> class. Don't
     *  create a Stage instance manually.</p>
     *
     *  <strong>Keyboard Events</strong>
     *
     *  <p>In Starling, keyboard events are only dispatched at the stage. Add an event listener
     *  directly to the stage to be notified of keyboard events.</p>
     *
     *  <strong>Resize Events</strong>
     *
     *  <p>When the Flash player is resized, the stage dispatches a <code>ResizeEvent</code>. The
     *  event contains properties containing the updated width and height of the Flash player.</p>
     *
     *  @see starling.events.KeyboardEvent
     *  @see starling.events.ResizeEvent
     *
     * */
    public class Stage extends DisplayObjectContainer
    {
        private var _stageWidth:int;
        private var _stageHeight:int;
        private var _color:uint;

        /** @private */
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

        /** The width of the stage coordinate system. Change it to scale its contents relative
         *  to the <code>viewPort</code> property of the Starling object. */
        public function get stageWidth():int  { return _stageWidth; }
        public function set stageWidth(value:int):void  { _stageWidth = value; }

        /** The height of the stage coordinate system. Change it to scale its contents relative
         *  to the <code>viewPort</code> property of the Starling object. */
        public function get stageHeight():int  { return _stageHeight; }
        public function set stageHeight(value:int):void  { _stageHeight = value; }

        /** The background color of the stage. */
        public function get color():uint  { return _color; }
        public function set color(value:uint):void  { _color = value; }

        /** @inheritDoc */
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

        /** Returns the object that is found topmost beneath a point in stage coordinates, or
         *  the stage itself if nothing else is found. */
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
