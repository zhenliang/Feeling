package com.feeling.display
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class Camera extends DisplayObject 
	{
		protected var _viewMatrix:Matrix3D;
		
		public function Camera()
		{
			_viewMatrix = new Matrix3D();
		}
		
		public function get viewMatrix():Matrix3D
		{
			_viewMatrix.identity();
			_viewMatrix.appendTranslation(-x, -y, -z);
			_viewMatrix.appendRotation(-rotationX, Vector3D.X_AXIS);
			_viewMatrix.appendRotation(-rotationY, Vector3D.Y_AXIS);
			_viewMatrix.appendRotation(-rotationZ, Vector3D.Z_AXIS);
			return _viewMatrix;
		}
	}
}