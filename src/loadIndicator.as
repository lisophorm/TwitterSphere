package 
{
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	

	
	public class loadIndicator extends Sprite
	{
		[Embed(source="assets/fonts/BROADW.TTF", fontStyle = 'normal', fontName='_Arial', mimeType='application/x-font')]
		public static var myFont:Class;
		
		public var gino:Font2=new Font2();
		
		public var loadStatus:TextField;
		private var format:TextFormat;
		private var updateText:String;
		//SUPER SENIOR OBJECT RECURSE - by Steve Smith / SeniorCreative 
		public static function o (oObj:Object, sPrefix:String = ""):void
		{
			
			    sPrefix == "" ? sPrefix = "---" : sPrefix += "---";
			    
			    for (var i:* in oObj)
			    {
				        
				        trace (sPrefix , i + " : " + oObj[i], "  ");
				        
				        if (typeof( oObj[i] ) == "object") o ( oObj[i], sPrefix); // around we go again        
			    }
		}

		
		public function loadIndicator()
		{
			var theFont:Font=new  myFont() as Font;
			//trace(myFont.fontName);
//			trace("fonzo :: " + gino.fontName);
			o(theFont);
			this.format = new TextFormat(gino.fontName, 40, 0xA0A0A0, true);
			return;
		}// end function
		
		public function init() : void
		{
			this.loadStatus = new TextField();
			this.loadStatus.width = 500;
			this.loadStatus.defaultTextFormat = this.format;
			this.loadStatus.selectable = false;
			this.loadStatus.antiAliasType = AntiAliasType.ADVANCED;
			this.loadStatus.text = "Downloading Tweets...";
			addChild(this.loadStatus);
			this.position();
			return;
		}// end function
		
		private function position() : void
		{
			this.loadStatus.autoSize = TextFieldAutoSize.LEFT;
			this.loadStatus.width = this.loadStatus.textWidth + 5;
			this.loadStatus.height = this.loadStatus.textHeight + 5;
			this.loadStatus.x = -this.loadStatus.width / 2;
			this.loadStatus.y = -this.loadStatus.height / 2;
			return;
		}// end function
		
		public function newMessage(param1) : void
		{
			this.updateText = param1;
			TweenLite.to(this.loadStatus, 0.4, {alpha:0, onComplete:this.changeMessage});
			return;
		}// end function
		
		public function changeMessage() : void
		{
			this.loadStatus.text = this.updateText;
			this.position();
			TweenLite.to(this.loadStatus, 0.4, {alpha:1});
			return;
		}// end function
		
	}
}
