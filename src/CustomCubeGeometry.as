package
{
	import away3d.primitives.CubeGeometry;
	
	public class CustomCubeGeometry extends CubeGeometry
	{
		
		public var destWidth:Number;
		public var destHeight:Number;
		public var isTweening:Boolean=false;
		public var currentScale:Number=1;
		
		public function CustomCubeGeometry(width:Number=100, height:Number=100, depth:Number=100, segmentsW:uint=1, segmentsH:uint=1, segmentsD:uint=1, tile6:Boolean=true)
		{
			destWidth=width;
			destHeight=height;
			super(width, height, depth, segmentsW, segmentsH, segmentsD, tile6);

		}
	}
}