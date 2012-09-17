package feeling.events
{
    /** A ResizeEvent is dispatched by the stage when the size of the Flash container changes.
     *  Use it to update the Starling viewport and the stage size.
     *
     *  <p>The event contains properties containing the updated width and height of the Flash
     *  player. If you want to scale the contents of your stage to fill the screen, update the
     *  <code>Starling.current.viewPort</code> rectangle accordingly. If you want to make use of
     *  the additional screen estate, update the values of <code>stage.stageWidth</code> and
     *  <code>stage.stageHeight</code> as well.</p>
     *
     *  @see starling.display.Stage
     *  @see starling.core.Starling
     */
    public class ResizeEvent extends Event
    {
        /** Event type for a resized Flash player. */
        public static const RESIZE:String = "resize";

        private var _width:int;
        private var _height:int;

        /** Creates a new ResizeEvent. */
        public function ResizeEvent(type:String, width:int, height:int, bubbles:Boolean = false)
        {
            super(type, bubbles);
            _width = width;
            _height = height;
        }

        /** The updated width of the player. */
        public function get width():int  { return _width; }

        /** The updated height of the player. */
        public function get height():int  { return _height; }
    }
}
