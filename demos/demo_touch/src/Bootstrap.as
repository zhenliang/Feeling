package
{
    import feeling.core.Feeling;

    import flash.display.Sprite;

    [SWF(width = "1000", height = "560", backgroundColor = "#ffffff", frameRate = "31")]
    public class Bootstrap extends Sprite
    {
        public function Bootstrap()
        {
            Feeling.init(Game, stage);
            Feeling.instance.start();
        }
    }
}
