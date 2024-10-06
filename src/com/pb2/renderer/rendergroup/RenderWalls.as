package com.pb2.renderer.rendergroup{

    import com.pb2.PB2Wall;
	import com.pb2.renderer.WallTextures;
    import com.pb2.PB2Game;
    import flash.display3D.*;
    import flash.geom.Matrix3D;

    public class RenderWalls implements IRenderGroup{
        public static const name:String = "Walls";

		public var game:PB2Game;
		public var c3d:Context3D;
		private var simpleShader:Program3D;
		private var roughSurfaceShader:Program3D;
		private var regularSurfaceShader:Program3D;

		private var wallTextures:WallTextures = new WallTextures();

		// Walls
		private var idx_wall:IndexBuffer3D;
		private var vtx_wall:VertexBuffer3D;
		private var idx_wall_vec:Vector.<uint>;
		private var vtx_wall_vec:Vector.<Number>;

		// Rough surfaces
		private var idx_rough_wall:IndexBuffer3D;
		private var vtx_rough_wall:VertexBuffer3D;
		private var idx_rough_wall_vec:Vector.<uint>;
		private var vtx_rough_wall_vec:Vector.<Number>;

		// Regular surfaces
		private var idx_reg_wall:IndexBuffer3D;
		private var vtx_reg_wall:VertexBuffer3D;
		private var idx_reg_wall_vec:Vector.<uint>;
		private var vtx_reg_wall_vec:Vector.<Number>;

		// Grass surfaces
		private var idx_grass_wall:IndexBuffer3D;
		private var vtx_grass_wall:VertexBuffer3D;
		private var idx_grass_wall_vec:Vector.<uint>;
		private var vtx_grass_wall_vec:Vector.<Number>;


		public function getName() : String {
            return name;
        }

        public function RenderWalls(game:PB2Game, c3d:Context3D, simpleShader:Program3D, roughSurfaceShader:Program3D, regularSurfaceShader:Program3D) : void{
            this.simpleShader = simpleShader;
			this.roughSurfaceShader = roughSurfaceShader;
			this.regularSurfaceShader = regularSurfaceShader;
            this.game = game;
            this.c3d = c3d;
        }

		// Set up index and vertex buffers for rendering regular walls.
		private function setupRegularWall(box:PB2Wall) : void {
			if(!wallTextures.isRegular(box.mat)) return;

			const ATLAS_WIDTH:uint 			= wallTextures.getRegTextureAtlasWidth();
			const ATLAS_HEIGHT:uint 		= wallTextures.getRegTextureAtlasHeight();

			const SURFACE_LENGTH:Number 	= 120.0 / ATLAS_WIDTH;	// top & bottom width in tex coords.
			const CORNER_LENGTH:Number 		= 12.0 / ATLAS_WIDTH;	// corner width in tex coords.
			const TEXTURE_HEIGHT:Number 	= 16.0 / ATLAS_HEIGHT;

			const textureV:Number 			= 16.0 / ATLAS_HEIGHT * wallTextures.regularIDtoIndex(box.mat); // texture coordinate based on texture.
			const offset:Number 			= box.x / ATLAS_WIDTH;
			const u:Number 					= box.w / ATLAS_WIDTH;

			// Offsets from the left of the texture atlas.
			// First comes the top, then top left, then top right, then bottom, then bottom left and finally bottom right.
			const TOP:Number 				= 0;
			const TOP_LEFT:Number 			= SURFACE_LENGTH;
			const TOP_RIGHT:Number 			= SURFACE_LENGTH + CORNER_LENGTH;
			const BOTTOM:Number 			= SURFACE_LENGTH + 2 * CORNER_LENGTH;
			const BOTTOM_LEFT:Number 		= 2 * SURFACE_LENGTH + 2 * CORNER_LENGTH;
			const BOTTOM_RIGHT:Number 		= 2 * SURFACE_LENGTH + 3 * CORNER_LENGTH;

			const VERTEX_SIZE:uint = 6;
			var indexOffset:uint = vtx_reg_wall_vec.length / VERTEX_SIZE;

			// ==== TOP TEXTURE | INDEX & VERTEX BUFFER ==== 
			idx_reg_wall_vec = idx_reg_wall_vec.concat(new <uint>[
				indexOffset + 0,
				indexOffset + 1,
				indexOffset + 2,
				indexOffset + 2,
				indexOffset + 3,
				indexOffset + 0,
			]);

			// Shader will take texture coordinates of u and v and then repeat it based on tex length and offset for texture for texture type!
			vtx_reg_wall_vec = vtx_reg_wall_vec.concat(new <Number>[
				//x				y				u,			v			offset for texture type		tex length
				box.x,			box.y,			offset,		textureV,						TOP,	SURFACE_LENGTH,
				box.x + box.w,	box.y,			u + offset,	textureV,						TOP,	SURFACE_LENGTH,
				box.x + box.w,	box.y + 16,		u + offset,	textureV + TEXTURE_HEIGHT,		TOP,	SURFACE_LENGTH,
				box.x,			box.y + 16,		offset,		textureV + TEXTURE_HEIGHT,		TOP,	SURFACE_LENGTH
			]);
			// ---------------------------------------------
			// ==== BOTTOM TEXTURE | INDEX & VERTEX BUFFER ====  
			if(wallTextures.hasBottom(box.mat)){
				indexOffset = vtx_reg_wall_vec.length / VERTEX_SIZE;

				idx_reg_wall_vec = idx_reg_wall_vec.concat(new <uint>[
					indexOffset + 0,
					indexOffset + 1,
					indexOffset + 2,
					indexOffset + 2,
					indexOffset + 3,
					indexOffset + 0,
				]);

				// Shader will take texture coordinates of u and v and then repeat it based on tex length and offset for texture for texture type!
				vtx_reg_wall_vec = vtx_reg_wall_vec.concat(new <Number>[
					//x				y					u,			v			offset for texture type		tex length
					box.x,			box.y + box.h - 16,	offset,		textureV,					BOTTOM,		SURFACE_LENGTH,
					box.x + box.w,	box.y + box.h - 16,	u + offset,	textureV,					BOTTOM,		SURFACE_LENGTH,
					box.x + box.w,	box.y + box.h,		u + offset,	textureV + TEXTURE_HEIGHT,	BOTTOM,		SURFACE_LENGTH,
					box.x,			box.y + box.h,		offset,		textureV + TEXTURE_HEIGHT,	BOTTOM,		SURFACE_LENGTH
				]);
			}

			// --------------------------------------------------------------
			// ==== TOP LEFT & TOP RIGHT TEXTURE | INDEX & VERTEX BUFFER ====  
			if(wallTextures.hasCorner(box.mat)){
				// ==== TOP LEFT ====
				indexOffset = vtx_reg_wall_vec.length / VERTEX_SIZE;

				idx_reg_wall_vec = idx_reg_wall_vec.concat(new <uint>[
					indexOffset + 0,
					indexOffset + 1,
					indexOffset + 2,
					indexOffset + 2,
					indexOffset + 3,
					indexOffset + 0,
				]);

				// Corners don't follow u texture offset.
				vtx_reg_wall_vec = vtx_reg_wall_vec.concat(new <Number>[
					//x				y				u,				v			 offset for texture type	tex length
					box.x,			box.y,			0,				textureV,					TOP_LEFT,	CORNER_LENGTH,
					box.x + 12,		box.y,			CORNER_LENGTH,	textureV,					TOP_LEFT,	CORNER_LENGTH,
					box.x + 12,		box.y + 16,		CORNER_LENGTH,	textureV + TEXTURE_HEIGHT,	TOP_LEFT,	CORNER_LENGTH,
					box.x,			box.y + 16,		0,				textureV + TEXTURE_HEIGHT,	TOP_LEFT,	CORNER_LENGTH
				]);
				// ==== TOP RIGHT ====
				indexOffset = vtx_reg_wall_vec.length / VERTEX_SIZE;

				idx_reg_wall_vec = idx_reg_wall_vec.concat(new <uint>[
					indexOffset + 0,
					indexOffset + 1,
					indexOffset + 2,
					indexOffset + 2,
					indexOffset + 3,
					indexOffset + 0,
				]);

				// Corners don't follow u texture offset.
				vtx_reg_wall_vec = vtx_reg_wall_vec.concat(new <Number>[
					//x						y				u,					v			  offset for texture type	tex length
					box.x + box.w - 12,		box.y,			0,					textureV,					TOP_RIGHT,	CORNER_LENGTH,
					box.x + box.w,			box.y,			CORNER_LENGTH,		textureV,					TOP_RIGHT,	CORNER_LENGTH,
					box.x + box.w,			box.y + 16,		CORNER_LENGTH,		textureV + TEXTURE_HEIGHT,	TOP_RIGHT,	CORNER_LENGTH,
					box.x + box.w - 12,		box.y + 16,		0,					textureV + TEXTURE_HEIGHT,	TOP_RIGHT,	CORNER_LENGTH
				]);
			}
			// --------------------------------------------------------------
			// ==== BOTTOM LEFT & BOTTOM RIGHT TEXTURE | INDEX & VERTEX BUFFER ====  
			if(wallTextures.hasCorner(box.mat) && wallTextures.hasBottom(box.mat)){
				// ==== BOTTOM LEFT ====
				indexOffset = vtx_reg_wall_vec.length / VERTEX_SIZE;

				idx_reg_wall_vec = idx_reg_wall_vec.concat(new <uint>[
					indexOffset + 0,
					indexOffset + 1,
					indexOffset + 2,
					indexOffset + 2,
					indexOffset + 3,
					indexOffset + 0,
				]);

				// Corners don't follow u texture offset.
				vtx_reg_wall_vec = vtx_reg_wall_vec.concat(new <Number>[
					//x				y						u,				v			 	offset for texture type		tex length
					box.x,			box.y + box.h - 16,		0,				textureV,					BOTTOM_LEFT,	CORNER_LENGTH,
					box.x + 12,		box.y + box.h - 16,		CORNER_LENGTH,	textureV,					BOTTOM_LEFT,	CORNER_LENGTH,
					box.x + 12,		box.y + box.h,			CORNER_LENGTH,	textureV + TEXTURE_HEIGHT,	BOTTOM_LEFT,	CORNER_LENGTH,
					box.x,			box.y + box.h,			0,				textureV + TEXTURE_HEIGHT,	BOTTOM_LEFT,	CORNER_LENGTH
				]);
				// ==== BOTTOM RIGHT ====
				indexOffset = vtx_reg_wall_vec.length / VERTEX_SIZE;

				idx_reg_wall_vec = idx_reg_wall_vec.concat(new <uint>[
					indexOffset + 0,
					indexOffset + 1,
					indexOffset + 2,
					indexOffset + 2,
					indexOffset + 3,
					indexOffset + 0,
				]);

				// Corners don't follow u texture offset.
				vtx_reg_wall_vec = vtx_reg_wall_vec.concat(new <Number>[
					//x						y						u,				v			  	 offset for texture type	tex length
					box.x + box.w - 12,		box.y + box.h - 16,		0,				textureV,					BOTTOM_RIGHT,	CORNER_LENGTH,
					box.x + box.w,			box.y + box.h - 16,		CORNER_LENGTH,	textureV,					BOTTOM_RIGHT,	CORNER_LENGTH,
					box.x + box.w,			box.y + box.h,			CORNER_LENGTH,	textureV + TEXTURE_HEIGHT,	BOTTOM_RIGHT,	CORNER_LENGTH,
					box.x + box.w - 12,		box.y + box.h,			0,				textureV + TEXTURE_HEIGHT,	BOTTOM_RIGHT,	CORNER_LENGTH
				]);
			}
			// --------------------------------------------------------------
		}

		// Set up index and vertex buffers for rendering black walls.
		private function setupRoughWall(box:PB2Wall) : void {
			if(!wallTextures.isRough(box.mat)) return;

			const VERTEX_SIZE:uint = 4;
			const indexOffset:uint = vtx_rough_wall_vec.length / VERTEX_SIZE;
			const TEXTUREHEIGHT:Number = 0.25; // this is in terms of texture atlas. 1 texture atlas split into 4 = 0.25
			const TEXTUREWIDTH:Number = 219;
			
			idx_rough_wall_vec = idx_rough_wall_vec.concat(new <uint>[
					indexOffset + 0,
					indexOffset + 1,
					indexOffset + 2,
					indexOffset + 2,
					indexOffset + 3,
					indexOffset + 0,
			]);

			// Set the v coords based on what material it is.
			// This is for getting the correct texture from the texture atlas.
			var v:Number = TEXTUREHEIGHT;

			switch(box.mat){
				case WallTextures.SAND:
					v *= 0;
					break;
				case WallTextures.WET_SAND:
					v *= 1;
					break;
				case WallTextures.MUD:
					v *= 2;
					break;
				case WallTextures.ROCKS:
					v *= 3;
					break;	
				default:
					throw new Error("Non rough surface in setupRoughWalls()! box.mat: " + box.mat);
			}
			// a little offset so it doesnt render texture on top.
			v += 0.005;

			// Divide the box's width into percentage in terms of texture width.
			// This gives the repeating texture pattern.
			// We would also want to offset the texture to the origin (0,0) to follow the original PB2 render exactly.
			const offset:Number = box.x / TEXTUREWIDTH;
			const u:Number = box.w / TEXTUREWIDTH + offset;
		
			vtx_rough_wall_vec = vtx_rough_wall_vec.concat(new <Number>[
				//x				y			u 		v 
				box.x,			box.y - 6,	offset, v,
				box.x + box.w,	box.y - 6,  u, 		v,
				box.x + box.w,	box.y + 20, u, 		v + TEXTUREHEIGHT,
				box.x,			box.y + 20, offset, v + TEXTUREHEIGHT,
			]);
		}

		private function setupGrassWall(box:PB2Wall) : void {
			if(!wallTextures.isGrass(box.mat)) return;

			const ATLAS_WIDTH:uint = wallTextures.getGrassTextureAtlasWidth();
			const ATLAS_HEIGHT:uint = wallTextures.getGrassTextureAtlasHeight();

			const HEIGHT:uint = 37;
            const TOP_WIDTH:uint = 133;
            const TOP_LEFT_WIDTH:uint = 28;
            const TOP_RIGHT_WIDTH:uint = 44;
			const TEXTURE_HEIGHT:Number = HEIGHT / ATLAS_HEIGHT;

			// Offsets from the left of the texture atlas.
			// First comes the top, then top left, then top right.
			const TOP:Number = 0;
			const TOP_LEFT:Number = TOP_WIDTH / ATLAS_WIDTH;
			const TOP_RIGHT:Number = (TOP_WIDTH + TOP_LEFT_WIDTH) / ATLAS_WIDTH;

			const VERTEX_SIZE:uint = 6;
			var indexOffset:uint = vtx_grass_wall_vec.length / VERTEX_SIZE;

			// the x coordinates for top and corners texture respective.
			const topRightStartX: Number = box.x + box.w - TOP_RIGHT_WIDTH + 16;
			const topRightEndX: Number = box.x + box.w + 16;

			const topLeftStartX: Number = box.x + 1;
			const topLeftEndX: Number = box.x + TOP_LEFT_WIDTH;

			const topStartX: Number = topLeftEndX;
			const topEndX: Number = box.x + box.w - TOP_RIGHT_WIDTH + 16;

			// As top texture does not cover the full width of wall, calculate the percentage needed to properly interpolate the u coord across texture atlas.
			const percentageIncrease: Number = (topEndX - topStartX) / (box.w); 

			// const percentageIncrease: Number = 1; // Indicates the percentage of tex u which dictates the interpolation rate due to it's shrunk x coords.
			const textureV:Number = HEIGHT / ATLAS_HEIGHT * wallTextures.grassIDtoIndex(box.mat); // texture coordinate based on texture.
			const offset:Number = box.x / ATLAS_WIDTH;
			const u:Number = box.w / ATLAS_WIDTH;

			// offset as top texture starts later than actual wall width.
			const topOffset:Number = TOP_LEFT_WIDTH / ATLAS_WIDTH; 

			// ==== TOP TEXTURE | INDEX & VERTEX BUFFER ==== 
			idx_grass_wall_vec = idx_grass_wall_vec.concat(new <uint>[
				indexOffset + 0,
				indexOffset + 1,
				indexOffset + 2,
				indexOffset + 2,
				indexOffset + 3,
				indexOffset + 0,
			]);

			// Shader will take texture coordinates of u anv and then repeat it based on tex length and offset for texture for texture type!
			vtx_grass_wall_vec = vtx_grass_wall_vec.concat(new <Number>[
				//x				y						u,													v			offset for texture type		tex length
				topStartX,		box.y - 23,				offset + topOffset,			                        textureV,						TOP,	TOP_WIDTH / ATLAS_WIDTH,
				topEndX,		box.y - 23,				u * percentageIncrease + offset + topOffset,		textureV,						TOP,	TOP_WIDTH / ATLAS_WIDTH,
				topEndX,		box.y + HEIGHT - 23,	u * percentageIncrease + offset + topOffset,		textureV + TEXTURE_HEIGHT,		TOP,	TOP_WIDTH / ATLAS_WIDTH,
				topStartX,		box.y + HEIGHT - 23,	offset + topOffset,				                    textureV + TEXTURE_HEIGHT,		TOP,	TOP_WIDTH / ATLAS_WIDTH
			]);

			// ---------------------------------------------
			// ==== TOP LEFT & TOP RIGHT TEXTURE | INDEX & VERTEX BUFFER ====  
			// ==== TOP LEFT ====
			indexOffset = vtx_grass_wall_vec.length / VERTEX_SIZE;

			idx_grass_wall_vec = idx_grass_wall_vec.concat(new <uint>[
				indexOffset + 0,
				indexOffset + 1,
				indexOffset + 2,
				indexOffset + 2,
				indexOffset + 3,
				indexOffset + 0,
			]);

			// Corners don't follow u texture offset.
			vtx_grass_wall_vec = vtx_grass_wall_vec.concat(new <Number>[
				//x					y						u,									v	                        offset for texture type	tex length
				topLeftStartX,		box.y - 23,				0,									textureV,					TOP_LEFT,	TOP_LEFT_WIDTH / ATLAS_WIDTH,
				topLeftEndX,		box.y - 23,				(TOP_LEFT_WIDTH - 1) / ATLAS_WIDTH,	textureV,					TOP_LEFT,	TOP_LEFT_WIDTH / ATLAS_WIDTH,
				topLeftEndX,		box.y + HEIGHT - 23,	(TOP_LEFT_WIDTH - 1) / ATLAS_WIDTH,	textureV + TEXTURE_HEIGHT,	TOP_LEFT,	TOP_LEFT_WIDTH / ATLAS_WIDTH,
				topLeftStartX,		box.y + HEIGHT - 23,	0,									textureV + TEXTURE_HEIGHT,	TOP_LEFT,	TOP_LEFT_WIDTH / ATLAS_WIDTH
			]);
			// ==== TOP RIGHT ====
			indexOffset = vtx_grass_wall_vec.length / VERTEX_SIZE;

			idx_grass_wall_vec = idx_grass_wall_vec.concat(new <uint>[
				indexOffset + 0,
				indexOffset + 1,
				indexOffset + 2,
				indexOffset + 2,
				indexOffset + 3,
				indexOffset + 0,
			]);

			// Corners don't follow u texture offset.
			vtx_grass_wall_vec = vtx_grass_wall_vec.concat(new <Number>[
				//x					y						u,									v	  		  offset for texture type	tex length
				topRightStartX,		box.y - 23,				0,									textureV,					TOP_RIGHT,	TOP_RIGHT_WIDTH / ATLAS_WIDTH,
				topRightEndX,		box.y - 23,				TOP_RIGHT_WIDTH / ATLAS_WIDTH,		textureV,					TOP_RIGHT,	TOP_RIGHT_WIDTH / ATLAS_WIDTH,
				topRightEndX,		box.y + HEIGHT - 23,	TOP_RIGHT_WIDTH / ATLAS_WIDTH,		textureV + TEXTURE_HEIGHT,	TOP_RIGHT,	TOP_RIGHT_WIDTH / ATLAS_WIDTH,
				topRightStartX,		box.y + HEIGHT - 23,	0,									textureV + TEXTURE_HEIGHT,	TOP_RIGHT,	TOP_RIGHT_WIDTH / ATLAS_WIDTH
			]);
			// // --------------------------------------------------------------
		}

		// Set up index and vertex buffers for rendering black walls.
		private function setupBlackWall(box:PB2Wall, boxCount:uint) : void {
			// Create vector of indices for every box, offsetting the index for subsequent boxes.
			idx_wall_vec = idx_wall_vec.concat(new <uint>[
					boxCount + 0,
					boxCount + 1,
					boxCount + 2,
					boxCount + 2,
					boxCount + 3,
					boxCount + 0,
			]);

			// Create vector of vertices for every box.
			vtx_wall_vec = vtx_wall_vec.concat(new <Number>[
				//x				//y
				box.x,			box.y,
				box.x + box.w,	box.y,
				box.x + box.w,	box.y + box.h,
				box.x,			box.y + box.h,
			]);
		}

        public function setup() : void{
			idx_wall_vec = new Vector.<uint>();
			vtx_wall_vec = new Vector.<Number>();
			idx_rough_wall_vec = new Vector.<uint>();
			vtx_rough_wall_vec = new Vector.<Number>();
			idx_reg_wall_vec = new Vector.<uint>();
			vtx_reg_wall_vec = new Vector.<Number>();
			idx_grass_wall_vec = new Vector.<uint>();
			vtx_grass_wall_vec = new Vector.<Number>();
			
			var boxCount:uint = 0;

			for each (var box:PB2Wall in game.boxes){
				wallTextures.loadBitmap(box.mat);
				setupBlackWall(box, boxCount);
				setupRoughWall(box);
				setupRegularWall(box);
				setupGrassWall(box);

				boxCount += 4; // 4 unique indices per box
			}
			wallTextures.createTextures(c3d);

			// For black walls (All)
			var vertexSize:uint = 2; // x y
			var numOfIndices:uint  = idx_wall_vec.length;
			var numOfVertices:uint = vtx_wall_vec.length / vertexSize;
			
			idx_wall = c3d.createIndexBuffer(numOfIndices, Context3DBufferUsage.STATIC_DRAW);
			idx_wall.uploadFromVector(idx_wall_vec, 0, numOfIndices);

			vtx_wall = c3d.createVertexBuffer(numOfVertices, vertexSize, Context3DBufferUsage.STATIC_DRAW);
			vtx_wall.uploadFromVector(vtx_wall_vec, 0, numOfVertices);

			// For rough walls
			vertexSize = 4; // x y u v
			numOfIndices = idx_rough_wall_vec.length;
			numOfVertices = vtx_rough_wall_vec.length / vertexSize;

			if(numOfIndices != 0){
				idx_rough_wall = c3d.createIndexBuffer(numOfIndices, Context3DBufferUsage.STATIC_DRAW);
				idx_rough_wall.uploadFromVector(idx_rough_wall_vec, 0, numOfIndices);

				vtx_rough_wall = c3d.createVertexBuffer(numOfVertices, vertexSize, Context3DBufferUsage.STATIC_DRAW);
				vtx_rough_wall.uploadFromVector(vtx_rough_wall_vec, 0, numOfVertices);
			}

			// For regular walls
			vertexSize = 6;
			numOfIndices = idx_reg_wall_vec.length;
			numOfVertices = vtx_reg_wall_vec.length / vertexSize;

			if(numOfIndices != 0){
				idx_reg_wall = c3d.createIndexBuffer(numOfIndices, Context3DBufferUsage.STATIC_DRAW);
				idx_reg_wall.uploadFromVector(idx_reg_wall_vec, 0, numOfIndices);

				vtx_reg_wall = c3d.createVertexBuffer(numOfVertices, vertexSize, Context3DBufferUsage.STATIC_DRAW);
				vtx_reg_wall.uploadFromVector(vtx_reg_wall_vec, 0, numOfVertices);
			}

			// For grass walls
			numOfIndices = idx_grass_wall_vec.length;
			numOfVertices = vtx_grass_wall_vec.length / vertexSize;

			if(numOfIndices != 0){
				idx_grass_wall = c3d.createIndexBuffer(numOfIndices, Context3DBufferUsage.STATIC_DRAW);
				idx_grass_wall.uploadFromVector(idx_grass_wall_vec, 0, numOfIndices);

				vtx_grass_wall = c3d.createVertexBuffer(numOfVertices, vertexSize, Context3DBufferUsage.STATIC_DRAW);
				vtx_grass_wall.uploadFromVector(vtx_grass_wall_vec, 0, numOfVertices);
			}
        }

		private function renderBlackWalls(mainTransform: Matrix3D) : void {
			const wall_color:Vector.<Number> = new <Number>[0.0, 0.0, 0.0, 1.0];

			c3d.setProgram(simpleShader);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mainTransform, true);
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, wall_color);
			c3d.setVertexBufferAt(0, vtx_wall, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
			c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
			c3d.drawTriangles(idx_wall, 0);
		}

		private var cts_wall:Vector.<Number> = new <Number>[1, 0, 1, 1]; // fc0.X = 1 fc0.y = 0

		private function renderRegularWalls(mainTransform: Matrix3D) : void {
			if(idx_reg_wall_vec.length == 0) return;

			c3d.setProgram(regularSurfaceShader);
			c3d.setTextureAt(0, wallTextures.regularTextureAtlas);

			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mainTransform, true);
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, cts_wall);

			c3d.setVertexBufferAt(0, vtx_reg_wall, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
			c3d.setVertexBufferAt(1, vtx_reg_wall, 2, Context3DVertexBufferFormat.FLOAT_2); // va1 is texture coords (uv)
			c3d.setVertexBufferAt(2, vtx_reg_wall, 4, Context3DVertexBufferFormat.FLOAT_1); // va2 is textureTypeOffset
			c3d.setVertexBufferAt(3, vtx_reg_wall, 5, Context3DVertexBufferFormat.FLOAT_1); // va3 is texture length
			c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			c3d.drawTriangles(idx_reg_wall, 0);

			c3d.setTextureAt(0, null);
			c3d.setVertexBufferAt(1, null);
			c3d.setVertexBufferAt(2, null);
			c3d.setVertexBufferAt(3, null);
		}

		private function renderGrassWalls(mainTransform: Matrix3D) : void {
			if(idx_grass_wall_vec.length == 0) return;

			c3d.setProgram(regularSurfaceShader);
			c3d.setTextureAt(0, wallTextures.grassTextureAtlas);

			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mainTransform, true);
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, cts_wall);

			c3d.setVertexBufferAt(0, vtx_grass_wall, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
			c3d.setVertexBufferAt(1, vtx_grass_wall, 2, Context3DVertexBufferFormat.FLOAT_2); // va1 is texture coords (uv)
			c3d.setVertexBufferAt(2, vtx_grass_wall, 4, Context3DVertexBufferFormat.FLOAT_1); // va2 is textureTypeOffset
			c3d.setVertexBufferAt(3, vtx_grass_wall, 5, Context3DVertexBufferFormat.FLOAT_1); // va3 is texture length
			c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			c3d.drawTriangles(idx_grass_wall, 0);

			c3d.setTextureAt(0, null);
			c3d.setVertexBufferAt(1, null);
			c3d.setVertexBufferAt(2, null);
			c3d.setVertexBufferAt(3, null);
		}

		private var textureTransform:Matrix3D = new Matrix3D(); // an identity matrix, only exist so it works with texturedFractionalShader.
		// Rough walls only have the top surface to render.
		private function renderRoughWalls(mainTransform: Matrix3D) : void {
			if(idx_rough_wall_vec.length == 0) return;

			c3d.setProgram(roughSurfaceShader);

			// Load texture atlas.
			c3d.setTextureAt(0, wallTextures.roughTextureAtlas);

			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mainTransform, true);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, textureTransform, true);

			c3d.setVertexBufferAt(0, vtx_rough_wall, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
			c3d.setVertexBufferAt(1, vtx_rough_wall, 2, Context3DVertexBufferFormat.FLOAT_2); // va1 is texture coords (uv)

			c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			c3d.drawTriangles(idx_rough_wall, 0);

			c3d.setTextureAt(0, null);
			c3d.setVertexBufferAt(1, null);
		}

        public function render(mainTransform: Matrix3D, pass:uint) : void{
			renderBlackWalls(mainTransform);
			renderRoughWalls(mainTransform);
			renderRegularWalls(mainTransform);
			renderGrassWalls(mainTransform);
        }

        public function free() : void{
			wallTextures.unloadTexture();

			if (idx_wall != null) {
				idx_wall.dispose();
				idx_wall = null;
			}
			if (vtx_wall != null) {
				vtx_wall.dispose();
				vtx_wall = null;
			}
			if (idx_rough_wall != null) {
				idx_rough_wall.dispose();
				idx_rough_wall = null;
			}
			if (vtx_rough_wall != null) {
				vtx_rough_wall.dispose();
				vtx_rough_wall = null;
			}
			if (idx_reg_wall != null) {
				idx_reg_wall.dispose();
				idx_reg_wall = null;
			}
			if (vtx_reg_wall != null) {
				vtx_reg_wall.dispose();
				vtx_reg_wall = null;
			}
			if (idx_grass_wall != null) {
				idx_grass_wall.dispose();
				idx_grass_wall = null;
			}
			if (vtx_grass_wall != null) {
				vtx_grass_wall.dispose();
				vtx_grass_wall = null;
			}
        }
    }
}