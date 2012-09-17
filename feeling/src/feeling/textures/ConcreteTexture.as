package feeling.textures
{
    import feeling.data.VertexData;

    import flash.display3D.textures.TextureBase;

    /** A ConcreteTexture wraps a Stage3D texture object, storing the properties of the texture. */
    public class ConcreteTexture extends Texture
    {
        private var _width:int;
        private var _height:int;
        private var _base:TextureBase;
        private var _premultipliedAlpha:Boolean;

        /** Creates a ConcreteTexture object from a TextureBase, storing information about size,
         *  mip-mapping, and if the channels contain premultiplied alpha values. */
        public function ConcreteTexture(base:TextureBase, width:int, height:int, premultipliedAlpha:Boolean)
        {
            _base = base;
            _width = width;
            _height = height;
            _premultipliedAlpha = premultipliedAlpha;
        }

        /** Disposes the TextureBase object. */
        public override function dispose():void
        {
            if (_base)
                _base.dispose();
            super.dispose();
        }

        /** @inheritDoc */
        public override function get base():TextureBase  { return _base; }
        /** @inheritDoc */
        public override function get premultipliedAlpha():Boolean  { return _premultipliedAlpha; }
        /** @inheritDoc */
        public override function get width():Number  { return _width; }
        /** @inheritDoc */
        public override function get height():Number  { return _height; }
        /** @inheritDoc */
        public override function adjustVertexData(vertexData:VertexData):VertexData  { return vertexData.clone(); }
    }
}
