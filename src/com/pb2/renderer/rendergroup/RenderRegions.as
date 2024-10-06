package com.pb2.renderer.rendergroup{

	import com.pb2.PB2Region;
	import com.pb2.PB2Game;
	import flash.display3D.*;
	import flash.geom.Matrix3D;

	// For textures
	import flash.display3D.textures.RectangleTexture;
	import flash.display.BitmapData;
	import com.pb2.renderer.AcceleratedRenderer;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;

	public class RenderRegions implements IRenderGroup{
		public static const name:String = "Regions";

		public var game:PB2Game;
		public var c3d:Context3D;
		private var shaderProgram:Program3D;

		// Regions
		private const REGION_VERTEX_SIZE:uint = 4;
		private var USEBtnBasePanel:DisplayObject;
		private var USEBtnText:DisplayObject;
		private var regions_to_render:Vector.<PB2Region>;
		private var tex_region:RectangleTexture;
		private var tex_regionTxt:RectangleTexture;
		private var idx_region:IndexBuffer3D;
		private var vtx_region:VertexBuffer3D;
		private var vtx_region_vec:Vector.<Number>;

		public function getName() : String {
			return name;
		}

		public function RenderRegions(game:PB2Game, c3d:Context3D, shaderProgram: Program3D) : void{
			this.shaderProgram = shaderProgram;
			this.game = game;
			this.c3d = c3d;

			// Rasterize both USE base panel and USE text.
			const QUALITY:Number = 2.5; 
			var USEBtn:MovieClip = new switchh() as MovieClip;
			USEBtnBasePanel = USEBtn.getChildAt(0);
			USEBtnText = USEBtn.getChildAt(2);

			var bmp:BitmapData = AcceleratedRenderer.rasterize(USEBtnBasePanel, QUALITY);
			var width:uint = USEBtn.getBounds(USEBtn).width * QUALITY;
			var height:uint = USEBtn.getBounds(USEBtn).height * QUALITY;
			tex_region = c3d.createRectangleTexture(width, height, Context3DTextureFormat.BGRA, false);
			tex_region.uploadFromBitmapData(bmp);

			bmp = AcceleratedRenderer.rasterize(USEBtnText, QUALITY);
			tex_regionTxt = c3d.createRectangleTexture(width, height, Context3DTextureFormat.BGRA, false);
			tex_regionTxt.uploadFromBitmapData(bmp);
			
			// A region is a rectangle, consisting of 2 triangles. Therefore we need 6 indices, 3 per triangle.
			var idx_region_vec:Vector.<uint> = new <uint>[
				0,	1,	2,  
				2,	3,	0
			];
			const NUMOFINDICES:uint = idx_region_vec.length;
			const NUMOFVERTICES:uint = 4;

			// Create a index buffer to be used for every region.
			idx_region = c3d.createIndexBuffer(NUMOFINDICES, Context3DBufferUsage.STATIC_DRAW);
			idx_region.uploadFromVector(idx_region_vec, 0, NUMOFINDICES);

			// Create a vertex buffer to be used for ever region.
			vtx_region = c3d.createVertexBuffer(NUMOFVERTICES, REGION_VERTEX_SIZE, Context3DBufferUsage.DYNAMIC_DRAW);
			vtx_region_vec = new Vector.<Number>(NUMOFVERTICES * REGION_VERTEX_SIZE);

			// Calculate region's texture coordinates
			// Top left
			vtx_region_vec[0*4 + 2 + 0] = 0; // u
			vtx_region_vec[0*4 + 2 + 1] = 0; // v
			// Top right
			vtx_region_vec[1*4 + 2 + 0] = 1; // u
			vtx_region_vec[1*4 + 2 + 1] = 0; // v
			// Bottom right
			vtx_region_vec[2*4 + 2 + 0] = 1;  // u
			vtx_region_vec[2*4 + 2 + 1] = 1;  // v
			// Bottom left
			vtx_region_vec[3*4 + 2 + 0] = 0;  // u
			vtx_region_vec[3*4 + 2 + 1] = 1;  // v
		}

		public function setup() : void{
			regions_to_render = new Vector.<PB2Region>();

			for each(var region:PB2Region in game.regions){
				var useBtnMc:MovieClip = region.mc;
				//region with no button, skip attempt to render it.
				if(useBtnMc == null) continue;
				regions_to_render.push(region);
			}
		}

		public function render(mainTransform: Matrix3D, pass:uint) : void{
			const frames:uint = AcceleratedRenderer.frames;

			const buttonWidth:Number = 39.35;
			const halfButtonWidth:Number  = buttonWidth / 2.0; 
			const halfButtonHeight:Number = buttonWidth / 1.354 / 2.0; // ratio derived from JPEXS

			const yOffset:int = -5; // actual button location is a little bit higher than the actual center region
			const renderPanelOffsetX:Number = 0.1; // offset value to not render the coloured panel outside of base panel.
			const renderPanelOffsetY:Number = 0.08;
			// offset value to shift USE txt from top left to center
			//												xOffset yOffset
			const TxtOffSet:Vector.<Number> = new <Number>[	0.313, 	0.222, 	0, 0];
			const ones:Vector.<Number> = new <Number>[1, 1, 1, 1];

			const offset1:Vector.<Number> = new <Number>[0, 0, 0, renderPanelOffsetX];
			const offset2:Vector.<Number> = new <Number>[0, 0, 0, renderPanelOffsetY];
			const offset3:Vector.<Number> = new <Number>[1, 1, 1, 1 - renderPanelOffsetX];
			const offset4:Vector.<Number> = new <Number>[1, 1, 1, 1 - renderPanelOffsetY];

			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, ones);
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, offset1);
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, offset2);
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, offset3); 
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, offset4);
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 7, TxtOffSet);

			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mainTransform, true);
			c3d.setTextureAt(0, tex_region);
			c3d.setTextureAt(1, tex_regionTxt);
			c3d.setProgram(shaderProgram);
			
			c3d.setVertexBufferAt(0, vtx_region, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
			c3d.setVertexBufferAt(1, vtx_region, 2, Context3DVertexBufferFormat.FLOAT_2); // va1 is texture coords for base panel (uv)

			for each(var region:PB2Region in regions_to_render){
				c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, region.getPanelColor());
				c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 6, region.animatePanel());
				c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 8, region.animateUSE(frames % 120));

				// Calculate the center of region
				var centerX:Number = (2 * region.x + region.w) / 2;
				var centerY:Number = (2 * region.y + region.h) / 2 + yOffset; 

				// Calculate region's vertex coordinates
				// Top left
				vtx_region_vec[0]  = centerX - halfButtonWidth;  // x
				vtx_region_vec[1]  = centerY - halfButtonHeight; // y
				// Top right
				vtx_region_vec[4]  = centerX + halfButtonWidth;  // x
				vtx_region_vec[5]  = centerY - halfButtonHeight; // y
				// Bottom right
				vtx_region_vec[8]  = centerX + halfButtonWidth;  // x
				vtx_region_vec[9]  = centerY + halfButtonHeight; // y
				// Bottom left
				vtx_region_vec[12] = centerX - halfButtonWidth;  // x
				vtx_region_vec[13] = centerY + halfButtonHeight; // y

				vtx_region.uploadFromVector(vtx_region_vec, 0, vtx_region_vec.length / REGION_VERTEX_SIZE);

				c3d.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
				c3d.drawTriangles(idx_region /*, firstIndex, numTriangles */);
			}

			c3d.setTextureAt(0, null);
			c3d.setTextureAt(1, null);
			c3d.setVertexBufferAt(1, null);
		}

		public function free() : void{
			// TODO: for now, loading a new level does not reload vertex buffer & index buffer..
			// Might wanna rewrite it so that vertex buffer & index buffer is only created once a match is created if there is memory issues.
		}
	}
}