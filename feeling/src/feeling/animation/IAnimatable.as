package feeling.animation
{
    public interface IAnimatable
    {
        function advanceTime(time:Number):void;
        function get isComplete():Boolean;
    }
}
