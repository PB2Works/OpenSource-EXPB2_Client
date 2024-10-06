package com.pb2{
    public class PB2Water {

        public static const WATER_COLOR: String = "#C1DBE2";
        public static const ACID_COLOR: String = "#91F200";

        public var x:Number;
        public var y:Number;
        public var w:Number;
        public var h:Number;
        public var damage:Number;

        public var name: String;
        public var color: Vector.<Number>;   //#XXXXXX
        public var friction: Boolean;

        public var isAcid: Boolean;

        public function PB2Water(x:Number, y:Number, w:Number, h:Number, damage:Number){
            this.x = x;
            this.y = y;
            this.w = w;
            this.h = h;
            this.damage = damage;
            color = new Vector.<Number>(3); // R G B

            if(damage == 0){
                name = "Water";
                isAcid = false;
                setColor(WATER_COLOR);
            }
            else{
                name = "Acid";
                isAcid = true;
                setColor(ACID_COLOR);
            }
        }

        public function setName(name: String) : void{
            this.name = name;
        }

        public function setFriction(friction: Boolean) : void{
            this.friction = friction;
        }

        public function setColor(str_color: String) : void{
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
    }
}