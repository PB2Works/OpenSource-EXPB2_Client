package com.pb2.renderer.rendergroup{

    import com.pb2.PB2Game;
    import flash.display3D.*;
    import flash.geom.Matrix3D;

	// For textures
	import flash.display3D.textures.RectangleTexture;
	import flash.display.BitmapData;
	import com.pb2.renderer.AcceleratedRenderer;

    public class RenderShadowmap implements IRenderGroup{
        public static const name:String = "Shadowmap";
        
		private var game:PB2Game;
		private var c3d:Context3D;

		private var shadowBitmap:BitmapData;

		private var shaderProgram:Program3D;

		private var tex_shadowmap:RectangleTexture;
		private var idx_shadowmap:IndexBuffer3D;
		private var vtx_shadowmap:VertexBuffer3D;
		private const vtx_shadowmap_sz:int = 4;
        
		public function getName() : String {
            return name;
        }

        public function RenderShadowmap(game:PB2Game, c3d:Context3D, shaderProgram:Program3D) : void{
            this.shaderProgram = shaderProgram;
            this.game = game;
            this.c3d = c3d;

			var indexBuffer:Vector.<uint> = new <uint>[
				0, 1, 2,
				2, 3, 0,
			];
			idx_shadowmap = c3d.createIndexBuffer(indexBuffer.length, Context3DBufferUsage.STATIC_DRAW);
			idx_shadowmap.uploadFromVector(indexBuffer, 0, 2 * 3);

			vtx_shadowmap = c3d.createVertexBuffer(4, vtx_shadowmap_sz, Context3DBufferUsage.STATIC_DRAW);
        }

        private function updateTexture() : void {
        	shadowBitmap = game.shadowbmp.bitmapData;
        	if (tex_shadowmap == null)
				tex_shadowmap = c3d.createRectangleTexture(shadowBitmap.width, shadowBitmap.height, Context3DTextureFormat.BGRA, false);
			tex_shadowmap.uploadFromBitmapData(shadowBitmap);
        }

        public function setup() : void {
			if (!game.HQ) return;

            var x:Number = game.shadowbmp.x;
			var y:Number = game.shadowbmp.y;
			var w:Number = game.shadowbmp.width;
			var h:Number = game.shadowbmp.height;
			
			var vertexBuffer:Vector.<Number> = new <Number>
			[
			 // x,     y,     s, t
				x,     y,     0, 0,
				x + w, y,     1, 0,
				x + w, y + h, 1, 1,
				x,     y + h, 0, 1,
			];
			vtx_shadowmap.uploadFromVector(vertexBuffer, 0, 4);

			updateTexture();
        }

        public function render(mainTransform: Matrix3D, pass:uint) : void {
			if (!game.HQ) 									return;
        	if (shadowBitmap != game.shadowbmp.bitmapData) 	updateTexture();

            c3d.setProgram(shaderProgram);
			c3d.setTextureAt(0, tex_shadowmap);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mainTransform, true);
			c3d.setVertexBufferAt(0, vtx_shadowmap, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
			c3d.setVertexBufferAt(1, vtx_shadowmap, 2, Context3DVertexBufferFormat.FLOAT_2); // va1 is texture coordinates (st)
			c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			c3d.drawTriangles(idx_shadowmap, 0, 2);

			c3d.setTextureAt(0, null);
			c3d.setVertexBufferAt(1, null);
        }

        public function free() : void{
            if (tex_shadowmap != null) {
				tex_shadowmap.dispose();
				tex_shadowmap = null;
			}
        }
    }
}