package
{
    import feeling.core.Feeling;
    import feeling.core.RenderSupport;
    import feeling.display.DisplayObjectContainer;
    import feeling.textures.Texture;
    import feeling_ex.DebugCamera;

    public class Game extends DisplayObjectContainer
    {
		private static var _feeling:Feeling;
		
        public function Game()
        {
			var feeling:Feeling = Feeling.instance;
			var renderSupport:RenderSupport = feeling.renderSupport;
			renderSupport.camera.removeFromParent(true);
			renderSupport.camera = new DebugCamera();
			
			var texture:Texture = Assets.getTexture("StarlingFront");
			
			var myImg:MyImage = new MyImage(texture);
			myImg.x = 0;
			myImg.y = 0;
			myImg.z = -500;
			myImg.scaleX = 0.5;
			myImg.scaleY = 0.5;
			addChild(myImg);
			
			for (var i:int = 0; i < 150; i++)
			{
				var randomImg:MyImage = new MyImage(texture);
				randomImg.x = -500 + 1000 * Math.random();
				randomImg.y = -280 + 560 * Math.random();
				randomImg.z = -1000 + 2000 * Math.random();
				randomImg.scaleX = 0.5;
				randomImg.scaleY = 0.5;
				addChild( randomImg );
			}
        }
    }
}
