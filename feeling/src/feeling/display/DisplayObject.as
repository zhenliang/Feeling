package feeling.display
{
    import feeling.events.Event;
    import feeling.events.EventDispatcher;
    
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;

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

		private var _name:String;
		private var _parent:DisplayObjectContainer;

        // properties

        public function get x():Number  { return _x; }
        public function set x( value:Number ):void  { _x = value; }
        public function get y():Number  { return _y; }
        public function set y( value:Number ):void  { _y = value; }
		public function get z():Number  { return _z; }
		public function set z( value:Number ):void  { _z = value; }

		public function get rotationX():Number  { return _rotationX; }
		public function set rotationX( value:Number ):void
		{
			// move into range [-180 deg, +180 deg]
			while ( value < -180 )
				value += 360;
			while ( value > 180)
				value -= 360;
			_rotationX = value;
		}
		public function get rotationY():Number  { return _rotationY; }
		public function set rotationY( value:Number ):void
		{
			// move into range [-180 deg, +180 deg]
			while ( value < -180 )
				value += 360;
			while ( value > 180)
				value -= 360;
			_rotationY = value;
		}
        public function get rotationZ():Number  { return _rotationZ; }
        public function set rotationZ( value:Number ):void
        {
            // move into range [-180 deg, +180 deg]
			while ( value < -180 )
				value += 360;
			while ( value > 180)
				value -= 360;
            _rotationZ = value;
        }

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

		public function get width():Number { return getBounds(_parent).width; }
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
		
		public function get height():Number { return getBounds(_parent).height; }
		public function set height(value:Number):void
		{
			_scaleY = 1.0;
			var actualHeight:Number = height;
			if (actualHeight != 0.0)
				scaleY = value / actualHeight;
			else
				scaleY = 1.0;
		}
		
		public function get root():DisplayObject
		{
			var currentObject:DisplayObject = this;
			while (currentObject.parent)
				currentObject = currentObject.parent;
			return currentObject;
		}

		public function get scaleX():Number  { return _scaleX; }
		public function set scaleX( value:Number ):void  { _scaleX = value; }
		public function get scaleY():Number  { return _scaleY; }
		public function set scaleY( value:Number ):void  { _scaleY = value; }
		public function get scaleZ():Number  { return _scaleZ; }
		public function set scaleZ( value:Number ):void  { _scaleZ = value; }
		
		public function get pivotX():Number  { return _pivotX; }
		public function set pivotX( value:Number ):void  { _pivotX = value; }
		public function get pivotY():Number  { return _pivotY; }
		public function set pivotY( value:Number ):void  { _pivotY = value; }
		public function get pivotZ():Number  { return _pivotZ; }
		public function set pivotZ( value:Number ):void  { _pivotZ = value; }
		
        public function get alpha():Number  { return _alpha; }
        public function set alpha( value:Number ):void
        {
            _alpha = Math.max( 0.0, Math.min( 1.0, value ) );
        }

        public function get visible():Boolean  { return _visible; }
        public function set visible( value:Boolean ):void  { _visible = value; }
		
		public function get touchable():Boolean { return _touchable; }
		public function set touchable(value:Boolean):void { _touchable = value; }

        public function get name():String  { return _name; }
        public function set name( value:String ):void  { _name = value; }

        public function get parent():DisplayObjectContainer  { return _parent; }
		public function get stage():Stage { return root as Stage; }
		
        // construction

        public function DisplayObject()
        {
            _x = _y = _z = 0.0;
            _scaleX = _scaleY = _scaleZ = 1.0;
			_rotationX = _rotationY = _rotationZ = 0.0;
			_pivotX = _pivotY = _pivotZ = 0.0;
            _alpha = 1.0;
            _visible = true;
			_touchable = true;
        }

        public function dispose():void
        {
        }

        // functions

        public function removeFromParent( dispose:Boolean = false ):void
        {
            if ( _parent )
                _parent.removeChild( this );

            if ( dispose )
                this.dispose();
        }
		
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

		public function getBounds(targetSpace:DisplayObject):Rectangle
		{
			throw new Error("Method needs to bu implemented in subclass");
			return null;
		}
		
		public function hitTestPoint(localPoint:Point, forTouch:Boolean = false):DisplayObject
		{
			// on a touch test, invisible or untouchable objects cause the test to fail
			if (forTouch && (!_visible || !_touchable))
				return null;
			
			// otherwise, check bounding box
			if (getBounds(this).containsPoint(localPoint))
				return this;
			
			return null;
		}
		
        public function render():void
        {
            // override in subclass
        }

        // internal methods

        internal function setParent( value:DisplayObjectContainer ):void
        {
            _parent = value;
        }
		
		internal function dispatchEventOnChildren(event:Event):void
		{
			dispatchEvent(event);
		}
    }
}
