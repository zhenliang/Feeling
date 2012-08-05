package feeling.display
{
    import feeling.core.Feeling;
    import feeling.core.RenderSupport;
    import feeling.core.ShaderManager;
    import feeling.ds.VertexData;
    import feeling.shaders.QuadShader;

    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;

    public class Quad extends DisplayObject
    {
        protected var _vertexData:VertexData;
        protected var _vertexBuffer:VertexBuffer3D;

        public function Quad(width:Number, height:Number, color:uint = 0xffffff)
        {
            _vertexData = new VertexData(4);
            _vertexData.setPosition(0, 0.0, 0.0);
            _vertexData.setPosition(1, width, 0.0);
            _vertexData.setPosition(2, 0.0, height);
            _vertexData.setPosition(3, width, height);
            _vertexData.setUniformColor(color);
        }

        public override function dispose():void
        {
            if (_vertexBuffer)
                _vertexBuffer.dispose();

            super.dispose();
        }

        public override function getBounds(targetSpace:DisplayObject):Rectangle
        {
            var minX:Number = Number.MAX_VALUE, maxX:Number = -Number.MAX_VALUE;
            var minY:Number = Number.MAX_VALUE, maxY:Number = -Number.MAX_VALUE;

            if (targetSpace == this) // optimization
            {
                for (var i:int = 0; i < 4; ++i)
                {
                    var pos:Vector3D = _vertexData.getPostion(i);
                    minX = Math.min(minX, pos.x);
                    minY = Math.min(minY, pos.y);
                    maxX = Math.max(maxX, pos.x);
                    maxY = Math.max(maxY, pos.y);
                }
            }
            else
            {
                var transformationMatrix:Matrix = getTransformationMatrixToSpace(targetSpace);
                for (var k:int = 0; k < 4; ++k)
                {
                    var point:Point = new Point();
                    point.x = _vertexData.getPostion(k).x;
                    point.y = _vertexData.getPostion(k).y;
                    var transformedPoint:Point = transformationMatrix.transformPoint(point);
                    minX = Math.min(minX, transformedPoint.x);
                    minY = Math.min(minY, transformedPoint.y);
                    maxX = Math.max(maxX, transformedPoint.x);
                    maxY = Math.max(maxY, transformedPoint.y);
                }
            }

            return new Rectangle(minX, minY, maxX - minX, maxY - minY);
        }

        public override function render():void
        {
            var context:Context3D = Feeling.instance.context3d;
            var shaderMgr:ShaderManager = Feeling.instance.shaderManager;
            var renderSupport:RenderSupport = Feeling.instance.renderSupport;

            if (_vertexBuffer == null)
                createVertexBuffer();

            var alphaVector:Vector.<Number> = new <Number>[alpha, alpha, alpha, alpha];

            context.setProgram(shaderMgr.getProgram(QuadShader.PROGRAM_NAME));
            context.setVertexBufferAt(0, _vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_3);
            context.setVertexBufferAt(1, _vertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_3);
            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, renderSupport.mvpMatrix, true);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, alphaVector, 1);
            context.drawTriangles(renderSupport.quadIndexBuffer, 0, 2);

            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
        }

        protected function createVertexBuffer():void
        {
            if (_vertexBuffer)
                _vertexBuffer.dispose();
            _vertexBuffer = _vertexData.toVertexBuffer();
        }
    }
}
