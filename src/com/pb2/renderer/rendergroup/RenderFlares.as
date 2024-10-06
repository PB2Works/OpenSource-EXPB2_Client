package com.pb2.renderer.rendergroup{

    import com.pb2.PB2Game;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.IGraphicsData;
	import flash.display.GraphicsBitmapFill;
	import flash.geom.Rectangle;
	import flash.geom.Point;
    import flash.display3D.*;
    import flash.geom.Matrix3D;

	// For textures
	import flash.display3D.textures.RectangleTexture;
	import flash.display.BitmapData;
	import com.pb2.renderer.AcceleratedRenderer;

    public class RenderFlares implements IRenderGroup {
        public static const name:String = "Flares";
        
		public var game:PB2Game;
		public var c3d:Context3D;
		private var shaderProgram:Program3D;
		private var atlasBitmap:BitmapData;

		private var tex_flares:RectangleTexture;
		private var idx_flares:IndexBuffer3D;
		private var vtx_flares:VertexBuffer3D;
		private var vtx_flares_vec:Vector.<Number>;

		private static const N_FLARES:uint = 6;

		private var flares:Array;
		private var flarestotal:int;

		private static const atlasCoords:Vector.<uint> = new <uint>[
			0  ,   0, // f1
			30 , 149, // f2
			150,  77, // f3
			47 , 149, // f4
			0  , 149, // f5
			150,   0  // f6
		];

		private var flareSizes:Vector.<Number>;

		private static const childNames:Vector.<String> = new <String>["f1", "f2", "f3", "f4", "f5", "f6"];
        
		public function getName() : String {
            return name;
        }

        public function RenderFlares(game:PB2Game, c3d:Context3D, shaderProgram: Program3D) : void{
            this.shaderProgram = shaderProgram;
            this.game = game;
            this.c3d = c3d;

			var indexBuffer:Vector.<uint> = new <uint>[
				// f1
				0,   1,  2,
				2,   3,  0,

				// f2
				4,   5,  6,
				6,   7,  4,

				// f3
				8,   9, 10,
				10, 11,  8,

				// f4
				12, 13, 14,
				14, 15, 12,

				// f5
				16, 17, 18,
				18, 19, 16,

				// f6
				20, 21, 22,
				22, 23, 20,
			];

			idx_flares = c3d.createIndexBuffer(indexBuffer.length, Context3DBufferUsage.STATIC_DRAW);
			idx_flares.uploadFromVector(indexBuffer, 0, indexBuffer.length);

			vtx_flares_vec = new Vector.<Number>(4 * 4 * N_FLARES);

			const atlasWidth:Number = 150 + 78;
			const atlasHeight:Number = 149 + 29;
			flareSizes = new Vector.<Number>(N_FLARES * 2);
			atlasBitmap = new BitmapData(atlasWidth, atlasHeight, true, 0);
			var mc:MovieClip = new lens_flare();
			game.addChild(mc);
			var fromRect:Rectangle = new Rectangle();
			var toPoint:Point = new Point(); 
			fromRect.x = 0;
			fromRect.y = 0;
			for (var i:int = 0; i < N_FLARES; i++) {
				var tid:int  = i * 2;
				var vid:int  = i * 16;
				var flare:MovieClip = mc.getChildByName(childNames[i]) as MovieClip;
				var shape:Shape = flare.getChildAt(0) as Shape;
				for each (var graphicsData:IGraphicsData in shape.graphics.readGraphicsData()) {
					if (!(graphicsData is GraphicsBitmapFill)) continue;
					var bmp:BitmapData = (graphicsData as GraphicsBitmapFill).bitmapData;

					var x:Number = atlasCoords[tid + 0];
					var y:Number = atlasCoords[tid + 1];
					var w:Number = bmp.width;
					var h:Number = bmp.height;
					var tx:Number = x / atlasWidth;
					var ty:Number = y / atlasHeight;
					var tw:Number = w / atlasWidth;
					var th:Number = h / atlasHeight;

					fromRect.width  = w;
					fromRect.height = h;

					toPoint.x = x;
					toPoint.y = y;

					flareSizes[tid] = w;
					flareSizes[tid + 1] = h;

					// TOP LEFT
					vtx_flares_vec[vid + 2]  = tx;
					vtx_flares_vec[vid + 3]  = ty;

					// TOP RIGHT
					vtx_flares_vec[vid + 6]  = tx + tw;
					vtx_flares_vec[vid + 7]  = ty;

					// BOTTOM RIGHT
					vtx_flares_vec[vid + 10] = tx + tw;
					vtx_flares_vec[vid + 11] = ty + th;

					// BOTTOM LEFT
					vtx_flares_vec[vid + 14] = tx;
					vtx_flares_vec[vid + 15] = ty + th;

					atlasBitmap.copyPixels(bmp, fromRect, toPoint);
					bmp.dispose();
					break;
				}
			}

			game.removeChild(mc);
			vtx_flares = c3d.createVertexBuffer(N_FLARES * 4, 4, Context3DBufferUsage.DYNAMIC_DRAW);
        }

        public function setup() : void {
            if (tex_flares == null)
				tex_flares = c3d.createRectangleTexture(atlasBitmap.width, atlasBitmap.height, Context3DTextureFormat.BGRA, false);
			tex_flares.uploadFromBitmapData(atlasBitmap);

			flares = game.flare;
			flarestotal = game.flarestotal;
        }

        // draw order: f1 -> f6
        private var cts_flares_vec:Vector.<Number> = new <Number>[1, 1, 1, 1];
        public function render(mainTransform: Matrix3D, pass:uint) : void{
            c3d.setProgram(shaderProgram);
			c3d.setTextureAt(0, tex_flares);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mainTransform, true);
			c3d.setVertexBufferAt(0, vtx_flares, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
			c3d.setVertexBufferAt(1, vtx_flares, 2, Context3DVertexBufferFormat.FLOAT_2); // va1 is texture coordinates (st)
			c3d.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE); // Additive with alpha factor

			for (var i:int = 0; i < flarestotal; i++) {
				var mc:MovieClip = game.flare[i];
				if (!mc.visible || mc.scaleX == 0) continue;

				for (var j:int = 0; j < N_FLARES; j++) {
					var k:int = j * 16;
					var mc2:MovieClip = mc.getChildByName(childNames[j]) as MovieClip;
					var w:Number = flareSizes[j * 2];
					var h:Number = flareSizes[j * 2 + 1];
					var x:Number = mc.x + mc2.x - w / 2;
					var y:Number = mc.y + mc2.y - h / 2;

					// TOP LEFT
					vtx_flares_vec[k + 0]  = x;
					vtx_flares_vec[k + 1]  = y;

					// TOP RIGHT
					vtx_flares_vec[k + 4]  = x + w;
					vtx_flares_vec[k + 5]  = y;

					// BOTTOM RIGHT
					vtx_flares_vec[k + 8]  = x + w;
					vtx_flares_vec[k + 9]  = y + h;

					// BOTTOM LEFT
					vtx_flares_vec[k + 12] = x;
					vtx_flares_vec[k + 13] = y + h;
				}

				cts_flares_vec[3] = mc.alpha;
				c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, cts_flares_vec);
				vtx_flares.uploadFromVector(vtx_flares_vec, 0, 4 * N_FLARES);
				c3d.drawTriangles(idx_flares, 0);
			}

			c3d.setTextureAt(0, null);
			c3d.setVertexBufferAt(1, null);
        }

        public function free() : void {
            if (tex_flares != null) {
				tex_flares.dispose();
				tex_flares = null;
			}
        }
    }
}