package
{
    import feeling.core.Feeling;

    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;

    [SWF(width = "1000", height = "560", backgroundColor = "#ffffff", frameRate = "31")]
    public class Bootstrap extends Sprite
    {
        public function Bootstrap()
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;

            Feeling.init(Game, stage);
            Feeling.instance.start();
        }
    }
}
