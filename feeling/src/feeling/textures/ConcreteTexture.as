package feeling.textures
{
    import feeling.data.VertexData;

    import flash.display3D.textures.TextureBase;

    public class ConcreteTexture extends Texture
    {
        private var _width:int;
        private var _height:int;
        private var _base:TextureBase;
        private var _premultipliedAlpha:Boolean;

        public function ConcreteTexture(base:TextureBase, width:int, height:int, premultipliedAlpha:Boolean)
        {
            _base = base;
            _width = width;
            _height = height;
            _premultipliedAlpha = premultipliedAlpha;
        }

        public override function dispose():void
        {
            if (_base)
                _base.dispose();
            super.dispose();
        }

        public override function get base():TextureBase  { return _base; }
        public override function get premultipliedAlpha():Boolean  { return _premultipliedAlpha; }
        public override function get width():Number  { return _width; }
        public override function get height():Number  { return _height; }

        public override function adjustVertexData(vertexData:VertexData):VertexData
        {
            return vertexData.clone();
        }
    }
}
