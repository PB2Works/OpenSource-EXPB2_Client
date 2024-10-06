package com.pb2 {
	import flash.display.Bitmap;
	import flash.display.BitmapData;

	public class PB2CustomImage {
		public static const MAX_SIZE:uint = 1024 * 1024 * 10;
		
		public var id:int;
		public var width:int;
		public var height:int;
		public var bitmap:Bitmap;
		public var bitmap_data:BitmapData;
		public var load_callbacks:Vector.<Function>;
		public var load_callback_params:Vector.<Object>;
		
		public function PB2CustomImage(id:int, width:int, height:int) {
			this.id = id;
			this.width = width;
			this.height = height;
			bitmap = null;
			bitmap_data = null;
			load_callbacks = new Vector.<Function>();
			load_callback_params = new Vector.<Object>();
		}
	}
}