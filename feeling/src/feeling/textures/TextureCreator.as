package feeling.textures
{
    import feeling.core.Feeling;
    import feeling.utils.getNextPowerOfTwo;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display3D.Context3DTextureFormat;
    import flash.geom.Point;
    import flash.geom.Rectangle;

    public class TextureCreator
    {
        /** Creates a texture object from a bitmap.*/
        public static function createFromBitmap(bitmap:Bitmap, optimizeForRenderTexture:Boolean = false):Texture
        {
            return createFromBitmapData(bitmap.bitmapData, optimizeForRenderTexture);
        }

        /** Creates a texture from bitmap data. */
        public static function createFromBitmapData(data:BitmapData, optimizeForRenderTexture:Boolean = false):Texture
        {
            var origWidth:int = data.width;
            var origHeight:int = data.height;
            var legalWidth:int = getNextPowerOfTwo(data.width);
            var legalHeight:int = getNextPowerOfTwo(data.height);

            var format:String = Context3DTextureFormat.BGRA;

            import flash.display3D.textures.Texture;
            var nativeTexture:flash.display3D.textures.Texture = Feeling.instance.context3d.createTexture(legalWidth, legalHeight,
                format, optimizeForRenderTexture);

            if ((legalWidth > origWidth) || (legalHeight > origHeight))
            {
                var potData:BitmapData = new BitmapData(legalWidth, legalHeight, true, 0);
                potData.copyPixels(data, data.rect, new Point(0, 0));
                nativeTexture.uploadFromBitmapData(potData);
                potData.dispose();
            }
            else
            {
                nativeTexture.uploadFromBitmapData(data);
            }

            var concreteTexture:feeling.textures.Texture = new ConcreteTexture(nativeTexture, legalWidth, legalHeight, true);
            return createFromTexture(concreteTexture, new Rectangle(0, 0, origWidth, origHeight));
        }

        /** Creates a texture that contains a region (in pixels) of another texture. The new
         *  texture will reference the base texture; no data is duplicated. */
        public static function createFromTexture(texture:Texture, region:Rectangle):Texture
        {
            if ((region.x == 0) && (region.y == 0) && (region.width == texture.width) && (region.height == texture.height))
            {
                return texture;
            }
            else
            {
                return new SubTexture(texture, region);
            }
        }
    }
}
