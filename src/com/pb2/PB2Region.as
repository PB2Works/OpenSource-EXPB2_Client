package com.pb2 {
	import flash.display.MovieClip;
	
	public class PB2Region {
		public static const USE_NONE:uint               = 0;
		public static const USE_KEY_BUTTON:uint         = 1;
		public static const USE_CHAR_NO_VEHICLE:uint    = 2;
		public static const USE_CHAR_VEHICLE:uint       = 3;
		public static const USE_CHAR:uint               = 4;
		public static const USE_DOOR:uint               = 5;
		public static const USE_PLAYER:uint             = 6;
		public static const USE_HEROES:uint             = 7;
		public static const USE_KEY:uint                = 8;
		public static const USE_KEY_BUTTON_RED:uint     = 9;
		public static const USE_KEY_BUTTON_BLUE:uint    = 10;
		public static const USE_KEY_RED:uint            = 11;
		public static const USE_KEY_BLUE:uint           = 12;
		public static const USE_PLAYER_RED:uint         = 13;
		public static const USE_PLAYER_BLUE:uint        = 14;
		public static const USE_KEY_SILENT:uint         = 15;
		public static const USE_KEY_BUTTON_SILENT:uint  = 16;
		public static const USE_UNUSED:uint             = 17;
		public static const USE_BULLET_PROJECTILES:uint = 18;

		public var x:Number;
		public var y:Number;
		public var w:Number;
		public var h:Number;
		public var mc:MovieClip; //representing the button
		public var use_target:int;
		public var use_target_uid:String = "";
		public var use_on:int;
		public var play_sound:Boolean;

		public var isActivatedOnce:Boolean = false; // boolean representing whether the button has been pressed ONCE.
		public var animationTimer:int = -1;

		// Returns color based on USE button type.
		public function getPanelColor() : Vector.<Number> {
			const greenColor:Vector.<Number> = new <Number>[0, 0.835, 0.082, 1];
			const blueColor:Vector.<Number> = new <Number>[0.118, 0.314, 0.67, 1];
			const redColor:Vector.<Number> = new <Number>[0.659, 0, 0, 1];

			switch(this.use_on){
				case USE_KEY_BUTTON:
					return greenColor;
				case USE_KEY_BUTTON_RED:
					return redColor;
				case USE_KEY_BUTTON_BLUE:
					return blueColor;
				default:
					throw new Error("Region has an invalid use_on property! use_on: " + this.use_on);
			}
		}

		// This function is invoked every render attempt.
		// Returns a percentage vector to be multiplied with USE button's alpha for animation.
		public function animateUSE(frames:uint) : Vector.<Number> {
			if(isActivatedOnce) return new <Number>[0, 0, 0, 0];

			const TOTALFRAMES:uint = 31; // animation last over TOTALFRAMES - 1. (-1 due to modulos)
			const CURRENTFRAME:uint = frames % TOTALFRAMES;
			var colorPercentage: Number;

			// Dim the text
			if(CURRENTFRAME <= 10){
				colorPercentage = 1 - CURRENTFRAME / 10;
			}
			// Lighten up text and hold it for 10 frames.
			else{
				colorPercentage = (CURRENTFRAME - 10) / 10;
			}

			return new <Number>[colorPercentage, colorPercentage, colorPercentage, 0];
		}

		// This function is invoked every render attempt.
		// Returns a percentage vector to be multiplied with lit colour to obtain dull colour. Percentage is dependent on animation frames.
		// COLOUR OF PANEL WHEN DULL : MULTIPLY COLOUR BY 27% FOR EACH COMPONENT ();
		public function animatePanel() : Vector.<Number> {
			const TOTALFRAMES:uint = 10; // let animation run over "TOTALFRAMES" amount of frames.
			const dullColorPercentage:Vector.<Number> = new <Number>[0.27, 0.27, 0.27, 1];

			// button is not activated OR animation has finished.
			if(!this.isActivatedOnce || this.animationTimer == 0){
				switch(use_on){
					case USE_KEY_BUTTON:
						return dullColorPercentage;
					case USE_KEY_BUTTON_RED:
						return new <Number>[1, 1, 1, 1];
					case USE_KEY_BUTTON_BLUE:
						return new <Number>[1, 1, 1, 1];
					default:
						throw new Error("Region has an invalid use_on property! use_on: " + this.use_on);
				}
			} 
			// for the very first frame of the animation.
			if(this.animationTimer == -1) this.animationTimer = TOTALFRAMES;

			// in the midst of an animation.
			const colorChange:Number = this.animationTimer / 10; // drops from 1 to 0 based on timer.
			this.animationTimer--;
			switch(use_on){
				case USE_KEY_BUTTON:
					return new <Number>[0.27 + colorChange * 0.73, 0.27 + colorChange * 0.73, 0.27 + colorChange * 0.73, 1];
				case USE_KEY_BUTTON_RED:
					return new <Number>[1 + colorChange * 0.5, 1 + colorChange * 0.5, 1 + colorChange * 0.5, 1];
				case USE_KEY_BUTTON_BLUE:
					return new <Number>[1 + colorChange * 0.5, 1 + colorChange * 0.5, 1 + colorChange * 0.5, 1];
				default:
					throw new Error("Region has an invalid use_on property! use_on: " + this.use_on);
			}
		}

		public function PB2Region(x:Number, y:Number, w:Number, h:Number) {
			this.x = x;
			this.y = y;
			this.w = w;
			this.h = h;
		}
	}
}