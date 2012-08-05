package
{
    import feeling.display.Quad;
    import feeling.events.EnterFrameEvent;
    import feeling.events.Event;
    import feeling.events.TouchEvent;

    public class MyQuad extends Quad
    {
        private static var ROTATE_SPEED:Number = 40;

        private var _rotateScale:Number;

        public function MyQuad(width:Number, height:Number, color:uint = 16777215)
        {
            super(width, height, color);

            _rotateScale = Math.random();

            pivotX = width / 2;
            pivotY = height / 2;

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            addEventListener(TouchEvent.TOUCH, onTouch);
        }

        private function onEnterFrame(e:EnterFrameEvent):void
        {
            rotationZ += e.passedTime * ROTATE_SPEED * _rotateScale;
        }

        private function onTouch(e:TouchEvent):void
        {
            rotationZ = 0.0;
        }
    }
}
