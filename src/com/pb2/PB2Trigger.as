package com.pb2 {
    import flash.display.MovieClip;

    public class PB2Trigger {
        // Base stuff.
        public var uid: String;
        public var enabledd: Boolean;
        public var maxcalls: int;
        public var forcehyperjump: Boolean;
        public var actions: Vector.<Action>;
        
        // Storing original properties for COOP.
        public var s_enabledd: Boolean;
        public var s_maxcalls: int;

        public function PB2Trigger(uid: String, enabled: Boolean, maxCalls: int) {
            this.uid = uid;
            this.s_enabledd = this.enabledd = enabled;
            this.s_maxcalls = this.maxcalls = maxCalls;
            this.forcehyperjump = false;
            this.actions = new Vector.<Action>();
        }

        public function addAction(type: int, arg: Vector.<String>) : void {
            this.actions.push(new Action(type, arg));
        }
    }
}

class Action {
    public var type: int;
    public var args: Vector.<String>;

    public function Action(type: int, arg: Vector.<String>) {
        this.type = type;
        this.args = arg;
    }
}