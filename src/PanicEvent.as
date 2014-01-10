package
{
	import flash.events.Event;
	
	public class PanicEvent extends Event
	{
		
		public static var PANIC_EVENT:String="panic";
		
		public var sourceID:String;
		public function PanicEvent(type:String, tweetID:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this.sourceID=tweetID;
			super(type, bubbles, cancelable);
		}
	}
}