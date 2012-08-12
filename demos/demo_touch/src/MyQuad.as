package
{
    import feeling.display.Quad;
    import feeling.events.EnterFrameEvent;
    import feeling.events.Event;
    import feeling.events.Touch;
    import feeling.events.TouchEvent;
    import feeling.events.TouchPhase;

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
            var touch:Touch = e.getTouch(this);
            if (!touch)
                return;

            if (touch.phase == TouchPhase.BEGAN)
                SetColor(0xff0000);
            else if (touch.phase == TouchPhase.ENDED)
                SetColor(0x00ff00);
            else if (touch.phase == TouchPhase.HOVER)
                SetColor(0x0000ff);
            else if (touch.phase == TouchPhase.MOVED)
                SetColor(0x00ffff);
            else if (touch.phase == TouchPhase.STATIONARY)
                SetColor(0xffff00);
        }

        private function SetColor(color:uint):void
        {
            // this.color = ~_vertexData.getColor(1);
            setVertexColor(0, ~_vertexData.getColor(1));
            setVertexColor(1, ~_vertexData.getColor(2));
            setVertexColor(2, ~_vertexData.getColor(3));
            setVertexColor(3, ~_vertexData.getColor(0));
        }
    }
}
