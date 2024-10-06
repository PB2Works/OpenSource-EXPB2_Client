package com.pb2.renderer.rendergroup{

	import com.pb2.PB2Door;
	import com.pb2.PB2Game;
	import flash.display3D.*;
	import flash.geom.Matrix3D;

	public class RenderDoors implements IRenderGroup{
		public static const name:String = "Doors";

		public var game:PB2Game;
		public var c3d:Context3D;
		private var shaderProgram:Program3D;

		private var idx_door:IndexBuffer3D;
		private var vtx_door:VertexBuffer3D;
		private var idx_door_vec:Vector.<uint>;
		private var vtx_door_vec:Vector.<Number>
		
		public function getName() : String {
			return name;
		}

		public function RenderDoors(game:PB2Game, c3d:Context3D, shaderProgram: Program3D) : void{
			this.shaderProgram = shaderProgram;
			this.game = game;
			this.c3d = c3d;
		}

		// Creates the inital vertex and index buffer that will be used for every door.
		public function setup() : void{
			// 1. Vector of indices for doors. Ensuring that indices are unique per doors.
			// A door is a rectangle, consisting of 2 triangles. Therefore we need 6 indices, 3 per triangle.
			idx_door_vec = new Vector.<uint>();

			var indexOffset:uint = 0;
			for each(var door:PB2Door in game.doors){
				if(!door.vis) continue;

				idx_door_vec = idx_door_vec.concat(new <uint>[
					indexOffset + 0,
					indexOffset + 1,
					indexOffset + 2,
					indexOffset + 2,
					indexOffset + 3,
					indexOffset + 0
				])

				indexOffset += 4;
			}

			const VERTEX_SIZE:uint = 5; // x, y
			const NUMOFINDICES:uint = idx_door_vec.length;

			// Create a index buffer to be used for every door.
			idx_door = c3d.createIndexBuffer(NUMOFINDICES, Context3DBufferUsage.STATIC_DRAW);
			idx_door.uploadFromVector(idx_door_vec, 0, NUMOFINDICES);

			// Create a vertex buffer based on how many doors we have on the map.
			const NUMOFVERTICES:uint = idx_door_vec.length / 6 * 4;	// every 6 indices represents 4 indices.

			vtx_door_vec = new Vector.<Number>(NUMOFVERTICES * VERTEX_SIZE);
			vtx_door = c3d.createVertexBuffer(NUMOFVERTICES, VERTEX_SIZE, Context3DBufferUsage.DYNAMIC_DRAW);	
		}

        public function render(mainTransform: Matrix3D, pass:uint) : void{
            const VERTEX_SIZE:uint = 5;
			c3d.setProgram(shaderProgram);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mainTransform, true);
			c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);

			var offset:uint = 0;
			for each(var door:PB2Door in game.doors){
				if (!door.vis) continue;

				// Top left vertex
				vtx_door_vec[offset +  0] = door.x;
				vtx_door_vec[offset +  1] = door.y;
				vtx_door_vec[offset +  2] = door.color[0];
				vtx_door_vec[offset +  3] = door.color[1];
				vtx_door_vec[offset +  4] = door.color[2];

				// Top right vertex
				vtx_door_vec[offset +  5] = door.x + door.w;
				vtx_door_vec[offset +  6] = door.y;
				vtx_door_vec[offset +  7] = door.color[0];
				vtx_door_vec[offset +  8] = door.color[1];
				vtx_door_vec[offset +  9] = door.color[2];

				// Bottom right vertex
				vtx_door_vec[offset + 10] = door.x + door.w;
				vtx_door_vec[offset + 11] = door.y + door.h;
				vtx_door_vec[offset + 12] = door.color[0];
				vtx_door_vec[offset + 13] = door.color[1];
				vtx_door_vec[offset + 14] = door.color[2];

				// Bottom left vertex
				vtx_door_vec[offset + 15] = door.x;
				vtx_door_vec[offset + 16] = door.y + door.h;
				vtx_door_vec[offset + 17] = door.color[0];
				vtx_door_vec[offset + 18] = door.color[1];
				vtx_door_vec[offset + 19] = door.color[2];

				offset += VERTEX_SIZE * 4;
			}

			const NUMOFVERTICES:uint = vtx_door_vec.length / VERTEX_SIZE;
			vtx_door.uploadFromVector(vtx_door_vec, 0, NUMOFVERTICES);

			c3d.setVertexBufferAt(0, vtx_door, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
			c3d.setVertexBufferAt(1, vtx_door, 2, Context3DVertexBufferFormat.FLOAT_3); // va0 is position (rgb)
			c3d.drawTriangles(idx_door);

			c3d.setVertexBufferAt(1, null); 
		}

		public function free() : void{
			if (idx_door != null) {
				idx_door.dispose();
				idx_door = null;
			}
			if (vtx_door != null) {
				vtx_door.dispose();
				vtx_door = null;
			}
		}
	}
}