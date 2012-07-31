package com.feeling.input
{
	import com.feeling.events.KeyboardEvent;

	public class KeyboardInput
	{
		private var _keyStatus:Object;
		
		public function KeyboardInput()
		{
			_keyStatus = {};
		}
		
		public function updateStatus(e:KeyboardEvent):void
		{
			switch (e.type)
			{
				case KeyboardEvent.KEY_DOWN: onKeyDown(e); break;
				case KeyboardEvent.KEY_UP: onKeyUp(e); break;
			}
		}
		
		public function getKeyStatus(charCode:uint):Boolean
		{
			return _keyStatus[charCode];
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			_keyStatus[e.charCode] = true;
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			_keyStatus[e.charCode] = false;
		}
	}
}