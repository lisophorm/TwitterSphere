package com.darcey.utils
{
	import away3d.core.base.SubGeometry;
	import away3d.entities.Mesh;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.events.ProgressEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;

	// ---------------------------------------------------------------------------------------------------------------------------
	public class DTools
	{
		
		// ---------------------------------------------------------------------------------------------------------------------------
		public static function trim(arg:String):String
		{ 
			//return arg ? arg.replace(/^\s+|\s+$/gs, '') : "";
			return arg.replace( /^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "$2" );
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		// ---------------------------------------------------------------------------------------------------------------------------
		public static function getFileExtension(str:String):String
		{
			var extIndex:Number = str.lastIndexOf(".");
			if (extIndex == -1) {
				return "";
			} else {
				return str.substr(extIndex + 1,str.length);
			}
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		
		
		// ---------------------------------------------------------------------------------------------------------------------------
		// 1 Decimal place
		public static function getPercentageFromProgressEvent(e:ProgressEvent):Number
		{
			var p:Number = 0;
			
			p = (100/e.bytesTotal * e.bytesLoaded) * 100;
			p = Math.round(p) / 100;
			
			return p;
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		
		
		
		// ---------------------------------------------------------------------------------------------------------------------------
		public static function mergeBitmapData(bitmapData1:BitmapData,bitmapData2:BitmapData,alpha1:Number=255,alpha2:Number=255):BitmapData
		{			
			var result:BitmapData = new BitmapData(bitmapData1.width, bitmapData1.height, true, 0);
			//result.draw(bitmapData1);
			result.merge(bitmapData1,bitmapData1.rect,new Point(0, 0),128,128,128,alpha1);
			result.merge(bitmapData2,bitmapData1.rect,new Point(0, 0),128,128,128,alpha2);
			
			return result;
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		
		
		// ---------------------------------------------------------------------------------------------------------------------------
		// Simply takes a degree value and ensures it's max is 360 if 361 or 721 it converts to 1 degree
		public static function convertDegreeTo360Limit(degrees:Number):Number
		{			
			var rotations:Number = Math.floor(Math.abs(degrees)/360);
			return Math.round(Math.abs(degrees) - (rotations * 360));
		}
		// ---------------------------------------------------------------------------------------------------------------------------
		
		
		
		
		
		// ----------------------------------------------------------------------------------------------------
		private static function createDebugTextField(width:Number,height:Number,border:Boolean=true,background:Boolean=true,label:String="textfield"):TextField
		{
			var txt:TextField = new TextField();
			txt.width = width;
			txt.height = height;
			txt.border = border;
			txt.background = background;
			txt.text = label;
			return txt;
		}
		// ----------------------------------------------------------------------------------------------------

		
		
		
		// -------------------------------------------------------------------------------------------
		public static function rotateBitmap(degrees:Number,bmp:Bitmap):BitmapData
		{
			var bmpData:BitmapData;
			
			
			var matrix:Matrix = new Matrix();
			matrix.translate(-bmpData.width/2, -bmpData.height/2);
			matrix.rotate(toRad(degrees));
			matrix.translate(bmpData.width/2, bmpData.height/2);
			bmpData = new BitmapData(bmpData.width,bmpData.height,true,0);
			bmpData.draw(bmp, matrix);
			
			return bmpData;
		}
		// -------------------------------------------------------------------------------------------
		
		
		
		
		// -------------------------------------------------------------------------------------------
		public static function toRad(n:Number):Number
		{
			return (n * 0.0174532925);
		}
		// -------------------------------------------------------------------------------------------
		
		
		
		
		// -------------------------------------------------------------------------------------------
		public static function findItemInArray(itemToFind:*,arrayToSearch:Array,exclusionList:Array=null):Number
		{
			var index:Number = -1;
			
			//trace("");
			//trace("----------");
			for (var i:uint = 0; i <= arrayToSearch.length-1; i++)
			{
				//trace("Checking arrayToSearch["+i+"] = [" + arrayToSearch[i] + "] typeof:" + typeof(arrayToSearch[i]) + "   to see if it matches [" + itemToFind + "] typeof: " + typeof(itemToFind) );
				if (arrayToSearch[i] == itemToFind)
				{
					//trace("MATCH FOUND");
					
					if (exclusionList){
						// Check if arrayToSearch[i] is in the exclusionList
						var exclusionFound:Boolean = false;
						for (var v:uint = 0; v <= exclusionList.length-1; v++)
						{
							//trace("\t" + "Checking to see if the found item in arrayToSearch["+i+"] = " + arrayToSearch[i] + "  is not in the exclusion list exclusionList["+v+"] = " + exclusionList[v]);
							if (exclusionList[v] == arrayToSearch[i])
							{
								// Exclusion found
								exclusionFound = true;
								//trace("\t" + "Item is in the exclusion list keep on checking");
								break;
							}
						}
						if (!exclusionFound)
						{
							index = i;
							//trace("Item is not in exclusion list we can return the index and break the loop checking: index = [" + index + "]");
							break;
						}
					} else {
						//trace("No exclusion list specified can return the index it has been found on: index = [" + index + "]");
						index = i;
						break;
					}
				}
			}
			//trace("----------");
			//trace("");
			return index;
		}
		// -------------------------------------------------------------------------------------------
		
		
		// -------------------------------------------------------------------------------------------
		public static function getBooleanFromNumber(n:Number):Boolean
		{
			if (n>1 || n<0){
				trace("");
				trace("DTools ## WARNING ## get Boolean from number() has been supplied a number greater than 1 or less than 0, returning true");
				trace("");
				return true;
			}
			
			if (n == 0)
			{
				return false;
			} else {
				return true;
			}
		}
		// -------------------------------------------------------------------------------------------
		
		
		// -------------------------------------------------------------------------------------------
		public static function getBooleanFromString(str:String):Boolean
		{
			str = str.toLowerCase();
			
			if (str != "false" && str != "true" && str != "0" && str != "1"){
				trace("");
				trace("DTools ## WARNING ## get Boolean from string() has not been supplied a usable input [" + str + "]");
				trace("DTools ## WARNING ## Input required is either 0,1,true or false. Returning true as default.");
				trace("");
				return true;
			}
			
			if (str == "false" || str == "0")
			{
				return false;
			} else {
				return true;
			}
		}
		// -------------------------------------------------------------------------------------------
		
		
		
		
		
		/*
		incrementUV(plane, new Point(0.01, 0.01));
		scaleUV(plane, new Point(0.99, 0.99));
		*/
		
		// -------------------------------------------------------------------------------------------
		public static function incrementUV(m:Mesh, pos:Point):void
		{
			var v:Vector.<Number> = SubGeometry(m.geometry.subGeometries[0]).UVData;
			for (var i:int = 0; i < v.length; i=i+2)
			{
				v[i] += pos.x;
				v[i + 1] += pos.y;
				SubGeometry(m.geometry.subGeometries[0]).updateUVData(v);
			}
		}
		// -------------------------------------------------------------------------------------------
		
		
		// -------------------------------------------------------------------------------------------
		public static function scaleUV(m:Mesh, pos:Point):void
		{
			var v:Vector.<Number> = SubGeometry(m.geometry.subGeometries[0]).UVData;
			for (var i:int = 0; i < v.length; i=i+2)
			{
				v[i] += ( pos.x - 1) * 0.5;
				v[i + 1] += (pos.y - 1) * 0.5;
				
				v[i] /= pos.x
				v[i + 1] /= pos.y;
				
				SubGeometry(m.geometry.subGeometries[0]).updateUVData(v);
			}
		}
		// -------------------------------------------------------------------------------------------
		
		
		
		// -------------------------------------------------------------------------------------------
		public static function rotateUV(m:Mesh, rotationDeg:Number, rotateAbout:Point):void
		{
			var v:Vector.<Number> = SubGeometry(m.geometry.subGeometries[0]).UVData;
			var r:Number= rotationDeg*(Math.PI/180);
			
			
			for (var i:int = 0; i < v.length; i=i+2)
			{
				v[i] -= rotateAbout.x;
				v[i + 1] -= rotateAbout.y;
				v[i] = v[i] * Math.cos(r) + v[i + 1] * -Math.sin(r);
				v[i + 1] = v[i] * Math.sin(r) +v[i + 1] * Math.cos(r);
				v[i] += rotateAbout.x;
				v[i + 1] += rotateAbout.y;
			}
			SubGeometry(m.geometry.subGeometries[0]).updateUVData(v);
		}
		// -------------------------------------------------------------------------------------------
		
		
		
		
	}
	// ---------------------------------------------------------------------------------------------------------------------------
}