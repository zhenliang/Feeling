package feeling.textures
{
    import feeling.data.VertexData;

    import flash.display3D.textures.TextureBase;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class SubTexture extends Texture
    {
        private var _parent:Texture;
        private var _clipping:Rectangle;
        private var _rootClipping:Rectangle;

        public function SubTexture(parentTexture:Texture, region:Rectangle)
        {
            _parent = parentTexture;

            clipping = new Rectangle(region.x / parentTexture.width, region.y / parentTexture.height, region.width / parentTexture.
                width, region.height / parentTexture.height);
        }

        public override function get base():TextureBase  { return _parent.base; }

        public override function get width():Number  { return _parent.width * _clipping.width; }
        public override function get height():Number  { return _parent.height * _clipping.height; }

        public override function get premultipliedAlpha():Boolean  { return _parent.premultipliedAlpha; }

        public override function adjustVertexData(vertexData:VertexData):VertexData
        {
            var newData:VertexData = super.adjustVertexData(vertexData);
            var numVertices:int = vertexData.numVertices;

            var clipX:Number = _rootClipping.x;
            var clipY:Number = _rootClipping.y;
            var clipWidth:Number = _rootClipping.width;
            var clipHeight:Number = _rootClipping.height;

            for (var i:int = 0; i < numVertices; ++i)
            {
                var texCoords:Point = vertexData.getTexCoords(i);
                newData.setTexCoords(i, clipX + texCoords.x * clipWidth, clipY + texCoords.y * clipHeight);
            }

            return newData;
        }

        public function get parent():Texture  { return _parent; }

        public function get clipping():Rectangle  { return clipping.clone(); }
        public function set clipping(value:Rectangle):void
        {
            _clipping = value.clone();
            _rootClipping = value.clone();

            var parentTexture:SubTexture = _parent as SubTexture;
            while (parentTexture)
            {
                var parentClipping:Rectangle = parentTexture._clipping;
                _rootClipping.x = parentClipping.x + _rootClipping.x * parentClipping.width;
                _rootClipping.y = parentClipping.y + _rootClipping.y * parentClipping.height;
                _rootClipping.width *= parentClipping.width;
                _rootClipping.height *= parentClipping.height;
                _parent = parentTexture._parent as SubTexture;
            }
        }
    }
}
