package com.pb2 {
	import com.pb2works.lua.*;

	public class LuaEvents {
		private var listeners: Vector.<LuaFunction> = null;

		public function LuaEvents() {
			listeners = new Vector.<LuaFunction>();
		}

		public function register(func: LuaFunction) : void {
			listeners.push(func);
		}

		public function dispatch(...args) : void {
			for each (var listener: LuaFunction in listeners) {
				listener.run.apply(listener, args);
			}
		}

		public function clear() : void {
			listeners = new Vector.<LuaFunction>();
		}
	}
}