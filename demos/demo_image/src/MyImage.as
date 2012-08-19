package
{
    import feeling.display.Image;
    import feeling.events.EnterFrameEvent;
    import feeling.events.Event;
    import feeling.textures.Texture;

    public class MyImage extends Image
    {
        private static var ROTATE_SPEED:Number = 40;

        private var _rotateScale:Number;

        public function MyImage(texture:Texture)
        {
            super(texture);

            _rotateScale = Math.random();

            pivotX = texture.width / 2;
            pivotY = -texture.height / 2;

            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        private function onEnterFrame(e:EnterFrameEvent):void
        {
            rotationZ += e.passedTime * ROTATE_SPEED * _rotateScale;
        }
    }
}
