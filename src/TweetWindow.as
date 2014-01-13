package 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class TweetWindow extends Sprite
	{
		
		[Embed(source="assets/logo.png")]
		private var logoImg:Class;
		
		[Embed(source="assets/baloon.png")]
		private var balloon:Class;
		
		[Embed(source="assets/close.png")]
		private var close:Class;
		
		private var bgn:Shape;
		private var nba:Bitmap;
		private var textBalloon:Bitmap;
		private var closeBtn:Bitmap;
		private var windowWidth:int;
		private var windowHeight:int;
		private var windowScale:Number;
		private var font:Font;
		private var nameFormat:TextFormat;
		private var msgFormat:TextFormat;
		private var nameField:TextField;
		private var msgField:TextField;
		public var tweetRef:TweetMesh;
		private var tweetName:String;
		private var tweetText:String;
		private var tweetProfile:Bitmap;
		private var tweetImage:Bitmap;
		public var canTap:Boolean;
		private var tapCounter:uint;
		private var deltaX:Number;
		private var deltaY:Number;
		private var forcedTimeout:uint;
		
		private var mysqlDate:String;
		
		private var twitterWin:TwitterWin;
		
		public var tweetWindowW:Number;
		
		public var realWidth:Number;
		
		public function TweetWindow()
		{
			
			twitterWin=new TwitterWin();
			
			addChild(twitterWin);
			
			return;
		}// end function
		
		public function init(param1:String, param2:String, param3:Bitmap, theDate:String, param4:Bitmap = null, param5:Number = 1) : void
		{
//			var dummyData : BitmapData = new BitmapData(300, 300);
//			dummyData.floodFill(0, 0, 0xFFFF0000);
//			dummyData.fillRect(new Rectangle(30, 30, 20, 20), 0xFF00FF00);
//			
//			param4 = new Bitmap(dummyData);
			
			this.tweetName = param1;
			this.tweetText = param2.split('\\').join('');
			this.tweetProfile = param3;
			this.tweetImage = param4;
			this.windowScale = param5;
			this.mysqlDate=theDate;
			
			// in case we don't have extra user photo
			if (this.tweetImage == null)
			{
				twitterWin.twitterPhotoBorder.visible=false;
				twitterWin.twitterPhotoBorder.scaleX=0;
				twitterWin.twitterPhotoBorder.x=0;
				twitterWin.TwitterPhotoContainer.visible=false;
				twitterWin.TwitterPhotoContainer.scaleX=0;
				twitterWin.centerPhotoRef.visible=false;
				twitterWin.centerPhotoRef.x=0;
				twitterWin.centerPhotoRef.scaleX=0;
				twitterWin.twitterPhotoBorder.visible=false;
				twitterWin.twitterPhotoBorder.x=0;
				twitterWin.twitterPhotoBorder.scaleX=0;
				twitterWin.twitterBackground.width=439;
				realWidth=twitterWin.twitterBackground.width;
				twitterWin.redButton.x=409;
			}
			else
			{
				if (this.tweetImage.width >= this.tweetImage.height)
				{
					var percX:Number=twitterWin.centerPhotoRef.width/this.tweetImage.width;
					//trace("horizo"+percX+" ori image width:"+this.tweetImage.width+" dest ref width:"+twitterWin.centerPhotoRef.width);

					this.tweetImage.scaleX*= percX;
					this.tweetImage.scaleY*=percX;
					twitterWin.TwitterPhotoContainer.PhotoHolder.addChild(tweetImage);
					if(twitterWin.TwitterPhotoContainer.PhotoHolder.height<twitterWin.centerPhotoRef.height) {
						twitterWin.TwitterPhotoContainer.PhotoHolder.height=twitterWin.centerPhotoRef.height;
						twitterWin.TwitterPhotoContainer.PhotoHolder.scaleY=twitterWin.TwitterPhotoContainer.PhotoHolder.scaleX;
					}
					//trace("new width:"+this.tweetImage.width+" new height:"+twitterWin.centerPhotoRef.height);

				}
				else if (this.tweetImage.height >= this.tweetImage.width)
				{

					var percY:Number=twitterWin.centerPhotoRef.height/this.tweetImage.height;
					//trace("vert"+percY+" ori image width:"+this.tweetImage.width+" dest ref width:"+twitterWin.centerPhotoRef.width);

					this.tweetImage.scaleY*=percY;
					this.tweetImage.scaleX*=percY;
					//trace("new width:"+this.tweetImage.width+" new height:"+twitterWin.centerPhotoRef.height);

					twitterWin.TwitterPhotoContainer.PhotoHolder.addChild(tweetImage);
					}
				else
				{
					//var _loc_6:* = 400 * this.windowScale;
					//this.tweetImage.height = 400 * this.windowScale;
					//this.tweetImage.width = _loc_6;
				}
				/*var sizeDiff:Number=twitterWin.twitterPhotoBorder.width-this.tweetImage.width;
				twitterWin.TwitterPhotoContainer.PhotoMask.width-=sizeDiff;
				twitterWin.twitterPhotoBorder.width-=sizeDiff;
				twitterWin.twitterBackground.width-=sizeDiff;
				twitterWin.redButton.x-=sizeDiff;
				twitterWin.centerPhotoRef.width-=sizeDiff;*/
				
				twitterWin.TwitterPhotoContainer.PhotoMask.width=this.tweetImage.width;
				twitterWin.twitterPhotoBorder.width=this.tweetImage.width;
				twitterWin.centerPhotoRef.width=0;
				twitterWin.redButton.x=this.tweetImage.width+twitterWin.TwitterPhotoContainer.x+5;
				twitterWin.twitterBackground.width=twitterWin.redButton.x+25;
				realWidth=twitterWin.twitterBackground.width;
			}
			this.drawBox();
			return;
		}// end function
		
		private function drawBox() : void
		{
			//trace("drawbox");
			
			if (this.tweetImage != null)
			{
				//_loc_5 = 20 * this.windowScale;
				//addChild(this.tweetImage);
				//this.tweetImage.smoothing = true;
				//this.tweetImage.x = this.textBalloon.x + this.textBalloon.width + _loc_5;
				//this.tweetImage.y = (_loc_5 + (this.bgn.height - _loc_5)) / 2 - this.tweetImage.height / 2;
			}
			//var _loc_4:* = new close();
			//this.closeBtn = new close() as Bitmap;
			//this.closeBtn.smoothing = true;
			if (this.tweetImage != null)
			{
				//this.closeBtn.x = this.tweetImage.x + this.tweetImage.width;
			}
			else
			{
				//this.closeBtn.x = this.textBalloon.x + this.textBalloon.width - 5;
			}
			//this.closeBtn.y = this.nba.y;
			//addChild(this.closeBtn);
			//_loc_1 = null;
			//_loc_2 = null;
			//_loc_3 = null;
			tweetProfile.smoothing=true;
			tweetProfile.width=twitterWin.profileFrame.width;
			tweetProfile.height=twitterWin.profileFrame.height;
			twitterWin.profilePhoto.addChild(tweetProfile);
			prepareText();
			return;
		}// end function
		public function kill():void {
			if(tweetProfile) {
				tweetProfile.bitmapData.dispose();
				tweetProfile=null;
			}
			if(tweetImage) {
				tweetImage.bitmapData.dispose();
				tweetImage=null;
			}
		}
		private function prepareText() : void
		{

			if(tweetName!=null) {
			twitterWin.theAuthor.htmlText=this.tweetName;
			} else {
				trace("******** tweetname is null");
			}
//			trace("twitter author:"+this.tweetName);

			if (this.tweetText != "" || this.tweetText != null)
			{
				twitterWin.twitterBody.htmlText = this.tweetText;
				
			}
			else
			{
				twitterWin.twitterBody.htmlText = "";
			}
			twitterWin.publishDate.text=this.mysqlDate;
			this.z = 0;
			this.transform.matrix3D = null;
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.checkTap);
			this.forcedTimeout = setTimeout(this.forceClose, 17000);
			//this.cacheAsBitmap=true;
			return;
		}// end function
		
		private function forceClose() : void
		{
			dispatchEvent(new Event("windowTouch"));
			this.canTap = true;
			dispatchEvent(new Event("windowRelease"));
			return;
		}// end function
		
		private function checkTap(event:MouseEvent) : void
		{
			dispatchEvent(new Event("windowTouch"));
			this.deltaX = stage.mouseX - this.x;
			this.deltaY = stage.mouseY - this.y;
			this.canTap = true;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, this.moveDrag);
			stage.addEventListener(MouseEvent.MOUSE_UP, this.stopTap);
			this.tapCounter = setTimeout(this.hideTap, 150);
			return;
		}// end function
		
		private function hideTap() : void
		{
			this.canTap = false;
			return;
		}// end function
		
		private function moveDrag(event:MouseEvent) : void
		{
			if (this && this.deltaX)
			{
				this.x = stage.mouseX - this.deltaX;
				this.y = stage.mouseY - this.deltaY;
			}
			clearTimeout(this.forcedTimeout);
			this.forcedTimeout = setTimeout(this.forceClose, 17000);
			return;
		}// end function
		
		private function stopTap(event:MouseEvent) : void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.moveDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP, this.stopTap);
			if (this.canTap == true)
			{
				this.removeEventListener(MouseEvent.MOUSE_DOWN, this.checkTap);
			}
			dispatchEvent(new Event("windowRelease"));
			return;
		}
		
	}
}
