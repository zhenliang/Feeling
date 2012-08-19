package feeling.core
{
    import feeling.animation.Juggler;
    import feeling.display.DisplayObject;
    import feeling.display.Stage;
    import feeling.events.ResizeEvent;
    import feeling.events.TouchPhase;
    import feeling.events.TouchProcessor;
    import feeling.input.KeyboardInput;
    import feeling.shaders.ImageShader;
    import feeling.shaders.QuadShader;

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

        public function Feeling(gameClass:Class, flashStage:flash.display.Stage, viewPoint:Rectangle = null, stage3D:Stage3D =
            null, renderMode:String = "auto"):void
        {
            if (gameClass == null)
                throw new Error("[Feeling] Game class must not be null");
            if (flashStage == null)
                throw new Error("[Feeling] flash stage must not be null");

            if (viewPoint == null)
                viewPoint = new Rectangle(0, 0, flashStage.stageWidth, flashStage.stageHeight);
            if (stage3D == null)
                stage3D = flashStage.stage3Ds[0];

            _gameClass = gameClass;

            _viewPoint = viewPoint;
            _feelingStage = new Stage(_viewPoint.width, _viewPoint.height);

            _stage3d = stage3D;
            _stage3d.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated, false, 0, true);
            _stage3d.requestContext3D(renderMode);

            _antiAliasing = 0;

            _lastFrameTimestamp = getTimer() / 1000.0;

            _shaderManager = new ShaderManager();
            _juggler = new Juggler();
            _keyboardInput = new KeyboardInput();
            _touchProcessor = new TouchProcessor(_feelingStage);

            // flash events

            flashStage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
            flashStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent, false, 0, true);
            flashStage.addEventListener(KeyboardEvent.KEY_UP, onKeyboardEvent, false, 0, true);
            flashStage.addEventListener(Event.RESIZE, onResize, false, 0, true);

            var touchEventTypes:Array = Multitouch.supportsTouchEvents ? [TouchEvent.TOUCH_BEGIN, TouchEvent.TOUCH_MOVE,
                TouchEvent.TOUCH_END] : [MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_UP];
            for each (var touchEventType:String in touchEventTypes)
            {
                flashStage.addEventListener(touchEventType, onTouch, false, 0, true);
            }
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

        public function get context3d():Context3D  { return _context3d; }
        public function get feelingStage():Stage  { return _feelingStage; }
        public function get renderSupport():RenderSupport  { return _renderSupport; }
        public function get shaderManager():ShaderManager  { return _shaderManager; }
        public function get juggler():Juggler  { return _juggler; }
        public function get keyboardInput():KeyboardInput  { return _keyboardInput; }

        public function start():void  { _started = true; }
        public function stop():void  { _started = false; }

        public function get antiAliasing():int  { return _antiAliasing; }
        public function set antiAliasing(value:int):void
        {
            _antiAliasing = value;
            updateViewPoint();
        }

        public function get viewPoint():Rectangle  { return _viewPoint.clone(); }
        public function set viewPoint(value:Rectangle):void
        {
            _viewPoint = value.clone();
            updateViewPoint();
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
            _renderSupport.setupDefaultBlendFactors();

            _context3d.clear();
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
    }
}
