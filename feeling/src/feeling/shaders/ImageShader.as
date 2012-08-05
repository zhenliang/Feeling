package feeling.shaders
{
    import com.adobe.utils.AGALMiniAssembler;

    import feeling.core.Feeling;

    import flash.display3D.Context3DProgramType;

    public class ImageShader
    {
        public static const PROGRAM_NAME:String = "ImageProgram";

        public static function registerPrograms():void
        {
            // create a vertex and fragment program - from assembly
            var vertexProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexProgramAssembler.assemble(Context3DProgramType.VERTEX, "m44 op, va0, vc0 \n" + // 4*4 matrix transform to ouput clipspace
                "mov v0, va1 \n" + // pass color to fragment program
                "mov v1, va2 \n" // pass texture coordinates to fragment program
                );

            var fragmentProgramAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            fragmentProgramAssembler.assemble(Context3DProgramType.FRAGMENT, "tex ft1, v1, fs1 <2d,clamp,linear> \n" + // sample texture 1
                "mul ft2, ft1, v0 \n" + // multiply color with texel color
                "mul oc, ft2, fc0 \n" // multiply color with alpha
                );

            Feeling.instance.shaderManager.registerProgram(PROGRAM_NAME, vertexProgramAssembler.agalcode, fragmentProgramAssembler.
                agalcode);
        }
    }
}
