package
{
    import feeling.core.Feeling;
    import feeling.core.RenderSupport;
    import feeling.display.DisplayObjectContainer;
    import feeling.display.MovieClip;
    import feeling.display.Quad;
    import feeling.events.Event;
    import feeling.textures.TextureAtlas;

    import feeling_ex.DebugCamera;

    public class Game extends DisplayObjectContainer
    {
        private var _movieClip:MovieClip;

        public function Game()
        {
            var feeling:Feeling = Feeling.instance;
            var renderSupport:RenderSupport = feeling.renderSupport;
            renderSupport.camera.removeFromParent(true);
            renderSupport.camera = new DebugCamera();

            var textureAtlas:TextureAtlas = Assets.getTextureAtlas();
            _movieClip = new MovieClip(textureAtlas.getTextures(), 12);
            _movieClip.x = 0;
            _movieClip.y = 0;
            _movieClip.pivotX = _movieClip.width / 2;
            _movieClip.pivotY = -_movieClip.height / 2;
            _movieClip.z = -500;
            addChild(_movieClip);

            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
        }

        public function onAddedToStage(... args):void
        {
            Feeling.instance.juggler.add(_movieClip);
        }

        public function onRemovedFromStage(... args):void
        {
            Feeling.instance.juggler.remove(_movieClip);
        }

    }
}
