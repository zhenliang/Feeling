package com.feeling.display
{
	import com.feeling.core.Feeling;
	import com.feeling.core.RenderSupport;
	import com.feeling.core.ShaderManager;
	import com.feeling.ds.VertexData;
	import com.feeling.shaders.ImageShader;
	import com.feeling.textures.Texture;
	import com.feeling.textures.TextureCreator;
	
	import flash.display.Bitmap;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;

	public class Image extends Quad
	{
		private var _texture:Texture;

		public static function fromBitmap(bitmap:Bitmap):Image
		{
			return new Image(TextureCreator.createFromBitmap(bitmap));
		}
		
		public function Image(texture:Texture)
		{
			if (texture)
			{
				super(texture.width, texture.height);
				_vertexData.setTexCoords(0, 0.0, 0.0);
				_vertexData.setTexCoords(1, 1.0, 0.0);
				_vertexData.setTexCoords(2, 0.0, 1.0);
				_vertexData.setTexCoords(3, 1.0, 1.0);
				_texture = texture;
			}
			else
			{
				throw new Error();
			}
		}
		
		public override function render():void
		{
			var context:Context3D = Feeling.instance.context3d;
			var shaderMgr:ShaderManager = Feeling.instance.shaderManager;
			var renderSupport:RenderSupport = Feeling.instance.renderSupport;
			
			if (!_vertexBuffer)
				createVertexBuffer();
			
			var alphaVec:Vector.<Number> = new <Number>[alpha, alpha, alpha, alpha];
			
			context.setProgram(shaderMgr.getProgram(ImageShader.PROGRAM_NAME));
			context.setTextureAt(1, _texture.nativeTexture);
			context.setVertexBufferAt(0, _vertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_3);
			context.setVertexBufferAt(1, _vertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_3);
			context.setVertexBufferAt(2, _vertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, renderSupport.mvpMatrix, true);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, alphaVec, 1);
			context.drawTriangles(renderSupport.quadIndexBuffer, 0, 2);
			
			context.setTextureAt(1, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
		}
		
		protected override function createVertexBuffer():void
		{
			if (_vertexBuffer)
				_vertexBuffer.dispose();
			_vertexBuffer = _texture.adjustVertexData(_vertexData).toVertexBuffer();
		}
	}
}