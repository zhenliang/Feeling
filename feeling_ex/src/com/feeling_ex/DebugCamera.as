package com.feeling_ex
{
	import com.feeling.core.Feeling;
	import com.feeling.display.Camera;
	import com.feeling.events.EnterFrameEvent;
	import com.feeling.events.Event;
	import com.feeling.input.KeyboardInput;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class DebugCamera extends Camera
	{
		private static var MOVE_SPEED:Number = 80;
		private static var ROTATE_SPEED:Number = 360 / 30;
		
		private var _forwardVec:Vector3D;
		private var _upVec:Vector3D;
		
		private var _modelMatrix:Matrix3D;
		
		public function DebugCamera()
		{
			reset();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		public override function get viewMatrix():Matrix3D
		{
			var viewMatrix:Matrix3D = _modelMatrix.clone();
			viewMatrix.invert();
			return viewMatrix;
		}
		
		public function onEnterFrame(e:EnterFrameEvent):void
		{
			updateTranslation(e.passedTime);
			updateRotation(e.passedTime);
			updateModelMatrix();
			
			// 从转换矩阵更新法向量
			
			_upVec = _modelMatrix.deltaTransformVector(new Vector3D(0, 1, 0));

			// 按下 r 键则重置数据
			
			var kKeyboardInput:KeyboardInput = Feeling.instance.keyboardInput;
			if (kKeyboardInput.getKeyStatus("r".charCodeAt(0)))
				reset();
		}
		
		private function updateTranslation(passedTime:Number):void
		{
			var kKeyboardInput:KeyboardInput = Feeling.instance.keyboardInput;
			
			if (kKeyboardInput.getKeyStatus("w".charCodeAt(0)))
				move(passedTime, _forwardVec);
			if (kKeyboardInput.getKeyStatus("s".charCodeAt(0)))
				move(passedTime, new Vector3D(-_forwardVec.x, -_forwardVec.y, -_forwardVec.z));
			
			var rightVec:Vector3D = _forwardVec.crossProduct(_upVec);
			if (kKeyboardInput.getKeyStatus("d".charCodeAt(0)))
				move(passedTime, rightVec);
			if (kKeyboardInput.getKeyStatus("a".charCodeAt(0)))
				move(passedTime, new Vector3D(-rightVec.x, -rightVec.y, -rightVec.z));
			
			if (kKeyboardInput.getKeyStatus("q".charCodeAt(0)))
				move(passedTime, _upVec);
			if (kKeyboardInput.getKeyStatus("e".charCodeAt(0)))
				move(passedTime, new Vector3D(-_upVec.x, -_upVec.y, -_upVec.z));
		}
		
		private function updateRotation(passedTime:Number):void
		{
			var kKeyboardInput:KeyboardInput = Feeling.instance.keyboardInput;
			
			var oldForwardVector:Vector3D = _forwardVec.clone(); 
			var oldUpVector:Vector3D = _upVec.clone();
			var oldRightVector:Vector3D = oldForwardVector.crossProduct(oldUpVector);
			
			if (kKeyboardInput.getKeyStatus("i".charCodeAt(0)))
				_forwardVec = MathUtil.RotateVector3d(_forwardVec, oldRightVector, ROTATE_SPEED * passedTime);
			if (kKeyboardInput.getKeyStatus("k".charCodeAt(0)))
				_forwardVec = MathUtil.RotateVector3d(_forwardVec, oldRightVector, -ROTATE_SPEED * passedTime);
			if (kKeyboardInput.getKeyStatus("j".charCodeAt(0)))
				_forwardVec = MathUtil.RotateVector3d(_forwardVec, oldUpVector, ROTATE_SPEED * passedTime);
			if (kKeyboardInput.getKeyStatus("l".charCodeAt(0)))
				_forwardVec = MathUtil.RotateVector3d(_forwardVec, oldUpVector, -ROTATE_SPEED * passedTime);
			if (kKeyboardInput.getKeyStatus("z".charCodeAt(0)))
				rotationZ -= ROTATE_SPEED * passedTime;
			if (kKeyboardInput.getKeyStatus("c".charCodeAt(0)))
				rotationZ += ROTATE_SPEED * passedTime;
		}
		
		private function updateModelMatrix():void
		{
			// 生成转换矩阵
			
			_modelMatrix.identity();
			_modelMatrix.appendTranslation(x, y, z);
			var curPos:Vector3D = new Vector3D(x, y, z);
			var pointAt:Vector3D = curPos.add(_forwardVec);
			var relateUpVector:Vector3D = new Vector3D(0, -1, 0);
			var upVecRotationMatrix:Matrix3D = new Matrix3D();
			upVecRotationMatrix.appendRotation(rotationZ, Vector3D.Z_AXIS);
			relateUpVector = upVecRotationMatrix.deltaTransformVector(relateUpVector);
			_modelMatrix.pointAt(pointAt, new Vector3D(0, 0, -1), relateUpVector);
		}
		
		private function reset():void
		{
			x = 0;
			y = 0;
			z = 0;
			
			rotationX = 0;
			rotationY = 0;
			rotationZ = 0;
			
			_forwardVec = new Vector3D(0, 0, -1);
			_upVec = new Vector3D(0, 1, 0);
			
			_modelMatrix = new Matrix3D();
		}
		
		private function move(passedTime:Number, direction:Vector3D):void
		{
			x += MOVE_SPEED * passedTime * direction.x;
			y += MOVE_SPEED * passedTime * direction.y;
			z += MOVE_SPEED * passedTime * direction.z;
		}
	}
}