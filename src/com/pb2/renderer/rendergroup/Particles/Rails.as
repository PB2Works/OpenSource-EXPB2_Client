package com.pb2.renderer.rendergroup.Particles{

    import flash.display3D.*;
    import flash.display.MovieClip;
    import com.pb2.renderer.AcceleratedRenderer;
    import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.display3D.textures.RectangleTexture;
	import flash.display.BitmapData;
	import flash.geom.Matrix3D;

    // Rails is responsible for rendering of rails. It's render function is invoked by RenderParticles, which bookeeps the list of particles to render.
    public class Rails{

		private var texture_atlas:RectangleTexture;
        private var atlasBmp:BitmapData
        private var atlasHeight:Number;
        private var rails:Vector.<MovieClip>;
        private static const cts_rail:Vector.<Number> = new <Number>[1, 0, 0, 0];

        private var idx_rails:IndexBuffer3D;
		private var vtx_rails:VertexBuffer3D;
		private var idx_rails_vec:Vector.<uint>;
		private var vtx_rails_vec:Vector.<Number>;

        private var rails_height:Vector.<Number>;
        private var rails_texCoord_v:Vector.<Number>;

        private var c3d:Context3D;

        // represents a timer / counter that represents the last time since buffer size has changed in terms of number of frames passed.
        // this is to facilitate the reset of the index and vertex buffer back to it's original initial buffer size after it has expanded after a certain no. of frames
        // this also means that bufferHasUpdatedTimer will always be 0 if index & vertex buffer == INITIAL_BUFFER_SIZE.
        private var bufferHasUpdatedTimer:uint;

        // buffer size is dynamic, it will change according, expanding if the supplied type buffer is greater and shrinking after a while of inactivity.
        public  var bufferSize:uint;

        // Used to set the initial size of vertex and index buffers.
        public  static const INITIAL_BUFFER_SIZE:Number = 50;
        private static const RAIL_WIDTH:Number          = 60.95;
        private static const TOTAL_ATLAS_WIDTH:Number   = RAIL_WIDTH * 20;
        private static const QUALITY:Number             = 3;
        private static const VERTEX_SIZE:uint           = 7;
        private static const DEG_TO_RAD:Number = Math.PI / 180.0;
        private static var   MAX_PARTICLE_INDICES:uint;
	    private static var   MAX_PARTICLE_VERTICES:uint;

        public function Rails(c3d: Context3D){
            this.c3d = c3d;

            setupAtlas();
        }

        // Initial height represents the y offset for that given rail texture.
        private function drawMovieClipToAtlas(mc: MovieClip, width:Number, initialHeight:Number, maxHeight:Number, totalFrames:uint) : void {
            const areaDrawn:Rectangle = new Rectangle(0, 0, width * QUALITY, maxHeight * QUALITY);

            // loop through every frame in the movie clip to draw every rail. ignore last frame.
			for(var i:uint = 1; i < mc.totalFrames; i++){
				mc.gotoAndStop(i);

                // height changes over the course of animation therefore we need offset it to center it in texture atlas.
                // maxHeight represents the highest height of this given rail.
                var heightOffset: Number = initialHeight + (maxHeight - mc.height) / 2;
                atlasBmp.copyPixels(AcceleratedRenderer.rasterize(mc, QUALITY), areaDrawn, new Point(width * (i - 1) * QUALITY, heightOffset * QUALITY));
			}
        }

        private function setListOfRails() : void {
            rails = new <MovieClip>[
                new rail(),     // lite rail
                new rail2(),    // heavy rail
                new rail3(),    // red laser
                new rail4(),    // orange rail
                new rail5(),    // green / poison rail
                new rail6(),    // blue laser
            ];
        }

        private function setAtlasHeight() : void {
            atlasHeight = 0;
            
            for each(var rail:MovieClip in rails){
                atlasHeight += rail.height;
            }
        }

        private function setTexCoordV() : void {
            var i:uint = 0;
            var heightUsed: Number = 0;

            rails_texCoord_v = new Vector.<Number>(rails.length);

            for each(var rail:MovieClip in rails){
                rails_texCoord_v[i] = heightUsed / atlasHeight;
                heightUsed += rail.height;
                i++
            }

        }

        private function setRailHeight() : void {
            var i:uint = 0;
            rails_height = new Vector.<Number>(rails.length);

            for each(var rail:MovieClip in rails){
                rails_height[i] = rail.height;
                i++
            }
        }

        // can be used to get tex coords v or rail height
        private function getInfo(rails_info: Vector.<Number>, type: uint) : Number {
            switch(type){
                case PB2Particle.LITE_RAIL:
                    return rails_info[0];
                case PB2Particle.HEAVY_RAIL:
                    return rails_info[1];
                case PB2Particle.RED_LASER:
                    return rails_info[2];
                case PB2Particle.ORANGE_RAIL:
                    return rails_info[3];
                case PB2Particle.GREEN_RAIL:
                    return rails_info[4];
                case PB2Particle.BLUE_LASER:
                    return rails_info[5];
                default:
                    throw new Error("Particle effect is not of rail type! type: " + type);
            }
        }
                        
        public function setupAtlas() : void{
            setListOfRails();
            setAtlasHeight();
            setTexCoordV();
            setRailHeight();

            // Width in width of all frames of animated rail. The length of first rail is enough to cover for all of the rails.
            atlasBmp = new BitmapData(RAIL_WIDTH * (rails[0].totalFrames - 1) * QUALITY, atlasHeight * QUALITY, true, 0);

            var heightUsed: Number = 0;
            for each(var rail:MovieClip in rails){
                // initial height is the maximum height throughout the rails animation.
                drawMovieClipToAtlas(rail, rail.width, heightUsed, rail.height, rail.totalFrames);

                rail.gotoAndStop(1);
                heightUsed += rail.height;
            }

            texture_atlas = c3d.createRectangleTexture(atlasBmp.width, atlasBmp.height, Context3DTextureFormat.BGRA, false);
			texture_atlas.uploadFromBitmapData(atlasBmp);
			atlasBmp.dispose(); 
        }

        public function setBuffer(size: uint) : void {
            bufferSize = size;
			
            if(size == INITIAL_BUFFER_SIZE){
                bufferHasUpdatedTimer = 0;
            }
            else{
                bufferHasUpdatedTimer = 1;
            }

			MAX_PARTICLE_INDICES  = bufferSize * 6;
			MAX_PARTICLE_VERTICES = bufferSize * 4;

			idx_rails_vec = new Vector.<uint>(MAX_PARTICLE_INDICES);
			idx_rails     = c3d.createIndexBuffer(MAX_PARTICLE_INDICES, Context3DBufferUsage.DYNAMIC_DRAW);

			vtx_rails_vec = new Vector.<Number>(MAX_PARTICLE_VERTICES * VERTEX_SIZE);
			vtx_rails     = c3d.createVertexBuffer(MAX_PARTICLE_VERTICES, VERTEX_SIZE, Context3DBufferUsage.DYNAMIC_DRAW);
        }

        // update vertex and index buffer based on updated particle effects.
        private function updateBuffer(railsToRender: Vector.<PB2Particle>) : void {
            var indexOffset:uint    = 0;
            var indexVecOffset:uint = 0;
            var vertexOffset:uint   = 0;

            for each(var rail:PB2Particle in railsToRender){
                // updates the index vector buffer
                idx_rails_vec[indexVecOffset + 0] = indexOffset + 0;
                idx_rails_vec[indexVecOffset + 1] = indexOffset + 1;
                idx_rails_vec[indexVecOffset + 2] = indexOffset + 2;
                idx_rails_vec[indexVecOffset + 3] = indexOffset + 2;
                idx_rails_vec[indexVecOffset + 4] = indexOffset + 3;
                idx_rails_vec[indexVecOffset + 5] = indexOffset + 0;

                var half_width: Number  = RAIL_WIDTH / 2;
                var half_height: Number = getInfo(rails_height, rail.type) / 2;
                var u: Number           = (rail.currentFrame - 1) * RAIL_WIDTH / TOTAL_ATLAS_WIDTH;
                var end_u: Number       = rail.currentFrame * RAIL_WIDTH / TOTAL_ATLAS_WIDTH;
                var v: Number           = getInfo(rails_texCoord_v, rail.type);
                var end_v: Number       = v + getInfo(rails_height, rail.type) / atlasHeight;

                // trace("half_w: " + half_width + ", half_h: " + half_height + ", u: " + u + ", end u: " + end_u + ", v: " + v + ", end v: " + end_v);

                // ==========================================    Updates the Vertex vector    ==========================================
                // TOP LEFT                                                     TOP RIGHT
                vtx_rails_vec[vertexOffset +   0] = rail.x - half_width;        vtx_rails_vec[vertexOffset +   7] = rail.x + half_width;
                vtx_rails_vec[vertexOffset +   1] = rail.y - half_height;       vtx_rails_vec[vertexOffset +   8] = rail.y - half_height;
                vtx_rails_vec[vertexOffset +   2] = u;                          vtx_rails_vec[vertexOffset +   9] = end_u;
                vtx_rails_vec[vertexOffset +   3] = v;                          vtx_rails_vec[vertexOffset +  10] = v;
                vtx_rails_vec[vertexOffset +   4] = rail.x;                     vtx_rails_vec[vertexOffset +  11] = rail.x;
                vtx_rails_vec[vertexOffset +   5] = rail.y;                     vtx_rails_vec[vertexOffset +  12] = rail.y;
                vtx_rails_vec[vertexOffset +   6] = rail.rotation * DEG_TO_RAD; vtx_rails_vec[vertexOffset +  13] = rail.rotation * DEG_TO_RAD;

                // BOTTOM LEFT                                                  // BOTTOM RIGHT
                vtx_rails_vec[vertexOffset +  21] = rail.x - half_width;        vtx_rails_vec[vertexOffset +  14] = rail.x + half_width;
                vtx_rails_vec[vertexOffset +  22] = rail.y + half_height;       vtx_rails_vec[vertexOffset +  15] = rail.y + half_height;
                vtx_rails_vec[vertexOffset +  23] = u;                          vtx_rails_vec[vertexOffset +  16] = end_u;
                vtx_rails_vec[vertexOffset +  24] = end_v;                      vtx_rails_vec[vertexOffset +  17] = end_v;
                vtx_rails_vec[vertexOffset +  25] = rail.x;                     vtx_rails_vec[vertexOffset +  18] = rail.x;
                vtx_rails_vec[vertexOffset +  26] = rail.y;                     vtx_rails_vec[vertexOffset +  19] = rail.y;
                vtx_rails_vec[vertexOffset +  27] = rail.rotation * DEG_TO_RAD; vtx_rails_vec[vertexOffset +  20] = rail.rotation * DEG_TO_RAD;

                // =====================================================================================================================

                indexOffset    += 4;
                indexVecOffset += 6;
                vertexOffset   += VERTEX_SIZE * 4;
            }

            // Fills the rest of the vector.
            for(var i:uint = indexVecOffset; i < idx_rails_vec.length; i++){
                idx_rails_vec[i] = 0;
            }

            for(var j:uint = vertexOffset; j < vtx_rails_vec.length; j++){
                vtx_rails_vec[j] = 0;
            }

            idx_rails.uploadFromVector(idx_rails_vec, 0, MAX_PARTICLE_INDICES);
			vtx_rails.uploadFromVector(vtx_rails_vec, 0, MAX_PARTICLE_VERTICES);
        }

        // check if we need to resize buffer every interval.
        // expand due to the increase number of particles or decrease after a certain amount of inactivty.
        public function checkToResizeBuffer(bufferLen: uint) : void {
            const INTERVAL:uint = 300;

            // only increment counter if buffer has recently expanded.
            if(bufferHasUpdatedTimer != 0) {
                bufferHasUpdatedTimer++;
            }
            
            // check if current index and vertex buffer can fit the updated type buffer (expand)
            if(bufferLen > bufferSize)   {
                setBuffer(bufferLen);
            }

            // current buffer is still too big, reset timer
            else if(bufferLen > INITIAL_BUFFER_SIZE){
                bufferHasUpdatedTimer = 1;
            }

            // shrink
            else if(bufferHasUpdatedTimer > INTERVAL){
                setBuffer(INITIAL_BUFFER_SIZE);
            }
        }

        public function render(mainTransform: Matrix3D, railsToRender: Vector.<PB2Particle>, shaderProgram: Program3D) : void {
            updateBuffer(railsToRender);

            // it's finally time to render >:)
            c3d.setProgram(shaderProgram);
            c3d.setTextureAt(0, texture_atlas);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mainTransform, true);
			c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 4, cts_rail);
			c3d.setVertexBufferAt(0, vtx_rails, 0, Context3DVertexBufferFormat.FLOAT_2); // va0 is position (xy)
			c3d.setVertexBufferAt(1, vtx_rails, 2, Context3DVertexBufferFormat.FLOAT_2); // va1 is texture coords (uv)
			c3d.setVertexBufferAt(2, vtx_rails, 4, Context3DVertexBufferFormat.FLOAT_2); // va2 is center coords (xy)
			c3d.setVertexBufferAt(3, vtx_rails, 6, Context3DVertexBufferFormat.FLOAT_1); // va3 is rotation
			c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			c3d.drawTriangles(idx_rails, 0, railsToRender.length * 2);

			c3d.setTextureAt(0, null);
			c3d.setVertexBufferAt(1, null);
			c3d.setVertexBufferAt(2, null);
			c3d.setVertexBufferAt(3, null);
        }

    }
}