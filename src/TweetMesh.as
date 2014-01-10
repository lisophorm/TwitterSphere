package 
{
	import flash.desktop.Icon;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display3D.textures.CubeTexture;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	import away3d.bounds.NullBounds;
	import away3d.core.base.Geometry;
	import away3d.entities.Mesh;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.BitmapTexture;
	import away3d.utils.Cast;
	
	public class TweetMesh extends Mesh
	{
		
		[Embed(source="assets/photo.png")]
		private var photoImg:Class;
		
		public var planeSize:int;
		public var origX:Number;
		public var origY:Number;
		public var origZ:Number;
		public var destScaleW:Number;
		public var destScaleH:Number;
		public var currentScale:Number;
		private var planeM:TextureMaterial;
		private var profileLoader:Loader;
		private var profileRequest:URLRequest;
		private var pictureLoader:Loader;
		private var pictureRequest:URLRequest;
		private var afterLoad:Boolean;
		public var tweetName:String;
		public var tweetText:String;
		public var tweetProfile:Bitmap;
		public var tweetImage:Bitmap;
		public var tweetImageLink:String;
		public var tweetDate:String;
		private var retryProfile:int = 0;
		private var retryPicture:int = 0;
		
		public var sourceID:String;
		
		private var retryAttempts:Number=1;
		
		public function TweetMesh(geometry:Geometry=null, material:MaterialBase=null):void
		{
			super(geometry, material);
		}
		
		public function init(param1, param2, param3) : void
		{
			if (param1.name == null || param1.name == "")
			{
				this.tweetText = param1.nameNoFont;
			}
			else
			{
				this.tweetName = param1.name;
			}
			if (param1.text == null || param1.text == "")
			{
				this.tweetText = param1.textNoFont;
			}
			else
			{
				this.tweetText = param1.text;
			}
			this.sourceID=param1.sourceId;
//			trace("id of the tweet:"+this.sourceID);
			this.tweetImageLink = param1.picture;
			this.afterLoad = param3;
			this.planeSize = param2.width;
			this.geometry = param2;
			this.material = new ColorMaterial(0, 1);
			this.material.bothSides=true;

			if (this.tweetImageLink)
			{
				this.pictureImageLoader(this.tweetImageLink);
			}
			this.profileImageLoader(param1.profilePicture);
			
			this.tweetDate=param1.mysqldate;
			
			return;
		}// end function
		
		private function profileImageLoader(param1:String) : void
		{
			param1=param1.replace("_normal","_bigger");
			this.profileRequest = new URLRequest(param1);
			this.profileLoader = new Loader();
			this.profileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.gotProfilePicture);
			this.profileLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.profileIOError);
			this.profileLoader.load(this.profileRequest);
			return;
		}// end function
		
		private function gotProfilePicture(event:Event) : void
		{
			this.tweetProfile = this.profileLoader.content as Bitmap;
			var _loc_2:int = 56;
			this.profileLoader.height = 56;
			this.profileLoader.width = _loc_2;
			this.profileLoader.x = 3;
			this.profileLoader.y = 3;
			this.profileLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.gotProfilePicture);
			this.profileLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.profileIOError);
			if (this.afterLoad == true)
			{
				this.blueBorder();
			}
			else
			{
				this.whiteBorder();
			}
			if (this.tweetImageLink == "" || this.tweetImageLink == null)
			{
				dispatchEvent(new Event("profileLoaded"));
			}
			else if (this.tweetImage)
			{
				dispatchEvent(new Event("profileLoaded"));
			}
			this.profileRequest = null;
			return;
		}// end function
		
		private function blueBorder() : void
		{
			var _loc_1:* = new Sprite();
			_loc_1.graphics.beginFill(0x39D7FA);
			_loc_1.graphics.drawRect(0, 0, 64, 64);
			_loc_1.graphics.endFill();
			_loc_1.addChild(this.profileLoader);
			var _loc_2:* = new BitmapData(256, 256, true,0xffffff);
			_loc_2.draw(_loc_1);
			this.planeM = new TextureMaterial(new BitmapTexture(_loc_2), true, false, false);
			this.planeM.bothSides = true;

			this.material = this.planeM;
			_loc_1 = null;
			_loc_2 = null;
			return;
		}// end function
		
		public function whiteBorder() : void
		{
//			trace("whiteborder");
			var gino:Mesh=new Mesh(null,null);
			var _loc_1:* = new Sprite();
			if (this.tweetImageLink==null)
			{
				_loc_1.graphics.beginFill(0xFFFFFF);
			} else {
				// tweet with photo
				_loc_1.graphics.beginFill(0xFFFFFF);
			}
			_loc_1.graphics.drawRect(1,0.7, 85, 69);
			_loc_1.graphics.endFill();
			_loc_1.addChild(this.profileLoader);
			if (this.tweetImageLink!=null)
			{
			var icon:Bitmap= new photoImg() as Bitmap;
			icon.x=icon.y=40;
			_loc_1.addChild(icon);
			}
			var _loc_2:BitmapData = new BitmapData(256, 128, true,0x000000);
			var M:Matrix=new Matrix();
			M.scale(1.37,1.03);
			//M.scale(1,1);
			M.translate(85,64);
			
			_loc_2.draw(_loc_1,M);

		
			this.planeM = new TextureMaterial(new BitmapTexture(_loc_2), true, false, false);
			this.planeM.bothSides = true;
			this.material = this.planeM;
			_loc_1 = null;
			_loc_2 = null;
			return;
		}// end function
		
		private function pictureImageLoader(param1) : void
		{
			this.pictureRequest = new URLRequest(param1);
			this.pictureLoader = new Loader();
			this.pictureLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.gotPicture);
			this.pictureLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.pictureIOError);
			this.pictureLoader.load(this.pictureRequest);
			return;
		}// end function
		
		private function gotPicture(event:Event) : void
		{
			this.tweetImage = this.pictureLoader.content as Bitmap;
			this.pictureLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.gotPicture);
			this.pictureLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.pictureIOError);
			this.pictureLoader = null;
			this.pictureRequest = null;
			if (this.tweetProfile)
			{
				dispatchEvent(new Event("profileLoaded"));
			}
			return;
		}// end function
		
		public function cancelAll() : void
		{
			if (this.profileLoader)
			{
				this.profileLoader.close();
				this.profileLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.gotProfilePicture);
				this.profileLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.profileIOError);
				this.profileLoader = null;
				this.profileRequest = null;
			}
			if (this.pictureLoader)
			{
				this.pictureLoader.close();
				this.pictureLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.gotPicture);
				this.pictureLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.pictureIOError);
				this.pictureLoader = null;
				this.pictureRequest = null;
			}
			return;
		}// end function
		
		public function kill():void {
			trace("kill tweetmesh");
			//cancelAll();
			if(this.tweetImageLink!=null) {
				trace("disposing photo");
				tweetImage.bitmapData.dispose();
				tweetImage=null;
			}
			if (tweetProfile)
			{
				trace("disposing material");
				//this.material=null;
				//this.planeM.texture.dispose();
				//this.planeM.dispose();
				//this.planeM=null;
				tweetProfile.bitmapData.dispose();
				tweetProfile=null;
				
			}
			
			if(this.geometry) {
				//this.geometry.dispose();
			}
		}
		
		private function profileIOError(event:IOErrorEvent) : void
		{
			var _loc_2:BitmapData = null;
			trace("Profile IO Error: " + event.text);
			trace("Retrying...");
			this.profileLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.gotProfilePicture);
			this.profileLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.profileIOError);
			this.profileLoader = null;
			if (retryProfile < retryAttempts)
			{
				setTimeout(this.profileImageLoader, 5000, this.profileRequest.url);
				retryProfile++;
			}
			else
			{
				_loc_2 = new BitmapData(64, 64, false, 0);
				this.tweetProfile = new Bitmap(_loc_2, "auto", true);
				this.planeM = new TextureMaterial(new BitmapTexture(_loc_2), true, false, false);
				this.planeM.bothSides = true;
				this.material = this.planeM;
				dispatchEvent(new Event("profileLoaded"));
			}
			return;
		}// end function
		
		private function pictureIOError(event:IOErrorEvent) : void
		{
			trace("Picture IO Error: " + event.text);
			trace("Retrying...");
			this.pictureLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.gotPicture);
			this.pictureLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, this.pictureIOError);
			this.pictureLoader = null;
			if (this.retryPicture < retryAttempts)
			{
				setTimeout(this.pictureImageLoader, 5000, this.pictureRequest.url);
				this.retryPicture++;
			}
			else if (this.tweetProfile)
			{
				dispatchEvent(new Event("profileLoaded"));
			}
			return;
		}// end function
		
	}
}
