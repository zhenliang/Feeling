package feeling.shaders
{
    import com.adobe.utils.AGALMiniAssembler;

    import feeling.core.Feeling;

    import flash.display3D.Context3DProgramType;

    public class QuadShader
    {
        public static const PROGRAM_NAME:String = "QuadProgram";

        public static function registerPrograms():void
        {
            var vertexProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexProgramAssembler.assemble(Context3DProgramType.VERTEX, "m44 op, va0, vc0 \n" // 4*4 matrix transform to output clipspace 
                + "mov v0, va1 \n" // pass color to fragment program 
                );

            var fragmentProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            fragmentProgramAssembler.assemble(Context3DProgramType.FRAGMENT, "mul ft0, v0, fc0 \n" // multiply alpha (fc0) by color (v0)
                + "mov oc, ft0 \n" // output color
                );

            Feeling.instance.shaderManager.registerProgram(PROGRAM_NAME, vertexProgramAssembler.agalcode, fragmentProgramAssembler.
                agalcode);
        }
    }
}
