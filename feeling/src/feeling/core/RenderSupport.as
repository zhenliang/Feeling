package feeling.core
{
    import com.adobe.utils.PerspectiveMatrix3D;

    import feeling.data.Color;
    import feeling.display.Camera;
    import feeling.display.DisplayObject;

    import flash.display3D.Context3DBlendFactor;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;

    /** A class that contains helper methods simplifying Stage3D rendering.
     *
     *  A RenderSupport instance is passed to any "render" method of display objects.
     *  It allows manipulation of the current transformation matrix (similar to the matrix
     *  manipulation methods of OpenGL 1.x) and other helper methods.
     */
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

        private var _mvpMatrix:Matrix3D;

        private var _matrixStack:Vector.<Matrix3D>;
        private var _matrixStackSize:int;

        private var _ortho:Boolean;

        // construction

        /** Creates a new RenderSupport object with an empty matrix stack. */
        public function RenderSupport(width:Number, height:Number)
        {
            _camera = new Camera();

            _modelMatrix = new Matrix3D();
            _viewMatrix = new Matrix3D();
            _projectionMatrix = new PerspectiveMatrix3D();

            _mvpMatrix = new Matrix3D();

            _matrixStack = new <Matrix3D>[];
            _matrixStackSize = 0;

            _ortho = false;

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

        public function get ortho():Boolean  { return _ortho; }
        public function set ortho(value:Boolean):void  { _ortho = value; }

        // matrix manipulation

        /** Sets up the projection matrix for rendering. */
        public function setupPerspectiveMatrix(width:Number, height:Number, near:Number = 0.001, far:Number = 1000.0):void
        {
            if (_ortho)
                _projectionMatrix.orthoRH(width, height, near, far);
            else
                _projectionMatrix.perspectiveFieldOfViewRH(45.0, width / height, near, far);
        }

        /** Changes the modelview matrix to the identity matrix. */
        public function identityMatrix():void
        {
            _modelMatrix.identity();
        }

        /** Prepends a translation to the modelview matrix. */
        public function translateMatrix(dx:Number, dy:Number, dz:Number):void
        {
            _modelMatrix.prependTranslation(dx, dy, dz);
        }

        /** Prepends a rotation (angle in radians) to the modelview matrix. */
        public function rotateMatrix(angle:Number, axis:Vector3D):void
        {
            _modelMatrix.prependRotation(angle, axis);
        }

        /** Prepends an incremental scale change to the modelview matrix. */
        public function scaleMatrix(sx:Number, sy:Number, sz:Number):void
        {
            _modelMatrix.prependScale(sx, sy, sz);
        }

        /** Prepends translation, scale and rotation of an object to the modelview matrix. */
        public function transformMatrix(object:DisplayObject):void
        {
            transformMatrixForObject(_modelMatrix, object);
        }

        /** Pushes the current modelview matrix to a stack from which it can be restored later. */
        public function pushMatrix():void
        {
            if (_matrixStack.length < _matrixStackSize + 1)
                _matrixStack.push(new Matrix3D());

            _matrixStack[_matrixStackSize++].copyFrom(_modelMatrix);
        }

        /** Restores the modelview matrix that was last pushed to the stack. */
        public function popMatrix():void
        {
            _modelMatrix.copyFrom(_matrixStack[--_matrixStackSize]);
        }

        /** Empties the matrix stack, resets the modelview matrix to the identity matrix. */
        public function resetMatrix():void
        {
            _matrixStackSize = 0;
            identityMatrix();
        }

        /** Calculates the product of modelview and projection matrix.
         *  CAUTION: Don't save a reference to this object! Each call returns the same instance. */
        public function get mvpMatrix():Matrix3D
        {
            _mvpMatrix.identity();
            _mvpMatrix.append(_modelMatrix);
            _mvpMatrix.append(_camera.viewMatrix);
            _mvpMatrix.append(_projectionMatrix);
            return _mvpMatrix;
        }

        // other helper methods

        /** Sets up the default blending factors, depending on the premultiplied alpha status. */
        public function setupDefaultBlendFactors(premultipliedAlpha:Boolean):void
        {
            var destFactor:String = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
            var sourceFactor:String = premultipliedAlpha ? Context3DBlendFactor.ONE : Context3DBlendFactor.SOURCE_ALPHA;
            Feeling.instance.context3d.setBlendFactors(sourceFactor, destFactor);
        }

        /** Clears the render context with a certain color and alpha value. */
        public function clear(argb:uint = 0x0, alpha:Number = 1.0):void
        {
            Feeling.instance.context3d.clear(Color.getRed(argb) / 255, Color.getGreen(argb) / 255, Color.getBlue(argb) /
                255, alpha);
        }
    }
}
