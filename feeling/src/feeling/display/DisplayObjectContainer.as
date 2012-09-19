package feeling.display
{
    import feeling.core.Feeling;
    import feeling.core.RenderSupport;
    import feeling.events.Event;

    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.getQualifiedClassName;

    /**
     *  A DisplayObjectContainer represents a collection of display objects.
     *  It is the base class of all display objects that act as a container for other objects. By
     *  maintaining an ordered list of children, it defines the back-to-front positioning of the
     *  children within the display tree.
     *
     *  <p>A container does not a have size in itself. The width and height properties represent the
     *  extents of its children. Changing those properties will scale all children accordingly.</p>
     *
     *  <p>As this is an abstract class, you can't instantiate it directly, but have to
     *  use a subclass instead. The most lightweight container class is "Sprite".</p>
     *
     *  <strong>Adding and removing children</strong>
     *
     *  <p>The class defines methods that allow you to add or remove children. When you add a child,
     *  it will be added at the frontmost position, possibly occluding a child that was added
     *  before. You can access the children via an index. The first child will have index 0, the
     *  second child index 1, etc.</p>
     *
     *  Adding and removing objects from a container triggers non-bubbling events.
     *
     *  <ul>
     *   <li><code>Event.ADDED</code>: the object was added to a parent.</li>
     *   <li><code>Event.ADDED_TO_STAGE</code>: the object was added to a parent that is
     *       connected to the stage, thus becoming visible now.</li>
     *   <li><code>Event.REMOVED</code>: the object was removed from a parent.</li>
     *   <li><code>Event.REMOVED_FROM_STAGE</code>: the object was removed from a parent that
     *       is connected to the stage, thus becoming invisible now.</li>
     *  </ul>
     *
     *  Especially the <code>ADDED_TO_STAGE</code> event is very helpful, as it allows you to
     *  automatically execute some logic (e.g. start an animation) when an object is rendered the
     *  first time.
     *
     *  @see Sprite
     *  @see DisplayObject
     */
    public class DisplayObjectContainer extends DisplayObject
    {
        // members

        private var _children:Vector.<DisplayObject>;

        // construction

        /** @private */
        public function DisplayObjectContainer()
        {
            if (getQualifiedClassName(this) == "feeling.display::DisplayObjectContainer")
                throw new Error();

            _children = new Vector.<DisplayObject>();
        }

        /** Disposes the resources of all children. */
        public override function dispose():void
        {
            for each (var child:DisplayObject in _children)
                child.dispose();

            super.dispose();
        }

        // properties

        /** The number of children of this container. */
        public function get numChildren():int  { return _children.length; }

        // child management

        /** Adds a child to the container. It will be at the frontmost position. */
        public function addChild(child:DisplayObject):void
        {
            addChildAt(child, numChildren);
        }

        /** Adds a child to the container at a certain index. */
        public function addChildAt(child:DisplayObject, index:int):void
        {
            if ((index >= 0) && (index <= numChildren))
            {
                child.removeFromParent();
                _children.splice(index, 0, child);
                child.setParent(this);
                child.dispatchEvent(new Event(Event.ADDED, true));
                if (stage)
                    child.dispatchEventOnChildren(new Event(Event.ADDED_TO_STAGE));
            }
            else
                throw new Error();
        }

        /** Removes a child from the container. If the object is not a child, nothing happens.
         *  If requested, the child will be disposed right away. */
        public function removeChild(child:DisplayObject, dispose:Boolean = false):void
        {
            var childIndex:int = getChildIndex(child);
            if (-1 != childIndex)
                removeChildAt(childIndex, dispose);
        }

        /** Removes a child at a certain index. Children above the child will move down. If
         *  requested, the child will be disposed right away. */
        public function removeChildAt(index:int, dispose:Boolean = false):void
        {
            if ((index >= 0) && (index < numChildren))
            {
                var child:DisplayObject = _children[index];
                child.dispatchEvent(new Event(Event.REMOVED, true));
                if (stage)
                    child.dispatchEventOnChildren(new Event(Event.REMOVED_FROM_STAGE));
                child.setParent(null);
                _children.splice(index, 1);
                if (dispose)
                    child.dispose();
            }
            else
                throw new Error();
        }

        /** Removes all children from the container */
        public function removeAllChildren(dispose:Boolean = false):void
        {
            for (var i:int = _children.length; i >= 0; --i)
                removeChildAt(i, dispose);
        }

        /** Returns a child object at a certain index. */
        public function getChildAt(index:int):DisplayObject
        {
            return _children[index];
        }

        /** Returns a child object with a certain name (non-recursively). */
        public function getChildByName(name:String):DisplayObject
        {
            for each (var currentChild:DisplayObject in _children)
                if (currentChild.name == name)
                    return currentChild;
            return null;
        }

        /** Returns the index of a child within the container, or "-1" if it is not found. */
        public function getChildIndex(child:DisplayObject):int
        {
            return _children.indexOf(child);
        }

        /** Moves a child to a certain index. Children at and after the replaced position move up.*/
        public function setChildIndex(child:DisplayObject, index:int):void
        {
            var oldIndex:int = getChildIndex(child);
            if (-1 != oldIndex)
            {
                _children.splice(oldIndex, 1);
                _children.splice(index, 0, child);
            }
            else
                throw new Error();
        }

        /** Swaps the indexes of two children. */
        public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
        {
            var index1:int = getChildIndex(child1);
            var index2:int = getChildIndex(child2);
            if ((-1 == index1) || (-1 == index2))
                throw new Error();

            swapChildrenAt(index1, index2);
        }

        /** Swaps the indexes of two children. */
        public function swapChildrenAt(index1:int, index2:int):void
        {
            var child1:DisplayObject = getChildAt(index1);
            var child2:DisplayObject = getChildAt(index2);
            _children[index1] = child2;
            _children[index2] = child1;
        }

        /** Determines if a certain object is a child of the container (recursively). */
        public function contains(child:DisplayObject):Boolean
        {
            if (child == this)
                return true;

            for each (var currentChild:DisplayObject in _children)
            {
                if (currentChild is DisplayObjectContainer)
                {
                    if ((currentChild as DisplayObjectContainer).contains(child))
                        return true;
                }
                else
                {
                    if (currentChild == child)
                        return true;
                }

                return false;
            }

            return false;
        }

        // other methods

        /** @inheritDoc */
        public override function getBounds(targetSpace:DisplayObject):Rectangle
        {
            var numChildren:int = _children.length;

            if (numChildren == 0)
            {
                var matrix:Matrix = getTransformationMatrixToSpace(targetSpace);
                var position:Point = matrix.transformPoint(new Point(x, y));
                return new Rectangle(position.x, position.y);
            }
            else if (numChildren == 1)
                return _children[0].getBounds(targetSpace);
            else
            {
                var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
                var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;
                for each (var child:DisplayObject in _children)
                {
                    var childBounds:Rectangle = child.getBounds(targetSpace);
                    minX = Math.min(minX, childBounds.x);
                    minY = Math.min(minY, childBounds.y);
                    maxX = Math.max(maxX, childBounds.x + childBounds.width);
                    maxY = Math.max(maxY, childBounds.y + childBounds.height);
                }
                return new Rectangle(minX, minY, maxX - minX, maxY - minY);
            }

            return new Rectangle();
        }

        /** @inheritDoc */
        public override function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject
        {
            if (forTouch && (!visible || !touchable))
                return null;

            for (var i:int = _children.length - 1; i >= 0; --i)
            {
                var child:DisplayObject = _children[i];
                var transformationMatrix:Matrix = getTransformationMatrixToSpace(child);
                var transformedPoint:Point = transformationMatrix.transformPoint(localPoint);
                var target:DisplayObject = child.hitTest(transformedPoint, forTouch);
                if (target)
                    return target;
            }

            return null;
        }

        /** @inheritDoc */
        public override function render(alpha:Number):void
        {
            var renderSupport:RenderSupport = Feeling.instance.renderSupport;

            alpha *= this.alpha;

            for each (var child:DisplayObject in _children)
            {
                var childAlpha:Number = child.alpha;
                if (child.visible && (child.alpha != 0.0) && (child.scaleX != 0) && (child.scaleY != 0))
                {
                    renderSupport.pushMatrix();

                    renderSupport.transformMatrix(child);
                    child.render(alpha);

                    renderSupport.popMatrix();
                }
            }
        }

        // internal methods

        /** @private */
        internal override function dispatchEventOnChildren(event:Event):void
        {
            // the event listeners might modify the display tree, which could make crash.
            // thus, we collect them in a list and iterate over that list instead.

            var listeners:Vector.<DisplayObject> = new <DisplayObject>[];
            getChildEventListeners(this, event.type, listeners);
            for each (var listener:DisplayObject in listeners)
                listener.dispatchEvent(event);
        }

        // private methods

        private function getChildEventListeners(object:DisplayObject, eventType:String, listeners:Vector.<DisplayObject>):void
        {
            if (object.hasEventListener(eventType))
                listeners.push(object);

            var container:DisplayObjectContainer = object as DisplayObjectContainer;
            if (container)
            {
                for each (var child:DisplayObject in container._children)
                    getChildEventListeners(child, eventType, listeners);
            }
        }
    }
}
