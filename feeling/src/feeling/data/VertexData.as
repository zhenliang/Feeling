package feeling.data
{
    import feeling.core.Feeling;

    import flash.display3D.Context3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Vector3D;

    /** The VertexData class manages a raw list of vertex information, allowing direct upload
     *  to Stage3D vertex buffers. <em>You only have to work with this class if you create display
     *  objects with a custom render function. If you don't plan to do that, you can safely
     *  ignore it.</em>
     *
     *  <p>To render objects with Stage3D, you have to organize vertex data in so-called
     *  vertex buffers. Those buffers reside in graphics memory and can be accessed very
     *  efficiently by the GPU. Before you can move data into vertex buffers, you have to
     *  set it up in conventional memory - that is, in a Vector object. The vector contains
     *  all vertex information (the coordinates, color, and texture coordinates) - one
     *  vertex after the other.</p>
     *
     *  <p>To simplify creating and working with such a bulky list, the VertexData class was
     *  created. It contains methods to specify and modify vertex data. The raw Vector managed
     *  by the class can then easily be uploaded to a vertex buffer.</p>
     *
     *  <strong>Premultiplied Alpha</strong>
     *
     *  <p>The color values of the "BitmapData" object contain premultiplied alpha values, which
     *  means that the <code>rgb</code> values were multiplied with the <code>alpha</code> value
     *  before saving them. Since textures are created from bitmap data, they contain the values in
     *  the same style. On rendering, it makes a difference in which way the alpha value is saved;
     *  for that reason, the VertexData class mimics this behavior. You can choose how the alpha
     *  values should be handled via the <code>premultipliedAlpha</code> property.</p>
     *
     *  <p><em>Note that vertex data with premultiplied alpha values will lose all <code>rgb</code>
     *  information of a vertex with a zero <code>alpha</code> value.</em></p>
     */
    public class VertexData
    {
        /** The total number of elements (Numbers) stored per vertex. */
        public static const ELEMENTS_PER_VERTEX:int = 9;

        /** The offset of position data (x, y) within a vertex. */
        public static const POSITION_OFFSET:int = 0;

        /** The offset of color data (r, g, b, a) within a vertex. */
        public static const COLOR_OFFSET:int = 3;

        /** The offset of texture coordinate (u, v) within a vertex. */
        public static const TEXCOORD_OFFSET:int = 7;

        private var _data:Vector.<Number>;
        private var _premultipliedAlpha:Boolean;

        // ctrs

        /** Create a new VertexData object with a specified number of vertices. */
        public function VertexData(numVertices:int, premultipliedAlpha:Boolean = false)
        {
            _data = new Vector.<Number>(numVertices * ELEMENTS_PER_VERTEX, true);
            _premultipliedAlpha = premultipliedAlpha;
        }

        /** Creates a duplicate of the vertex data object. */
        public function clone():VertexData
        {
            var clone:VertexData = new VertexData(0, _premultipliedAlpha);
            clone._data = _data.concat();
            clone._data.fixed = true;
            return clone;
        }

        // functions

        /** Updates the position values of a vertex. */
        public function setPosition(vertexId:int, x:Number, y:Number, z:Number = 0.0):void
        {
            setValues(getOffset(vertexId) + POSITION_OFFSET, x, y, z);
        }

        /** Returns the position of a vertex. */
        public function getPostion(vertexId:int):Vector3D
        {
            var offset:int = getOffset(vertexId) + POSITION_OFFSET;
            return new Vector3D(_data[offset], _data[offset + 1], _data[offset + 2]);
        }

        /** Updates the color and alpha values of a vertex. */
        public function setColor(vertexId:int, rgb:uint, alpha:Number = 1.0):void
        {
            var multiplier:Number = _premultipliedAlpha ? alpha : 1.0;
            setValues(getOffset(vertexId) + COLOR_OFFSET, Color.getRed(rgb) / 255 * multiplier, Color.getGreen(rgb) / 255 *
                multiplier, Color.getBlue(rgb) / 255 * multiplier, alpha);
        }

        /** Sets all vertices of the object to the same color and alpha values. */
        public function setUniformColor(rgb:uint, alpha:Number = 1.0):void
        {
            for (var i:int = 0; i < numVertices; ++i)
                setColor(i, rgb, alpha);
        }

        /** Returns the RGB color of a vertex (no alpha). */
        public function getColor(vertexId:int):uint
        {
            var offset:int = getOffset(vertexId) + COLOR_OFFSET;
            var divisor:Number = _premultipliedAlpha ? _data[offset + 3] : 1.0;
            if (divisor == 0)
                return 0;

            var red:Number = _data[offset] / divisor;
            var green:Number = _data[offset + 1] / divisor;
            var blue:Number = _data[offset + 2] / divisor;
            return Color.createRgb(red * 255, green * 255, blue * 255);
        }

        /** Returns the alpha value of a vertex in the range 0-1. */
        public function getAlpha(vertexId:int):uint
        {
            var offset:int = getOffset(vertexId) + COLOR_OFFSET + 3;
            return _data[offset];
        }

        /** Updates the alpha value of a vertex (range 0-1). */
        public function setAlpha(vertexId:int, alpha:Number):void
        {
            if (_premultipliedAlpha)
                setColor(vertexId, getColor(vertexId), alpha);
            else
            {
                var offset:int = getOffset(vertexId) + COLOR_OFFSET + 3;
                _data[offset] = alpha;
            }
        }

        /** Multiplies the alpha value of a vertex with a certain delta. */
        public function scaleAlpha(vertexId:int, alpha:Number):void
        {
            if (_premultipliedAlpha)
                setAlpha(vertexId, getAlpha(vertexId) * alpha);
            else
            {
                var offset:int = getOffset(vertexId) + COLOR_OFFSET + 3;
                _data[offset] *= alpha;
            }
        }

        /** Updates the texture coordinates of a vertex (range 0-1). */
        public function setTexCoords(vertexId:int, u:Number, v:Number):void
        {
            setValues(getOffset(vertexId) + TEXCOORD_OFFSET, u, v);
        }

        /** Returns the texture coordinates of a vertex in the range 0-1. */
        public function getTexCoords(vertexId:int):Point
        {
            var offset:int = getOffset(vertexId) + TEXCOORD_OFFSET;
            return new Point(_data[offset], _data[offset + 1]);
        }

        /** Appends the vertices from another VertexData object. */
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

        /** Translate the position of a vertex by a certain offset. */
        public function translateVertex(vertexId:int, deltaX:Number, deltaY:Number, deltaZ:Number = 0.0):void
        {
            var offset:int = getOffset(vertexId) + POSITION_OFFSET;
            _data[offset] += deltaX;
            _data[offset + 1] += deltaY;
            _data[offset + 2] += deltaZ;
        }

        /** Transforms the position of a vertex by multiplication with a transformation matrix. */
        public function transformVertex(vertexId:int, matrix:Matrix3D = null):void
        {
            if (matrix)
            {
                var position:Vector3D = getPostion(vertexId);
                var transPosition:Vector3D = matrix.transformVector(position);
                setPosition(vertexId, transPosition.x, transPosition.y, transPosition.z);
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

        /** Indicates if the rgb values are stored premultiplied with the alpha value. */
        public function get premultipliedAlpha():Boolean  { return _premultipliedAlpha; }

        /** Changes the way alpha and color values are stored. Updates all exisiting vertices. */
        public function set premultipliedAlpha(value:Boolean):void
        {
            if (value == _premultipliedAlpha)
                return;

            var dataLen:int = _data.length;

            for (var i:int = COLOR_OFFSET; i < dataLen; i += ELEMENTS_PER_VERTEX)
            {
                var alpha:Number = _data[i + 3];
                var divisor:Number = _premultipliedAlpha ? alpha : 1.0;
                var multiplier:Number = value ? alpha : 0.0;

                if (divisor != 0)
                {
                    _data[i] = _data[i] / divisor * multiplier;
                    _data[i + 1] = _data[i + 1] / divisor * multiplier;
                    _data[i + 2] = _data[i + 2] / divisor * multiplier;
                }
            }

            _premultipliedAlpha = value;
        }

        /** The total number of vertices. */
        public function get numVertices():int  { return _data.length / ELEMENTS_PER_VERTEX; }

        /** The raw vertex data; not a copy! */
        public function get data():Vector.<Number>  { return _data; }
    }
}
