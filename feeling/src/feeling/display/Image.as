package feeling.display
{
    import feeling.core.Feeling;
    import feeling.core.RenderSupport;
    import feeling.core.ShaderManager;
    import feeling.data.VertexData;
    import feeling.shaders.ImageShader;
    import feeling.textures.Texture;
    import feeling.textures.TextureCreator;

    import flash.display.Bitmap;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    /** An Image is a quad with a texture mapped onto it.
     *
     *  <p>The Image class is the Starling equivalent of Flash's Bitmap class. Instead of
     *  BitmapData, Starling uses textures to represent the pixels of an image. To display a
     *  texture, you have to map it onto a quad - and that's what the Image class is for.</p>
     *
     *  <p>As "Image" inherits from "Quad", you can give it a color. For each pixel, the resulting
     *  color will be the result of the multiplication of the color of the texture with the color of
     *  the quad. That way, you can easily tint textures with a certain color. Furthermore, images
     *  allow the manipulation of texture coordinates. That way, you can move a texture inside an
     *  image without changing any vertex coordinates of the quad. You can also use this feature
     *  as a very efficient way to create a rectangular mask.</p>
     *
     *  @see starling.textures.Texture
     *  @see Quad
     */
    public class Image extends Quad
    {
        private var _texture:Texture;

        /** Creates an Image with a texture that is created from a bitmap object. */
        public static function fromBitmap(bitmap:Bitmap):Image
        {
            return new Image(TextureCreator.createFromBitmap(bitmap));
        }

        /** Creates a quad with a texture mapped onto it. */
        public function Image(texture:Texture)
        {
            if (texture)
            {
                var frame:Rectangle = texture.frame;
                var width:Number = frame ? frame.width : texture.width;
                var height:Number = frame ? frame.height : texture.height;

                super(width, height);

                _vertexData.premultipliedAlpha = texture.premultipliedAlpha;
                _vertexData.setTexCoords(0, 0.0, 0.0);
                _vertexData.setTexCoords(1, 1.0, 0.0);
                _vertexData.setTexCoords(2, 0.0, 1.0);
                _vertexData.setTexCoords(3, 1.0, 1.0);
                _texture = texture;
            }
            else
            {
                throw new Error();
            }
        }

        /** Disposes vertex- and index-buffer, but does NOT dispose the texture! */
        public override function dispose():void
        {
            super.dispose();
        }

        /** Gets the texture coordinates of a vertex. Coordinates are in the range [0, 1]. */
        public function getTexCoords(vertexId:int):Point  { return _vertexData.getTexCoords(vertexId); }

        /** Sets the texture coordinates of a vertex. Coordinates are in the range [0, 1]. */
        public function setTexCoords(vertexId:int, coords:Point):void
        {
            _vertexData.setTexCoords(vertexId, coords.x, coords.y);
            if (_vertexBuffer)
                createVertexBuffer();
        }

        /** Returns a 'VertexData' object with the raw data of the object required for rendering.
         *  The texture coordinates are already in their refined format. */
        public override function get vertexData():VertexData  { return _texture.adjustVertexData(_vertexData); }

        /** The texture that is displayed on the quad. */
        public function get texture():Texture  { return _texture; }
        public function set texture(value:Texture):void
        {
            if (!value)
                throw new Error();
            else if (value != _texture)
            {
                _texture = value;
                _vertexData.premultipliedAlpha = _texture.premultipliedAlpha;
                if (_vertexBuffer)
                    createVertexBuffer();
            }
        }

        /** @inheritDoc */
        public override function render(alpha:Number):void
        {
            var context:Context3D = Feeling.instance.context3d;
            var shaderMgr:ShaderManager = Feeling.instance.shaderManager;
            var renderSupport:RenderSupport = Feeling.instance.renderSupport;

            if (!_vertexBuffer)
                createVertexBuffer();
            if (!_indexBuffer)
                createIndexBuffer();

            alpha *= this.alpha;

            var pma:Boolean = _texture.premultipliedAlpha;
            var alphaVec:Vector.<Number> = pma ? new <Number>[alpha, alpha, alpha, alpha] : new <Number>[1.0, 1.0, 1.0, alpha];
            renderSupport.setupDefaultBlendFactors(pma);

            context.setProgram(shaderMgr.getProgram(ImageShader.PROGRAM_NAME));
            context.setTextureAt(1, _texture.base);
            context.setVertexBufferAt(0, _vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_3);
            context.setVertexBufferAt(1, _vertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
            context.setVertexBufferAt(2, _vertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, renderSupport.mvpMatrix, true);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, alphaVec, 1);
            context.drawTriangles(_indexBuffer, 0, 2);

            context.setTextureAt(1, null);
            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
            context.setVertexBufferAt(2, null);
        }
    }
}
