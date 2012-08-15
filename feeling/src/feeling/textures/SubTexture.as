package feeling.textures
{
    import feeling.ds.VertexData;

    import flash.display3D.textures.TextureBase;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class SubTexture extends Texture
    {
        private var _baseTexture:Texture;
        private var _clipping:Rectangle;
        private var _rootClipping:Rectangle;

        public function SubTexture(baseTexture:Texture, region:Rectangle)
        {
            _baseTexture = baseTexture;

            clipping = new Rectangle(region.x / baseTexture.width, region.y / baseTexture.height, region.width / baseTexture.
                width, region.height / baseTexture.height);
        }

        public override function get width():Number  { return _baseTexture.width * _clipping.width; }
        public override function get height():Number  { return _baseTexture.height * _clipping.height; }

        public override function get base():TextureBase  { return _baseTexture.base; }

        public override function adjustVertexData(vertexData:VertexData):VertexData
        {
            var newData:VertexData = super.adjustVertexData(vertexData);

            var clipX:Number = _rootClipping.x;
            var clipY:Number = _rootClipping.y;
            var clipWidth:Number = _rootClipping.width;
            var clipHeight:Number = _rootClipping.height;

            for (var i:int = 0; i < vertexData.numVertices; ++i)
            {
                var texCoords:Point = vertexData.getTexCoords(i);
                newData.setTexCoords(i, clipX + texCoords.x * clipWidth, clipY + texCoords.y * clipHeight);
            }

            return newData;
        }

        public function get baseTexture():Texture  { return _baseTexture; }

        public function get clipping():Rectangle  { return clipping.clone(); }
        public function set clipping(value:Rectangle):void
        {
            _clipping = value.clone();
            _rootClipping = value.clone();

            var baseTexture:SubTexture = _baseTexture as SubTexture;
            while (baseTexture)
            {
                var baseClipping:Rectangle = baseTexture._clipping;
                _rootClipping.x = baseClipping.x + _rootClipping.x * baseClipping.width;
                _rootClipping.y = baseClipping.y + _rootClipping.y * baseClipping.height;
                _rootClipping.width *= baseClipping.width;
                _rootClipping.height *= baseClipping.height;
                _baseTexture = baseTexture._baseTexture as SubTexture;
            }
        }
    }
}
