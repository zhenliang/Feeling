package com.feeling.textures
{
	import com.feeling.ds.VertexData;
	
	import flash.display3D.textures.TextureBase;

	public class ConcreteTexture extends Texture
	{
		private var _width:int;
		private var _height:int;
		private var _base:TextureBase;
		
		public function ConcreteTexture(base:TextureBase, width:int, height:int)
		{
			_base = base;
			_width = width;
			_height = height;
		}
		
		public override function dispose():void
		{
			_base.dispose();
		}
		
		public override function get width():Number { return _width; }
		public override function get height():Number { return _height; }
		public override function get nativeTexture():TextureBase { return _base; }
		
		public override function adjustVertexData(vertexData:VertexData):VertexData
		{
			return vertexData.clone();
		}
	}
}