package com.pb2.renderer.rendergroup{

	import com.pb2.PB2Game;
	import com.pb2.Projectile;
	import flash.display3D.*;
	import flash.geom.Matrix3D;
	import flash.display.MovieClip;
	import com.pb2.renderer.AcceleratedRenderer;

	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display3D.textures.RectangleTexture;
	import flash.geom.ColorTransform;

	public class RenderProjectiles implements IRenderGroup{
		public static const name:String = "Bullets";
		private static var tex_projectile:RectangleTexture;

		private var game:PB2Game;
		private var c3d:Context3D;
		private var projectileShader:Program3D;
		private var rotGlowShader:Program3D;

		private var idx_projectile:IndexBuffer3D;
		private var vtx_projectile:VertexBuffer3D;
		private var idx_rot_glow:IndexBuffer3D;
		private var vtx_rot_glow:VertexBuffer3D;
		private var idx_projectile_vec:Vector.<uint>;
		private var vtx_projectile_vec:Vector.<Number>;
		private static const cts_projectile:Vector.<Number> = new <Number>[1, 0, 0, 0];
		private var idx_rot_glow_vec:Vector.<uint>;
		private var vtx_rot_glow_vec:Vector.<Number>;

		private var bullet_count:uint;
		private var bullets:Array;
		private var max_bullets:uint;
		private var glow_count:uint;

		private var MAX_PROJECTILE_INDICES:uint;
		private var MAX_PROJECTILE_VERTICES:uint;
		private static const PROJECTILE_VERTEX_SIZE:uint = 7;
		private static const ROT_GLOW_VERTEX_SIZE:uint = 4;

		// Contains a list of class for which RenderProjectiles checks and only renders if current projectile has a class in this Vector.
		// This is set through the constructor
		// This is to selectively render certain bullet classes, to achieve shadowmap effect on certain bullet classes.
		private var class_to_render:Vector.<uint>;
		private static const render_pass_classes:Vector.<Vector.<uint>> = new <Vector.<uint>>[
			new <uint>[Projectile.GRENADE, Projectile.ROCKETS],
			new <uint>[Projectile.BULLET, Projectile.ENERGY]
		];	

		private static const QUALITY:Number = 3.5;
		private static const DEG_TO_RAD:Number = Math.PI / 180.0;
		private static const ROT_GLOW_INDEX:uint = 1;
		
		public function getName() : String {
			return name;
		}

		public function RenderProjectiles(game:PB2Game, c3d:Context3D, projectileShader: Program3D, rotGlowShader: Program3D) : void {

			this.projectileShader   = projectileShader;
			this.rotGlowShader      = rotGlowShader;
			this.game               = game;
			this.c3d                = c3d;

			setupTextureAtlas(c3d);
		}

		// Returns a boolean that indicates what classes of bullet projectiles is this specific RenderProjectiles instance rendering.
		private function toRenderClass(cclass: uint) : Boolean {
			return !(class_to_render.indexOf(cclass) == -1);
		}

		// Sets up texture atlas only once.
		private static function setupTextureAtlas(c3d: Context3D) : void {
			if(tex_projectile) return;  // texture already loaded.

			var laserMovieClip:MovieClip = new lazer();
			var atlasBmp:BitmapData = new BitmapData(Projectile.ATLAS_WIDTH * QUALITY, Projectile.ATLAS_HEIGHT * QUALITY, true, 0);

			// Draw rot glow
			var rotGlow:DisplayObject = laserMovieClip.getChildAt(1);
			var rotGlowBitmap:BitmapData = AcceleratedRenderer.rasterize(rotGlow, QUALITY);

			var cTransform:ColorTransform = new ColorTransform();
			cTransform.alphaMultiplier = 0.15;
			rotGlowBitmap.colorTransform(new Rectangle(0, 0, rotGlowBitmap.width, rotGlowBitmap.height), cTransform);

			atlasBmp.copyPixels(
				rotGlowBitmap, 
				new Rectangle(0, 0, Projectile.ROT_GLOW[0] * QUALITY, Projectile.ROT_GLOW[1] * QUALITY), 
				new     Point(      Projectile.ROT_GLOW[2] * QUALITY, Projectile.ROT_GLOW[3] * QUALITY)
			);

			laserMovieClip.removeChildAt(ROT_GLOW_INDEX);

			// loop through every frame in the movie clip to draw every bullet
			for(var i:uint = laserMovieClip.currentFrame; i <= laserMovieClip.totalFrames; i++){
				if(i === Projectile.INVISIBLE_BULLET)       continue;
				if(Projectile.RAILS_INDEX.indexOf(i) != -1) continue;   // dont draw if bullet index is rail type.

				laserMovieClip.gotoAndStop(i);

				var startX: Number  = Projectile.Atlas[i-1][2];
				var startY: Number  = Projectile.Atlas[i-1][3];
				var width:  Number  = Projectile.Atlas[i-1][0];
				var height: Number  = Projectile.Atlas[i-1][1];

				var startPoint:Point = new Point(startX * QUALITY, startY * QUALITY);
				atlasBmp.copyPixels(AcceleratedRenderer.rasterize(laserMovieClip, QUALITY), new Rectangle(0, 0, width * QUALITY, height * QUALITY), startPoint);
			}

			tex_projectile = c3d.createRectangleTexture(atlasBmp.width, atlasBmp.height, Context3DTextureFormat.BGRA, false);
			tex_projectile.uploadFromBitmapData(atlasBmp);
			atlasBmp.dispose(); 
		}

		private function reorderRotGlow() : void {
			// if instance of RenderProjectiles is not rendering energy projectiles, return.
			if(class_to_render.indexOf(Projectile.ENERGY) == -1) return;

			const u:Number       =     Projectile.ROT_GLOW[2] / Projectile.ATLAS_WIDTH;
			const v:Number       =     Projectile.ROT_GLOW[3] / Projectile.ATLAS_HEIGHT;
			const end_u:Number   = u + Projectile.ROT_GLOW[0] / Projectile.ATLAS_WIDTH;
			const end_v:Number   = v + Projectile.ROT_GLOW[1] / Projectile.ATLAS_HEIGHT;

			var vertexBufferOffset:uint = 0;
			var vertexOffset:uint       = 0;
			var indexOffset:uint        = 0;

			// Sets up rot glow indices and vertexes
			glow_count = 0;
			for each(var bullet: Object in bullets){
				if (!bullet || !bullet.visible || bullet.cclass != Projectile.ENERGY) // the array sets the 1st element to null when cycling thru 64 bullets.
					continue;

				glow_count++;

				var x: Number = bullet.x;
				var y: Number = bullet.y;

				var half_width:Number  = Projectile.ROT_GLOW[0] / 2 * bullet.scaleX;
				var half_height:Number = Projectile.ROT_GLOW[1] / 2 * bullet.scaleY;

				vtx_rot_glow_vec[vertexBufferOffset +  0]  = x - half_width;
				vtx_rot_glow_vec[vertexBufferOffset +  1]  = y - half_height;
				vtx_rot_glow_vec[vertexBufferOffset +  2]  = u;
				vtx_rot_glow_vec[vertexBufferOffset +  3]  = v;

				vtx_rot_glow_vec[vertexBufferOffset +  4]  = x + half_width;
				vtx_rot_glow_vec[vertexBufferOffset +  5]  = y - half_height;
				vtx_rot_glow_vec[vertexBufferOffset +  6]  = end_u;
				vtx_rot_glow_vec[vertexBufferOffset +  7]  = v;

				vtx_rot_glow_vec[vertexBufferOffset +  8]  = x + half_width;
				vtx_rot_glow_vec[vertexBufferOffset +  9]  = y + half_height;
				vtx_rot_glow_vec[vertexBufferOffset + 10]  = end_u;
				vtx_rot_glow_vec[vertexBufferOffset + 11]  = end_v;

				vtx_rot_glow_vec[vertexBufferOffset + 12]  = x - half_width;
				vtx_rot_glow_vec[vertexBufferOffset + 13]  = y + half_height;
				vtx_rot_glow_vec[vertexBufferOffset + 14]  = u;
				vtx_rot_glow_vec[vertexBufferOffset + 15]  = end_v;

				idx_rot_glow_vec[vertexOffset + 0] = indexOffset + 0;
				idx_rot_glow_vec[vertexOffset + 1] = indexOffset + 1;
				idx_rot_glow_vec[vertexOffset + 2] = indexOffset + 2;
				idx_rot_glow_vec[vertexOffset + 3] = indexOffset + 2;
				idx_rot_glow_vec[vertexOffset + 4] = indexOffset + 3;
				idx_rot_glow_vec[vertexOffset + 5] = indexOffset + 0;

				vertexBufferOffset += ROT_GLOW_VERTEX_SIZE * 4;
				vertexOffset       += 6;
				indexOffset        += 4;   
			}
			if(glow_count == 0) return;

			// Clear up unused indices (or else it will crash)
			for (var i:int = glow_count; i < max_bullets; i++) {
				idx_rot_glow_vec[i*6 + 0] = 0;
				idx_rot_glow_vec[i*6 + 1] = 0;
				idx_rot_glow_vec[i*6 + 2] = 0;
				idx_rot_glow_vec[i*6 + 3] = 0;
				idx_rot_glow_vec[i*6 + 4] = 0;
				idx_rot_glow_vec[i*6 + 5] = 0;
			}

			idx_rot_glow.uploadFromVector(idx_rot_glow_vec, 0, MAX_PROJECTILE_INDICES);
			vtx_rot_glow.uploadFromVector(vtx_rot_glow_vec, 0, MAX_PROJECTILE_VERTICES);
		}

		private function reorderBullets() : void {
			const DATA:Vector.<Vector.<Number>>  = Projectile.Atlas;

			bullet_count = 0;
			var bullet:Object;
			for each(bullet in bullets) {
				if(!bullet || !bullet.visible || !toRenderClass(bullet.cclass)) continue;
				bullet_count++;
			}
			if (bullet_count == 0) return;
			
			// sets up rot glow first
			reorderRotGlow();

			var vertexBufferOffset:uint = 0;
			var vertexOffset:uint       = 0;
			var indexOffset:uint        = 0;

			for each(bullet in bullets) {
				if(!bullet) continue;
				// trace("x: " + bullet.x + " y: " + bullet.y + " visible?: " + bullet.visible);

				// the array sets the 1st element to null when cycling thru 64 bullets.
				if(!bullet || !bullet.visible || !toRenderClass(bullet.cclass)) continue;

				// Cache MovieClip properties
				var x: Number        = bullet.x;
				var y: Number        = bullet.y;
				var rotation: Number = bullet.rotation * DEG_TO_RAD;
				var currentFrame:int = bullet.currentFrame;


				var half_width:Number   =     DATA[currentFrame - 1][0] / 2 * bullet.scaleX;
				var half_height:Number  =     DATA[currentFrame - 1][1] / 2 * bullet.scaleY;
				var u:Number            =     DATA[currentFrame - 1][2] / Projectile.ATLAS_WIDTH;
				var v:Number            =     DATA[currentFrame - 1][3] / Projectile.ATLAS_HEIGHT;
				var end_u:Number        = u + DATA[currentFrame - 1][0] / Projectile.ATLAS_WIDTH;
				var end_v:Number        = v + DATA[currentFrame - 1][1] / Projectile.ATLAS_HEIGHT;

				vtx_projectile_vec[vertexBufferOffset +  0] = x - half_width;  // x
				vtx_projectile_vec[vertexBufferOffset +  1] = y - half_height; // y
				vtx_projectile_vec[vertexBufferOffset +  2] = u;               // u
				vtx_projectile_vec[vertexBufferOffset +  3] = v;               // v
				vtx_projectile_vec[vertexBufferOffset +  4] = x;               // centerX
				vtx_projectile_vec[vertexBufferOffset +  5] = y;               // centerY
				vtx_projectile_vec[vertexBufferOffset +  6] = rotation;        // rotation

				vtx_projectile_vec[vertexBufferOffset +  7] = x + half_width;  // x
				vtx_projectile_vec[vertexBufferOffset +  8] = y - half_height; // y
				vtx_projectile_vec[vertexBufferOffset +  9] = end_u;           // u
				vtx_projectile_vec[vertexBufferOffset + 10] = v;               // v
				vtx_projectile_vec[vertexBufferOffset + 11] = x;               // centerX
				vtx_projectile_vec[vertexBufferOffset + 12] = y;               // centerY
				vtx_projectile_vec[vertexBufferOffset + 13] = rotation;        // rotation

				vtx_projectile_vec[vertexBufferOffset + 14] = x + half_width;  // x
				vtx_projectile_vec[vertexBufferOffset + 15] = y + half_height; // y
				vtx_projectile_vec[vertexBufferOffset + 16] = end_u;           // u
				vtx_projectile_vec[vertexBufferOffset + 17] = end_v;           // v
				vtx_projectile_vec[vertexBufferOffset + 18] = x;               // centerX
				vtx_projectile_vec[vertexBufferOffset + 19] = y;               // centerY
				vtx_projectile_vec[vertexBufferOffset + 20] = rotation;        // rotation

				vtx_projectile_vec[vertexBufferOffset + 21] = x - half_width;  // x
				vtx_projectile_vec[vertexBufferOffset + 22] = y + half_height; // y
				vtx_projectile_vec[vertexBufferOffset + 23] = u;               // u
				vtx_projectile_vec[vertexBufferOffset + 24] = end_v;           // v
				vtx_projectile_vec[vertexBufferOffset + 25] = x;               // centerX
				vtx_projectile_vec[vertexBufferOffset + 26] = y;               // centerY
				vtx_projectile_vec[vertexBufferOffset + 27] = rotation;        // rotation


				idx_projectile_vec[vertexOffset + 0] = indexOffset + 0;
				idx_projectile_vec[vertexOffset + 1] = indexOffset + 1;
				idx_projectile_vec[vertexOffset + 2] = indexOffset + 2;
				idx_projectile_vec[vertexOffset + 3] = indexOffset + 2;
				idx_projectile_vec[vertexOffset + 4] = indexOffset + 3;
				idx_projectile_vec[vertexOffset + 5] = indexOffset + 0;

				vertexBufferOffset += PROJECTILE_VERTEX_SIZE * 4;
				vertexOffset       += 6;
				indexOffset        += 4;
			}

			// Clear up unused indices (or else it will crash)
			// even though we wouldn't actually use them,
			// since the .drawTriangles count is low enough -_-
			for (var i:int = bullet_count; i < max_bullets; i++) {
				idx_projectile_vec[i*6 + 0] = 0;
				idx_projectile_vec[i*6 + 1] = 0;
				idx_projectile_vec[i*6 + 2] = 0;
				idx_projectile_vec[i*6 + 3] = 0;
				idx_projectile_vec[i*6 + 4] = 0;
				idx_projectile_vec[i*6 + 5] = 0;
			}

			idx_projectile.uploadFromVector(idx_projectile_vec, 0, MAX_PROJECTILE_INDICES);
			vtx_projectile.uploadFromVector(vtx_projectile_vec, 0, MAX_PROJECTILE_VERTICES);
		}

		private function resizeBuffers(new_max:uint) : void {
			max_bullets = new_max;

			MAX_PROJECTILE_INDICES  = new_max * 6;
			MAX_PROJECTILE_VERTICES = new_max * 4;

			idx_projectile_vec = new Vector.<uint>(MAX_PROJECTILE_INDICES);
			idx_projectile     = c3d.createIndexBuffer(MAX_PROJECTILE_INDICES, Context3DBufferUsage.DYNAMIC_DRAW);

			vtx_projectile_vec = new Vector.<Number>(MAX_PROJECTILE_VERTICES * PROJECTILE_VERTEX_SIZE);
			vtx_projectile     = c3d.createVertexBuffer(MAX_PROJECTILE_VERTICES, PROJECTILE_VERTEX_SIZE, Context3DBufferUsage.DYNAMIC_DRAW);


			idx_rot_glow_vec = new Vector.<uint>(MAX_PROJECTILE_INDICES);
			idx_rot_glow     = c3d.createIndexBuffer(MAX_PROJECTILE_INDICES, Context3DBufferUsage.DYNAMIC_DRAW); 

			vtx_rot_glow_vec = new Vector.<Number>(MAX_PROJECTILE_VERTICES * ROT_GLOW_VERTEX_SIZE);
			vtx_rot_glow     = c3d.createVertexBuffer(MAX_PROJECTILE_VERTICES, ROT_GLOW_VERTEX_SIZE, Context3DBufferUsage.DYNAMIC_DRAW);
		}

		public function setup() : void {
			bullets = game.puls;
			glow_count = 0;

			resizeBuffers(game.pulsmax);
		}

		public function render(mainTransform: Matrix3D, pass:uint) : void {
			if (game.pulsmax > max_bullets) resizeBuffers(game.pulsmax);

			// Sets up the index & vertex buffer again due to changing number of bullets and it's properties.
			class_to_render = render_pass_classes[pass];

			reorderBullets();
			if(bullet_count == 0) return;

			c3d.setTextureAt(0, tex_projectile);

			// Render rot glow first. (unfortunately i need to set another draw call because rot_glow blends differently from the actual projectile.)
			if(glow_count != 0){
				c3d.setProgram(rotGlowShader);
				c3d.setVertexBufferAt(0, vtx_rot_glow, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
				c3d.setVertexBufferAt(1, vtx_rot_glow, 2, Context3DVertexBufferFormat.FLOAT_2); // va1 is texture coords (uv)
				c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE);
				c3d.drawTriangles(idx_rot_glow, 0, glow_count * 2);
			}

			// Render projectiles
			c3d.setProgram(projectileShader);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mainTransform, true);
			c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, cts_projectile);
			c3d.setVertexBufferAt(0, vtx_projectile, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
			c3d.setVertexBufferAt(1, vtx_projectile, 2, Context3DVertexBufferFormat.FLOAT_2); // va1 is texture coords (uv)
			c3d.setVertexBufferAt(2, vtx_projectile, 4, Context3DVertexBufferFormat.FLOAT_2); // va2 is center coords (xy)
			c3d.setVertexBufferAt(3, vtx_projectile, 6, Context3DVertexBufferFormat.FLOAT_1); // va3 is rotation
			c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			c3d.drawTriangles(idx_projectile, 0, bullet_count * 2);

			c3d.setTextureAt(0, null);
			c3d.setVertexBufferAt(1, null);
			c3d.setVertexBufferAt(2, null);
			c3d.setVertexBufferAt(3, null);
		}

		public function free() : void{
			if (idx_projectile != null) {
				idx_projectile.dispose();
				vtx_projectile = null;
			}
			if (vtx_projectile != null) {
				vtx_projectile.dispose();
				vtx_projectile = null;
			}
		}
	}
}