package com.darcey.ui
{
	// ------------------------------------------------------------------------------------------------------------------------------
	import com.bit101.components.HSlider;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	// ------------------------------------------------------------------------------------------------------------------------------
	
	
	// ------------------------------------------------------------------------------------------------------------------------------
	public class SliderList extends Sprite
	{
		// ------------------------------------------------------------------------------------------------------------------------------
		private var sliders:Array;
		private var sliderIndex:int = 0;
		private var sliderYStep:Number = 12;
		private var xpos:Number = 5;
		private var ypos:Number = 0;
		// ------------------------------------------------------------------------------------------------------------------------------
		
		
		// ------------------------------------------------------------------------------------------------------------------------------
		public function SliderList()
		{
			sliders = [];
		}
		// ------------------------------------------------------------------------------------------------------------------------------
		
		
		// ------------------------------------------------------------------------------------------------------------------------------
		public function addSliderGap():void
		{
			sliderIndex ++;
		}
		// ------------------------------------------------------------------------------------------------------------------------------
		
		
		// ------------------------------------------------------------------------------------------------------------------------------
		public function addSlider(
			label:String,
			width:int,
			min:Number,max:Number,
			defaultValue:Number,target:Object,paramater:String,defineParamaterBySliderInitValue:Boolean = false):void
		{
			sliderIndex++;
			
			var slider:Object = new Object();
			sliders["Slider " + sliderIndex] = slider;
			
			slider.objToUpdate = target;
			slider.paramToUpdate = paramater;
			
			slider.component = new HSlider();
			HSlider(slider.component).name = "Slider " + sliderIndex;
			HSlider(slider.component).width = width;
			HSlider(slider.component).minimum = min;
			HSlider(slider.component).maximum = max;
			if (defineParamaterBySliderInitValue)
			{
				target[paramater] = defaultValue;
				HSlider(slider.component).value = defaultValue;
			} else {
				if (defaultValue != slider.objToUpdate[slider.paramToUpdate])
				{
					/*
					trace("###########################################################");
					trace("WARNING OBJ PARAMTER NOT SAME VALUE AS DEFAULT SLIDER VALUE");
					trace("OBJ: " + target + " PARAM: " + paramater);
					trace("USING OBJECTS CURRENT VALUE AS DEFAULT VALUE ON SLIDER");
					trace("###########################################################");
					*/
					HSlider(slider.component).value = target[paramater];
				} else {
					HSlider(slider.component).value = defaultValue;
				}
			}
			HSlider(slider.component).x = 0;
			HSlider(slider.component).y = (sliderIndex-1) * sliderYStep;
			addChild(slider.component);
			
			slider.labeltext = label;
			slider.label = addText(slider.labeltext + " " + HSlider(slider.component).value.toFixed(2),10);
			TextField(slider.label).x = (HSlider(slider.component).x + HSlider(slider.component).width) + 10;
			TextField(slider.label).y = -2 + ((sliderIndex-1) * sliderYStep);
			addChild(slider.label);
			
			HSlider(slider.component).addEventListener(Event.CHANGE,sliderUpdate);
		}
		// ------------------------------------------------------------------------------------------------------------------------------
		
		
		
		// ------------------------------------------------------------------------------------------------------------------------------
		private function sliderUpdate(e:Event):void
		{
			var hslider:HSlider = (e.target) as HSlider;
			var slider:Object = sliders[hslider.name];
			updateText(slider.labeltext + " " + slider.component.value.toFixed(2),slider.label,10);
			
			slider.objToUpdate[slider.paramToUpdate] = hslider.value;
			
			/*
			switch (slider.paramToUpdate)
			{
				case "x": slider.objToUpdate.x = hslider.value; break;
				case "y": slider.objToUpdate.y = hslider.value; break;
				case "z": slider.objToUpdate.z = hslider.value; break;
			}
			*/

		}
		// ------------------------------------------------------------------------------------------------------------------------------
		
		
		

		
		
		
		
		
		// ------------------------------------------------------------------------------------------------------------------------------
		private function addText(label:String = "message",size:int=10):TextField
		{
			var tf:TextFormat = new TextFormat();
			tf.color = 0xFFFFFF;
			tf.size = size;
			tf.font = "arial";
			tf.bold = true;
			var text:TextField = new TextField();
			text.antiAliasType = AntiAliasType.ADVANCED;
			text.autoSize = TextFieldAutoSize.LEFT;
			text.multiline = false;
			text.selectable = false;
			text.text = label;
			text.setTextFormat(tf);
			return text;
		}
		private function updateText(label:String,text:TextField,size:int = 10):void
		{
			var tf:TextFormat = new TextFormat();
			tf.color = 0xFFFFFF;
			tf.size = size;
			tf.font = "arial";
			tf.bold = true;
			text.text = label;
			text.setTextFormat(tf);
		}
		// ------------------------------------------------------------------------------------------------------------------------------		
		
		
		
	}
	// ------------------------------------------------------------------------------------------------------------------------------
	
	
}