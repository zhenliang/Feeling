package com.feeling.events
{
	public class Event
	{
		public static const ADDED_TO_STAGE:String = "addedToStage";
		public static const ENTER_FRAME:String = "enterFrame";
		
		private var _type:String;
		private var _bubbles:Boolean;
		private var _target:EventDispatcher;
		private var _currentTarget:EventDispatcher;
		
		public function Event(type:String, bubbles:Boolean = false)
		{
			_type = type;
			_bubbles = bubbles;
		}
		
		public function get type():String { return _type; }
		public function get bubbles():Boolean { return _bubbles; }
		public function get target():EventDispatcher { return _target; }
		public function get currentTarget():EventDispatcher { return _currentTarget; }
		
		internal function setTarget(target:EventDispatcher):void { _target = target; }
		internal function setCurrentTarget(currentTarget:EventDispatcher):void { _currentTarget = currentTarget; }
	}
}
