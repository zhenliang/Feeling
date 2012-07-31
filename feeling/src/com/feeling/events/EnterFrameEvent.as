package com.feeling.events
{
	public class EnterFrameEvent extends Event
	{
		private var _passedTime:Number;
		
		public function EnterFrameEvent(type:String, passedTime:Number, bubbles:Boolean=false)
		{
			super(type, bubbles);
			_passedTime = passedTime;
		}
		
		public function get passedTime():Number { return _passedTime; }
	}
}