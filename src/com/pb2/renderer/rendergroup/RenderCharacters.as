package com.pb2.renderer.rendergroup{

	import com.pb2.PB2Game;
	import flash.display3D.*;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.display.MovieClip;

	// For textures
	import flash.display3D.textures.RectangleTexture;
	import flash.display.BitmapData;

	public class RenderCharacters implements IRenderGroup{
		public static const name:String = "Characters";

		public var game:PB2Game;
		public var c3d:Context3D;
		private var shaderProgram:Program3D;

		// Player
		private var idx_player:IndexBuffer3D;
		private var vtx_player:VertexBuffer3D;
		private var mdl_player:Vector.<PlayerModel>;
		private var mens:Vector.<player>;
		public static var ZERO_VECTOR:Vector3D = new Vector3D(0, 0, 0, 0);

		public function getName() : String {
			return name;
		}

		public function RenderCharacters(game:PB2Game, c3d:Context3D, shaderProgram: Program3D) : void{
			this.shaderProgram = shaderProgram;
			this.game = game;
			this.c3d = c3d;

			idx_player = c3d.createIndexBuffer(3 * 2 * 13, Context3DBufferUsage.STATIC_DRAW); // 13 triangle pairs with 3 vertices each (duh)
			vtx_player = c3d.createVertexBuffer(13 * 4, 4, Context3DBufferUsage.DYNAMIC_DRAW); // 13 groups of 4 vertices (aka rectangles) 
			idx_player.uploadFromVector(new <uint>
			[
				0,   1,  2,
				2,   3,  0,
				4,   5,  6,
				6,   7,  4,
				8,   9, 10,
				10, 11,  8,
				12, 13, 14,
				14, 15, 12,
				16, 17, 18,
				18, 19, 16,
				20, 21, 22,
				22, 23, 20,
				24, 25, 26,
				26, 27, 24,
				28, 29, 30, 
				30, 31, 28,
				32, 33, 34, 
				34, 35, 32,
				36, 37, 38, 
				38, 39, 36,
				40, 41, 42, 
				42, 43, 40,
				44, 45, 46, 
				46, 47, 44,
				48, 49, 50, 
				50, 51, 48
			]
			, 0, 13 * 2 * 3); // 13 triangle pairs with 3 vertices each (duh)
		}

		public function setup() : void{
			mens = game.mens;
			mdl_player = new Vector.<PlayerModel>(game.playerstotal);
			
			for (var i:int = 0; i < game.playerstotal; i++) {
				var model:PlayerModel = null;
				if (mens[i].char != 5)
					model = PlayerModel.newFrom(mens[i], c3d);
				mens[i].mdl3d = model;
				mdl_player[i] = model;
			}
		}

		// Layering
		// Arm1 > Leg1 > Head > Body > Toe > Leg2 > Arm2
		// Draw order (opppsite)
		// Arm2, Leg2, Toe, Body, Head, Leg1, Arm1
		
		/* Flash DisplayObject transformation matrix:
										 CHILD                           PARENT
			(Translate (origin) x Scale x Rotate x Translate) X (Scale x Rotate x Translate) X ...
		*/
		
		// Full order
		// arm2.upper, arm2.lower, leg2.lower, leg2.upper, leg2.middle, toe, body, head,
		// leg1.lower, leg1.upper, leg1.middle, arm1.upper, arm1.lower
		
		private var mtx_playerA:Matrix3D  = new Matrix3D();
		private var mtx_playerB:Matrix3D  = new Matrix3D();
		private var mtx_player1:Matrix3D  = new Matrix3D();
		private var mtx_player2:Matrix3D  = new Matrix3D();
		private var mtx_player3:Matrix3D  = new Matrix3D();
		private var mtx_player4:Matrix3D  = new Matrix3D();
		private var mtx_player5:Matrix3D  = new Matrix3D();
		private var mtx_player6:Matrix3D  = new Matrix3D();
		private var mtx_player7:Matrix3D  = new Matrix3D();
		private var mtx_player8:Matrix3D  = new Matrix3D();
		private var mtx_player9:Matrix3D  = new Matrix3D();
		private var mtx_player10:Matrix3D = new Matrix3D();
		private var mtx_player11:Matrix3D = new Matrix3D();
		private var mtx_player12:Matrix3D = new Matrix3D();
		private var mtx_player13:Matrix3D = new Matrix3D();
		private var mtx_players:Vector.<Matrix3D> = new <Matrix3D>[mtx_player1, mtx_player2, mtx_player3, mtx_player4, mtx_player5, mtx_player6, mtx_player7, mtx_player8, mtx_player9, mtx_player10, mtx_player11, mtx_player12, mtx_player13];
		private var vec_player0:Vector.<Number> = new Vector.<Number>(13 * 4 * 4); // 13 bodyparts with 4 vertices each (rectangle) with 4 attributes each (x y s t) 
		private var vec_player1:Vector.<Number> = new <Number>
		[
		  0, 0, 0,
		  1, 0, 0,
		  1, 1, 0,
		  0, 1, 0
		];
		private var vec_player2:Vector.<Number> = new Vector.<Number>(4 * 3);
		private var vec_playeri:Vector.<uint> = new <uint>[3, 4, 7, 5, 6, 2, 1, 0, 7, 5, 6, 3, 4];

		private function renderPlayerModels(mainTransform: Matrix3D) : void {
			var w:Number;
			var h:Number;
			var bmtx:Matrix3D = mtx_playerA;
			var mtx:Matrix3D = mtx_playerB;
			var m1:Matrix3D = mtx_player1;
			var m2:Matrix3D = mtx_player2;
			var m3:Matrix3D = mtx_player3;
			var m4:Matrix3D = mtx_player4;
			var m5:Matrix3D = mtx_player5;
			var m6:Matrix3D = mtx_player6;
			var m7:Matrix3D = mtx_player7;
			var m8:Matrix3D = mtx_player8;
			var m9:Matrix3D = mtx_player9;
			var m10:Matrix3D = mtx_player10;
			var m11:Matrix3D = mtx_player11;
			var m12:Matrix3D = mtx_player12;
			var m13:Matrix3D = mtx_player13;
			var ms:Vector.<Matrix3D> = mtx_players;
			var p0:Vector.<Number> = vec_player0;
			var p1:Vector.<Number> = vec_player1;
			var p2:Vector.<Number> = vec_player2;
			var pi:Vector.<uint> = vec_playeri;
			var pl:MovieClip;
			var mdl:PlayerModel;
			var flip:Number;
			var coords:Vector.<Number>;
			
			c3d.setProgram(shaderProgram);
			c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			c3d.setVertexBufferAt(0, vtx_player, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
			c3d.setVertexBufferAt(1, vtx_player, 2, Context3DVertexBufferFormat.FLOAT_2); // va1 is texture (st)
			
			mtx.identity();
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mtx, true); // All of the vertices will already be transformed
			
			for (var i:int = 0; i < game.playerstotal; i++) {
				pl = mens[i];
				if (!pl) return;
				mdl = pl.mdl3d;
				flip = pl.head.scaleX;
				if (!pl.visible || mdl == null /*|| mdl == undefined*/) continue;
				coords = mdl.atlas.coords;
				
				bmtx.identity();
				bmtx.appendScale(flip, 1, 1);
				bmtx.appendRotation(pl.arm2.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
				bmtx.appendTranslation(pl.arm2.x + pl.x, pl.arm2.y + pl.y, 0);
				bmtx.append(mainTransform);
					w = mdl.arm_upper_w;
					h = mdl.arm_upper_h;
					m1.identity();
					m1.appendTranslation(mdl.arm_upper_px / w, mdl.arm_upper_py / h, 0);
					m1.appendScale(w, h, 1);
					m1.appendRotation(pl.arm2.upper.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
					m1.append(bmtx);
					////////////////////////////////////////////////////////////////////////////////
					w = mdl.arm_lower_w;
					h = mdl.arm_lower_h;
					m2.identity();
					m2.appendTranslation(mdl.arm_lower_px / w, mdl.arm_lower_py / h, 0);
					m2.appendScale(w, h, 1);
					m2.appendRotation(pl.arm2.lower.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
					m2.appendTranslation(pl.arm2.lower.x, pl.arm2.lower.y, 0);
					m2.append(bmtx);
				
				
				bmtx.identity();
				bmtx.appendScale(flip, 1, 1);
				bmtx.appendRotation(pl.leg2.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
				bmtx.appendTranslation(pl.leg2.x + pl.x, pl.leg2.y + pl.y, 0);
				bmtx.append(mainTransform);
					w = mdl.leg_lower_w;
					h = mdl.leg_lower_h;
					m3.identity();
					m3.appendTranslation(mdl.leg_lower_px / w, mdl.leg_lower_py / h, 0);
					m3.appendScale(w, h, 1);
					m3.appendRotation(pl.leg2.lower.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
					m3.appendTranslation(pl.leg2.lower.x, pl.leg2.lower.y, 0);
					m3.append(bmtx);
					////////////////////////////////////////////////////////////////////////////////
					w = mdl.leg_upper_w;
					h = mdl.leg_upper_h;
					m4.identity();
					m4.appendTranslation(mdl.leg_upper_px / w, mdl.leg_upper_py / h, 0);
					m4.appendScale(w, h, 1);
					m4.appendRotation(pl.leg2.upper.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
					m4.appendTranslation(pl.leg2.upper.x, pl.leg2.upper.y, 0);
					m4.append(bmtx);
					////////////////////////////////////////////////////////////////////////////////
					w = mdl.leg_middle_w;
					h = mdl.leg_middle_h;
					m5.identity();
					m5.appendTranslation(mdl.leg_middle_px / w, mdl.leg_middle_py / h, 0);
					m5.appendScale(w, h, 1);
					m5.appendRotation(pl.leg2.middle.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
					m5.appendTranslation(pl.leg2.middle.x, pl.leg2.middle.y, 0);
					m5.append(bmtx);
				
				
				w = mdl.toe_w;
				h = mdl.toe_h;
				m6.identity();
				m6.appendTranslation(mdl.toe_px / w, mdl.toe_py / h, 0);
				m6.appendScale(w * flip, h, 1);
				m6.appendRotation(pl.toe.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
				m6.appendTranslation(pl.toe.x + pl.x, pl.toe.y + pl.y, 0);
				m6.append(mainTransform);
				////////////////////////////////////////////////////////////////////////////////
				w = mdl.body_w;
				h = mdl.body_h;
				m7.identity();
				m7.appendTranslation(mdl.body_px / w, mdl.body_py / h, 0);
				m7.appendScale(w * flip, h, 1);
				m7.appendRotation(pl.body.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
				m7.appendTranslation(pl.body.x + pl.x, pl.body.y + pl.y, 0);
				m7.append(mainTransform);
				////////////////////////////////////////////////////////////////////////////////
				w = mdl.head_w;
				h = mdl.head_h;
				m8.identity();
				m8.appendTranslation(mdl.head_px / w, mdl.head_py / h, 0);
				m8.appendScale(w * flip, h, 1);
				m8.appendRotation(pl.head.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
				m8.appendTranslation(pl.head.x + pl.x, pl.head.y + pl.y, 0);
				m8.append(mainTransform);
				
				
				bmtx.identity();
				bmtx.appendScale(flip, 1, 1);
				bmtx.appendRotation(pl.leg1.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
				bmtx.appendTranslation(pl.leg1.x + pl.x, pl.leg1.y + pl.y, 0);
				bmtx.append(mainTransform);
					w = mdl.leg_lower_w;
					h = mdl.leg_lower_h;
					m9.identity();
					m9.appendTranslation(mdl.leg_lower_px / w, mdl.leg_lower_py / h, 0);
					m9.appendScale(w, h, 1);
					m9.appendRotation(pl.leg1.lower.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
					m9.appendTranslation(pl.leg1.lower.x, pl.leg1.lower.y, 0);
					m9.append(bmtx);
					////////////////////////////////////////////////////////////////////////////////
					w = mdl.leg_upper_w;
					h = mdl.leg_upper_h;
					m10.identity();
					m10.appendTranslation(mdl.leg_upper_px / w, mdl.leg_upper_py / h, 0);
					m10.appendScale(w, h, 1);
					m10.appendRotation(pl.leg1.upper.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
					m10.appendTranslation(pl.leg1.upper.x, pl.leg2.upper.y, 0);
					m10.append(bmtx);
					////////////////////////////////////////////////////////////////////////////////
					w = mdl.leg_middle_w;
					h = mdl.leg_middle_h;
					m11.identity();
					m11.appendTranslation(mdl.leg_middle_px / w, mdl.leg_middle_py / h, 0);
					m11.appendScale(w, h, 1);
					m11.appendRotation(pl.leg1.middle.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
					m11.appendTranslation(pl.leg1.middle.x, pl.leg1.middle.y, 0);
					m11.append(bmtx);
				
				
				bmtx.identity();
				bmtx.appendScale(flip, 1, 1);
				bmtx.appendRotation(pl.arm1.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
				bmtx.appendTranslation(pl.arm1.x + pl.x, pl.arm1.y + pl.y, 0);
				bmtx.append(mainTransform);
					w = mdl.arm_upper_w;
					h = mdl.arm_upper_h;
					m12.identity();
					m12.appendTranslation(mdl.arm_upper_px / w, mdl.arm_upper_py / h, 0);
					m12.appendScale(w, h, 1);
					m12.appendRotation(pl.arm1.upper.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
					m12.appendTranslation(pl.arm1.upper.x, pl.arm1.upper.y, 0);
					m12.append(bmtx);
					////////////////////////////////////////////////////////////////////////////////
					w = mdl.arm_lower_w;
					h = mdl.arm_lower_h;
					m13.identity();
					m13.appendTranslation(mdl.arm_lower_px / w, mdl.arm_lower_py / h, 0);
					m13.appendScale(w, h, 1);
					m13.appendRotation(pl.arm1.lower.rotation, Vector3D.Z_AXIS, ZERO_VECTOR);
					m13.appendTranslation(pl.arm1.lower.x, pl.arm1.lower.y, 0);
					m13.append(bmtx);
				
				
				var ji:int;
				var bi:int;
				for (var j:int = 0; j < 13; j++) {
					mtx_players[j].transformVectors(p1, p2);
					ji = j * 16;
					bi = 8 * pi[j];
					p0[ji + 0]  = p2[0];
					p0[ji + 1]  = p2[1];
					p0[ji + 2]  = coords[bi + 0];
					p0[ji + 3]  = coords[bi + 1];
					p0[ji + 4]  = p2[3];
					p0[ji + 5]  = p2[4];
					p0[ji + 6]  = coords[bi + 2];
					p0[ji + 7]  = coords[bi + 3];
					p0[ji + 8]  = p2[6];
					p0[ji + 9]  = p2[7];
					p0[ji + 10] = coords[bi + 4];
					p0[ji + 11] = coords[bi + 5];
					p0[ji + 12] = p2[9];
					p0[ji + 13] = p2[10];
					p0[ji + 14] = coords[bi + 6];
					p0[ji + 15] = coords[bi + 7];
				}
				vtx_player.uploadFromVector(p0, 0, 4 * 13);
				c3d.setTextureAt(0, mdl.atlas.tex);
				c3d.drawTriangles(idx_player, 0, 2 * 13);
			}
			c3d.setTextureAt(0, null);
			c3d.setVertexBufferAt(1, null);
		}

		public function render(mainTransform: Matrix3D, pass:uint) : void{
			renderPlayerModels(mainTransform);
		}

		public function free() : void{
			if (mdl_player != null) {
				for (var i:int = 0; i < mdl_player.length; i++) {
					var model:PlayerModel = mdl_player[i];
					if (model != null) model.dispose();
				}
				mdl_player = null;
			}
		}
	}
}

import flash.geom.Vector3D;
import flash.geom.Point;
import flash.display.Bitmap;

// Player MovieClip structure:
/*
	head
	body
	toe
	arm1
	  .upper
	  .lower
	arm2
	  .upper
	  .lower
	leg1
	  .upper
	  .middle
	  .lower
	leg2
	  .upper
	  .middle
	  .lower
*/

class AtlasTexture {
	import com.pb2.renderer.AcceleratedRenderer;
	
	import flash.geom.Rectangle;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.RectangleTexture;
	
	public var tex:Texture;
	private var c3d:Context3D;
	private var size:uint;
	public var coords:Vector.<Number>; // UV coordinates of subtextures. Length: 4 (vertices) * 2 (s t) * size
	private var bmps:Vector.<BitmapData>;
	private var lastBitmap:uint;
	private var textureFormat:String;
	
	public function AtlasTexture(c3d:Context3D, size:uint, textureFormat:String) {
		this.c3d = c3d;
		this.size = size;
		this.textureFormat = textureFormat;
		coords = new Vector.<Number>(4 * 2 * size);
		bmps = new Vector.<BitmapData>(size);
		lastBitmap = 0;
	}
	
	public function addBitmap(bmp:BitmapData) : void {
		bmps[lastBitmap++] = bmp;
	}
	
	private function pack(width:int, height:int) : Vector.<Number> {
		var tree:PackNode = new PackNode(0, 0, width, height);
		var result:Vector.<Number> = new Vector.<Number>(size * 2, true);
		
		var max:int;
		var i:int;
		var tn:int;
		var order:Vector.<uint> = new Vector.<uint>(size, true);
		
		for (i = 0; i < size; i++) order[i] = i;
		
		// Sort by size
		for (i = 0; i < size-1; i++) {
			max = i;
			var t:uint;
			for (var j:int = i + 1; j < size; j++) {
				if ((bmps[order[j]].width * bmps[order[j]].height) <= (bmps[order[max]].width * bmps[order[max]].height)) continue;
				max = j;
			}
			t = order[i];
			order[i] = order[max];
			order[max] = t;
		}
		
		// Attempt packing
		for (i = 0; i < size; i++) {
			var oi:uint = order[i];
			var pos:PackNode = tree.insert(new Rectangle(0, 0, bmps[oi].width, bmps[oi].height));
			if (pos == null) return null; // Packing failed (no more space)
			result[oi*2 + 0] = pos.x;
			result[oi*2 + 1] = pos.y;
		}
		
		return result;
	}
	
	public function build() : void {
		var width:int  = 64;
		var height:int = 64;
		// width & height must be powers of 2
		
		// Construct atlas to hold all BitmapDatas
		var abmp:BitmapData;
		var pos:Vector.<Number>;
		var i:uint = 0;
		
		while (true) {
			pos = pack(width, height);
			if (pos != null) break;
			if (i++ % 2 == 0) width *= 2;
			else              height *= 2;
		}
		
		abmp = new BitmapData(width, height, true, 0);
		var x:Number;
		var y:Number;
		var tw:Number;
		var th:Number;
		
		for (i = 0; i < size; i++) {
			x  = pos[2 * i + 0];
			y  = pos[2 * i + 1];
			tw = bmps[i].width;
			th = bmps[i].height;
			abmp.copyPixels(bmps[i], new Rectangle(0, 0, tw, th), new Point(x, y));
			x  /= width;
			y  /= height;
			tw /= width;
			th /= height;
			coords[8 * i + 0] = x;
			coords[8 * i + 1] = y;
			coords[8 * i + 2] = x + tw;
			coords[8 * i + 3] = y;
			coords[8 * i + 4] = x + tw;
			coords[8 * i + 5] = y + th;
			coords[8 * i + 6] = x;
			coords[8 * i + 7] = y + th;
		}
		
		tex = c3d.createTexture(width, height, textureFormat, false);
		tex.uploadFromBitmapData(abmp);
		abmp.dispose();
		
		for (i = 0; i < bmps.length; i++) bmps[i].dispose();
		bmps = null;
	}
	
	public function dispose() : void {
		if (tex != null) {
			tex.dispose();
			tex = null;
		}
		// bmps = null; -- Assumes all bmps either don't exist or already disposed
		c3d = null;
	}
}

import flash.geom.Rectangle;

class PackNode {
	public var area:Rectangle;
	public var children:Vector.<PackNode>;
	
	public function PackNode(x:int, y:int, width:int, height:int) {
		area = new Rectangle(x, y, width, height);
		children = null;
	}
	
	public function get x() : int {
		return area.x;
	}
	
	public function get y() : int {
		return area.y;
	}
	
	public function get width() : int {
		return area.width - area.x;
	}
	
	public function get height() : int {
		return area.height - area.y;
	}
	
	public function insert(new_area:Rectangle) : PackNode {
		var new_node:PackNode;
		
		if (children != null) {
			new_node = children[0].insert(new_area);
			if (new_node == null) return children[1].insert(new_area);
			return new_node;
		}
		
		new_node = new PackNode(new_area.x, new_area.y, new_area.width, new_area.height);
		if (new_node.width <= width && new_node.height <= height) {
			children = new Vector.<PackNode>(2, true);
			children[0] = new PackNode(x+new_node.width, y, area.width, y + new_node.height);
			children[1] = new PackNode(x, y+new_node.height, area.width, area.height);
			return new PackNode(x, y, x + new_node.width, y + new_node.height)
		}
		
		return null;
	}
}

class PlayerModel {
	import com.pb2.renderer.AcceleratedRenderer;
	
	import flash.geom.Rectangle;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	
	public static const textureFormat:String = Context3DTextureFormat.BGRA;
	
	public var head_px:Number;
	public var head_py:Number;
	public var head_w:Number;
	public var head_h:Number;
	
	public var body_px:Number;
	public var body_py:Number;
	public var body_w:Number;
	public var body_h:Number;
	
	public var toe_px:Number;
	public var toe_py:Number;
	public var toe_w:Number;
	public var toe_h:Number;
	
	public var arm_px:Number;
	public var arm_py:Number;
	public var arm_upper_px:Number;
	public var arm_upper_py:Number;
	public var arm_upper_w:Number;
	public var arm_upper_h:Number;
	public var arm_lower_px:Number;
	public var arm_lower_py:Number;
	public var arm_lower_w:Number;
	public var arm_lower_h:Number;
	
	public var leg_px:Number;
	public var leg_py:Number;
	public var leg_upper_px:Number;
	public var leg_upper_py:Number;
	public var leg_upper_w:Number;
	public var leg_upper_h:Number;
	public var leg_middle_px:Number;
	public var leg_middle_py:Number;
	public var leg_middle_w:Number;
	public var leg_middle_h:Number;
	public var leg_lower_px:Number;
	public var leg_lower_py:Number;
	public var leg_lower_w:Number;
	public var leg_lower_h:Number;
	
	private var c3d:Context3D;
	public var atlas:AtlasTexture;
	
	public function PlayerModel(c3d:Context3D) {
		this.c3d = c3d;
	}
	
	private function disposeResources() : void {
		atlas.dispose();
	}
	
	public function dispose() : void {
		atlas = null;
		c3d = null;
	}
	
	public function fullUpdate(player:MovieClip) : void {
		this.disposeResources();
		this.from(player);
	}
	
	public function from(player:MovieClip) : void {
		const q:Number = 2; // Render quality
		var bounds:Rectangle = new Rectangle();
		var bmp:BitmapData;
		atlas = new AtlasTexture(c3d, 8, textureFormat);
		
		bmp = AcceleratedRenderer.rasterize(player.head, 2);
		bounds.copyFrom(player.head.getBounds(player.head));
		head_px = bounds.x;
		head_py = bounds.y;
		head_w = bounds.width;
		head_h = bounds.height;
		atlas.addBitmap(bmp);
		
		bmp = AcceleratedRenderer.rasterize(player.body, q);
		bounds.copyFrom(player.body.getBounds(player.body));
		body_px = bounds.x;
		body_py = bounds.y;
		body_w = bounds.width;
		body_h = bounds.height;
		atlas.addBitmap(bmp);
		
		bmp = AcceleratedRenderer.rasterize(player.toe, q);
		bounds.copyFrom(player.toe.getBounds(player.toe));
		toe_w = bounds.width;
		toe_h = bounds.height;
		toe_px = bounds.x;
		toe_py = bounds.y;
		atlas.addBitmap(bmp);
		
		bounds.copyFrom(player.arm1.getBounds(player.arm1));
		arm_px = bounds.x;
		arm_py = bounds.y;
		
		bmp = AcceleratedRenderer.rasterize(player.arm1.upper, q);
		bounds.copyFrom(player.arm1.upper.getBounds(player.arm1.upper));
		arm_upper_px = bounds.x;
		arm_upper_py = bounds.y;
		arm_upper_w = bounds.width;
		arm_upper_h = bounds.height;
		atlas.addBitmap(bmp);
		
		bmp = AcceleratedRenderer.rasterize(player.arm1.lower, q);
		bounds.copyFrom(player.arm1.lower.getBounds(player.arm1.lower));
		arm_lower_px = bounds.x;
		arm_lower_py = bounds.y;
		arm_lower_w = bounds.width;
		arm_lower_h = bounds.height;
		atlas.addBitmap(bmp);
		
		bounds.copyFrom(player.leg1.getBounds(player.leg1));
		leg_px = bounds.x;
		leg_py = bounds.y;
		
		bmp = AcceleratedRenderer.rasterize(player.leg1.upper, q);
		bounds.copyFrom(player.leg1.upper.getBounds(player.leg1.upper));
		leg_upper_px = bounds.x;
		leg_upper_py = bounds.y;
		leg_upper_w = bounds.width;
		leg_upper_h = bounds.height;
		atlas.addBitmap(bmp);
		
		bmp = AcceleratedRenderer.rasterize(player.leg1.middle, q);
		bounds.copyFrom(player.leg1.middle.getBounds(player.leg1.middle));
		leg_middle_px = bounds.x;
		leg_middle_py = bounds.y;
		leg_middle_w = bounds.width;
		leg_middle_h = bounds.height;
		atlas.addBitmap(bmp);
		
		bmp = AcceleratedRenderer.rasterize(player.leg1.lower, q);
		bounds.copyFrom(player.leg1.lower.getBounds(player.leg1.lower));
		leg_lower_px = bounds.x;
		leg_lower_py = bounds.y;
		leg_lower_w = bounds.width;
		leg_lower_h = bounds.height;
		atlas.addBitmap(bmp);
		
		atlas.build();
	}
	
	public static function newFrom(player:MovieClip, c3d:Context3D) : PlayerModel {
		var model:PlayerModel = new PlayerModel(c3d);
		model.from(player);
		return model;
	}
}
