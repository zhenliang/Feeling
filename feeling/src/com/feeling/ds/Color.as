package com.feeling.ds
{

    public class Color
    {
        public static function getRed( color:uint ):int  { return ( color >> 16 ) & 0xff; }

        public static function getGreen( color:uint ):int  { return ( color >> 8 ) & 0xff; }

        public static function getBlue( color:uint ):int  { return color & 0xff; }

        public static function create( red:int, green:int, blue:int ):uint
        {
            return ( red << 16 ) | ( green << 8 ) | blue;
        }
    }
}
