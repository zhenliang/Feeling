package com.feeling.display
{
    import com.feeling.events.Event;
    import com.feeling.events.EventDispatcher;

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

        public function get name():String  { return _name; }
        public function set name( value:String ):void  { _name = value; }

        public function get parent():DisplayObjectContainer  { return _parent; }

        // construction

        public function DisplayObject()
        {
            _x = _y = _z = 0.0;
            _scaleX = _scaleY = _scaleZ = 1.0;
			_rotationX = _rotationY = _rotationZ = 0.0;
			_pivotX = _pivotY = _pivotZ = 0.0;
            _alpha = 1.0;
            _visible = true;
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
