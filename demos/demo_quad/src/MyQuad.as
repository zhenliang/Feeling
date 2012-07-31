package
{
    import com.feeling.display.Quad;
    import com.feeling.events.EnterFrameEvent;
    import com.feeling.events.Event;

    public class MyQuad extends Quad
    {
		private static var ROTATE_SPEED:Number = 40;
		
		private var _rotateScale:Number;
		
        public function MyQuad( width:Number, height:Number, color:uint = 16777215 )
        {
            super( width, height, color );
			
			_rotateScale = Math.random();
			
            pivotX = width / 2;
            pivotY = height / 2;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
		
		private function onEnterFrame(e:EnterFrameEvent):void
		{
			rotationZ += e.passedTime * ROTATE_SPEED *_rotateScale;
		}
    }
}
