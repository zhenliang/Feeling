package feeling.core
{
    import com.adobe.utils.PerspectiveMatrix3D;

    import feeling.display.Camera;
    import feeling.display.DisplayObject;
    import feeling.ds.Color;

    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.IndexBuffer3D;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;

    public class RenderSupport
    {
        public static function transformMatrixForObject(matrix:Matrix3D, object:DisplayObject):void
        {
            matrix.prependTranslation(object.x, object.y, object.z);

            matrix.prependRotation(object.rotationX, Vector3D.X_AXIS);
            matrix.prependRotation(object.rotationY, Vector3D.Y_AXIS);
            matrix.prependRotation(object.rotationZ, Vector3D.Z_AXIS);

            matrix.prependScale(object.scaleX, object.scaleY, object.scaleZ);

            matrix.prependTranslation(-object.pivotX, -object.pivotY, -object.pivotZ);
        }

        // members

        private var _camera:Camera;

        private var _modelMatrix:Matrix3D;
        private var _viewMatrix:Matrix3D;
        private var _projectionMatrix:PerspectiveMatrix3D;

        private var _matrixStack:Vector.<Matrix3D>;

        // construction

        public function RenderSupport(width:Number, height:Number)
        {
            _camera = new Camera();

            _modelMatrix = new Matrix3D();
            _viewMatrix = new Matrix3D();
            _projectionMatrix = new PerspectiveMatrix3D();

            _matrixStack = new Vector.<Matrix3D>();

            setupPerspectiveMatrix(width, height);
        }

        public function dispose():void  {}

        // camera

        public function get camera():Camera  { return _camera; }
        public function set camera(camera:Camera):void
        {
            _camera.removeFromParent(true);
            _camera = camera;
            Feeling.instance.feelingStage.addChild(_camera);
        }

        // matrix manipulation

        public function setupPerspectiveMatrix(width:Number, height:Number, near:Number = 0.001, far:Number = 1000.0):void
        {
            // _projectionMatrix.orthoRH(width, height, near, far);
            _projectionMatrix.perspectiveFieldOfViewRH(45.0, width / height, near, far);
        }

        public function identityMatrix():void
        {
            _modelMatrix.identity();
        }

        // 平移
        public function translateMatrix(dx:Number, dy:Number, dz:Number):void
        {
            _modelMatrix.prependTranslation(dx, dy, dz);
        }

        // 旋转
        public function rotateMatrix(angle:Number, axis:Vector3D):void
        {
            _modelMatrix.prependRotation(angle, axis);
        }

        // 缩放
        public function scaleMatrix(sx:Number, sy:Number, sz:Number):void
        {
            _modelMatrix.prependScale(sx, sy, sz);
        }

        // 转换
        public function transformMatrix(object:DisplayObject):void
        {
            transformMatrixForObject(_modelMatrix, object);
        }

        public function pushMatrix():void
        {
            _matrixStack.push(_modelMatrix.clone());
        }

        public function popMatrix():void
        {
            _modelMatrix = _matrixStack.pop();
        }

        public function resetMatrix():void
        {
            if (_matrixStack.length)
                _matrixStack = new Vector.<Matrix3D>();

            identityMatrix();
        }

        public function get mvpMatrix():Matrix3D
        {
            var mvpMatrix:Matrix3D = new Matrix3D();
            mvpMatrix.append(_modelMatrix);
            mvpMatrix.append(_camera.viewMatrix);
            mvpMatrix.append(_projectionMatrix);
            return mvpMatrix;
        }

        // other helper methods

        public function setupDefaultBlendFactors():void
        {
            Feeling.instance.context3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
        }

        public function clear(argb:uint = 0x0):void
        {
            Feeling.instance.context3d.clear(Color.getRed(argb) / 255, Color.getGreen(argb) / 255, Color.getBlue(argb) /
                255);
        }
    }
}
