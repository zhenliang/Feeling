package feeling.display
{
    import feeling.config.Config;
    import feeling.core.Feeling;
    import feeling.core.RenderSupport;
    import feeling.core.ShaderManager;
    import feeling.data.CoordType;
    import feeling.data.VertexData;
    import feeling.shaders.QuadShader;

    import flash.display3D.Context3D;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Vector3D;

    public class Quad extends DisplayObject
    {
        protected var _vertexData:VertexData;
        protected var _vertexBuffer:VertexBuffer3D;
        protected var _indexBuffer:IndexBuffer3D;

        public function Quad(width:Number, height:Number, color:uint = 0xffffff)
        {
            _vertexData = new VertexData(4);

            if (Config.COORD_TYPE == CoordType.FLASH_2D)
            {
                // x 左到右，y 上到下
                _vertexData.setPosition(0, 0.0, 0.0);
                _vertexData.setPosition(1, width, 0.0);
                _vertexData.setPosition(2, 0.0, height);
                _vertexData.setPosition(3, width, height);
            }
            else
            {
                // x 左到右，y 下到上
                _vertexData.setPosition(0, 0.0, 0.0);
                _vertexData.setPosition(1, width, 0.0);
                _vertexData.setPosition(2, 0.0, -height);
                _vertexData.setPosition(3, width, -height);
            }

            _vertexData.setUniformColor(color);
        }

        public override function dispose():void
        {
            if (_vertexBuffer)
                _vertexBuffer.dispose();
            if (_indexBuffer)
                _indexBuffer.dispose();

            super.dispose();
        }

        public function get color():uint  { return _vertexData.getColor(0); }

        public function set color(value:uint):void
        {
            _vertexData.setUniformColor(value);
            if (_vertexBuffer)
                createVertexBuffer();
        }

        public function getVertexColor(vertexId:int):uint
        {
            return _vertexData.getColor(vertexId);
        }

        public function setVertexColor(vertexId:int, color:int):void
        {
            _vertexData.setColor(vertexId, color);
            if (_vertexBuffer)
                createVertexBuffer();
        }

        public function get vertexData():VertexData  { return _vertexData.clone(); }

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

        public override function render(alpha:Number):void
        {
            var context:Context3D = Feeling.instance.context3d;
            var shaderMgr:ShaderManager = Feeling.instance.shaderManager;
            var renderSupport:RenderSupport = Feeling.instance.renderSupport;

            if (_vertexBuffer == null)
                createVertexBuffer();
            if (_indexBuffer == null)
                createIndexBuffer();

            alpha *= this.alpha;

            var alphaVector:Vector.<Number> = new <Number>[alpha, alpha, alpha, alpha];

            context.setProgram(shaderMgr.getProgram(QuadShader.PROGRAM_NAME));
            context.setVertexBufferAt(0, _vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_3);
            context.setVertexBufferAt(1, _vertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
            context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, renderSupport.mvpMatrix, true);
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, alphaVector, 1);
            context.drawTriangles(_indexBuffer, 0, 2);

            context.setVertexBufferAt(0, null);
            context.setVertexBufferAt(1, null);
        }

        protected function createVertexBuffer():void
        {
            if (!_vertexBuffer)
                _vertexBuffer = Feeling.instance.context3d.createVertexBuffer(4, VertexData.ELEMENTS_PER_VERTEX);
            _vertexBuffer.uploadFromVector(vertexData.data, 0, 4);
        }

        protected function createIndexBuffer():void
        {
            if (!_indexBuffer)
                _indexBuffer = Feeling.instance.context3d.createIndexBuffer(6);
            _indexBuffer.uploadFromVector(Vector.<uint>([0, 1, 2, 1, 2, 3]), 0, 6);
        }
    }
}
