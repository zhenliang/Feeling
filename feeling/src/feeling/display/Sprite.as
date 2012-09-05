package feeling.display
{
    /** A Sprite is the most lightweight, non-abstract container class.
     *  <p>Use it as a simple means of grouping objects together in one coordinate system, or
     *  as the base class for custom display objects.</p>
     *
     *  <strong>Flattened Sprites</strong>
     *
     *  <p>The <code>flatten</code>-method allows you to optimize the rendering of static parts of
     *  your display list.</p>
     *
     *  <p>It analyzes the tree of children attached to the sprite and optimizes the rendering calls
     *  in a way that makes rendering extremely fast. The speed-up comes at a price, though: you
     *  will no longer see any changes in the properties of the children (position, rotation,
     *  alpha, etc.). To update the object after changes have happened, simply call
     *  <code>flatten</code> again, or <code>unflatten</code> the object.</p>
     *
     *  @see DisplayObject
     *  @see DisplayObjectContainer
     */
    public class Sprite extends DisplayObjectContainer
    {
        /** Creates an empty sprite. */
        public function Sprite()
        {
            super();
        }
    }
}
