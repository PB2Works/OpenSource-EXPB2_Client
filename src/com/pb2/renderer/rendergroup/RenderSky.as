package com.pb2.renderer.rendergroup{

    import com.pb2.PB2Game;
    import flash.display3D.*;
    import flash.geom.Matrix3D;

	// For textures
	import flash.display3D.textures.RectangleTexture;
	import flash.display.BitmapData;
	import com.pb2.renderer.AcceleratedRenderer;

    public class RenderSky implements IRenderGroup{
        public static const name:String = "Sky";
        
		public var game:PB2Game;
		public var c3d:Context3D;
		private var shaderProgram:Program3D;
		private var matrix:Matrix3D;

		private var tex_sky:RectangleTexture;
		private var idx_sky:IndexBuffer3D;
		private var vtx_sky:VertexBuffer3D;
		private const vtx_sky_sz:int = 4;
		private var idx_sky_vec:Vector.<uint>;
		private var vtx_sky_vec:Vector.<Number>;
        
		public function getName() : String {
            return name;
        }

        public function RenderSky(game:PB2Game, c3d:Context3D, shaderProgram: Program3D, projection:Matrix3D) : void{
            this.shaderProgram = shaderProgram;
            this.game = game;
            this.c3d = c3d;

			idx_sky_vec = new <uint>[
				0, 1, 2,
				2, 3, 0,
			];
			idx_sky = c3d.createIndexBuffer( idx_sky_vec.length );
			idx_sky.uploadFromVector( idx_sky_vec, 0, idx_sky_vec.length );
			
			vtx_sky_vec = new <Number>
				[
				 // x,   y,   s, t
					0,   0,   0, 0,
					800, 0,   1, 0,
					800, 400, 1, 1,
					0,   400, 0, 1,
				];
			vtx_sky = c3d.createVertexBuffer( vtx_sky_vec.length / vtx_sky_sz, vtx_sky_sz );
			vtx_sky.uploadFromVector( vtx_sky_vec, 0, vtx_sky_vec.length / vtx_sky_sz );

			matrix = projection;
        }

        public function setup() : void{
            var bmp:BitmapData = AcceleratedRenderer.rasterize(game.sky);
			tex_sky = c3d.createRectangleTexture(800, 400, Context3DTextureFormat.BGRA, false);
			tex_sky.uploadFromBitmapData(bmp);
			bmp.dispose();
        }

        public function render(mainTransform: Matrix3D, pass:uint) : void{
            c3d.setProgram(shaderProgram);
			c3d.setTextureAt(0, tex_sky);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);
			c3d.setVertexBufferAt(0, vtx_sky, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
			c3d.setVertexBufferAt(1, vtx_sky, 2, Context3DVertexBufferFormat.FLOAT_2); // va1 is texture coordinates (st)
			c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			c3d.drawTriangles(idx_sky, 0, 2);

			c3d.setTextureAt(0, null);
			c3d.setVertexBufferAt(1, null);
        }

        public function free() : void{
            if (tex_sky != null) {
				tex_sky.dispose();
				tex_sky = null;
			}
        }
    }
}