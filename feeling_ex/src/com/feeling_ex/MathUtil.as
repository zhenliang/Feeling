package com.feeling_ex
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class MathUtil
	{
		public static function RotateVector3d(vec:Vector3D, axis:Vector3D, deg:Number ):Vector3D
		{
			var rotationMatrix:Matrix3D = new Matrix3D();
			rotationMatrix.appendRotation(deg, axis);
			return rotationMatrix.deltaTransformVector(vec);
		}
	}
}