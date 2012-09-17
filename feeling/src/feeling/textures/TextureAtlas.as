package feeling.textures
{
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;

    /** A texture atlas is a collection of many smaller textures in one big image. This class
     *  is used to access textures from such an atlas.
     *
     *  <p>Using a texture atlas for your textures solves two problems:</p>
     *
     *  <ul>
     *    <li>There is always one texture active at a given moment. Whenever you change the active
     *        texture, a "texture-switch" has to be executed, and that switch takes time.</li>
     *    <li>Any Stage3D texture has to have side lengths that are powers of two. Starling hides
     *        this limitation from you, but at the cost of additional graphics memory.</li>
     *  </ul>
     *
     *  <p>By using a texture atlas, you avoid both texture switches and the power-of-two
     *  limitation. All textures are within one big "super-texture", and Starling takes care that
     *  the correct part of this texture is displayed.</p>
     *
     *  <p>There are several ways to create a texture atlas. One is to use the atlas generator
     *  script that is bundled with Starling's sibling, the <a href="http://www.sparrow-framework.org">
     *  Sparrow framework</a>. It was only tested in Mac OS X, though. A great multi-platform
     *  alternative is the commercial tool <a href="http://www.texturepacker.com">
     *  Texture Packer</a>.</p>
     *
     *  <p>Whatever tool you use, Starling expects the following file format:</p>
     *
     *  <listing>
     * 	&lt;TextureAtlas imagePath='atlas.png'&gt;
     * 	  &lt;SubTexture name='texture_1' x='0'  y='0' width='50' height='50'/&gt;
     * 	  &lt;SubTexture name='texture_2' x='50' y='0' width='20' height='30'/&gt;
     * 	&lt;/TextureAtlas&gt;
     *  </listing>
     *
     *  <p>If your images have transparent areas at their edges, you can make use of the
     *  <code>frame</code> property of the Texture class. Trim the texture by removing the
     *  transparent edges and specify the original texture size like this:</p>
     *
     *  <listing>
     * 	&lt;SubTexture name='trimmed' x='0' y='0' height='10' width='10'
     * 	    frameX='-10' frameY='-10' frameWidth='30' frameHeight='30'/&gt;
     *  </listing>
     */
    public class TextureAtlas
    {
        private var _atlasTexture:Texture;
        private var _textureRegions:Dictionary;
        private var _textureFrames:Dictionary;

        /** Create a texture atlas from a texture by parsing the regions from an XML file. */
        public function TextureAtlas(texture:Texture, atlasXml:XML = null)
        {
            _textureRegions = new Dictionary();
            _textureFrames = new Dictionary();
            _atlasTexture = texture;

            if (atlasXml)
                parseAtlasXml(atlasXml);
        }

        /** Disposes the atlas texture. */
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

        /** Retrieves a subtexture by name. Returns <code>null</code> if it is not found. */
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

        /** Returns all textures that start with a certain string, sorted alphabetically
         *  (especially useful for "MovieClip"). */
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

        /** Creates a region for a subtexture and gives it a name. */
        public function addRegion(name:String, region:Rectangle, frame:Rectangle = null):void
        {
            _textureRegions[name] = region;
            if (frame)
                _textureFrames[name] = frame;
        }

        /** Removes a region with a certain name. */
        public function removeRegion(name:String):void
        {
            delete _textureRegions[name];
        }
    }
}
