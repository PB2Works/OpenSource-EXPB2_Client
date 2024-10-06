// i use this to keep track of the attributes first, its not used as of now.
// this is not the complete list either! i only recorded what i saw, i have not explicitly went to find
package com.pb2 {

	import flash.display.MovieClip;

	public class Projectile {

		private var x:Number;
		private var y:Number;
		private var thisis:String;

		private var nx:Number;
		private var ny:Number;
		private var scaleX:Number;
		private var scaleY:Number;
		private var lag:Number;
		private var cclass:Number;
		private var power:Number;
		private var max_power:Number;
		private var knockback_multiplier:Number;
		private var notbliped:Boolean;
		private var inwater:Boolean;
		private var lastin:Number;
		private var lastinbox:Number;
		private var master:int;				// determines who shot the bullet, in terms of player slot
		private var nadekind:int;
		private var maxbulletlife:Number;
		private var currentFrame:uint;  	// determines the bullet index.
		private var hasexploded:Boolean;
		private var radius:Number;
		private var hea:Number;
		private var heapo:Number;
		private var losthea:Number;
		private var rotation:Number;
		private var life:Number;
		private var spx:Number;
		private var spy:Number;
		private var attached:Number;
		private var stuckx:Number;
		private var stucky:Number;
		private var visible:Boolean;

		private var mc:MovieClip;

		public function Projectile() {

		}

		// ========================= STATIC VARS & FUNCS ===================================
		public static const INVISIBLE_BULLET:uint = 15;
		public static const RAILS_INDEX:Vector.<uint> = new <uint>[29, 40, 51];

		public static const BULLET:uint     = 0;
		public static const ROCKETS:uint    = 1;
		public static const RAILS:uint      = 2;
		public static const SWORDS:uint     = 3;
		public static const GRENADE:uint    = 4;
		public static const ENERGY:uint     = 5;
		public static const DEFIB:uint      = 7;

		public static const ATLAS_WIDTH:Number  = 404;
		public static const ATLAS_HEIGHT:Number = 384;

																//  x   y    w    h
		public static const ROT_GLOW:Vector.<Number> = new <Number>[60, 60, 272, 162];

		// The following table below contains the x y w and h of a bullet in the texture atlas.
		public static const Atlas:Vector.<Vector.<Number>> = new <Vector.<Number>>[
			// bullet 1
			new <Number>[92, 46, 0, 0],
			// bullet 2
			new <Number>[92, 46, 0, 46],
			// bullet 3
			new <Number>[92, 46, 0, 92],
			// bullet 4
			new <Number>[92, 46, 0, 138],
			// bullet 5
			new <Number>[92, 46, 92, 0],
			// bullet 6
			new <Number>[92, 46, 92, 46],
			// bullet 7
			new <Number>[51, 8, 353, 376],
			// bullet 8
			new <Number>[13, 6, 345, 370],
			// bullet 9
			new <Number>[72, 72, 332, 150],
			// bullet 10
			new <Number>[72, 72, 200, 162],
			// bullet 11
			new <Number>[14, 7, 256, 262],
			// bullet 12
			new <Number>[46, 46, 358, 330],
			// bullet 13
			new <Number>[18, 18, 340, 75],
			// bullet 14
			new <Number>[49, 49, 200, 335],
			// bullet 15 - INVISIBLE BULLET !
			new <Number>[0, 0, 0, 0],
			// bullet 16
			new <Number>[92, 46, 92, 92],
			// bullet 17
			new <Number>[20, 20, 256, 269],
			// bullet 18
			new <Number>[15, 8, 343, 362],
			// bullet 19
			new <Number>[11, 11, 184, 162],
			// bullet 20
			new <Number>[30, 30, 368, 0],
			// bullet 21
			new <Number>[200, 200, 0, 184],
			// bullet 22
			new <Number>[92, 46, 92, 138],
			// bullet 23
			new <Number>[92, 46, 184, 0],
			// bullet 24
			new <Number>[80, 3, 249, 381],
			// bullet 25
			new <Number>[13, 6, 345, 356],
			// bullet 26
			new <Number>[92, 46, 184, 46],
			// bullet 27
			new <Number>[44, 3, 285, 278],
			// bullet 28
			new <Number>[21, 3, 282, 284],
			// bullet 29 - RAIL !
			new <Number>[0, 0, 0, 0],
			// bullet 30
			new <Number>[73, 16, 331, 268],
			// bullet 31
			new <Number>[72, 27, 200, 234],
			// bullet 32
			new <Number>[41, 41, 200, 294],
			// bullet 33
			new <Number>[67, 46, 241, 289],
			// bullet 34
			new <Number>[92, 46, 276, 0],
			// bullet 35
			new <Number>[92, 46, 312, 100],
			// bullet 36
			new <Number>[92, 46, 249, 335],
			// bullet 37
			new <Number>[113, 70, 184, 92],
			// bullet 38
			new <Number>[64, 31, 276, 46],
			// bullet 39
			new <Number>[92, 46, 312, 284],
			// bullet 40 - RAIL !
			new <Number>[0, 0, 0, 0],
			// bullet 41
			new <Number>[75, 4, 329, 146],
			// bullet 42
			new <Number>[13, 6, 345, 350],
			// bullet 43
			new <Number>[18, 14, 297, 148],
			// bullet 44
			new <Number>[44, 7, 314, 93],
			// bullet 45
			new <Number>[9, 9, 346, 331],
			// bullet 46
			new <Number>[46, 46, 358, 54],
			// bullet 47
			new <Number>[56, 28, 200, 261],
			// bullet 48
			new <Number>[132, 46, 272, 222],
			// bullet 49
			new <Number>[7, 5, 276, 268],
			// bullet 50
			new <Number>[48, 8, 283, 268],
			// bullet 51 - RAIL !
			new <Number>[0, 0, 0, 0],
			// bullet 52
			new <Number>[16, 11, 184, 173],
			// bullet 53
			new <Number>[22, 22, 368, 30],
			// bullet 54
			new <Number>[18, 14, 277, 77],
			// bullet 55
			new <Number>[7, 5, 276, 273]
		];
	}
}