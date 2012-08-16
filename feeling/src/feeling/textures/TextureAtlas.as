package feeling.textures
{
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;

    public class TextureAtlas
    {
        private var _atlasTexture:Texture;
        private var _textureRegions:Dictionary;
        private var _textureFrames:Dictionary;

        public function TextureAtlas(texture:Texture, atlasXml:XML = null)
        {
            _textureRegions = new Dictionary();
            _textureFrames = new Dictionary();
            _atlasTexture = texture;

            if (atlasXml)
                parseAtlasXml(atlasXml);
        }

        public function dispose():void
        {
            _atlasTexture.dispose();
        }

        private function parseAtlasXml(atlasXml:XML):void
        {
            for each (var subTexture:XML in atlasXml.SubTexture)
            {
                var name:String = subTexture.attribute("name");
                var x:Number = parseFloat(subTexture.attribute("x"));
                var y:Number = parseFloat(subTexture.attribute("y"));
                var width:Number = parseFloat(subTexture.attribute("width"));
                var height:Number = parseFloat(subTexture.attribute("height"));
                var frameX:Number = parseFloat(subTexture.attribute("frameX"));
                var frameY:Number = parseFloat(subTexture.attribute("frameY"));
                var frameWidth:Number = parseFloat(subTexture.attribute("frameWidth"));
                var frameHeight:Number = parseFloat(subTexture.attribute("frameHeight"));

                var region:Rectangle = new Rectangle(x, y, width, height);
                var frame:Rectangle = ((frameWidth > 0) && (frameHeight > 0)) ? new Rectangle(frameX, frameY, frameWidth,
                    frameHeight) : null;

                addRegion(name, region, frame);
            }
        }

        public function getTexture(name:String):Texture
        {
            var region:Rectangle = _textureRegions[name];

            if (!region)
                return null;
            else
            {
                var texture:Texture = TextureCreator.createFromTexture(_atlasTexture, region);
                texture.frame = _textureFrames[name];
                return texture;
            }
        }

        public function getTextures(prefix:String = ""):Array
        {
            var textures:Array = [];
            var names:Array = [];
            var name:String;

            for (name in _textureRegions)
                if (name.indexOf(prefix) == 0)
                    names.push(name);

            names.sort(Array.CASEINSENSITIVE);

            for each (name in names)
                textures.push(getTexture(name));

            return textures;
        }

        public function addRegion(name:String, region:Rectangle, frame:Rectangle = null):void
        {
            _textureRegions[name] = region;
            if (frame)
                _textureFrames[name] = frame;
        }

        public function removeRegion(name:String):void
        {
            delete _textureRegions[name];
        }
    }
}
