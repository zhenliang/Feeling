package feeling.events
{
    import feeling.display.Image;
    import feeling.display.Sprite;
    import feeling.textures.Texture;
    import feeling.textures.TextureCreator;

    import flash.geom.Point;

    public class TouchMarker extends Sprite
    {
        [Embed(source = "media/textures/touch_marker.png")]
        private const TouchMarkerBmp:Class;

        private var _center:Point;
        private var _texture:Texture;

        public function TouchMarker()
        {
            _center = new Point();
            _texture = TextureCreator.createFromBitmap(new TouchMarkerBmp());

            for (var i:int = 0; i < 2; ++i)
            {
                var marker:Image = new Image(_texture);
                marker.z = -1.0;
                marker.pivotX = _texture.width / 2;
                marker.pivotY = _texture.height / 2;
                marker.touchable = false;
                addChild(marker);
            }
        }

        public override function dispose():void
        {
            _texture.dispose();
            super.dispose();
        }

        public function moveMarker(x:Number, y:Number, withCenter:Boolean = false):void
        {
            if (withCenter)
            {
                _center.x += x - realMarker.x;
                _center.y += y - realMarker.y;
            }

            realMarker.x = x;
            realMarker.y = y;
            mockMarker.x = 2 * _center.x - x;
            mockMarker.y = 2 * _center.y - y;
        }

        public function moveCenter(x:Number, y:Number):void
        {
            _center.x = x;
            _center.y = y;
            moveMarker(realX, realY); // reset mock position
        }

        public function get realX():Number  { return realMarker.x; }

        public function get realY():Number  { return realMarker.y; }

        public function get mockX():Number  { return mockMarker.x; }

        public function get mockY():Number  { return mockMarker.y; }

        private function get realMarker():Image  { return getChildAt(0) as Image; }

        private function get mockMarker():Image  { return getChildAt(1) as Image; }
    }
}
