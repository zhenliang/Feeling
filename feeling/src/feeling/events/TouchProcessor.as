package feeling.events
{
	import feeling.display.DisplayObject;
	import feeling.display.DisplayObjectContainer;
	
	import flash.geom.Point;

	public class TouchProcessor
	{
		private static const MULTITAP_TIME:Number = 0.3;
		private static const MULTITAP_DISTANCE:Number = 25;
		
		private var _root:DisplayObjectContainer;
		private var _elapsedTime:Number;
		private var _touchMarker:TouchMarker;
		
		private var _currentTouches:Vector.<Touch>;
		private var _queue:Vector.<Array>;
		private var _lastTaps:Vector.<Touch>;
		
		private var _shiftDown:Boolean = false;
		private var _ctrlDown:Boolean = false;
		
		public function TouchProcessor(root:DisplayObjectContainer)
		{
			_root = root;
			_elapsedTime = 0.0;
			_currentTouches = new <Touch>[];
			_queue = new <Array>[];
			_lastTaps = new <Touch>[];
			
			_root.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			_root.addEventListener(KeyboardEvent.KEY_UP, onKey);
		}
		
		public function dispose():void
		{
			_root.remomveEventLitener(KeyboardEvent.KEY_DOWN, onKey);
			_root.remomveEventLitener(KeyboardEvent.KEY_UP, onKey);
			if (_touchMarker)
				_touchMarker.dispose();
		}
		
		public function advanceTime(passedTime:Number):void
		{
			_elapsedTime += passedTime;
			
			// remove old taps
			if (_lastTaps.length)
			{
				_lastTaps = _lastTaps.filter(function(touch:Touch, ...rest):Boolean
				{
					return ((_elapsedTime - touch.timestamp) <= MULTITAP_TIME);
				});
			}
			
			while (_queue.length)
			{
				var processedTouchIds:Vector.<int> = new <int>[];
				var touchId:int;
				var touch:Touch;
				var hoverTouch:Touch = null;
				var hoverTarget:DisplayObject = null;
				
				// update existing touches
				for each (var currentTouch:Touch in _currentTouches)
				{
					// set touches that were moving to phase 'stationary'
					if (currentTouch.phase == TouchPhase.MOVED)
						currentTouch.setPhase(TouchPhase.STATIONARY);
					
					// check if target is still connected to stage, otherwise find new target
					if (currentTouch.target.stage == null)
						currentTouch.setTarget(_root.hitTestPoint(
							new Point(currentTouch.globalX, currentTouch.globalY), true));
				}
				
				// process new touches, but each ID only once
				while (_queue.length && (processedTouchIds.indexOf(_queue[_queue.length -1][0]) == -1))
				{
					var touchArgs:Array = _queue.pop();
					touchId = touchArgs[0];
					touch = getCurrentTouch(touchId);
					
					// hovering touches need special handling (see below)
					if (touch && (touch.phase == TouchPhase.HOVER))
					{
						hoverTouch = touch;
						hoverTarget = touch.target;
					}
					
					processTouch.apply(this, touchArgs);
					processedTouchIds.push(touchId);
				}
				
				// if the target of a hovering touch changed, we dispatch an event to the previous
				// target to notify it that it's no longer being hovered over.
				if (hoverTarget && (hoverTouch.target != hoverTarget))
				{
					hoverTarget.dispatchEvent(new TouchEvent(TouchEvent.TOUCH, _currentTouches, _shiftDown, _ctrlDown));
				}
				
				// dispatch events
				for each (touchId in processedTouchIds)
				{
					touch = getCurrentTouch(touchId);
					touch.target.dispatchEvent(new TouchEvent(TouchEvent.TOUCH, _currentTouches, _shiftDown, _ctrlDown));
				}
				
				// remove ended touches
				_currentTouches = _currentTouches.filter(function(currentTouch:Touch, ...rest):Boolean
				{
					return (currentTouch.phase != TouchPhase.ENDED);
				});
				
				// timestamps must differ for remaining touches
				if (_queue.length != 0)
					_elapsedTime += 0.00001;
			}
		}
		
		public function enqueue(touchId:int, phase:String, globalX:Number, globalY:Number):void
		{
			_queue.unshift(arguments);
			
			// multitouch simulation (only with mouse)
			if (_ctrlDown && simulateMultitouch && (touchId == 0))
			{
				_touchMarker.moveMarker(globalX, globalY, _shiftDown);
				
				// noly mouse can hover
				if (phase != TouchPhase.HOVER)
					_queue.unshift([1, phase, _touchMarker.mockX, _touchMarker.mockY]);
			}
		}
		
		private function processTouch(touchId:int, phase:String, globalX:Number, globalY:Number):void
		{
			var position:Point = new Point(globalX, globalY);
			var touch:Touch = getCurrentTouch(touchId);
			
			if (touch == null)
			{
				touch = new Touch(touchId, globalX, globalY, phase, null);
				addCurrentTouch(touch);
			}
			
			touch.setPosition(globalX, globalY);
			touch.setPhase(phase);
			touch.setTimestamp(_elapsedTime);
			
			if ((phase == TouchPhase.HOVER) || (phase == TouchPhase.BEGAN))
				touch.setTarget(_root.hitTestPoint(position, true));
			
			if (phase == TouchPhase.BEGAN)
				processTap(touch);
		}
		
		private function onKey(e:KeyboardEvent):void
		{
			if (e.keyCode == KeyCode.CTRL)
			{
				_ctrlDown = (e.type == KeyboardEvent.KEY_DOWN);
				
				if (simulateMultitouch)
				{
					_touchMarker.visible = _ctrlDown;
					_touchMarker.moveCenter(_root.width/2, _root.height/2);
					
					// if currently active, end mocked touch
					var mockedTouch:Touch = getCurrentTouch(1);
					if (mockedTouch && (mockedTouch.phase != TouchPhase.ENDED))
						enqueue(1, TouchPhase.ENDED, mockedTouch.globalX, mockedTouch.globalY);
				}
				else if (e.keyCode == KeyCode.SHIFT)
				{
					_shiftDown = (e.type == KeyboardEvent.KEY_DOWN);	
				}
			}
		}
		
		private function processTap(touch:Touch):void
		{
			var nearbyTap:Touch = null;
			var minSqDist:Number = MULTITAP_DISTANCE * MULTITAP_DISTANCE;
			
			for each (var tap:Touch in _lastTaps)
			{
				var sqDist:Number = Math.pow(tap.globalX - touch.globalX, 2) + Math.pow(tap.globalY - touch.globalY, 2);
				if (sqDist <= minSqDist)
				{
					nearbyTap = tap;
					break;
				}
			}
			
			if (nearbyTap)
			{
				touch.setTapCount(nearbyTap.tapCount + 1);
				_lastTaps.splice(_lastTaps.indexOf(nearbyTap), 1);
			}
			else
			{
				touch.setTapCount(1);
			}
			
			_lastTaps.push(touch.clone());
		}
		
		private function addCurrentTouch(touch:Touch):void
		{
			_currentTouches = _currentTouches.filter(function(existingTouch:Touch, ...rest):Boolean
			{
				return (existingTouch.id != touch.id);
			});
			
			_currentTouches.push(touch);
		}
		
		private function getCurrentTouch(touchId:int):Touch
		{
			for each (var touch:Touch in _currentTouches)
			{
				if (touch.id == touchId)
					return touch;
			}
			
			return null;
		}
		
		public function get simulateMultitouch():Boolean { return _touchMarker != null; }
		public function set simulateMultitouch(value:Boolean):void
		{
			if (simulateMultitouch == value)
				return;
			
			if (value)
			{
				_touchMarker = new TouchMarker();
				_touchMarker.visible = false;
				_root.addChild(_touchMarker);
			}
			else
			{
				_touchMarker.removeFromParent(true);
				_touchMarker = null;
			}
		}
	}
}
