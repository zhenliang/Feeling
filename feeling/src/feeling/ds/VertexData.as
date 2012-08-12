package feeling.ds
{
    import feeling.core.Feeling;

    import flash.display3D.Context3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Point;
    import flash.geom.Vector3D;

    public class VertexData
    {
        public static const ELEMENTS_PER_VERTEX:int = 8;
        public static const POSITION_OFFSET:int = 0;
        public static const COLOR_OFFSET:int = 3;
        public static const TEXCOORD_OFFSET:int = 6;

        private var _data:Vector.<Number>;

        public function VertexData(numVertices:int)
        {
            _data = new Vector.<Number>(numVertices * ELEMENTS_PER_VERTEX, true);
        }

        // functions

        public function clone():VertexData
        {
            var clone:VertexData = new VertexData(0);
            clone._data = _data.concat();
            clone._data.fixed = true;
            return clone;
        }

        public function setPosition(vertexId:int, x:Number, y:Number, z:Number = 0.0):void
        {
            setValues(getOffset(vertexId), x, y, z);
        }

        public function getPostion(vertexId:int):Vector3D
        {
            var offset:int = getOffset(vertexId) + POSITION_OFFSET;
            return new Vector3D(_data[offset], _data[offset + 1], _data[offset + 2]);
        }

        public function setColor(vertexId:int, color:uint):void
        {
            setValues(getOffset(vertexId) + COLOR_OFFSET, Color.getRed(color) / 255, Color.getGreen(color) / 255, Color.
                getBlue(color) / 255);
        }

        public function setUniformColor(color:uint):void
        {
            for (var i:int = 0; i < numVertices; ++i)
                setColor(i, color);
        }

        public function getColor(vertexId:int):uint
        {
            var offset:int = getOffset(vertexId) + COLOR_OFFSET;
            return Color.createRgb(_data[offset] * 255, _data[offset + 1] * 255, _data[offset + 2] * 255);
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

        public function toVertexBuffer():VertexBuffer3D
        {
            var context:Context3D = Feeling.instance.context3d;
            var buffer:VertexBuffer3D = context.createVertexBuffer(numVertices, ELEMENTS_PER_VERTEX);
            buffer.uploadFromVector(_data, 0, numVertices);
            return buffer;
        }

        // helpers

        private function setValues(offset:int, ... values):void
        {
            for (var i:int = 0; i < values.length; ++i)
                _data[offset + i] = values[i];
        }

        private function getOffset(vertexId:int):int
        {
            return vertexId * ELEMENTS_PER_VERTEX;
        }

        // properties

        public function get numVertices():int
        {
            return _data.length / ELEMENTS_PER_VERTEX;
        }
    }
}
