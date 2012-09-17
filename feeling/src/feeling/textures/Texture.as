package feeling.textures
{
    import feeling.config.Config;
    import feeling.data.CoordType;
    import feeling.data.VertexData;

    import flash.display3D.textures.TextureBase;
    import flash.geom.Rectangle;
    import flash.utils.getQualifiedClassName;

    /** <p>A texture stores the information that represents an image. It cannot be added to the
     *  display list directly; instead it has to be mapped onto a display object. In Starling,
     *  that display object is the class "Image".</p>
     *
     *  <strong>Texture Formats</strong>
     *
     *  <p>Since textures can be created from a "BitmapData" object, Starling supports any bitmap
     *  format that is supported by Flash. And since you can render any Flash display object into
     *  a BitmapData object, you can use this to display non-Starling content in Starling - e.g.
     *  Shape objects.</p>
     *
     *  <p>Starling also supports ATF textures (Adobe Texture Format), which is a container for
     *  compressed texture formats that can be rendered very efficiently by the GPU. Refer to
     *  the Flash documentation for more information about this format.</p>
     *
     *  <strong>Mip Mapping</strong>
     *
     *  <p>MipMaps are scaled down versions of a texture. When an image is displayed smaller than
     *  its natural size, the GPU may display the mip maps instead of the original texture. This
     *  reduces aliasing and accelerates rendering. It does, however, also need additional memory;
     *  for that reason, you can choose if you want to create them or not.</p>
     *
     *  <strong>Texture Frame</strong>
     *
     *  <p>The frame property of a texture allows you to define the position where the texture will
     *  appear within an Image. The rectangle is specified in the coordinate system of the
     *  texture (not the image):</p>
     *
     *  <listing>
     *  texture.frame = new Rectangle(-10, -10, 30, 30);
     *  var image:Image = new Image(texture);
     *  </listing>
     *
     *  <p>This code would create an image with a size of 30x30, with the texture placed at
     *  <code>x=10, y=10</code> within that image (assuming that the texture has a width and
     *  height of 10 pixels, it would appear in the middle of the image).
     *  The texture atlas makes use of this feature, as it allows to crop transparent edges
     *  of a texture and making up for the changed size by specifying the original texture frame.
     *  Tools like <a href="http://www.texturepacker.com/">TexturePacker</a> use this to
     *  optimize the atlas.</p>
     *
     *  @see starling.display.Image
     *  @see TextureAtlas
     */
    public class Texture
    {
        private var _frame:Rectangle;

        /** @private */
        public function Texture()
        {
            if (getQualifiedClassName(this) == "feeling.textures::Texture")
                throw new Error();
        }

        /** Disposes the underlying texture data. */
        public function dispose():void  {}

        /** The width of the texture in pixels. */
        public function get width():Number  { return 0; }

        /** The height of the texture in pixels. */
        public function get height():Number  { return 0; }

        /** The Stage3D texture object the texture is based on. */
        public function get base():TextureBase  { return null; }

        /** The texture frame (see class description). @default null */
        public function get frame():Rectangle  { return _frame; }
        public function set frame(value:Rectangle):void  { _frame = value ? value.clone() : null; }

        /** Indicates if the alpha values are premultiplied into the RGB values. */
        public function get premultipliedAlpha():Boolean  { return false; }

        /** Converts texture coordinates and vertex positions of raw vertex data into the format
         *  required for rendering. */
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
