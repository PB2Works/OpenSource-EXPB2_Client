package com.pb2 {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.media.SoundChannel;
	
	
	public class PB2Door extends MovieClip implements SoundAttachable {
		private var Game:PB2Game;

		public var vis:Boolean;
		public var playsounds:Boolean;
		public var moving:Boolean;
		public var s_moving:Boolean;

		public var w:Number;
		public var h:Number;
		public var tox:Number;
		public var toy:Number;
		public var maxspeed:Number;
		public var tarx:Number;
		public var tary:Number;
		public var s_x:Number;
		public var s_y:Number;
		public var s_maxspeed:Number;
		public var s_tarx:Number;
		public var s_tary:Number;
		public var onshot:int;
		public var forcehyperjump_float:Number;
		public var color:Vector.<Number>;
		public var use_on:int;
		public var use_target:int;
		public var surface:DisplayObject;
		
		public function PB2Door(x:Number, y:Number, w:Number, h:Number, vis:Boolean, moving:Boolean, tarx:Number, tary:Number, maxspeed:Number) {
			super();
			Game = PB2Game.GAME;

			Game.NoMouse(this);
			visible = false;
			this.vis = vis;
			s_x = this.x = x;
			s_y = this.y = y;
			scaleX = w / 100;
			scaleY = h / 100;
			this.w = w;
			this.h = h;
			tox = toy = 0;
			s_moving = this.moving = moving;
			s_tarx = this.tarx = tarx;
			s_tary = this.tary = tary;
			use_target = -1;
			use_on = 0;
			s_maxspeed = this.maxspeed = maxspeed;
			onshot = -1;
			playsounds = true;
			forcehyperjump_float = 0;
			color = new Vector.<Number>(4);
			color[3] = 1.0;
		}

		public function setColor(str_color:String) : void {
			color[0] = parseInt(str_color.slice(1,3), 16) / 255;
			color[1] = parseInt(str_color.slice(3,5), 16) / 255;
			color[2] = parseInt(str_color.slice(5,7), 16) / 255;
		}

		public function getColorAsHex() : String {
			var r:String = Math.floor(color[0]*255).toString(16).toUpperCase();
			var g:String = Math.floor(color[1]*255).toString(16).toUpperCase();
			var b:String = Math.floor(color[2]*255).toString(16).toUpperCase();
			r = r.length == 1 ? ("0" + r) : r;
			g = g.length == 1 ? ("0" + g) : g;
			b = b.length == 1 ? ("0" + b) : b;
			return "#" + r + g + b;
		}

		public function moveToward(tarx:Number, tary:Number, forcehyperjump:Boolean=false) : void {
			if(forcehyperjump) forcehyperjump_float = 1;
			this.tarx = tarx;
			this.tary = tary;
			moving = true;
			if(playsounds && vis) 
				Game.PlaySound(Game.s_t_door1_start, x + Number(w) / 2, y + Number(h) / 2, this);
		}

		public function stopMoving() : void {
			moving = false;
			tox = 0;
			toy = 0;
			x = tarx;
			y = tary;
			if(playsounds && vis)
				Game.PlaySound(Game.s_t_door1_stop, x + Number(w) / 2, y + Number(h) / 2, this);
		}

		// SoundAttachable interface
		private var channel:SoundChannel = null;

		public function get attached_sound() : SoundChannel {
			return channel;
		}

		public function set attached_sound(channel:SoundChannel) : void {
			this.channel = channel;
		}
	}
}
