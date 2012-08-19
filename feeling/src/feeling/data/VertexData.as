package feeling.data
{
    import feeling.core.Feeling;

    import flash.display3D.Context3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Vector3D;

    public class VertexData
    {
        public static const ELEMENTS_PER_VERTEX:int = 9;
        public static const POSITION_OFFSET:int = 0;
        public static const COLOR_OFFSET:int = 3;
        public static const TEXCOORD_OFFSET:int = 7;

        private var _data:Vector.<Number>;

        // ctrs

        public function VertexData(numVertices:int)
        {
            _data = new Vector.<Number>(numVertices * ELEMENTS_PER_VERTEX, true);
        }

        public function clone():VertexData
        {
            var clone:VertexData = new VertexData(0);
            clone._data = _data.concat();
            clone._data.fixed = true;
            return clone;
        }

        // functions

        public function setPosition(vertexId:int, x:Number, y:Number, z:Number = 0.0):void
        {
            setValues(getOffset(vertexId) + POSITION_OFFSET, x, y, z);
        }

        public function getPostion(vertexId:int):Vector3D
        {
            var offset:int = getOffset(vertexId) + POSITION_OFFSET;
            return new Vector3D(_data[offset], _data[offset + 1], _data[offset + 2]);
        }

        public function setColor(vertexId:int, rgb:uint, alpha:Number = 1.0):void
        {
            setValues(getOffset(vertexId) + COLOR_OFFSET, Color.getRed(rgb) / 255, Color.getGreen(rgb) / 255, Color.getBlue(rgb) /
                255, alpha);
        }

        public function setUniformColor(rgb:uint, alpha:Number = 1.0):void
        {
            for (var i:int = 0; i < numVertices; ++i)
                setColor(i, rgb, alpha);
        }

        public function getColor(vertexId:int):uint
        {
            var offset:int = getOffset(vertexId) + COLOR_OFFSET;
            return Color.createRgb(_data[offset] * 255, _data[offset + 1] * 255, _data[offset + 2] * 255);
        }

        public function getAlpha(vertexId:int):uint
        {
            var offset:int = getOffset(vertexId) + COLOR_OFFSET + 3;
            return _data[offset];
        }

        public function setTexCoords(vertexId:int, u:Number, v:Number):void
        {
            setValues(getOffset(vertexId) + TEXCOORD_OFFSET, u, v);
        }

        public function getTexCoords(vertexId:int):Point
        {
            var offset:int = getOffset(vertexId) + TEXCOORD_OFFSET;
            return new Point(_data[offset], _data[offset + 1]);
        }

        public function append(data:VertexData):void
        {
            _data.fixed = false;
            for each (var element:Number in data)
                _data.push(element);
            _data.fixed = true;
        }

        public function toVertexBuffer():VertexBuffer3D
        {
            var context:Context3D = Feeling.instance.context3d;
            var buffer:VertexBuffer3D = context.createVertexBuffer(numVertices, ELEMENTS_PER_VERTEX);
            buffer.uploadFromVector(_data, 0, numVertices);
            return buffer;
        }

        // helpers

        public function translateVertex(vertexId:int, deltaX:Number, deltaY:Number, deltaZ:Number = 0.0):void
        {
            var offset:int = getOffset(vertexId) + POSITION_OFFSET;
            _data[offset] += deltaX;
            _data[offset + 1] += deltaY;
            _data[offset + 2] += deltaZ;
        }

        public function transformVertex(vertexId:int, matrix:Matrix3D = null, alpha:Number = 1.0):void
        {
            if (matrix)
            {
                var position:Vector3D = getPostion(vertexId);
                var transPosition:Vector3D = matrix.transformVector(position);
                setPosition(vertexId, transPosition.x, transPosition.y, transPosition.z);
            }

            if (alpha < 1.0)
            {
                var offset:int = getOffset(vertexId) + COLOR_OFFSET;
                for (var i:int = 0; i < 4; ++i)
                    _data[offset + i] *= alpha;
            }
        }

        private function setValues(offset:int, ... values):void
        {
            var numValues:int = values.length;
            for (var i:int = 0; i < numValues; ++i)
                _data[offset + i] = values[i];
        }

        private function getOffset(vertexId:int):int
        {
            return vertexId * ELEMENTS_PER_VERTEX;
        }

        // properties

        public function get numVertices():int  { return _data.length / ELEMENTS_PER_VERTEX; }

        public function get data():Vector.<Number>  { return _data; }
    }
}
