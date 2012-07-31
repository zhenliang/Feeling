package com.feeling.display
{
    import com.feeling.core.Feeling;
    import com.feeling.core.RenderSupport;
    import com.feeling.events.Event;

    public class DisplayObjectContainer extends DisplayObject
    {
        // members

        private var _children:Vector.<DisplayObject>;

        // construction

        public function DisplayObjectContainer()
        {
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

        public function addChild( child:DisplayObject ):void
        {
            addChildAt( child, numChildren );
        }

        public function addChildAt( child:DisplayObject, index:int ):void
        {
            if ( ( index >= 0 ) && ( index <= numChildren ) )
            {
                child.removeFromParent();
                _children.splice( index, 0, child );
                child.setParent( this );
            }
        }

        public function removeChild( child:DisplayObject ):void
        {
            var childIndex:int = getChildIndex( child );
            if ( -1 != childIndex )
                removeChildAt( childIndex );
        }

        public function removeChildAt( index:int ):void
        {
            if ( ( index >= 0 ) && ( index < numChildren ) )
            {
                var child:DisplayObject = _children[ index ];
                child.setParent( null );
                _children.splice( index, 1 );
            }
        }

        public function removeAllChildren():void
        {
            for ( var i:int = _children.length; i >= 0; --i )
                removeChildAt( i );
        }

        public function getChildAt( index:int ):DisplayObject
        {
            return _children[ index ];
        }

        public function getChildByName( name:String ):DisplayObject
        {
            for each ( var currentChild:DisplayObject in _children )
                if ( currentChild.name == name )
                    return currentChild;
            return null;
        }

        public function getChildIndex( child:DisplayObject ):int
        {
            return _children.indexOf( child );
        }

        public function setChildIndex( child:DisplayObject, index:int ):void
        {
            var oldIndex:int = getChildIndex( child );
            if ( -1 != oldIndex )
            {
                _children.splice( oldIndex, 1 );
                _children.splice( index, 0, child );
            }
        }

        public function swapChildren( child1:DisplayObject, child2:DisplayObject ):void
        {
            var index1:int = getChildIndex( child1 );
            var index2:int = getChildIndex( child2 );
            if ( ( -1 == index1 ) || ( -1 == index2 ) )
                return;

            swapChildrenAt( index1, index2 );
        }

        public function swapChildrenAt( index1:int, index2:int ):void
        {
            var child1:DisplayObject = getChildAt( index1 );
            var child2:DisplayObject = getChildAt( index2 );
            _children[ index1 ] = child2;
            _children[ index2 ] = child1;
        }

        public function contains( child:DisplayObject ):Boolean
        {
            if ( child == this )
                return true;

            for each ( var currentChild:DisplayObject in _children )
            {
                if ( currentChild is DisplayObjectContainer )
                {
                    if ( ( currentChild as DisplayObjectContainer ).contains( child ) )
                        return true;
                }
                else
                {
                    if ( currentChild == child )
                        return true;
                }

                return false;
            }

            return false;
        }

        // other methods

        public override function render():void
        {
			var renderSupport:RenderSupport = Feeling.instance.renderSupport;
			
            var alpha:Number = this.alpha;

            for each ( var child:DisplayObject in _children )
            {
                var childAlpha:Number = child.alpha;
                if ( child.visible && ( childAlpha != 0.0 ) && ( child.scaleX != 0 ) && ( child.scaleY != 0 ) )
                {
					renderSupport.pushMatrix();

					renderSupport.transformMatrix( child );
                    child.alpha *= alpha;
                    child.render();
                    child.alpha = childAlpha;

					renderSupport.popMatrix();
                }
            }
        }
		
		internal override function dispatchEventOnChildren(event:Event):void
		{
			// the event listeners might modify the display tree, which could make crash.
			// thus, we collect them in a list and iterate over that list instead.
			
			var listeners:Vector.<DisplayObject> = new <DisplayObject>[];
			getChildEventListeners(this, event.type, listeners);
			for each (var listener:DisplayObject in listeners)
				listener.dispatchEvent(event);
		}
		
		private function getChildEventListeners(object:DisplayObject, eventType:String, listeners:Vector.<DisplayObject>):void
		{
			if (object.hasEventListener(eventType))
				listeners.push(object);
			
			var container:DisplayObjectContainer = object as DisplayObjectContainer;
			if (container)
			{
				for (var i:int = 0; i < container.numChildren; ++i)
				{
					getChildEventListeners(container.getChildAt(i), eventType, listeners);
				}
			}
		}
    }
}