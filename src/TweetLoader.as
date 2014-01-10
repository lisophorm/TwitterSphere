package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import PanicEvent;
	
	public class TweetLoader extends Sprite
	{
		private var date:Date;
		private var loader:URLLoader;
		private var cronLoader:URLLoader=new URLLoader();
		private var panicLoader:URLLoader=new URLLoader();
		private var timerCron:Timer;
		private var request:URLRequest;
		private var firstLoad:Boolean = true;
		public var tweets:Object;
		private var waitTime:Timer=new Timer(1000);
		public var isWaitingScreensaver:Boolean=false;
		private var haveDisplayTweet:Boolean=false;
		private var numberOfTweets:Number;
		private var panicList:Object=new Object;
		
		public function TweetLoader(Ntweets:Number)
		{
			
			this.numberOfTweets=Ntweets;
			
			cronLoader.addEventListener(IOErrorEvent.IO_ERROR,cronError);
			panicLoader.addEventListener(IOErrorEvent.IO_ERROR,cronError);
			panicLoader.addEventListener(Event.COMPLETE,this.gotPanic);
			
			
			waitTime.addEventListener(TimerEvent.TIMER,checkScreenSaver);
			waitTime.start();
			
			this.loader = new URLLoader();
			this.loader.addEventListener(Event.COMPLETE, this.gotTweets);
			this.loader.addEventListener(IOErrorEvent.IO_ERROR, this.loadIOError);
			
			timerCron=new Timer(20000);
			timerCron.addEventListener(TimerEvent.TIMER,callCron);
			timerCron.start();
			return;
		}
		
		private function gotPanic(event:Event) : void
		{
			panicList = JSON.parse(event.currentTarget.data);
			var evt:PanicEvent;
			if(panicList != null && panicList.length>0 ) {
				for(var i:Number=0;i<panicList.length;i++) {
					evt=new PanicEvent(PanicEvent.PANIC_EVENT,panicList[i].sourceId);
					dispatchEvent(evt);
				}
			}
			
			
			return;
		}
		
		private function callCron(e:TimerEvent):void {
			cronLoader.load(new URLRequest("http://nba.wassermanexperience.com/sucktweets.php"));
			panicLoader.load(new URLRequest("http://nba.wassermanexperience.com/alert.php?totaltweets="+this.numberOfTweets));
		}
		
		public function Twitter():void
		{
			return;
		}
		
		public function getTweets() : void
		{
			if (this.firstLoad == true)
			{
				this.date = new Date();
				this.request = new URLRequest("http://nba.wassermanexperience.com/tweetfeed.php?client=1&query=initTweets&numberOfPosts="+this.numberOfTweets.toString());
			}
			else if (this.firstLoad == false)
			{
				this.request = new URLRequest("http://nba.wassermanexperience.com/tweetfeed.php?client=1&query=newTweets&int=" + this.date.time);
				this.date = new Date();
			}

			this.loader.load(this.request);
			return;
		}
		
		private function gotTweets(event:Event) : void
		{
			this.tweets = JSON.parse(event.currentTarget.data);
			this.request = null;
			if (this.firstLoad == true)
			{
				this.firstLoad = false;
				dispatchEvent(new Event("tweetsLoaded"));
			}
			else
			{
				if (this.tweets && this.tweets.length != 0)
				{
					haveDisplayTweet=true;
					
				}
				// pulls a new tweer if nothing is on queue
				if(haveDisplayTweet==false) {
					setTimeout(this.getTweets, 3000);
				}
				
			}
			return;
		}
		
		private function cronError(event:IOErrorEvent): void {
			trace("CRON IO error: "+event.text);
		}
		
		private function loadIOError(event:IOErrorEvent) : void
		{
			trace("IO Error: " + event.text);
			trace("Retrying...");
			//this.loader.close();

			//this.loader = null;
			setTimeout(this.getTweets, 3000);
			return;
		}
		private function checkScreenSaver(e:TimerEvent):void {
			if(haveDisplayTweet==true) {
//				trace("must display tweet");
			}
			if(haveDisplayTweet==true && isWaitingScreensaver==false) {
//				trace("discharge tweet");
				haveDisplayTweet=false;
				dispatchEvent(new Event("newTweet"));
				setTimeout(this.getTweets, 3000);
			}
		}
		
	}
}
