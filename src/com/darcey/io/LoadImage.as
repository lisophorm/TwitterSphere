package com.darcey.io
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	
	public class LoadImage extends Loader
	{
		private var urlRequest:URLRequest;
		
		public function LoadImage(url:String)
		{
			this.name = "LoadImage(" + url + ")";
			//var mLoader:Loader = new Loader();
			urlRequest = new URLRequest(url);
			//this.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
			//this.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
			this.load(urlRequest);
		}
		
		private function onCompleteHandler(loadEvent:Event):void
		{
			//addChild(loadEvent.currentTarget.content);
			//trace("onCompleteHandler()");
		}
		
		private function onProgressHandler(mProgress:ProgressEvent):void
		{
			//var percent:Number = mProgress.bytesLoaded/mProgress.bytesTotal;
			//trace(percent);
		}
		
		public function dispose():void
		{
			urlRequest = null;
		}
		
	}
}