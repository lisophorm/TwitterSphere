package away3d.controllers
{
	import away3d.arcane;
	import away3d.containers.*;
	import away3d.entities.*;
	import away3d.core.math.*;
	import flash.geom.Vector3D;
	
	import flash.geom.Matrix3D;
	
	use namespace arcane;
	
	/**
	 * Extended camera used to hover round a specified target object.
	 * 
	 * @see	away3d.containers.View3D
	 */
	public class HoverControllerJB extends LookAtController
	{
		arcane var _currentPanAngle:Number = 0;
		arcane var _currentTiltAngle:Number = 90;
		arcane var _currentDistance:Number = 1000;
		
		private var _panAngle:Number = 0;
		private var _tiltAngle:Number = 90;
		private var _distance:Number = 1000;
		private var _maxDistance:Number = Infinity;
		private var _minDistance:Number = 20;
		private var _minPanAngle:Number = -Infinity;
		private var _maxPanAngle:Number = Infinity;
		private var _minTiltAngle:Number = -90;
		private var _maxTiltAngle:Number = 90;
		private var _steps:Number = 8;
		private var _yFactor:Number = 2;
		private var _wrapPanAngle:Boolean = false;
		private var upVector:Vector3D = new Vector3D();
		private var _noFlip:Boolean = false;
		
		/**
		 * Fractional step taken each time the <code>hover()</code> method is called. Defaults to 8.
		 * 
		 * Affects the speed at which the <code>tiltAngle</code> and <code>panAngle</code> resolve to their targets.
		 * 
		 * @see	#tiltAngle
		 * @see	#panAngle
		 */
		public var steps:Number = 8;
		
		/**
		 * Rotation of the camera in degrees around the y axis. Defaults to 0.
		 */
		public function get panAngle():Number
		{
			return _panAngle;
		}
		
		public function set panAngle(val:Number):void
		{
			val = Math.max(_minPanAngle, Math.min(_maxPanAngle, val));
			
			if (_panAngle == val)
				return;
			
			_panAngle = val;
			
			notifyUpdate();
		}
		
		/**
		 * Elevation angle of the camera in degrees. Defaults to 90.
		 */
		public function get tiltAngle():Number
		{
			return _tiltAngle;
		}
		
		public function set tiltAngle(val:Number):void
		{
			val = Math.max(_minTiltAngle, Math.min(_maxTiltAngle, val));
			
			if (_tiltAngle == val)
				return;
			
			_tiltAngle = val;
			
			notifyUpdate();
		}
		
		/**
		 * Distance between the camera and the specified target. Defaults to 1000.
		 */
		public function get distance():Number
		{
			return _distance;
		}
		
		public function set distance(val:Number):void
		{
			val = Math.max(_minDistance, Math.min(_maxDistance, val));
			
			if (_distance == val)
				return;
			
			_distance = val;
			
			notifyUpdate();
		}
		
		/**
		 * Maximum distance between the camera and the specified target.
		 * Defaults to Infinity.
		 */
		public function get maxDistance():Number
		{
			return _maxDistance;
		}
		
		public function set maxDistance(val:Number):void
		{
			if (_maxDistance == val)
				return;
			
			_maxDistance= val;
			
			distance = Math.max(_minDistance, Math.min(_maxDistance, _distance));
		}
		
		/**
		 * Minimum distance between the camera and the specified target.
		 * Defaults to 20.
		 */
		public function get minDistance():Number
		{
			return _minDistance;
		}
		
		public function set minDistance(val:Number):void
		{
			if (_minDistance == val)
				return;
			
			_minDistance = val;
			
			distance = Math.max(_minDistance, Math.min(_maxDistance, _distance));
		}
		
		/**
		 * Minimum bounds for the <code>panAngle</code>. Defaults to -Infinity.
		 * 
		 * @see	#panAngle
		 */
		public function get minPanAngle():Number
		{
			return _minPanAngle;
		}
		
		public function set minPanAngle(val:Number):void
		{
			if (_minPanAngle == val)
				return;
			
			_minPanAngle = val;
			
			panAngle = Math.max(_minPanAngle, Math.min(_maxPanAngle, _panAngle));
		}
		
		/**
		 * Maximum bounds for the <code>panAngle</code>. Defaults to Infinity.
		 * 
		 * @see	#panAngle
		 */
		public function get maxPanAngle():Number
		{
			return _maxPanAngle;
		}
		
		public function set maxPanAngle(val:Number):void
		{
			if (_maxPanAngle == val)
				return;
			
			_maxPanAngle = val;
			
			panAngle = Math.max(_minPanAngle, Math.min(_maxPanAngle, _panAngle));
		}
		
		/**
		 * Minimum bounds for the <code>tiltAngle</code>. Defaults to -90.
		 * 
		 * @see	#tiltAngle
		 */
		public function get minTiltAngle():Number
		{
			return _minTiltAngle;
		}
		
		public function set minTiltAngle(val:Number):void
		{
			if (_minTiltAngle == val)
				return;
			
			_minTiltAngle = val;
			
			tiltAngle = Math.max(_minTiltAngle, Math.min(_maxTiltAngle, _tiltAngle));
		}
		
		/**
		 * Maximum bounds for the <code>tiltAngle</code>. Defaults to 90.
		 * 
		 * @see	#tiltAngle
		 */
		public function get maxTiltAngle():Number
		{
			return _maxTiltAngle;
		}
		
		public function set maxTiltAngle(val:Number):void
		{
			if (_maxTiltAngle == val)
				return;
			
			_maxTiltAngle = val;
			
			tiltAngle = Math.max(_minTiltAngle, Math.min(_maxTiltAngle, _tiltAngle));
		}
		
		/**
		 * Fractional difference in distance between the horizontal camera orientation and vertical camera orientation. Defaults to 2.
		 * 
		 * @see	#distance
		 */
		public function get yFactor():Number
		{
			return _yFactor;
		}
		
		public function set yFactor(val:Number):void
		{
			if (_yFactor == val)
				return;
			
			_yFactor = val;
			
			notifyUpdate();
		}
		
		/**
		 * Defines whether the value of the pan angle wraps when over 360 degrees or under 0 degrees. Defaults to false.
		 */
		public function get wrapPanAngle():Boolean
		{
			return _wrapPanAngle;
		}
		
		public function set wrapPanAngle(val:Boolean):void
		{
			if (_wrapPanAngle == val)
				return;
			
			_wrapPanAngle = val;
			
			notifyUpdate();
		}
		
		public function get noFlip():Boolean 
		{
			return _noFlip;
		}
		
		public function set noFlip(value:Boolean):void 
		{
			_noFlip = value;
		}
		
		/**
		 * Creates a new <code>HoverController</code> object.
		 */
		public function HoverControllerJB(targetObject:Entity = null, lookAtObject:ObjectContainer3D = null, panAngle:Number = 0, tiltAngle:Number = 90, distance:Number = 1000, minTiltAngle:Number = -90, maxTiltAngle:Number = 90, minPanAngle:Number = NaN, maxPanAngle:Number = NaN, minDistance:Number = 20, maxDistance:Number = NaN, steps:Number = 8, yFactor:Number = 2, wrapPanAngle:Boolean = false, noFlip:Boolean = false)
		{
			super(targetObject, lookAtObject);
			
			this.distance = distance;
			this.panAngle = panAngle;
			this.tiltAngle = tiltAngle;
			this.minPanAngle = minPanAngle || -Infinity;
			this.maxPanAngle = maxPanAngle || Infinity;
			this.minTiltAngle = minTiltAngle;
			this.maxTiltAngle = maxTiltAngle;
			this.minDistance = minDistance;
			this.maxDistance = maxDistance || Infinity
			this.steps = steps;
			this.yFactor = yFactor;
			this.wrapPanAngle = wrapPanAngle;
			
			//values passed in contrustor are applied immediately
			_currentPanAngle = _panAngle;
			_currentTiltAngle = _tiltAngle;
			_currentDistance = _distance;
		}
		
		/**
		 * Updates the current tilt angle and pan angle values.
		 * 
		 * Values are calculated using the defined <code>tiltAngle</code>, <code>panAngle</code> and <code>steps</code> variables.
		 * 
		 * @see	#tiltAngle
		 * @see	#panAngle
		 * @see	#steps
		 */
		public override function update():void
		{
			if (_tiltAngle != _currentTiltAngle || _panAngle != _currentPanAngle || _distance !=_currentDistance) {
				
				notifyUpdate();
				
				if (wrapPanAngle) {
					if (_panAngle < 0)
						panAngle = (_panAngle % 360) + 360;
					else
						panAngle = _panAngle % 360;
					
					if (panAngle - _currentPanAngle < -180)
						panAngle += 360;
					else if (panAngle - _currentPanAngle > 180)
						panAngle -= 360;
				}
				
				_currentTiltAngle += (_tiltAngle - _currentTiltAngle)/(steps + 1);
				_currentPanAngle += (_panAngle - _currentPanAngle) / (steps + 1);
				_currentDistance += (_distance - _currentDistance) / (steps + 1);
				
				
				//snap coords if angle differences are close
				if ((Math.abs(tiltAngle - _currentTiltAngle) < 0.01) && (Math.abs(_panAngle - _currentPanAngle) < 0.01)) {
					_currentTiltAngle = _tiltAngle;
					_currentPanAngle = _panAngle;
				}
			}
			
			targetObject.x = lookAtObject.x + _currentDistance*Math.sin(_currentPanAngle*MathConsts.DEGREES_TO_RADIANS)*Math.cos(_currentTiltAngle*MathConsts.DEGREES_TO_RADIANS);
			targetObject.z = lookAtObject.z + _currentDistance*Math.cos(_currentPanAngle*MathConsts.DEGREES_TO_RADIANS)*Math.cos(_currentTiltAngle*MathConsts.DEGREES_TO_RADIANS);
			targetObject.y = lookAtObject.y + _currentDistance*Math.sin(_currentTiltAngle*MathConsts.DEGREES_TO_RADIANS)*yFactor;
			
			// stops camera from flipping if noFlip is set
			if (Math.cos(_currentTiltAngle*MathConsts.DEGREES_TO_RADIANS) < 0 && _noFlip) upVector.setTo(0, -1, 0);
			else upVector.setTo(0, 1, 0);
			
			if (targetObject != null || lookAtObject != null)
				targetObject.lookAt(lookAtObject.scene ? lookAtObject.scenePosition : lookAtObject.position, upVector);
			//super.update();
		}
	}
}