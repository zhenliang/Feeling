package feeling.textures
{
    import feeling.config.Config;
    import feeling.data.CoordType;
    import feeling.data.VertexData;

    import flash.display3D.textures.TextureBase;
    import flash.geom.Rectangle;
    import flash.utils.getQualifiedClassName;

    public class Texture
    {
        private var _frame:Rectangle;

        public function Texture()
        {
            if (getQualifiedClassName(this) == "feeling.textures::Texture")
                throw new Error();
        }

        public function dispose():void  {}

        public function get width():Number  { return 0; }
        public function get height():Number  { return 0; }

        public function get base():TextureBase  { return null; }

        public function get frame():Rectangle  { return _frame; }
        public function set frame(value:Rectangle):void  { _frame = value ? value.clone() : null; }

        public function get premultipliedAlpha():Boolean  { return false; }

        public function adjustVertexData(vertexData:VertexData):VertexData
        {
            var clone:VertexData = vertexData.clone();

            if (_frame)
            {
                var deltaRight:Number = _frame.width + _frame.x - width;
                var deltaBottom:Number = _frame.width + _frame.y - height;

                if (Config.COORD_TYPE == CoordType.FLASH_2D)
                {
                    // x 左到右，y 上到下
                    clone.translateVertex(0, -_frame.x, -_frame.y);
                    clone.translateVertex(1, -deltaRight, -_frame.y);
                    clone.translateVertex(2, -_frame.x, -deltaBottom);
                    clone.translateVertex(3, -deltaRight, -deltaBottom);
                }
                else
                {
                    // x 左到右，y 下到上
                    clone.translateVertex(0, -_frame.x, _frame.y);
                    clone.translateVertex(1, -deltaRight, _frame.y);
                    clone.translateVertex(2, -_frame.x, deltaBottom);
                    clone.translateVertex(3, -deltaRight, deltaBottom);
                }
            }

            return clone;
        }
    }
}
