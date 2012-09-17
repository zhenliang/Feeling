package feeling.utils
{
    /** Returns the next power of two that is equal to or bigger than the specified number. */
    public function getNextPowerOfTwo(number:int):int
    {
        var result:int = 1;
        while (result < number)
            result *= 2;
        return result;
    }
}
