package feeling.core
{
    import flash.display3D.Program3D;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    public class ShaderManager
    {
        private var _programs:Dictionary;

        public function ShaderManager()
        {
            _programs = new Dictionary();
        }

        public function dispose():void
        {
            for each (var program:Program3D in _programs)
                program.dispose();
            _programs = null;
        }

        public function registerProgram(name:String, vertexProgram:ByteArray, fragmentProgram:ByteArray):void
        {
            var program:Program3D = Feeling.instance.context3d.createProgram();
            program.upload(vertexProgram, fragmentProgram);
            _programs[name] = program;
        }

        public function unregisterProgram(name:String):void
        {
            var program:Program3D = getProgram(name);
            if (program)
            {
                program.dispose();
                delete _programs[name];
            }
        }

        public function getProgram(name:String):Program3D
        {
            return _programs[name] as Program3D;
        }
    }
}
