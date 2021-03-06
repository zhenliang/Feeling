package feeling.events
{
    /** A class that provides constant values for the phases of a touch object.
     *
     *  <p>A touch moves through at least the following phases in its life:</p>
     *
     *  <code>BEGAN -> MOVED -> ENDED</code>
     *
     *  <p>Furthermore, a touch can enter a <code>STATIONARY</code> phase. That phase will not
     *  trigger an event itself, but you might receive it when another touch does so.</p>
     *
     *  <p>Finally, there's the <code>HOVER</code> phase, which is exclusive to mouse input. It is
     *  the equivalent of a <code>MouseOver</code> event in Flash when the mouse button is
     *  <em>not</em> pressed.</p>
     */
    public class TouchPhase
    {
        /** Only available for mouse input: the cursor hovers over an object <em>without</em> a
         *  pressed button. */
        public static const HOVER:String = "hover";

        /** The finger touched the screen just now, or the mouse button was pressed. */
        public static const BEGAN:String = "began";

        /** The finger moves around on the screen, or the mouse is moved while the button is
         *  pressed. */
        public static const MOVED:String = "moved";

        /** The finger or mouse (with pressed button) has not moved since the last frame. */
        public static const STATIONARY:String = "stationary";

        /** The finger was lifted from the screen or from the mouse button. */
        public static const ENDED:String = "ended";
    }
}
