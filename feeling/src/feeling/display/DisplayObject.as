package feeling.display
{
    import feeling.events.Event;
    import feeling.events.EventDispatcher;
    import feeling.events.TouchEvent;

    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.getQualifiedClassName;

    /**
     *  The DisplayObject class is the base class for all objects that are rendered on the
     *  screen.
     *
     *  <p><strong>The Display Tree</strong></p>
     *
     *  <p>In Starling, all displayable objects are organized in a display tree. Only objects that
     *  are part of the display tree will be displayed (rendered).</p>
     *
     *  <p>The display tree consists of leaf nodes (Image, Quad) that will be rendered directly to
     *  the screen, and of container nodes (subclasses of "DisplayObjectContainer", like "Sprite").
     *  A container is simply a display object that has child nodes - which can, again, be either
     *  leaf nodes or other containers.</p>
     *
     *  <p>At the root of the display tree, there is the Stage, which is a container, too. To create
     *  a Starling application, you create a custom Sprite subclass, and Starling will add an
     *  instance of this class to the stage.</p>
     *
     *  <p>A display object has properties that define its position in relation to its parent
     *  (x, y), as well as its rotation and scaling factors (scaleX, scaleY). Use the
     *  <code>alpha</code> and <code>visible</code> properties to make an object translucent or
     *  invisible.</p>
     *
     *  <p>Every display object may be the target of touch events. If you don't want an object to be
     *  touchable, you can disable the "touchable" property. When it's disabled, neither the object
     *  nor its children will receive any more touch events.</p>
     *
     *  <strong>Transforming coordinates</strong>
     *
     *  <p>Within the display tree, each object has its own local coordinate system. If you rotate
     *  a container, you rotate that coordinate system - and thus all the children of the
     *  container.</p>
     *
     *  <p>Sometimes you need to know where a certain point lies relative to another coordinate
     *  system. That's the purpose of the method <code>getTransformationMatrix</code>. It will
     *  create a matrix that represents the transformation of a point in one coordinate system to
     *  another.</p>
     *
     *  <strong>Subclassing</strong>
     *
     *  <p>Since DisplayObject is an abstract class, you cannot instantiate it directly, but have
     *  to use one of its subclasses instead. There are already a lot of them available, and most
     *  of the time they will suffice.</p>
     *
     *  <p>However, you can create custom subclasses as well. That way, you can create an object
     *  with a custom render function. You will need to implement the following methods when you
     *  subclass DisplayObject:</p>
     *
     *  <ul>
     *    <li><code>function render(support:RenderSupport, alpha:Number):void</code></li>
     *    <li><code>function getBounds(targetSpace:DisplayObject):Rectangle</code></li>
     *  </ul>
     *
     *  Have a look at the Quad and Image classes for a sample implementation of those methods.
     *
     *  @see DisplayObjectContainer
     *  @see Sprite
     *  @see Stage
     */
    public class DisplayObject extends EventDispatcher
    {
        // members

        private var _x:Number;
        private var _y:Number;
        private var _z:Number;

        private var _rotationX:Number;
        private var _rotationY:Number;
        private var _rotationZ:Number;

        private var _scaleX:Number;
        private var _scaleY:Number;
        private var _scaleZ:Number;

        private var _pivotX:Number;
        private var _pivotY:Number;
        private var _pivotZ:Number;

        private var _alpha:Number;
        private var _visible:Boolean;

        private var _touchable:Boolean;
        private var _lastTouchTimestamp:Number;

        private var _name:String;
        private var _parent:DisplayObjectContainer;

        // construction

        /** @private */
        public function DisplayObject()
        {
            if (getQualifiedClassName(this) == "feeling.display::DisplayObject")
                throw new Error();

            _x = _y = _z = 0.0;
            _scaleX = _scaleY = _scaleZ = 1.0;
            _rotationX = _rotationY = _rotationZ = 0.0;
            _pivotX = _pivotY = _pivotZ = 0.0;
            _alpha = 1.0;
            _visible = true;
            _touchable = true;
            _lastTouchTimestamp = -1.0;
        }

        /** Releases all resources of the display object.
          * GPU buffers are released, event listeners are removed. */
        public function dispose():void
        {
            removeEventListeners();
        }

        // properties

        /** The transformation matrix of the object relative to its parent. */
        public function get transformationMatrix():Matrix
        {
            var matrix:Matrix = new Matrix();

            if ((_pivotX != 0.0) || (_pivotY != 0.0))
                matrix.translate(-_pivotX, -_pivotY);
            if ((_scaleX != 1.0) || (_scaleY != 1.0))
                matrix.scale(_scaleX, _scaleY);
            if (_rotationZ != 0.0)
                matrix.rotate(_rotationZ);
            if ((_x != 0.0) || (_y != 0.0))
                matrix.translate(_x, _y);

            return matrix;
        }

        /** The width of the object in pixels. */
        public function get width():Number  { return getBounds(_parent).width; }
        public function set width(value:Number):void
        {
            // this method call 'this.scaleX' instead of changing _scaleX directly.
            // that way, subclasses reacting on size changes need to override only the scaleX method
            _scaleX = 1.0;
            var actualWidth:Number = width;
            if (actualWidth != 0.0)
                scaleX = value / actualWidth;
            else
                scaleX = 1.0;
        }

        /** The height of the object in pixels. */
        public function get height():Number  { return getBounds(_parent).height; }
        public function set height(value:Number):void
        {
            _scaleY = 1.0;
            var actualHeight:Number = height;
            if (actualHeight != 0.0)
                scaleY = value / actualHeight;
            else
                scaleY = 1.0;
        }

        /** The topmost object in the display tree the object is part of. */
        public function get root():DisplayObject
        {
            var currentObject:DisplayObject = this;
            while (currentObject.parent)
                currentObject = currentObject.parent;
            return currentObject;
        }

        /** The x coordinate of the object relative to the local coordinates of the parent. */
        public function get x():Number  { return _x; }
        public function set x(value:Number):void  { _x = value; }
        /** The y coordinate of the object relative to the local coordinates of the parent. */
        public function get y():Number  { return _y; }
        public function set y(value:Number):void  { _y = value; }
        /** The z coordinate of the object relative to the local coordinates of the parent. */
        public function get z():Number  { return _z; }
        public function set z(value:Number):void  { _z = value; }

        /** The rotation of the object in radians. (In Feeling, all angles are measured
         *  in degree.) */
        public function get rotationX():Number  { return _rotationX; }
        public function set rotationX(value:Number):void
        {
            // move into range [-180 deg, +180 deg]
            while (value < -180)
                value += 360;
            while (value > 180)
                value -= 360;
            _rotationX = value;
        }

        public function get rotationY():Number  { return _rotationY; }
        public function set rotationY(value:Number):void
        {
            // move into range [-180 deg, +180 deg]
            while (value < -180)
                value += 360;
            while (value > 180)
                value -= 360;
            _rotationY = value;
        }

        public function get rotationZ():Number  { return _rotationZ; }
        public function set rotationZ(value:Number):void
        {
            // move into range [-180 deg, +180 deg]
            while (value < -180)
                value += 360;
            while (value > 180)
                value -= 360;
            _rotationZ = value;
        }

        /** The horizontal scale factor. '1' means no scale, negative values flip the object. */
        public function get scaleX():Number  { return _scaleX; }
        public function set scaleX(value:Number):void  { _scaleX = value; }
        /** The vertical scale factor. '1' means no scale, negative values flip the object. */
        public function get scaleY():Number  { return _scaleY; }
        public function set scaleY(value:Number):void  { _scaleY = value; }
        /** The forward scale factor. '1' means no scale, negative values flip the object. */
        public function get scaleZ():Number  { return _scaleZ; }
        public function set scaleZ(value:Number):void  { _scaleZ = value; }

        /** The x coordinate of the object's origin in its own coordinate space (default: 0). */
        public function get pivotX():Number  { return _pivotX; }
        public function set pivotX(value:Number):void  { _pivotX = value; }
        /** The y coordinate of the object's origin in its own coordinate space (default: 0). */
        public function get pivotY():Number  { return _pivotY; }
        public function set pivotY(value:Number):void  { _pivotY = value; }
        /** The z coordinate of the object's origin in its own coordinate space (default: 0). */
        public function get pivotZ():Number  { return _pivotZ; }
        public function set pivotZ(value:Number):void  { _pivotZ = value; }

        public function get alpha():Number  { return _alpha; }
        public function set alpha(value:Number):void  { _alpha = Math.max(0.0, Math.min(1.0, value)); }

        /** The visibility of the object. An invisible object will be untouchable. */
        public function get visible():Boolean  { return _visible; }
        public function set visible(value:Boolean):void  { _visible = value; }

        /** Indicates if this object (and its children) will receive touch events. */
        public function get touchable():Boolean  { return _touchable; }
        public function set touchable(value:Boolean):void  { _touchable = value; }

        /** The name of the display object (default: null). Used by 'getChildByName()' of
         *  display object containers. */
        public function get name():String  { return _name; }
        public function set name(value:String):void  { _name = value; }

        /** The display object container that contains this display object. */
        public function get parent():DisplayObjectContainer  { return _parent; }

        /** The stage the display object is connected to, or null if it is not connected
         *  to a stage. */
        public function get stage():Stage  { return root as Stage; }

        // functions

        /** Removes the object from its parent, if it has one. */
        public function removeFromParent(dispose:Boolean = false):void
        {
            if (_parent)
                _parent.removeChild(this);

            if (dispose)
                this.dispose();
        }

        /** Creates a matrix that represents the transformation from the local coordinate system
          * to another. */
        public function getTransformationMatrixToSpace(targetSpace:DisplayObject):Matrix
        {
            var rootMatrix:Matrix;
            var targetMatrix:Matrix;

            if (targetSpace == this)
                return new Matrix();
            else if (targetSpace == null)
            {
                // tragetCoordinateSpace 'null' respresents the target space of the root object.
                // -> move up from this to root
                rootMatrix = new Matrix();
                currentObject = this;
                while (currentObject)
                {
                    rootMatrix.concat(currentObject.transformationMatrix);
                    currentObject = currentObject.parent;
                }
                return rootMatrix;
            }
            else if (targetSpace._parent == this) // optimization
            {
                targetMatrix = targetSpace.transformationMatrix;
                targetMatrix.invert();
                return targetMatrix;
            }
            else if (targetSpace == _parent)
                return transformationMatrix;

            // 1. find a common parent of this and the target space

            var ancestors:Vector.<DisplayObject> = new <DisplayObject>[];
            var commonParent:DisplayObject = null;
            var currentObject:DisplayObject = this;
            while (currentObject)
            {
                ancestors.push(currentObject);
                currentObject = currentObject.parent;
            }

            currentObject = targetSpace;
            while (currentObject && (ancestors.indexOf(currentObject) == -1))
                currentObject = currentObject.parent;

            if (currentObject == null)
                throw new Error("[DisplayObject] 目标对象与本对象没有共同父节点");
            else
                commonParent = currentObject;

            // 2. move up from this to common parent

            rootMatrix = new Matrix();
            currentObject = this;
            while (currentObject != commonParent)
            {
                rootMatrix.concat(currentObject.transformationMatrix);
                currentObject = currentObject.parent;
            }

            // 3. now move up from target until we reach the common parent

            targetMatrix = new Matrix();
            currentObject = targetSpace;
            while (currentObject != commonParent)
            {
                targetMatrix.concat(currentObject.transformationMatrix);
                currentObject = currentObject.parent;
            }

            // 4. now combine the two matrices

            targetMatrix.invert();
            rootMatrix.concat(targetMatrix);

            return rootMatrix;
        }

        /** Returns a rectangle that completely encloses the object as it appears in another
         *  coordinate system. */
        public function getBounds(targetSpace:DisplayObject):Rectangle
        {
            throw new Error("Method needs to bu implemented in subclass");
            return null;
        }

        /** Returns the object that is found topmost beneath a point in local coordinates, or nil if
         *  the test fails. If "forTouch" is true, untouchable and invisible objects will cause
         *  the test to fail. */
        public function hitTest(localPoint:Point, forTouch:Boolean = false):DisplayObject
        {
            // on a touch test, invisible or untouchable objects cause the test to fail
            if (forTouch && (!_visible || !_touchable))
                return null;

            // otherwise, check bounding box
            if (getBounds(this).containsPoint(localPoint))
                return this;

            return null;
        }

        /** Renders the display object with the help of a support object. Never call this method
         *  directly, except from within another render method.
         *  @param alpha The accumulated alpha value from the object's parent up to the stage. */
        public function render(alpha:Number):void
        {
            // override in subclass
        }

        /** @inheritDoc */
        public override function dispatchEvent(e:Event):void
        {
            // on one given monent, this is only on set of touches -- thus,
            // we process only one touch event with a certain timestamp per frame
            if (e is TouchEvent)
            {
                var touchEvent:TouchEvent = e as TouchEvent;
                if (touchEvent.timestamp == _lastTouchTimestamp)
                    return;
                else
                    _lastTouchTimestamp = touchEvent.timestamp;
            }

            super.dispatchEvent(e);
        }

        // internal methods

        /** @private */
        internal function setParent(value:DisplayObjectContainer):void
        {
            _parent = value;
        }

        /** @private */
        internal function dispatchEventOnChildren(event:Event):void
        {
            dispatchEvent(event);
        }
    }
}
