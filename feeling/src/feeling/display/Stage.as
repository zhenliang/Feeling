package feeling.display
{
	import feeling.events.EnterFrameEvent;
	import feeling.events.Event;

    public class Stage extends DisplayObjectContainer
    {
        private var _width:Number;
        private var _height:Number;

        public function Stage( width:Number, height:Number )
        {
            _width = width;
            _height = height;
        }
		
		public function set width(val:Number):void { throw new Error(); }
		public function set height(val:Number):void { throw new Error(); }
		
		public function get stageWidth():Number { return _width; }
		public function get stageHeight():Number { return _height; }

        public function advanceTime( passedTime:Number ):void
        {
			dispatchEventOnChildren(new EnterFrameEvent(Event.ENTER_FRAME, passedTime));
        }
		
		public function broadcastEvent(e:Event):void
		{
			if (e.bubbles)
				throw new ArgumentError("[FeelingStage] Broadcast of bubbling events is prohibited");
			
			dispatchEventOnChildren(e);
		}
    }
}