package com.pb2.renderer.rendergroup{

    import com.pb2.PB2Game;
    import flash.display3D.*;
    import flash.geom.Matrix3D;

	// For textures
	import flash.display3D.textures.RectangleTexture;
	import flash.display.BitmapData;

    public class RenderBackgrounds implements IRenderGroup{
        public static const name:String = "Backgrounds";
        
		public var game:PB2Game;
		public var c3d:Context3D;
		private var shaderProgram:Program3D;

		// Backgrounds
		private var bmp_bg:Vector.<BitmapData>;
		private const bmp_bg_isz:uint = 17;
		private var tex_bg:Vector.<RectangleTexture>;
		private var idx_bg:IndexBuffer3D;
		private var vtx_bg:VertexBuffer3D;
		private var idx_bg_vec:Vector.<uint>;
		private var vtx_bg_vec:Vector.<Number>;
		private var cts_bg_clr:Vector.<Number>;
		private var bgtx:Vector.<Number>;
		private var bgty:Vector.<Number>;
		private var bgtw:Vector.<Number>;
		private var bgth:Vector.<Number>;
		private var bgt:Vector.<RectangleTexture>;
		private var bgstotal:int;
		private var bgx:Array;
		private var bgy:Array;
		private var bgw:Array;
		private var bgh:Array;
		private var bgm:Array;

		public function getName() : String {
            return name;
        }

        public function RenderBackgrounds(game:PB2Game, c3d:Context3D, shaderProgram: Program3D) : void{
            this.shaderProgram = shaderProgram;
            this.game = game;
            this.c3d = c3d;

			bmp_bg = new Vector.<BitmapData>(bmp_bg_isz);
			bmp_bg[0]  = new panel_tile();
			bmp_bg[1]  = new ground_tile();
			bmp_bg[2]  = new panel2_tile();
			bmp_bg[3]  = new white();
			bmp_bg[4]  = new slider_tile();
			bmp_bg[5]  = new panel3_tile();
			bmp_bg[6]  = new red();
			bmp_bg[7]  = new green();
			bmp_bg[8]  = new blue();
			bmp_bg[9]  = new panel4_tile();
			bmp_bg[10] = new panel5_tile();
			bmp_bg[11] = new panel6_tile();
			bmp_bg[12] = new panel7_tile();
			bmp_bg[13] = new panel8_tile();
			bmp_bg[14] = new pixel_wall();
			bmp_bg[15] = new pixel_bg();
			bmp_bg[16] = new pixel_open_door();
			bgt = new Vector.<RectangleTexture>(bmp_bg_isz);
        }

        public function setup() : void{
			bgstotal = game.bgstotal;
			bgx = game.bgx;
			bgy = game.bgy;
			bgw = game.bgw;
			bgh = game.bgh;
			bgm = game.bgm;
			
			idx_bg_vec = new <uint>[
				0, 1, 2,
				2, 3, 0
			];
			idx_bg = c3d.createIndexBuffer(6, Context3DBufferUsage.STATIC_DRAW);
			idx_bg.uploadFromVector(idx_bg_vec, 0, 6);
			
			vtx_bg_vec = new <Number>[
				0, 0,
				1, 0,
				1, 1,
				0, 1
			];
			vtx_bg = c3d.createVertexBuffer(4, 2, Context3DBufferUsage.STATIC_DRAW);
			vtx_bg.uploadFromVector(vtx_bg_vec, 0, 4);
			
			
			tex_bg = new Vector.<RectangleTexture>(bmp_bg.length);
			bgtw = new Vector.<Number>(bmp_bg.length);
			bgth = new Vector.<Number>(bmp_bg.length);
			bgtx = new Vector.<Number>(bmp_bg.length);
			bgty = new Vector.<Number>(bmp_bg.length);

			// Create texture based on all the bitmaps
			for (var i:int = 0; i < bmp_bg.length; i++) {
				tex_bg[i] = c3d.createRectangleTexture(bmp_bg[i].width, bmp_bg[i].height, Context3DTextureFormat.BGRA, false);
				tex_bg[i].uploadFromBitmapData(bmp_bg[i]);
			}
			
			bgt = new Vector.<RectangleTexture>(bgstotal);
			for (i = 0; i < bgstotal; i++) {
				bgt[i] = tex_bg[bgm[i]];
				bgtx[i] = (bgx[i] - game.bgu[i]) / bmp_bg[bgm[i]].width;
				bgty[i] = (bgy[i] - game.bgv[i]) / bmp_bg[bgm[i]].height;
				bgtw[i] = bgw[i] / bmp_bg[bgm[i]].width;
				bgth[i] = bgh[i] / bmp_bg[bgm[i]].height;
			}
        }

        public function render(mainTransform: Matrix3D, pass:uint) : void{
			var mtx:Matrix3D = new Matrix3D();
			var tmtx:Matrix3D = new Matrix3D();

			c3d.setProgram(shaderProgram);
			c3d.setVertexBufferAt(0, vtx_bg, 0, Context3DVertexBufferFormat.FLOAT_2);
			c3d.setVertexBufferAt(1, vtx_bg, 0, Context3DVertexBufferFormat.FLOAT_2);
			for (var i:int = 0; i < bgstotal; i++) {
				mtx.identity();
				mtx.appendScale(bgw[i], bgh[i], 1.0);
				mtx.appendTranslation(bgx[i], bgy[i], 0.0);
				mtx.append(mainTransform);

				tmtx.identity();
				tmtx.appendScale(bgtw[i], bgth[i], 1.0);
				tmtx.appendTranslation(bgtx[i], bgty[i], 0.0);

				c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mtx, true);
				c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, tmtx, true);
				c3d.setTextureAt(0, bgt[i]);
				c3d.drawTriangles(idx_bg, 0, 2);
			}

			c3d.setTextureAt(0, null);
			c3d.setVertexBufferAt(1, null);
        }

        public function free() : void{
			if (tex_bg != null) {
				for (var i:int = 0; i < tex_bg.length; i++)
					tex_bg[i].dispose();
				tex_bg = null;
			}
			if (idx_bg != null) {
				idx_bg.dispose();
				idx_bg = null;
			}
			if (vtx_bg != null) {
				vtx_bg.dispose();
				vtx_bg = null;
			}
        }
    }
}