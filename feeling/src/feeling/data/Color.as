package feeling.data
{
    /** A utility class containing predefined colors and methods converting between different
     *  color representations. */
    public class Color
    {
        /** Returns the alpha part of an ARGB color (0 - 255). */
        public static function getAlpha(color:uint):int  { return (color >> 24) & 0xff; }

        /** Returns the red part of an (A)RGB color (0 - 255). */
        public static function getRed(color:uint):int  { return (color >> 16) & 0xff; }

        /** Returns the green part of an (A)RGB color (0 - 255). */
        public static function getGreen(color:uint):int  { return (color >> 8) & 0xff; }

        /** Returns the blue part of an (A)RGB color (0 - 255). */
        public static function getBlue(color:uint):int  { return color & 0xff; }

        /** Creates an RGB color, stored in an unsigned integer. Channels are expected
         *  in the range 0 - 255. */
        public static function createRgb(red:int, green:int, blue:int):uint
        {
            return (red << 16) | (green << 8) | blue;
        }

        /** Creates an ARGB color, stored in an unsigned integer. Channels are expected
         *  in the range 0 - 255. */
        public static function createArgb(alpha:int, red:int, green:int, blue:int):uint
        {
            return (alpha << 24) | (red << 16) | (green << 8) | blue;
        }
    }
}
