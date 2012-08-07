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
        // members

        private var _camera:Camera;

        private var _modelMatrix:Matrix3D;
        private var _viewMatrix:Matrix3D;
        private var _projectionMatrix:PerspectiveMatrix3D;

        private var _matrixStack:Vector.<Matrix3D>;

        private var _quadIndexBuffer:IndexBuffer3D;

        // construction

        public function RenderSupport(width:Number, height:Number)
        {
            _camera = new Camera();

            _modelMatrix = new Matrix3D();
            _viewMatrix = new Matrix3D();
            _projectionMatrix = new PerspectiveMatrix3D();
            setupPerspectiveMatrix(width, height);

            _matrixStack = new Vector.<Matrix3D>();

            _quadIndexBuffer = Feeling.instance.context3d.createIndexBuffer(6);
            _quadIndexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 1, 2, 3]), 0, 6);
        }

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
            _projectionMatrix.orthoRH(width, height, near, far);
            return;
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
            translateMatrix(object.x, object.y, object.z);

            rotateMatrix(object.rotationX, Vector3D.X_AXIS);
            rotateMatrix(object.rotationY, Vector3D.Y_AXIS);
            rotateMatrix(object.rotationZ, Vector3D.Z_AXIS);

            scaleMatrix(object.scaleX, object.scaleY, object.scaleZ);

            translateMatrix(-object.pivotX, -object.pivotY, -object.pivotZ);
        }

        public function pushMatrix():void
        {
            _matrixStack.push(_modelMatrix.clone());
        }

        public function popMatrix():void
        {
            _modelMatrix = _matrixStack.pop();
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

        public function get quadIndexBuffer():IndexBuffer3D  { return _quadIndexBuffer; }

        public function setupDefaultBlendFactors():void
        {
            Feeling.instance.context3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
        }

        public function clear(color:uint = 0x0):void
        {
            Feeling.instance.context3d.clear(Color.getRed(color), Color.getGreen(color), Color.getBlue(color));
        }

        // cleanup

        public function dispose():void
        {
            _quadIndexBuffer.dispose();
        }
    }
}
