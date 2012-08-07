package
{
    import feeling.core.Feeling;
    import feeling.core.RenderSupport;
    import feeling.display.DisplayObjectContainer;
    import feeling.events.TouchEvent;

    import feeling_ex.DebugCamera;

    public class Game extends DisplayObjectContainer
    {
        public function Game()
        {
            var feeling:Feeling = Feeling.instance;

            feeling.feelingStage.addEventListener(TouchEvent.TOUCH, onTouch);

            var renderSupport:RenderSupport = feeling.renderSupport;
            renderSupport.camera.removeFromParent(true);
            renderSupport.camera = new DebugCamera();

            var myQuad1:MyQuad = new MyQuad(250, 250, 0x0000ff);
            myQuad1.x = 0;
            myQuad1.y = 0;
            myQuad1.z = -1;
            myQuad1.rotationZ = 45;
            addChild(myQuad1);

            var myQuad2:MyQuad = new MyQuad(50, 50, 0xff0000);
            myQuad2.x = 250;
            myQuad2.y = -50;
            myQuad2.z = -1;
            addChild(myQuad2);

            var myQuad3:MyQuad = new MyQuad(50, 50, 0x00ff00);
            myQuad3.x = -230;
            myQuad3.y = -30;
            myQuad3.z = -1;
            addChild(myQuad3);
        }

        private function onTouch(e:TouchEvent):void
        {
            trace(e.allToucehs + " " + e.timestamp.toFixed(5) + " " + e.target + " " + e.currentTarget);
        }
    }
}