package
{
	import feeling.textures.Texture;
	import feeling.textures.TextureCreator;
	
	import flash.display.Bitmap;
	import flash.utils.Dictionary;

	public class Assets
	{
		// Bitmaps
		
		[Embed(source = "../../media/textures/2x/background.png")]
		public static const Background:Class;
		
		[Embed(source = "../../media/textures/2x/logo.png")]
		public static const Logo:Class;

		[Embed(source = "../../media/textures/2x/button_back.png")]
		public static const ButtonBack:Class;

		[Embed(source = "../../media/textures/2x/button_big.png")]
		public static const ButtonBig:Class;

		[Embed(source = "../../media/textures/2x/button_normal.png")]
		public static const ButtonNormal:Class;

		[Embed(source = "../../media/textures/2x/button_square.png")]
		public static const ButtonSquare:Class;

		[Embed(source = "../../media/textures/2x/benchmark_object.png")]
		public static const BenchmarkObject:Class;
		
		[Embed(source = "../../media/textures/2x/starling_front.png")]
		public static const StarlingFront:Class;

		public static function getTexture(name:String):Texture
		{
			if (!_textures[name])
			{
				var bitmap:Bitmap = new Assets[name]();
				_textures[name] = TextureCreator.createFromBitmap(bitmap);
			}
			
			return _textures[name];
		}
		
		private static var _textures:Dictionary = new Dictionary();
	}
}

