package
{
    import com.feeling.core.Feeling;
    import com.feeling.core.RenderSupport;
    import com.feeling.display.DisplayObjectContainer;
    import com.feeling_ex.DebugCamera;

    public class Game extends DisplayObjectContainer
    {
        public function Game()
        {
			var feeling:Feeling = Feeling.instance;
			var renderSupport:RenderSupport = feeling.renderSupport;
			renderSupport.camera.removeFromParent(true);
			renderSupport.camera = new DebugCamera();
			
            var myQuad1:MyQuad = new MyQuad( 50, 50, 0x0000ff );
			myQuad1.x = 0;
			myQuad1.y = 0;
			myQuad1.z = -100;
            addChild( myQuad1 );
			
			var myQuad2:MyQuad = new MyQuad( 50, 50, 0xff0000 );
			myQuad2.x = 150;
			myQuad2.y = -50;
			myQuad2.z = -200;
			addChild( myQuad2 );
			
			var myQuad3:MyQuad = new MyQuad( 50, 50, 0x00ff00 );
			myQuad3.x = -150;
			myQuad3.y = 200;
			myQuad3.z = -150;
			addChild( myQuad3 );
			
			for (var i:int = 0; i < 150; i++)
			{
				var randomQuad:MyQuad = new MyQuad(30, 30, 0xffffff * Math.random());
				randomQuad.x = -500 + 1000 * Math.random();
				randomQuad.y = -280 + 560 * Math.random();
				randomQuad.z = -1000 + 2000 * Math.random();
				addChild( randomQuad );
			}
        }
    }
}
