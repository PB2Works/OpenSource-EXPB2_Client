package com.pb2.renderer.rendergroup{

    import com.pb2.PB2Game;
    import flash.display3D.*;
    import flash.geom.Matrix3D;
    import com.pb2.PB2Water;

    public class RenderWaters implements IRenderGroup{
        public static const name:String = "Waters";
		public var game:PB2Game;
		public var c3d:Context3D;
		private var shaderProgram:Program3D;

        private var idx_water:IndexBuffer3D;
		private var vtx_water:VertexBuffer3D;
		private var idx_water_vec:Vector.<uint>;
		private var vtx_water_vec:Vector.<Number>;
        
		public function getName() : String {
            return name;
        }

        public function RenderWaters(game:PB2Game, c3d:Context3D, shaderProgram: Program3D) : void{
            this.shaderProgram = shaderProgram;
            this.game = game;
            this.c3d = c3d;
        }

        // Creates the inital vertex and index buffer that will be used for every door.
        public function setup() : void{
			var waterCount:uint = 0;
			idx_water_vec = new Vector.<uint>();
			vtx_water_vec = new Vector.<Number>();

			for each(var water:PB2Water in game.waterList){
				if(!water.friction) continue;

				// Create vector of indices for every water, offsetting the index for subsequent boxes.
				idx_water_vec = idx_water_vec.concat(new <uint>[
						waterCount + 0,
						waterCount + 1,
						waterCount + 2,
						waterCount + 2,
						waterCount + 3,
						waterCount + 0,
				]);

				// Create vector of vertices for every water. Storing color attribute in vertex so only one draw call is needed.
				vtx_water_vec = vtx_water_vec.concat(new <Number>[
					//x					y					r,				g				b				a
					water.x,			water.y,			water.color[0],	water.color[1],	water.color[2],	1,
					water.x + water.w,	water.y,			water.color[0],	water.color[1],	water.color[2],	1,
					water.x + water.w,	water.y + water.h,	water.color[0],	water.color[1],	water.color[2], 1,
					water.x,			water.y + water.h,	water.color[0],	water.color[1],	water.color[2], 1
				]);

				waterCount += 4;	// 4 unique indices per water.
			}

			const VERTEX_SIZE:uint = 6; // x, y, r, g, b, 
			const NUMOFINDICES:uint = idx_water_vec.length;

			if(NUMOFINDICES != 0){
				// Create a index buffer to be used for every water.
				idx_water = c3d.createIndexBuffer(NUMOFINDICES, Context3DBufferUsage.STATIC_DRAW);
				idx_water.uploadFromVector(idx_water_vec, 0, NUMOFINDICES);
			}		
        }

        // TODO: Optimise rendering by checking previous rendered doors and comparing whether x and y coordinate & color has changed.
		// This will reduce the need of recreating Vector and uploadFromVector.
        public function render(mainTransform: Matrix3D, pass:uint) : void{
			if(idx_water_vec.length == 0) return;

			const VERTEX_SIZE:uint = 6; // x, y, r, g, b, 
			const NUMOFVERTICES:uint = vtx_water_vec.length / VERTEX_SIZE;

			var vertexOffset:uint = 0;
			// continuously update the rgb value of vertex buffer.
			for each(var water:PB2Water in game.waterList){
				if(!water.friction) continue;
				
				// A water has 4 vertices to update.
				for(var i:uint = 0; i < 4; i++){
					vtx_water_vec[vertexOffset + 2] = water.color[0];	// R
					vtx_water_vec[vertexOffset + 3] = water.color[1];	// G
					vtx_water_vec[vertexOffset + 4] = water.color[2];	// B
					vertexOffset += 6;
				}
			}

			vtx_water = c3d.createVertexBuffer(NUMOFVERTICES, VERTEX_SIZE, Context3DBufferUsage.DYNAMIC_DRAW);	
			vtx_water.uploadFromVector(vtx_water_vec, 0, NUMOFVERTICES);

			c3d.setProgram(shaderProgram);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mainTransform, true);
			c3d.setVertexBufferAt(0, vtx_water, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
			c3d.setVertexBufferAt(1, vtx_water, 2, Context3DVertexBufferFormat.FLOAT_4); // va1 is color rgba
			c3d.setBlendFactors(Context3DBlendFactor.DESTINATION_COLOR, Context3DBlendFactor.ZERO);
			c3d.drawTriangles(idx_water, 0);
        }

        public function free() : void{
            if (idx_water != null) {
				idx_water.dispose();
				idx_water = null;
			}
			if (vtx_water != null) {
				vtx_water.dispose();
				vtx_water = null;
			}
        }
    }
}