package feeling.ds
{

    public class Color
    {
        public static function getAlpha(color:uint):int  { return (color >> 24) & 0xff; }

        public static function getRed(color:uint):int  { return (color >> 16) & 0xff; }

        public static function getGreen(color:uint):int  { return (color >> 8) & 0xff; }

        public static function getBlue(color:uint):int  { return color & 0xff; }

        public static function createRgb(red:int, green:int, blue:int):uint
        {
            return (red << 16) | (green << 8) | blue;
        }

        public static function createArgb(alpha:int, red:int, green:int, blue:int):uint
        {
            return (alpha << 24) | (red << 16) | (green << 8) | blue;
        }
    }
}
