package
{
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class ThankyouScreen extends Sprite
	{
		[Embed(source="assets/fonts/MyriadPro-Regular.otf", embedAsCFF='false', fontStyle = 'normal', fontName='Myriad', mimeType='application/x-font')]
		private var MyriadPro : Class;
		
		private var thankyouText:TextField;
		private var isInitialised : Boolean = false;
		private var background:Sprite;
		private var youAreFootballText:TextField;
		private var textHolder:Sprite;
		private var content:Sprite;
		private var contentMask:Sprite;
		private var displayTimer:Object;
		private var timer:Timer;
		private var timeInterval:int = 150000;
//		private var timeInterval:int = 10000;
		private var barclaysCyan : uint = 0x00AEEF;
		private var touchScreenText:TextField;
		
		public function ThankyouScreen()
		{
			super();
			
			initialise();
		}
		
		protected function initialise() : void
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			Font.registerFont(MyriadPro);
			
			content = new Sprite();
			addChild(content);
			
			contentMask = new Sprite();
			contentMask.graphics.beginFill(0xFF0000);
			contentMask.graphics.drawRect(0, 0, 100, 100);
			contentMask.graphics.endFill();
			addChild(contentMask);
			content.mask = contentMask;			
			
			background = new Sprite();
			background.graphics.beginFill(0xFFFFFF);
			background.graphics.drawRect(0, 0, 100, 100);
			background.graphics.endFill();
			content.addChild(background);
			
			textHolder = new Sprite();
			textHolder.graphics.beginFill(0xFFFFFF);
			textHolder.graphics.drawRect(0, 0, 400, 180);
			textHolder.graphics.endFill();
			content.addChild(textHolder);
			
			var thankyouFormat : TextFormat = new TextFormat("Myriad", 60, barclaysCyan);
			
			thankyouText = new TextField();
			thankyouText.embedFonts = true;
			thankyouText.defaultTextFormat = thankyouFormat;
			thankyouText.width = 400;
			thankyouText.selectable = false;
			thankyouText.autoSize = TextFieldAutoSize.CENTER;
			thankyouText.text = "Thank you";
			textHolder.addChild(thankyouText);
			
			var youAreFootballFormat : TextFormat = new TextFormat("Myriad", 36, barclaysCyan);
			
			youAreFootballText = new TextField();
			youAreFootballText.embedFonts = true;
			youAreFootballText.defaultTextFormat = youAreFootballFormat;
			youAreFootballText.y = 80;
			youAreFootballText.width = 400;
			youAreFootballText.selectable = false;
			youAreFootballText.autoSize = TextFieldAutoSize.CENTER;
			youAreFootballText.text = "#YouAreFootball";
			textHolder.addChild(youAreFootballText);
			
			var touchScreenFormat : TextFormat = new TextFormat("Myriad", 19, barclaysCyan);
			
			touchScreenText = new TextField();
			touchScreenText.embedFonts = true;
			touchScreenText.defaultTextFormat = touchScreenFormat;
			touchScreenText.y = 140;
			touchScreenText.width = 400;
			touchScreenText.selectable = false;
			touchScreenText.autoSize = TextFieldAutoSize.CENTER;
			touchScreenText.text = "Touch screen to view your tweet";
			textHolder.addChild(touchScreenText);
			
			timer = new Timer(timeInterval);
			timer.addEventListener(TimerEvent.TIMER, show);
			timer.start();
		}
		
		protected function addedToStageHandler(event : Event) : void
		{
			stage.addEventListener(Event.RESIZE, stageResizeHandler);
		}
		
		protected function stageResizeHandler(event : Event) : void
		{
			textHolder.width = stage.stageWidth;
			textHolder.scaleY = textHolder.scaleX;
			var topHeight : int = (stage.stageHeight - textHolder.height) / 2;
			textHolder.y = (stage.stageHeight - textHolder.height) / 2;
			
			background.width = stage.stageWidth;
			background.height = stage.stageHeight;
			
			contentMask.width = stage.stageWidth;
			contentMask.height = stage.stageHeight;
			contentMask.x = -stage.stageWidth;
		}
		
		protected function show(event : TimerEvent):void
		{
			contentMask.x = stage.stageWidth;
			TweenMax.to(contentMask, .3, {x:0});
			TweenMax.delayedCall(5, hide);
		}
		
		protected function hide():void
		{
			TweenMax.to(contentMask, .3, {x:-stage.stageWidth});
		}
		
		public function reset():void
		{
			hide();
			timer.stop();
			timer.start();
		}
	}
}