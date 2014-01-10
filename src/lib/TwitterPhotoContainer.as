package  {
	
	import flash.display.MovieClip;
	
	
	public class TwitterPhotoContainer extends MovieClip {
		
		
		public var photoHolder:MovieClip=new PhotoHolder();
		
		public function TwitterPhotoContainer() {
			trace("twitterphotocontainer");
			addChild(photoHolder);
			photoHolder.mask=PhotoMask;
		}
	}
	
}
