package com.pb2 {
	import flash.media.Sound;
	import flash.media.SoundChannel;

	public class PB2CustomSong {
		public var url:String;
		public var sound:Sound;
		public var channel:SoundChannel;
		public var volume:Number;
		public var volume_scale:Number;
		public var callback:int;
		public var loop:Boolean;
		public var loadingSince:int;
		
		public function PB2CustomSong(url:String, volume_scale:Number, callback:int, loop:Boolean, loadingSince:int) {
			this.url = url;
			sound = null; // new Sound();
			channel = null; // new SoundChannel();
			volume = 0.0;
			this.volume_scale = Math.max(0, Math.min(2, volume_scale));
			this.callback = callback;
			this.loop = loop;
			this.loadingSince = loadingSince;
		}
	}
}