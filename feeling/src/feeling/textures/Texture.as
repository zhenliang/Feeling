package feeling.textures
{
	import feeling.ds.VertexData;
	
	import flash.display3D.textures.TextureBase;
	import flash.utils.getQualifiedClassName;

	public class Texture
	{
		public function Texture() 
		{
			if (getQualifiedClassName(this) == "feeling.textures::Texture") 
				throw new Error();
		}
		
		public function dispose():void {}
		public function get width():Number { return 0; }
		public function get height():Number { return 0; }
		public function get nativeTexture():TextureBase { return null; }
		public function adjustVertexData(vertexData:VertexData):VertexData { return null; }
	}
}