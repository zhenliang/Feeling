package
{
    import feeling.textures.Texture;
    import feeling.textures.TextureAtlas;
    import feeling.textures.TextureCreator;

    import flash.display.Bitmap;
    import flash.utils.Dictionary;

    public class Assets
    {
        // Bitmaps

        [Embed(source = "../../media/textures/2x/background.png")]
        public static const Background:Class;

        [Embed(source = "../../media/textures/2x/logo.png")]
        public static const Logo:Class;

        [Embed(source = "../../media/textures/2x/button_back.png")]
        public static const ButtonBack:Class;

        [Embed(source = "../../media/textures/2x/button_big.png")]
        public static const ButtonBig:Class;

        [Embed(source = "../../media/textures/2x/button_normal.png")]
        public static const ButtonNormal:Class;

        [Embed(source = "../../media/textures/2x/button_square.png")]
        public static const ButtonSquare:Class;

        [Embed(source = "../../media/textures/2x/benchmark_object.png")]
        public static const BenchmarkObject:Class;

        [Embed(source = "../../media/textures/2x/starling_front.png")]
        public static const StarlingFront:Class;

        [Embed(source = "../../media/textures/2x/atlas.png")]
        public static const Atlas:Class;

        [Embed(source = "../../media/textures/2x/atlas.xml", mimeType = "application/octet-stream")]
        public static const AtlasXml:Class;

        public static function getTexture(name:String):Texture
        {
            if (!sTextures[name])
            {
                var bitmap:Bitmap = new Assets[name]();
                sTextures[name] = TextureCreator.createFromBitmap(bitmap);
            }

            return sTextures[name];
        }

        public static function getTextureAtlas():TextureAtlas
        {
            var texture:Texture = getTexture("Atlas");
            var xml:XML = XML(new Assets["AtlasXml"]);
            return new TextureAtlas(texture, xml);
        }

        private static var sTextures:Dictionary = new Dictionary();
    }
}

