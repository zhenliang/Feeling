package feeling.core
{
    import feeling.animation.Juggler;
    import feeling.data.DebugInfo;
    import feeling.display.DisplayObject;
    import feeling.display.Stage;
    import feeling.events.ResizeEvent;
    import feeling.events.TouchPhase;
    import feeling.events.TouchProcessor;
    import feeling.input.KeyboardInput;
    import feeling.shaders.ImageShader;
    import feeling.shaders.QuadShader;

    import flash.display.Sprite;
    import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.TouchEvent;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;
    import flash.ui.Multitouch;
    import flash.utils.getTimer;


    /** The Starling class represents the core of the Starling framework.
     *
     *  <p>The Starling framework makes it possible to create 2D applications and games that make
     *  use of the Stage3D architecture introduced in Flash Player 11. It implements a display tree
     *  system that is very similar to that of conventional Flash, while leveraging modern GPUs
     *  to speed up rendering.</p>
     *
     *  <p>The Starling class represents the link between the conventional Flash display tree and
     *  the Starling display tree. To create a Starling-powered application, you have to create
     *  an instance of the Starling class:</p>
     *
     *  <pre>var starling:Starling = new Starling(Game, stage);</pre>
     *
     *  <p>The first parameter has to be a Starling display object class, e.g. a subclass of
     *  <code>starling.display.Sprite</code>. In the sample above, the class "Game" is the
     *  application root. An instance of "Game" will be created as soon as Starling is initialized.
     *  The second parameter is the conventional (Flash) stage object. Per default, Starling will
     *  display its contents directly below the stage.</p>
     *
     *  <p>It is recommended to store the starling instance as a member variable, to make sure
     *  that the Garbage Collector does not destroy it. After creating the Starling object, you
     *  have to start it up like this:</p>
     *
     *  <pre>starling.start();</pre>
     *
     *  <p>It will now render the contents of the "Game" class in the frame rate that is set up for
     *  the application (as defined in the Flash stage).</p>
     *
     *  <strong>Accessing the Starling object</strong>
     *
     *  <p>From within your application, you can access the current Starling object anytime
     *  through the static method <code>Starling.current</code>. It will return the active Starling
     *  instance (most applications will only have one Starling object, anyway).</p>
     *
     *  <strong>Viewport</strong>
     *
     *  <p>The area the Starling content is rendered into is, per default, the complete size of the
     *  stage. You can, however, use the "viewPort" property to change it. This can be  useful
     *  when you want to render only into a part of the screen, or if the player size changes. For
     *  the latter, you can listen to the RESIZE-event dispatched by the Starling
     *  stage.</p>
     *
     *  <strong>Native overlay</strong>
     *
     *  <p>Sometimes you will want to display native Flash content on top of Starling. That's what the
     *  <code>nativeOverlay</code> property is for. It returns a Flash Sprite lying directly
     *  on top of the Starling content. You can add conventional Flash objects to that overlay.</p>
     *
     *  <p>Beware, though, that conventional Flash content on top of 3D content can lead to
     *  performance penalties on some (mobile) platforms. For that reason, always remove all child
     *  objects from the overlay when you don't need them any longer. Starling will remove the
     *  overlay from the display list when it's empty.</p>
     *
     *  <strong>Multitouch</strong>
     *
     *  <p>Starling supports multitouch input on devices that provide it. During development,
     *  where most of us are working with a conventional mouse and keyboard, Starling can simulate
     *  multitouch events with the help of the "Shift" and "Ctrl" (Mac: "Cmd") keys. Activate
     *  this feature by enabling the <code>simulateMultitouch</code> property.</p>
     *
     */
    public class Feeling
    {
        // static members

        private static var _sInstance:Feeling;

        // static properties 

        public static function init(gameClass:Class, flashStage:flash.display.Stage):void
        {
            _sInstance = new Feeling(gameClass, flashStage);
        }

        /** The currently active Starling instance. */
        public static function get instance():Feeling
        {
            return _sInstance;
        }

        // members

        private var _gameClass:Class;

        private var _stage3d:Stage3D;
        private var _context3d:Context3D;
        private var _feelingStage:Stage; // feeling stage, not flash stage
        private var _renderSupport:RenderSupport;
        private var _shaderManager:ShaderManager;
        private var _juggler:Juggler;
        private var _keyboardInput:KeyboardInput;
        private var _touchProcessor:TouchProcessor;

        private var _antiAliasing:int;

        private var _viewPoint:Rectangle;

        private var _started:Boolean;
        private var _lastFrameTimestamp:Number;

        private var _nativeStage:flash.display.Stage;
        private var _nativeOverlay:flash.display.Sprite;

        private var _debugInfo:DebugInfo;

        /** Creates a new Starling instance.
         *  @param rootClass  A subclass of a Starling display object. Its contents will represent
         *                    the root of the display tree.
         *  @param stage      The Flash (2D) stage.
         *  @param viewPort   A rectangle describing the area into which the content will be
         *                    rendered. @default stage size
         *  @param stage3D    The Stage3D object into which the content will be rendered.
         *                    @default the first available Stage3D.
         *  @param renderMode Use this parameter to force software rendering.
         */
        public function Feeling(gameClass:Class, nativeStage:flash.display.Stage, viewPoint:Rectangle = null, stage3D:Stage3D =
            null, renderMode:String = "auto"):void
        {
            if (gameClass == null)
                throw new Error("[Feeling] Game class must not be null");
            if (nativeStage == null)
                throw new Error("[Feeling] flash stage must not be null");

            if (viewPoint == null)
                viewPoint = new Rectangle(0, 0, nativeStage.stageWidth, nativeStage.stageHeight);
            if (stage3D == null)
                stage3D = nativeStage.stage3Ds[0];

            _gameClass = gameClass;

            _nativeStage = nativeStage;

            _viewPoint = viewPoint;
            _feelingStage = new Stage(_viewPoint.width, _viewPoint.height, _nativeStage.color);

            _stage3d = stage3D;
            _stage3d.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated, false, 0, true);
            try
            {
                _stage3d.requestContext3D(renderMode);
            }
            catch (e:Error)
            {
                trace("[Feeling] Context3D error: ", e.message);
            }

            _antiAliasing = 16;

            _lastFrameTimestamp = getTimer() / 1000.0;

            _shaderManager = new ShaderManager();
            _juggler = new Juggler();
            _keyboardInput = new KeyboardInput();
            _touchProcessor = new TouchProcessor(_feelingStage);

            // flash events

            _nativeStage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
            _nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent, false, 0, true);
            _nativeStage.addEventListener(KeyboardEvent.KEY_UP, onKeyboardEvent, false, 0, true);
            _nativeStage.addEventListener(Event.RESIZE, onResize, false, 0, true);

            var touchEventTypes:Array = Multitouch.supportsTouchEvents ? [TouchEvent.TOUCH_BEGIN, TouchEvent.TOUCH_MOVE,
                TouchEvent.TOUCH_END] : [MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_UP];
            for each (var touchEventType:String in touchEventTypes)
            {
                nativeStage.addEventListener(touchEventType, onTouch, false, 0, true);
            }

            initDebugInfo();
        }

        public function dispose():void
        {
            if (_renderSupport)
                _renderSupport.dispose();
            if (_context3d)
                _context3d.dispose();
            if (_touchProcessor)
                _touchProcessor.dispose();
        }

        // functions

        /** The render context of this instance. */
        public function get context3d():Context3D  { return _context3d; }
        public function get feelingStage():Stage  { return _feelingStage; }
        public function get renderSupport():RenderSupport  { return _renderSupport; }
        public function get shaderManager():ShaderManager  { return _shaderManager; }
        /** The default juggler of this instance. Will be advanced once per frame. */
        public function get juggler():Juggler  { return _juggler; }
        public function get keyboardInput():KeyboardInput  { return _keyboardInput; }

        /** Starts rendering and dispatching of <code>ENTER_FRAME</code> events. */
        public function start():void  { _started = true; }

        /** Stops rendering. */
        public function stop():void  { _started = false; }

        /** The antialiasing level. 0 - no antialasing, 16 - maximum antialiasing. @default 0 */
        public function get antiAliasing():int  { return _antiAliasing; }
        public function set antiAliasing(value:int):void
        {
            _antiAliasing = value;
            updateViewPoint();
        }

        /** The viewport into which Starling contents will be rendered. */
        public function get viewPoint():Rectangle  { return _viewPoint.clone(); }
        public function set viewPoint(value:Rectangle):void
        {
            _viewPoint = value.clone();
            updateViewPoint();
        }

        /** The Flash (2D) stage Feeling renders beneath. */
        public function get nativeStage():flash.display.Stage
        {
            return _nativeStage;
        }

        /** A Flash Sprite placed directly on top of the Starling content. Use it to display native
         *  Flash components. */
        public function get nativeOverlay():Sprite
        {
            if (_nativeOverlay == null)
            {
                _nativeOverlay = new Sprite();
                _nativeStage.addChild(_nativeOverlay);
                updateNativeOverlay();
            }

            return _nativeOverlay;
        }

        public function get debugInfo():Sprite
        {
            if (_debugInfo == null)
                initDebugInfo();
            return _debugInfo;
        }

        private function initializeGraphicsApi():void
        {
            if (_context3d)
                return;

            _context3d = _stage3d.context3D;
            _context3d.enableErrorChecking = true;
            updateViewPoint();

            _renderSupport = new RenderSupport(_feelingStage.stageWidth, _feelingStage.stageHeight);
            _feelingStage.addChild(_renderSupport.camera);

            trace("[Feeling] Displayer Driver: " + _context3d.driverInfo);
        }

        private function initializePrograms():void
        {
            QuadShader.registerPrograms();
            ImageShader.registerPrograms();
        }

        private function initializeRoot():void
        {
            var game:DisplayObject = new _gameClass();
            if (game == null)
                throw new Error("[Feeling] Invaild game class: " + _gameClass);
            _feelingStage.addChild(game);
        }

        private function updateViewPoint():void
        {
            if (_context3d)
                _context3d.configureBackBuffer(_viewPoint.width, _viewPoint.height, _antiAliasing, false);

            _stage3d.x = _viewPoint.x;
            _stage3d.y = _viewPoint.y;
        }

        private function render():void
        {
            if (!_context3d)
                return;

            var nowTime:Number = getTimer() / 1000.0;
            var passedTime:Number = nowTime - _lastFrameTimestamp;
            _lastFrameTimestamp = nowTime;

            _feelingStage.advanceTime(passedTime);
            _juggler.advanceTime(passedTime);
            _touchProcessor.advanceTime(passedTime);

            _renderSupport.setupPerspectiveMatrix(_feelingStage.stageWidth, _feelingStage.stageHeight);
            _renderSupport.setupDefaultBlendFactors(true);
            _renderSupport.clear(_feelingStage.color);

            _feelingStage.render(1.0);
            _context3d.present();

            _renderSupport.resetMatrix();
        }

        // event handlers

        private function onContextCreated(... args):void
        {
            initializeGraphicsApi();
            initializePrograms();
            initializeRoot();

            _touchProcessor.simulateMultitouch = true;
        }

        private function onEnterFrame(... args):void
        {
            if (_debugInfo)
                updateDebugInfo();
            if (_nativeOverlay)
                updateNativeOverlay();
            if (_started)
                render();
        }

        private function onKeyboardEvent(e:KeyboardEvent):void
        {
            import feeling.events.KeyboardEvent;
            var keyboardEvent:feeling.events.KeyboardEvent = new feeling.events.KeyboardEvent(e.type, e.charCode, e.keyCode);

            _feelingStage.dispatchEvent(keyboardEvent);
            _keyboardInput.updateStatus(keyboardEvent);
        }

        private function onTouch(e:Event):void
        {
            var position:Point;
            var phase:String;
            var touchId:int;

            if (e is MouseEvent)
            {
                var mouseEvent:MouseEvent = e as MouseEvent;
                position = convertPosition(new Point(mouseEvent.stageX, mouseEvent.stageY));
                phase = getPhaseFromMouseEvent(mouseEvent);
                touchId = 0;
            }
            else
            {
                var touchEvent:TouchEvent = e as TouchEvent;
                position = convertPosition(new Point(touchEvent.stageX, touchEvent.stageY));
                phase = getPhaseFromTouchEvent(touchEvent);
                touchId = touchEvent.touchPointID;
            }

            _touchProcessor.enqueue(touchId, phase, position.x, position.y);

            function convertPosition(globalPos:Point):Point
            {
                if (_renderSupport)
                {
                    var viewMatrix:Matrix3D = _renderSupport.camera.viewMatrix.clone();
                    viewMatrix.invert();

                    var globalPos3d:Vector3D = new Vector3D();
                    globalPos3d.x = globalPos.x - _feelingStage.stageWidth / 2;
                    globalPos3d.y = _feelingStage.stageHeight / 2 - globalPos.y;
                    globalPos3d = viewMatrix.transformVector(globalPos3d);

                    globalPos.x = globalPos3d.x;
                    globalPos.y = globalPos3d.y;
                }

                return new Point((globalPos.x - _viewPoint.x) * (_viewPoint.width / _feelingStage.stageWidth), (globalPos.
                    y - _viewPoint.y) * (_viewPoint.height / feelingStage.stageHeight));
            }

            function getPhaseFromMouseEvent(e:MouseEvent):String
            {
                switch (e.type)
                {
                    case MouseEvent.MOUSE_DOWN:
                        return TouchPhase.BEGAN;
                        break;
                    case MouseEvent.MOUSE_UP:
                        return TouchPhase.ENDED;
                        break;
                    case MouseEvent.MOUSE_MOVE:
                        return mouseEvent.buttonDown ? TouchPhase.MOVED : TouchPhase.HOVER;
                        break;
                    default:
                        return null;
                }

                return null;
            }

            function getPhaseFromTouchEvent(e:TouchEvent):String
            {
                switch (e.type)
                {
                    case TouchEvent.TOUCH_BEGIN:
                        return TouchPhase.BEGAN;
                        break;
                    case TouchEvent.TOUCH_MOVE:
                        return TouchPhase.MOVED;
                        break;
                    case TouchEvent.TOUCH_END:
                        return TouchPhase.ENDED;
                        break;
                    default:
                        return null;
                }

                return null;
            }
        }

        private function onResize(e:flash.events.Event):void
        {
            var stage:flash.display.Stage = e.target as flash.display.Stage;
            _feelingStage.dispatchEvent(new ResizeEvent(Event.RESIZE, stage.stageWidth, stage.stageHeight));
            _feelingStage.stageWidth = stage.stageWidth;
            _feelingStage.stageHeight = stage.stageHeight;
            _viewPoint.width = stage.stageWidth;
            _viewPoint.height = stage.stageHeight;
            updateViewPoint();
        }

        private function updateNativeOverlay():void
        {
            _nativeOverlay.x = _viewPoint.x;
            _nativeOverlay.y = _viewPoint.y;
            _nativeOverlay.scaleX = _viewPoint.width / _feelingStage.stageWidth;
            _nativeOverlay.scaleY = _viewPoint.width / _feelingStage.stageHeight;

            // Having a native overlay on top of Stage3D content can cause a performance hit on
            // some environments. For that reason, we add it only to the stage while it's not empty.

            if ((_nativeOverlay.numChildren != 0) && !_nativeOverlay.parent)
                _nativeStage.addChild(_nativeOverlay);
            else if ((_nativeOverlay.numChildren == 0) && _nativeOverlay.parent)
                _nativeStage.removeChild(_nativeOverlay);
        }

        private function initDebugInfo():void
        {
            _debugInfo = new DebugInfo();
            nativeOverlay.addChild(_debugInfo);
        }

        private function updateDebugInfo():void
        {
            _debugInfo.currentFps = 1 / (getTimer() / 1000 - _lastFrameTimestamp);
            if (Math.abs(_debugInfo.currentFps - _debugInfo.lastFps) > 10)
                _debugInfo.fpsTxt.text = _debugInfo.currentFps.toFixed(2);
            _debugInfo.lastFps = _debugInfo.currentFps;
        }
    }
}
