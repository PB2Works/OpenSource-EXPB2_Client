package com.pb2 {
	import flash.media.SoundChannel;

	public interface SoundAttachable {
		function get attached_sound() : SoundChannel;
		function set attached_sound(channel:SoundChannel) : void;
	}
}