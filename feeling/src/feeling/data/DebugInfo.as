package feeling.data
{
    import flash.display.Sprite;
    import flash.text.TextField;

    public class DebugInfo extends Sprite
    {
        public var lastFps:Number;
        public var currentFps:Number;
        public var fpsTxt:TextField;

        public function DebugInfo()
        {
            fpsTxt = new TextField();
            fpsTxt.textColor = 0xffff00;
            fpsTxt.mouseEnabled = false;
            addChild(fpsTxt);
        }
    }
}
