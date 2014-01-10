package
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Quart;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.profiler.profile;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import away3d.bounds.NullBounds;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.events.MouseEvent3D;
	import away3d.lights.PointLight;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.Max3DSParser;
	import away3d.loaders.parsers.Parsers;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.primitives.SkyBox;
	import away3d.primitives.SphereGeometry;
	import away3d.primitives.TorusGeometry;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	
	[SWF(backgroundColor="#000000", frameRate="60", quality="BEST")]
	
	public class TwitterSphere extends Sprite
	{
		// Environment map.
		[Embed(source="assets/stars.jpg")]
		private var EnvPosX:Class;
		[Embed(source="assets/stars.jpg")]
		private var EnvPosY:Class;
		[Embed(source="assets/stars.jpg")]
		private var EnvPosZ:Class;
		[Embed(source="assets/stars.jpg")]
		private var EnvNegX:Class;
		[Embed(source="assets/stars.jpg")]
		private var EnvNegY:Class;
		[Embed(source="assets/stars.jpg")]
		private var EnvNegZ:Class;
		[Embed(source="assets/baseball.jpg")]
		private var basketTexture:Class;
		
		// Away3D4 Vars
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		private var cameraController:HoverController;
		
		// Away3D4 Camera handling variables (Hover Camera)
		private var move:Boolean = false;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		
		// Away3D Config
		private var cameraViewDistance:Number = 100000;
		private var antiAlias:Number = 4;
		
		// Lights
		private var lightPicker:StaticLightPicker;
		private var light2Picker:StaticLightPicker;
		private var light:PointLight;
		private var light2:PointLight;
		
		// Materials        
		private var skyBoxCubeMap:BitmapCubeTexture;
		private var sphereTexture:TextureMaterial;
		
		// Primitives etc
		private var skyBox:SkyBox;
		private var sphereGeometry:SphereGeometry;
		private var centralSphere:Mesh;
		
		//private var planeGeom:PlaneGeometry;
		private var planeGeom:CustomCubeGeometry;
		
		
		// Working variables
		private var pointLightParamaters:Object; // Needs to be an object to patch into slider ui
		
		private var loader:loadIndicator;
		
		private var twitter:TweetLoader;
		private var tweetCount:int = 0;
		private var meshes:Vector.<TweetMesh>;
		private var geometries:Vector.<CustomCubeGeometry>
		private var recentMeshes:Vector.<TweetMesh>;
		private var windows:Vector.<TweetWindow>;
		private var order:Vector.<uint>;
		
		private var degrees:Number;
		
		private var currentRow:int = 12;
		private var mode:int = 3;
		private var spinDelay:uint;
		private var spinDirection:Number = 0.25;
		private var screensaverDelay:uint;
		private var screensaverWait:uint;
		private var screensaverOn:Boolean;
		private var lastX:Number;
		private var lastY:Number;
		
		private var loader3D:Loader3D;
		
		// for debugging
		
		private var loadStatus:TextField;
		private var format:TextFormat;
		private var updateText:String;
		
		
		// constants
		private var sphereRadius:int = 400;
		private var scaling:Number = 0.5;
		private var scaleMin:Number=1;
		private var scaleMax:Number=4;
		private var screenSaverScale:Number = 1.3;
		private var blockTween:Boolean=false;
		
		private var maxTweets:Number=20;
		
		/**
		 * Constructor
		 */
		public function TwitterSphere()
		{
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true);
			
		}
		private function addedToStageHandler(e:Event):void
		{
			
			// We have been added to the stage and now need to clean up that event listener
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// Init
			init();
		}
		private function init():void
		{
			
			// Lets get busy
			setupAway3D4();
			setupLights();
			setupMaterials();
			
			setupPrimitivesAndModels();
			setupEventListeners();
			
		}
		private function setupEventListeners():void
		{
			
			// Setup event listeners
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			
			// Setup resize handler
			stage.addEventListener(Event.RESIZE, resizeHandler);
			resizeHandler(); // Good to run the resizeHandler to ensure everything is in its place
			
			// Setup render enter frame event listener
			stage.addEventListener(Event.ENTER_FRAME,renderHandler);
			
			Multitouch.inputMode = MultitouchInputMode.GESTURE;
			this.view.addEventListener(TransformGestureEvent.GESTURE_ZOOM, this.zoomCamera);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDown);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, this.keyDown);
			this.screensaverWait = setTimeout(this.screensaverOpen, 30000);
		}
		private function renderHandler(e:Event):void
		{
			if(meshes.length>=maxTweets) {
				blockTween=true;
			}
			if (this.cameraController.steps > 4)
			{
				(this.cameraController.steps - 1);
			}
			if (this.mode == 1)
			{
				cameraController.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
				cameraController.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;			}
			else if (this.mode == 3)
			{
				this.cameraController.panAngle = this.cameraController.panAngle + this.spinDirection;
			}
			//this.light.moveTo(this.camera.x, this.camera.y, this.camera.z);
			light2.moveTo(this.camera.x, this.camera.y, this.camera.z);
			this.view.render();
			return;
			
		}
		private function animate():void
		{
			
		}
		
		// 
		private function setupLights():void
		{
			this.light = new PointLight();
			this.light.specular = 0.005;
			this.light2 = new PointLight();
			this.light2.specular = 0.1;
			this.light2.diffuse=1;
			this.light2.ambient=0.3;
			light2.radius=3000;
			
			this.lightPicker = new StaticLightPicker([this.light]);
			this.light2Picker = new StaticLightPicker([this.light2]);
			this.scene.addChild(this.light2);
			
		}
		private function screensaverOpen() : void
		{
			trace("screensaverOPEN"+this.screensaverOn);
			if (this.screensaverOn == false)
			{
				this.screensaverOn = true;
			}
			var count:Number = 0;
			var newScale:Number;
			while (count < this.meshes.length)
			{
				newScale=this.meshes[count].scaleX*screenSaverScale;
				if (count == (this.meshes.length - 1) && this.screensaverOn == true)
				{
					this.meshes[count].currentScale=this.meshes[count].scaleX;
					TweenMax.to(this.meshes[count], 1.5, {overwrite:3,ease:Bounce.easeOut,delay:(count*0.01),x:this.meshes[count].x * screenSaverScale, y:this.meshes[count].y * screenSaverScale, z:this.meshes[count].z * screenSaverScale, onComplete:this.nextPhase, onCompleteParams:["close"]});
				}
				else
				{ 
					this.meshes[count].currentScale=this.meshes[count].scaleX;
					TweenMax.to(this.meshes[count], 1.5, {overwrite:3,ease:Bounce.easeOut,delay:(count*0.01), x:this.meshes[count].x * screenSaverScale, y:this.meshes[count].y * screenSaverScale, z:this.meshes[count].z * screenSaverScale});
				}
				count++;
			}
			return;
		}// end function
		
		private function screensaverClose() : void
		{
			setTimeout(this.screensaverCloseDo, 10000);
			return;
		}// end function
		
		private function screensaverCloseDo() : void
		{
			trace("SCRWEENSAVERCLOSE");
			var _loc_1:Number = this.meshes.length-1;
			var delayCount:Number=0;
			while (_loc_1 >= 0)
			{
				
				if (_loc_1 == 1 && this.screensaverOn == true)
				{
					
					TweenMax.to(this.meshes[_loc_1], 1.5, {overwrite:3,delay:(delayCount*0.01), x:this.meshes[_loc_1].origX, y:this.meshes[_loc_1].origY, z:this.meshes[_loc_1].origZ, onComplete:this.nextPhase, onCompleteParams:["open"]});
				}
				else
				{
					TweenMax.to(this.meshes[_loc_1], 1.5, {overwrite:3,delay:(delayCount*0.01),x:this.meshes[_loc_1].origX, y:this.meshes[_loc_1].origY, z:this.meshes[_loc_1].origZ});
				}
				delayCount++;
				_loc_1--;
			}
			return;
		}// end function
		
		private function nextPhase(param1) : void
		{
			if (param1 == "open")
			{
				this.screensaverDelay = setTimeout(this.screensaverOpen, 1000);
			}
			else if (param1 == "close")
			{
				this.screensaverDelay = setTimeout(this.screensaverClose, 1000);
			}
			return;
		}
		private function setupAway3D4():void
		{
			// Setup scene
			scene = new Scene3D();
			
			
			// Setup camera
			camera = new Camera3D();
			camera.lens.far = cameraViewDistance;
			
			// Setup view
			view = new View3D();
			view.scene = scene;
			view.camera = camera;
			view.antiAlias = antiAlias;
			addChild(view);
			
			// Setup a HoverController (aka HoverCamera3D in older versions of Away3D)
			cameraController = new HoverController(camera);
			cameraController.distance = 800;
			cameraController.minTiltAngle = -170
			cameraController.maxTiltAngle = 170;
			cameraController.panAngle = 45;
			cameraController.tiltAngle = 20;
			
			loader = new loadIndicator();
			addChild(this.loader);
			loader.init();
			loader.x = stage.stageWidth / 2;
			loader.y = stage.stageHeight / 2;
			
			// tweetloaded function
			this.twitter = new TweetLoader();
			this.meshes = new Vector.<TweetMesh>;
			this.geometries = new Vector.<CustomCubeGeometry>;
			this.recentMeshes = new Vector.<TweetMesh>;
			this.windows = new Vector.<TweetWindow>(8, true);
			this.order = new Vector.<uint>;
			this.twitter.getTweets();
			this.twitter.addEventListener("tweetsLoaded", this.initTweetDisplay);
			
		}
		private function initTweetDisplay(e:Event):void {
			
			loader.newMessage("Setting Up Tweets...");
			onRowLoader();
		}
		
		
		
		private function onRowLoader() : void
		{
			// this.twitter.tweets.length
			if (this.tweetCount == this.twitter.tweets.length || this.tweetCount>=maxTweets)
			{
				trace("Alle tweets");
				this.setupBall();
				return;
			}
			loader.loadStatus.text=("Loading "+tweetCount.toString()+" of:"+String(twitter.tweets.length))
			
			
			
			
			var tweetMeshInstance:TweetMesh = new TweetMesh();
			
			var planeGeomInstance:CustomCubeGeometry = new CustomCubeGeometry(14, 14, 3);
			
			tweetMeshInstance.init(this.twitter.tweets[this.tweetCount], planeGeomInstance, false);
			
			
			tweetMeshInstance.addEventListener("profileLoaded", this.showMesh);
			
			tweetMeshInstance.moveTo(1,1,1);
			
			tweetCount+=1;
			this.meshes.push(tweetMeshInstance);
			this.geometries.push(planeGeomInstance);
			this.scene.addChild(tweetMeshInstance);
			tweetMeshInstance = null;
			
			return;
		}
		
		private function moveTweets():void {
			//if(!blockTween) {
			
			var newScale:Number=Scale(meshes.length,50,500,6,2);
			trace("new scale:"+newScale);
			
			
			var l:Number=this.meshes.length;
			var tweetMeshInstance:TweetMesh;
			var destx:Number;
			var desty:Number;
			var destz:Number;
			for (var i:Number=0;i<this.meshes.length;i++){
				
				tweetMeshInstance=meshes[i];
				
				var phi:Number = Math.acos( -1 + ( 2 * i ) / l );
				var theta:Number = Math.sqrt( l * Math.PI ) * phi;
				
				tweetMeshInstance.origX = (sphereRadius+5) * Math.cos( theta ) * Math.sin( phi );
				tweetMeshInstance.origY= (sphereRadius+5) * Math.sin( theta ) * Math.sin( phi );
				tweetMeshInstance.origZ = (sphereRadius+5) * Math.cos( phi );
				
				destx=sphereRadius * Math.cos( theta ) * Math.sin( phi );
				desty=sphereRadius * Math.sin( theta ) * Math.sin( phi );
				destz=sphereRadius * Math.cos( phi );
				
				tweetMeshInstance.lookAt(new Vector3D());
				
				
				TweenMax.to(tweetMeshInstance, 1, {scaleX:newScale,scaleY:newScale,overwrite:3,x:destx,y:desty,z:destz,onUpdate:onLookAtTween, onUpdateParams:[tweetMeshInstance]});
				
			}
			
		}
		private function onLookAtTween(theMesh:TweetMesh):void {
			theMesh.lookAt(new Vector3D());
		}
		private function showMesh(event:Event) : void
		{
			
			var _loc_2:TweetMesh = event.currentTarget as TweetMesh;
			_loc_2.visible = true;
			_loc_2.removeEventListener("profileLoaded", this.showMesh);
			_loc_2.mouseEnabled = true;
			_loc_2.addEventListener(MouseEvent3D.CLICK, this.tweetClick);
			_loc_2.material.lightPicker = this.light2Picker;
			_loc_2 = null;
			
			
			
			this.onRowLoader();
			
			return;
		}
		private function tweetClick(param1:MouseEvent3D = null, param2:TweetMesh = null) : void
		{
			
			var currentMesh:TweetMesh = null;
			var _loc_6:* = NaN;
			var _loc_9:* = 0;
			var _loc_10:* = null;
			if (param1 != null)
			{
				trace("param 1 exists");
				currentMesh = param1.currentTarget as TweetMesh;
				TweenMax.to(currentMesh, 0.3, {x:currentMesh.x * 1.15, y:currentMesh.y * 1.15, z:currentMesh.z * 1.15, onComplete:this.onFinishClickTween, onCompleteParams:[currentMesh]});
			}
			else if (param2 != null)
			{
				trace("param 2 exists");
				currentMesh = param2;
			}
			trace("clicked tweet");
			trace("tweet click!"+currentMesh.position.toString());
			trace("tweet click text"+currentMesh.tweetText);
			var _loc_4:* = new Object();
			var _loc_5:Vector3D = this.getStagePosition(this.camera, currentMesh);
			
			if (currentMesh.tweetImage != null)
			{
				_loc_6 = 0.4;
			}
			else
			{
				_loc_6 = 0.5;
			}
			var tweetWinInstance:TweetWindow = new TweetWindow();
			tweetWinInstance.init(currentMesh.tweetName, currentMesh.tweetText, currentMesh.tweetProfile, currentMesh.tweetDate, currentMesh.tweetImage, _loc_6);
			tweetWinInstance.tweetRef = currentMesh;
			tweetWinInstance.addEventListener("windowTouch", this.touchWindow);
			addChild(tweetWinInstance);
			_loc_4.width = tweetWinInstance.width;
			_loc_4.height = tweetWinInstance.height;
			var _loc_8:* = new Array();
			var _loc_11:* = 0;
			while (_loc_11 < this.windows.length)
			{
				
				if (this.windows[_loc_11] == null)
				{
					_loc_8.push(_loc_11);
				}
				_loc_11 = _loc_11 + 1;
			}
			if (_loc_8.length == 0 || param2 != null && _loc_8.length <= 3)
			{
				this.closeWindow(null, this.windows[this.order[0]]);
				this.windows[this.order[0]] = tweetWinInstance;
				_loc_10 = this.calculatePositions(this.order[0]);
				this.order.push(this.order.shift());
			}
			else
			{
				_loc_9 = this.randomNumber((_loc_8.length - 1));
				this.windows[_loc_8[_loc_9]] = tweetWinInstance;
				_loc_10 = this.calculatePositions(_loc_8[_loc_9]);
				this.order.push(_loc_8[_loc_9]);
			}
			tweetWinInstance.alpha = 0.2;
			var _loc_12:* = currentMesh.planeSize;
			tweetWinInstance.height = currentMesh.planeSize;
			tweetWinInstance.width = _loc_12;
			tweetWinInstance.x = _loc_5.x;
			tweetWinInstance.y = _loc_5.y;
			tweetWinInstance.z = _loc_5.z;
			if(!TweenMax.isTweening(tweetWinInstance)) {
				TweenMax.to(tweetWinInstance, 0.8, {alpha:1, x:_loc_10.x, y:_loc_10.y, z:0, rotationX:0, rotationY:0, rotationZ:0, width:_loc_4.width, height:_loc_4.height});
			}
			currentMesh = null;
			_loc_4 = null;
			_loc_5 = null;
			tweetWinInstance = null;
			_loc_10 = null;
			_loc_8 = null;
			return;
		}
		private function touchWindow(event:Event) : void
		{
			event.currentTarget.addEventListener("windowRelease", this.releaseWindow);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, this.mouseDown);
			return;
		}
		private function releaseWindow(event:Event) : void
		{
			if (event.currentTarget.canTap == true)
			{
				this.closeWindow(event);
			}
			stage.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDown);
			event.currentTarget.removeEventListener("windowRelease", this.releaseWindow);
			return;
		}
		
		private function mouseDown(event:MouseEvent) : void
		{
			var _loc_2:* = undefined;
			clearTimeout(this.spinDelay);
			clearTimeout(this.screensaverDelay);
			clearTimeout(this.screensaverWait);
			this.spinDelay = 0;
			this.screensaverDelay = 0;
			this.screensaverWait = 0;
			if (this.screensaverOn == true)
			{
				this.screensaverOn = false;
				this.screensaverClose();
				_loc_2 = 0;
				while (_loc_2 < this.windows.length)
				{
					
					if (this.windows[_loc_2] != null)
					{
						this.closeWindow(null, this.windows[_loc_2], "on");
					}
					_loc_2 = _loc_2 + 1;
				}
			}
			stage.addEventListener(MouseEvent.MOUSE_UP, this.mouseUp);
			this.lastPanAngle = this.cameraController.panAngle;
			this.lastTiltAngle = this.cameraController.tiltAngle;
			this.lastX = stage.mouseX;
			this.lastY = stage.mouseY;
			this.mode = 1; 
			return;
		}
		
		private function mouseUp(event:MouseEvent) : void
		{
			this.mode = 2;
			this.spinDelay = setTimeout(this.resumeSpinning, 3000);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.mouseUp);
			if (this.cameraController.panAngle < this.lastPanAngle)
			{
				this.spinDirection = -0.25;
			}
			else if (this.cameraController.panAngle > this.lastPanAngle)
			{
				this.spinDirection = 0.25;
			}
			this.screensaverWait = setTimeout(this.screensaverOpen, 16000);
			return;
		}
		private function resumeSpinning() : void
		{
			clearTimeout(this.spinDelay);
			this.spinDelay = 0;
			if (this.cameraController.tiltAngle < 0 || this.cameraController.tiltAngle > 20)
			{
				this.cameraController.tiltAngle = 10;
				this.cameraController.steps = 30;
			}
			this.mode = 3;
			return;
		}
		private function onFinishClickTween(param1:TweetMesh) : void
		{
			TweenMax.to(param1, 0.4, {x:param1.x / 1.15, y:param1.y / 1.15, z:param1.z / 1.15});
			return;
		}
		private function closeWindow(event:Event = null, param2:TweetWindow = null, param3:String = "off") : void
		{
			var _loc_4:* = undefined;
			var _loc_6:* = undefined;
			var _loc_7:* = undefined;
			if (event != null)
			{
				_loc_4 = event.currentTarget;
				_loc_6 = 0;
				while (_loc_6 < this.windows.length)
				{
					
					if (_loc_4 == this.windows[_loc_6])
					{
						this.windows[_loc_6] = null;
						this.order.splice(this.order.indexOf(_loc_6), 1);
					}
					_loc_6 = _loc_6 + 1;
				}
			}
			else if (param2 != null)
			{
				_loc_4 = param2;
				if (param3 == "on")
				{
					_loc_7 = 0;
					while (_loc_7 < this.windows.length)
					{
						
						if (_loc_4 == this.windows[_loc_7])
						{
							this.windows[_loc_7] = null;
							this.order.splice(this.order.indexOf(_loc_7), 1);
						}
						_loc_7 = _loc_7 + 1;
					}
				}
			}
			var _loc_5:* = this.getStagePosition(this.camera, _loc_4.tweetRef);
			TweenMax.to(_loc_4, 0.4, {alpha:0.2, x:_loc_5.x, y:_loc_5.y, z:_loc_5.z, width:_loc_4.tweetRef.planeSize, height:_loc_4.tweetRef.planeSize, onComplete:this.destroyWindow, onCompleteParams:[_loc_4]});
			_loc_4.removeEventListener("windowTouch", this.touchWindow);
			_loc_4 = null;
			_loc_5 = null;
			return;
		}// end function
		
		private function destroyWindow(param1:TweetWindow) : void
		{
			if (this.contains(param1))
			{
				//param1.kill();
				while (param1.numChildren) {
					trace("killing:"+param1.getChildAt(0).name);
					param1.removeChildAt(0);
				}
				removeChild(param1);
			}
			return;
		}
		
		private function getStagePosition(cam:Camera3D, obj:ObjectContainer3D) : Vector3D
		{
			
			var camT:Matrix3D = cam.viewProjection.clone(); 
			var planT:Matrix3D = obj.sceneTransform.clone(); 
			
			camT.prepend(planT);
			var pv:Vector3D = Utils3D.projectVector(camT, new Vector3D()); 
			pv.x = (pv.x * stage.stageWidth / 2) + stage.stageWidth / 2 
			pv.y  = (pv.y*-1 * stage.stageHeight / 2) + stage.stageHeight / 2 
			return pv; 
		}
		
		private function displayNewTweet(event:Event) : void
		{
			trace("meshes length:"+this.meshes.length+" max tweets:"+maxTweets);
			var planeGeomInstance:CustomCubeGeometry = new CustomCubeGeometry(14, 14, 3);
			if(this.meshes.length>=maxTweets) {
				trace("replace mesh");
				var _loc_2:TweetMesh = this.meshes.shift();
				var tempGeom:CubeGeometry=this.geometries.shift();
				var _loc_3:TweetMesh = new TweetMesh();
				_loc_3.init(this.twitter.tweets[0], planeGeomInstance, false);
				_loc_3.x = _loc_2.x;
				_loc_3.y = _loc_2.y;
				_loc_3.z = _loc_2.z;
				_loc_3.origX = _loc_2.origX;
				_loc_3.origY = _loc_2.origY;
				_loc_3.origZ = _loc_2.origZ;
				_loc_3.lookAt(new Vector3D(0, 0, 0));
				_loc_3.addEventListener("profileLoaded", this.showTweet);
				this.meshes.push(_loc_3);
				TweenMax.to(_loc_2, 1, {scaleX:0,scaleY:0,scaleZ:0, onComplete:killTweetMesh, onCompleteParams:[_loc_2,tempGeom]});
				
				
				
			} else {
				trace("push mesh");
				var newMesh:TweetMesh = new TweetMesh();
				newMesh.init(this.twitter.tweets[0], planeGeomInstance, false);
				newMesh.moveTo(1,1,1);
				newMesh.lookAt(new Vector3D(0, 0, 0));
				newMesh.addEventListener("profileLoaded", this.showTweet);
				this.meshes.push(newMesh);
				
			}
			this.geometries.push(planeGeomInstance);
			planeGeomInstance=null;
			return;
		}
		private function killTweetMesh(theMesh:TweetMesh,tempGeom:CustomCubeGeometry):void {
			view.scene.removeChild(theMesh);
			theMesh.kill();
			theMesh.material.dispose();
			tempGeom.dispose();
			theMesh.geometry.dispose();
			theMesh=null;
		}
		private function showTweet(event:Event) : void
		{
			trace("show tweet");
			var _loc_2:TweetMesh = event.currentTarget as TweetMesh;
			_loc_2.removeEventListener("profileLoaded", this.showTweet);
			_loc_2.visible = true;
			_loc_2.mouseEnabled = true;
			_loc_2.addEventListener(MouseEvent3D.CLICK, this.tweetClick);
			_loc_2.material.lightPicker = this.light2Picker;
			
			moveTweets();
			this.scene.addChild(_loc_2);
			if (this.screensaverOn == true)
			{
				this.tweetClick(null, _loc_2);
			}
			_loc_2 = null;
			return;
		}
		private function setupBall() : void
		{
			trace("setupball");
			moveTweets();
			setTimeout(this.twitter.getTweets, 15000);
			TweenMax.to(this.loader, 0.3, {alpha:0});
			
			this.twitter.addEventListener("newTweet", this.displayNewTweet);
			//stage.addEventListener(Event.ENTER_FRAME, this.oEF);
			
			return;
		}
		private function zoomCamera(event:TransformGestureEvent) : void
		{
			var _loc_2:* = undefined;
			clearTimeout(this.spinDelay);
			clearTimeout(this.screensaverDelay);
			clearTimeout(this.screensaverWait);
			this.spinDelay = 0;
			this.screensaverDelay = 0;
			this.screensaverWait = 0;
			if (this.screensaverOn == true)
			{
				this.screensaverOn = false;
				this.screensaverClose();
				_loc_2 = 0;
				while (_loc_2 < this.windows.length)
				{
					
					if (this.windows[_loc_2] != null)
					{
						this.closeWindow(null, this.windows[_loc_2]);
					}
					_loc_2 = _loc_2 + 1;
				}
			}
			this.cameraController.distance = this.cameraController.distance / event.scaleX;
			if (this.cameraController.distance >= 1110)
			{
				this.cameraController.distance = 1110;
			}
			else if (this.cameraController.distance <= 570)
			{
				this.cameraController.distance = 570;
			}
			return;
		}// end function
		private function keyDown(event:KeyboardEvent) : void
		{
			if (event.keyCode == 38)
			{
				this.cameraController.distance = this.cameraController.distance + 5;
			}
			else if (event.keyCode == 40)
			{
				this.cameraController.distance = this.cameraController.distance - 5;
			}
			return;
		}
		
		private function setupMaterials():void
		{
			
			// Setup a cube map for the skybox to use
			skyBoxCubeMap = new BitmapCubeTexture(Cast.bitmapData(EnvPosX), Cast.bitmapData(EnvNegX), Cast.bitmapData(EnvPosY), Cast.bitmapData(EnvNegY), Cast.bitmapData(EnvPosZ), Cast.bitmapData(EnvNegZ));
			sphereTexture= new TextureMaterial(Cast.bitmapTexture(basketTexture), true, false, false);
			sphereTexture.lightPicker=lightPicker;
		}
		private function setupPrimitivesAndModels():void
		{
			
			// Setup the primitive
			skyBox = new SkyBox(skyBoxCubeMap);
			scene.addChild(skyBox);
			Parsers.enableAllBundled();
			
			loader3D=new Loader3D();
			loader3D.addEventListener(LoaderEvent.RESOURCE_COMPLETE,onResourceComplete);
			loader3D.addEventListener(LoaderEvent.LOAD_ERROR,onLoadResourceError);
			loader3D.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			loader3D.load(new URLRequest("assets/3d/coso.awd"));
			//sphereGeometry=new SphereGeometry(sphereRadius, 50, 50);
			//centralSphere=new Mesh(sphereGeometry,sphereTexture);
			//scene.addChild(centralSphere);
		}
		private function onAssetComplete(event :AssetEvent) : void {
			trace("asset complete"+event.asset.assetType);
			//var mesh : Mesh = event.asset as Mesh;
			//trace("mesh name:"+mesh.name);
			if (event.asset.assetType == "mesh") {
				var mesh : Mesh = event.asset as Mesh;
				mesh.material.lightPicker=light2Picker;
				mesh.material.mipmap=false;
				
			}
		}
		private function onResourceComplete(ev : LoaderEvent) : void
		{
			trace("resource load complete");
			loader3D.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			loader3D.removeEventListener(LoaderEvent.LOAD_ERROR, onLoadResourceError);
			var object3d:Mesh=Mesh(loader3D.getChildAt(0));
			object3d.scaleX=0.5;
			object3d.scaleY=0.5;
			object3d.scaleZ=0.5;
			//object3d.y=-100;
			scene.addChild(object3d);
		}
		private function onLoadResourceError(ev : LoaderEvent) : void
		{
			
			trace('Could not find', ev.url+"message:"+ev.message);
			
			loader3D.removeEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			loader3D.removeEventListener(LoaderEvent.LOAD_ERROR, onLoadResourceError);
			loader3D = null;
		}
		private function mouseDownHandler(e:MouseEvent):void
		{
			lastPanAngle = cameraController.panAngle;
			lastTiltAngle = cameraController.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
			move = true;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		// --------------------------------------------------------------------------------------------------------------
		// --------------------------------------------------------------------------------------------------------------
		/*** Mouse up handler */
		private function mouseUpHandler(e:MouseEvent):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		// --------------------------------------------------------------------------------------------------------------
		// --------------------------------------------------------------------------------------------------------------
		/*** Mouse stage leave handler */
		private function onStageMouseLeave(e:Event):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}
		// --------------------------------------------------------------------------------------------------------------
		
		
		
		// --------------------------------------------------------------------------------------------------------------
		/*** Resize handler */
		private function resizeHandler(e:Event=null):void
		{
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
			loader.x = stage.stageWidth / 2;
			loader.y = stage.stageHeight / 2;
		}
		
		
		private function calculatePositions(param1) : Point
		{
			var _loc_2:Point;
			var _loc_3:Number = 25;
			if (param1 == 0)
			{
				_loc_2 = new Point(_loc_3, _loc_3);
			}
			else if (param1 == 1)
			{
				_loc_2 = new Point(_loc_3, stage.stageHeight / 4 + _loc_3);
			}
			else if (param1 == 2)
			{
				_loc_2 = new Point(_loc_3, stage.stageHeight / 4 * 2 + _loc_3);
			}
			else if (param1 == 3)
			{
				_loc_2 = new Point(_loc_3, stage.stageHeight / 4 * 3 + _loc_3);
			}
			else if (param1 == 4)
			{
				_loc_2 = new Point(stage.stageWidth - this.windows[param1].width - _loc_3, _loc_3);
			}
			else if (param1 == 5)
			{
				_loc_2 = new Point(stage.stageWidth - this.windows[param1].width - _loc_3, stage.stageHeight / 4 + _loc_3);
			}
			else if (param1 == 6)
			{
				_loc_2 = new Point(stage.stageWidth - this.windows[param1].width - _loc_3, stage.stageHeight / 4 * 2 + _loc_3);
			}
			else if (param1 == 7)
			{
				_loc_2 = new Point(stage.stageWidth - this.windows[param1].width - _loc_3, stage.stageHeight / 4 * 3 + _loc_3);
			}
			return _loc_2;
		}
		
		private function randomNumber(param1:Number, param2:Number = 0) : Number
		{
			return Math.floor(Math.random() * (param1 - param2 + 1)) + param2;
		}
		
		public function Scale(elementToScale:Number,
							  rangeMin:Number, rangeMax:Number, 
							  scaledRangeMin:Number, scaledRangeMax:Number):Number
		{
			if(elementToScale<rangeMin) {
				elementToScale=rangeMin;
			}
			if(elementToScale>rangeMax) {
				elementToScale=rangeMax;
			}
			var scaled:Number = scaledRangeMin + ((elementToScale - rangeMin) * (scaledRangeMax - scaledRangeMin) / (rangeMax - rangeMin));
			return scaled;
		}
		
	}
}