package feeling.display
{
    import feeling.core.Feeling;
    import feeling.core.RenderSupport;
    import feeling.events.Event;

    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.getQualifiedClassName;

    public class DisplayObjectContainer extends DisplayObject
    {
        // members

        private var _children:Vector.<DisplayObject>;

        // construction

        public function DisplayObjectContainer()
        {
            if (getQualifiedClassName(this) == "feeling.display::DisplayObjectContainer")
                throw new Error();

            _children = new Vector.<DisplayObject>();
        }

        public override function dispose():void
        {
            for each (var child:DisplayObject in _children)
                child.dispose();

            super.dispose();
        }

        // properties

        public function get numChildren():int  { return _children.length; }

        // child management

        public function addChild(child:DisplayObject):void
        {
            addChildAt(child, numChildren);
        }

        public function addChildAt(child:DisplayObject, index:int):void
        {
            if ((index >= 0) && (index <= numChildren))
            {
                child.removeFromParent();
                _children.splice(index, 0, child);
                child.setParent(this);
                child.dispatchEvent(new Event(Event.ADDED));
                if (stage)
                    child.dispatchEventOnChildren(new Event(Event.ADDED_TO_STAGE));
            }
            else
                throw new Error();
        }

        public function removeChild(child:DisplayObject):void
        {
            var childIndex:int = getChildIndex(child);
            if (-1 != childIndex)
                removeChildAt(childIndex);
        }

        public function removeChildAt(index:int):void
        {
            if ((index >= 0) && (index < numChildren))
            {
                var child:DisplayObject = _children[index];
                child.dispatchEvent(new Event(Event.REMOVED));
                if (stage)
                    child.dispatchEventOnChildren(new Event(Event.REMOVED_FROM_STAGE));
                child.setParent(null);
                _children.splice(index, 1);
            }
            else
                throw new Error();
        }

        public function removeAllChildren():void
        {
            for (var i:int = _children.length; i >= 0; --i)
                removeChildAt(i);
        }

        public function getChildAt(index:int):DisplayObject
        {
            return _children[index];
        }

        public function getChildByName(name:String):DisplayObject
        {
            for each (var currentChild:DisplayObject in _children)
                if (currentChild.name == name)
                    return currentChild;
            return null;
        }

        public function getChildIndex(child:DisplayObject):int
        {
            return _children.indexOf(child);
        }

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

        public function swapChildren(child1:DisplayObject, child2:DisplayObject):void
        {
            var index1:int = getChildIndex(child1);
            var index2:int = getChildIndex(child2);
            if ((-1 == index1) || (-1 == index2))
                throw new Error();

            swapChildrenAt(index1, index2);
        }

        public function swapChildrenAt(index1:int, index2:int):void
        {
            var child1:DisplayObject = getChildAt(index1);
            var child2:DisplayObject = getChildAt(index2);
            _children[index1] = child2;
            _children[index2] = child1;
        }

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
