package feeling.core
{
    import feeling.display.DisplayObject;
    import feeling.display.Stage;
    import feeling.input.KeyboardInput;
    import feeling.shaders.ImageShader;
    import feeling.shaders.QuadShader;
    
    import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.geom.Rectangle;
    import flash.utils.getTimer;

    public class Feeling
    {
		// static members
		
		private static var _sInstance:Feeling;

        // static properties 

		public static function init(gameClass:Class, flashStage:flash.display.Stage):void
		{
			_sInstance = new Feeling(gameClass, flashStage); 
		}
		
		public static function get instance():Feeling
		{
			return _sInstance;
		}
		
		// members
		
		private var _gameClass:Class;
		
		private var _context3d:Context3D;
		private var _renderSupport:RenderSupport;
		private var _shaderManager:ShaderManager;
		private var _keyboardInput:KeyboardInput;
		
		private var _viewPoint:Rectangle;
		private var _stage3d:Stage3D;
		
		private var _feelingStage:Stage; // feeling stage, not flash stage
		
		private var _started:Boolean;
		private var _lastFrameTimestamp:Number;
		
        public function Feeling( gameClass:Class, flashStage:flash.display.Stage, viewPoint:Rectangle = null,
            stage3D:Stage3D = null, renderMode:String = "auto" ):void
        {
            if ( gameClass == null )
                throw new Error( "[Feeling] Game class must not be null" );
            if ( flashStage == null )
                throw new Error( "[Feeling] flash stage must not be null" );

            if ( viewPoint == null )
                viewPoint = new Rectangle( 0, 0, flashStage.stageWidth, flashStage.stageHeight );
            if ( stage3D == null )
                stage3D = flashStage.stage3Ds[ 0 ];

            _gameClass = gameClass;
			
			flashStage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			flashStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent, false, 0, true);
			flashStage.addEventListener(KeyboardEvent.KEY_UP, onKeyboardEvent, false, 0, true);
			
            _viewPoint = viewPoint;
            _feelingStage = new Stage( _viewPoint.width, _viewPoint.height );
			
			_stage3d = stage3D;
            _stage3d.addEventListener( Event.CONTEXT3D_CREATE, onContextCreated, false, 0, true );
            _stage3d.requestContext3D( renderMode );
			
			_lastFrameTimestamp = getTimer() / 1000.0;
			
			_shaderManager = new ShaderManager();
			_keyboardInput = new KeyboardInput();
        }

        // functions

		public function get context3d():Context3D { return _sInstance._context3d; }
		public function get renderSupport():RenderSupport { return _sInstance._renderSupport; }
		public function get shaderManager():ShaderManager { return _sInstance._shaderManager; } 
		public function get keyboardInput():KeyboardInput { return _keyboardInput; }
		
        private function initializeGraphicsAPI():void
        {
            if ( _context3d )
                return;

			_stage3d.x = _viewPoint.x;
			_stage3d.y = _viewPoint.y;
			
			_context3d = _stage3d.context3D;
			_context3d.configureBackBuffer( _viewPoint.width, _viewPoint.height, 1, false );
			_context3d.enableErrorChecking = true;
			
            _renderSupport = new RenderSupport(_feelingStage.stageWidth, _feelingStage.stageHeight );

            trace( "[Feeling] Displayer Driver: " + _context3d.driverInfo );
        }

        private function initializePrograms():void
        {
            QuadShader.registerPrograms();
			ImageShader.registerPrograms();
        }

        private function initializeRoot():void
        {
            if ( _feelingStage.numChildren > 0 )
                return;

            var game:DisplayObject = new _gameClass();
            if ( game == null )
                throw new Error( "[Feeling] Invaild game class: " + _gameClass );
            _feelingStage.addChild( game );
			
			_feelingStage.addChild(_renderSupport.camera);
        }

        public function start():void  { _started = true; }
        public function stop():void  { _started = false; }

		public function dispose():void
		{
			if ( _renderSupport )
				_renderSupport.dispose();
			if ( _context3d )
				_context3d.dispose();
		}
		
        private function render():void
        {
            if (!_context3d)
                return;

            var nowTime:Number = getTimer() / 1000.0;
            var passedTime:Number = nowTime - _lastFrameTimestamp;
            _lastFrameTimestamp = nowTime;

            _feelingStage.advanceTime( passedTime );

			_renderSupport.setupPerspectiveMatrix( _viewPoint.width, _viewPoint.height );
			_renderSupport.setupDefaultBlendFactors();

			_context3d.clear();
            _feelingStage.render();
			_context3d.present();
        }

        // event handlers

        private function onContextCreated( ... args ):void
        {
            initializeGraphicsAPI();
            initializePrograms();
            initializeRoot();
        }

        private function onEnterFrame( ... args ):void
        {
            if ( _started )
                render();
        }
		
		private function onKeyboardEvent(e:KeyboardEvent):void
		{
			import feeling.events.KeyboardEvent;
			var keyboardEvent:feeling.events.KeyboardEvent = new feeling.events.KeyboardEvent(e.type, e.charCode, e.keyCode);
			
			_feelingStage.broadcastEvent(keyboardEvent);
			_keyboardInput.updateStatus(keyboardEvent);
		}
    }
}
