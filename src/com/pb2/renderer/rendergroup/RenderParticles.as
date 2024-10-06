package com.pb2.renderer.rendergroup{

	import com.pb2.renderer.rendergroup.Particles.*;

    import com.pb2.PB2Game;
    import flash.display3D.*;
    import flash.geom.Matrix3D;

	/*
		Unlike most render groups, particles render on a event basis. Therefore, it does not get information from PB2Game class directly.
		Instead, when Effect() is invoked (spawns new particle), it updates RenderParticles via newParticle(). 
		newParticle will push the relevant details of this particular particle into a main buffer (particlesToRender).

		Every frame, RenderParticles will constantly update this buffer, 
		- remove particles from this buffer when it has finished playing by setting it to null.
		- get updates caused by EffectLogic by accessing the ef array.
		- update PB2Particles properties based on updates.

		Following the es array, this main buffer follows the same fixed cycle system with a limit (of either 224 or 128).

		TODO 2: To update this buffer requires the ef buffer, which consist of Movieclips. We don't necessarily need to 
		construct Movieclips for it, just some of it's properties. We will need to refactor the PB2Game code such that this buffer can copy from
		another array / Vector containing only these properties. 

		Other than this main buffer, each render class has its own unique type buffer via Vector.filter() (i tested it and it doesnt seem to be computationally intensive)
		Unlike the main buffer, type buffers are dynamic and are not fixed, but contains no null value.
		That way, each render classes do not have to waste computation resouces in looping through the main buffer if we already no there is no need to.
		
		TODO 3: Find a computationally less intensive way of filtering the main buffer, without sarcrifiring modularity. (is it even possible?)

		The above tradeoff is that we use more memory for an average of less computational work.

		Every particle will have a field named currentFrame and totalFrame, which we will be manually controlling.
		Particle's currentFrame will determine it's lifespan in the buffer. If it reaches to totalFrames, buffer will remove particle from itself.
		Using this, we can get the u v coords of a texture based on its currentFrame.

		RenderParticles will handle the bookkeeping of particles information, so the respective particle classes can retrieve each's corresponding
		type buffer and create its own vertex and index buffers from there.

		Respective particle classes will still need
		- manage index and vertex buffer sizes
		- upload a vector matching the index and vertex buffer size (type buffer + 0s)
		- do the actual rendering.
	*/
    public class RenderParticles implements IRenderGroup{
        public static const name:String = "Particles";

		public var game:PB2Game;
		public var c3d:Context3D;
		private var rotatedTexturedShader:Program3D;

		private var idx_particles:IndexBuffer3D;
		private var vtx_particles:VertexBuffer3D;
		private var idx_particles_vec:Vector.<uint>;
		private var vtx_particles_vec:Vector.<Number>;

		private static const RENDER_ON_GAME_LAYER: uint 	= 0;
		private static const RENDER_ON_3D_FRONT_LAYER: uint = 1;

		private var renderRail: Rails;
		// Type buffers (so every render function does not have to loop through the main buffer necessarily.)
		public static var railsToRender:Vector.<PB2Particle>;
		// private static var explosionsToRender:Vector.<PB2Particle>;
		
		private function debug(name: String, buffer: Vector.<PB2Particle>, maxBufferSize: String) : void{
			if(buffer.length == 0) return;
			
			trace("---- " + name + " Buffer [size: " + buffer.length +", max-size: " + maxBufferSize + "] ----");

			for each(var particle:PB2Particle in buffer){
				if(!particle) continue;

				trace("| " + name + " ID: " + particle.id + ", type: " + particle.type + ", typ: " + particle.typ + ", x: " + particle.x + ", y: " + 
				particle.x + ", totalFrames: " + particle.totalFrames + ", currentFrame: " + particle.currentFrame);
			}

			trace("------ End Of Buffer ------\n");
		}

		public function getName() : String {
            return name;
        }


        public function RenderParticles(game:PB2Game, c3d:Context3D, rotatedTexturedShader:Program3D) : void{
            this.rotatedTexturedShader = rotatedTexturedShader;
            this.game = game;
            this.c3d = c3d;

			// set up texture atlases
			renderRail = new Rails(c3d);
        }

        public function setup() : void{
			railsToRender = new Vector.<PB2Particle>();

			// sets up buffer
			renderRail.setBuffer(Rails.INITIAL_BUFFER_SIZE);
        }

		// Updates the main buffers and all type buffers.
		public function updateBuffer(mainBuffer: Vector.<PB2Particle>) : void {

			// Updates the properties of PB2Projectile in buffer due to EffectsLogic by getting information from ef array.
			for each(var particle:PB2Particle in mainBuffer){
				if(!particle) continue;

				// once it finishes it's last frame.
				if(particle.currentFrame == particle.totalFrames){
					mainBuffer[particle.id] = null;
				}
				else{
					particle.currentFrame++;

					// EffectsLogic ignore particle with typ 0, therefore nothing to update.
					if(particle.typ == 0) continue;

					// Get particle's updated information from particlesToRender
					var updatedParticle:Object = game.ef[particle.id];

					particle.x 				= updatedParticle.x;
					particle.y 				= updatedParticle.y;
					particle.tox 			= updatedParticle.tox;
					particle.toy 			= updatedParticle.toy;
					particle.life 			= updatedParticle.life;
					
					particle.rotation		= updatedParticle.rotation;
					particle.transform		= updatedParticle.transform;
					particle.scaleX			= updatedParticle.scaleX;
					particle.scaleY			= updatedParticle.scaleY;

					particle.float_frame 	= updatedParticle.float_frame;
					particle.framespeed		= updatedParticle.framespeed;

					// for typ 3 particles
					if(particle.typ == 3){
						particle.toang 		= updatedParticle.toang;
					}
					
					// for message
					if(particle.type == PB2Particle.TEXT_MSG){
						particle.msgtext.x 		= updatedParticle.msgtext.x
						particle.msgtext.alpha 	= updatedParticle.msgtext.alpha;
						particle.strquad.x 		= updatedParticle.strquad.x;
					}
				}
			}

			// Update type buffers based on main buffer
			railsToRender = mainBuffer.filter(function(particle: PB2Particle, index:int, vector:Vector.<PB2Particle>):Boolean{
				if(!particle) return false;

				return (
                    particle.type == PB2Particle.LITE_RAIL || particle.type == PB2Particle.HEAVY_RAIL || particle.type == PB2Particle.RED_LASER ||
                    particle.type == PB2Particle.ORANGE_RAIL || particle.type == PB2Particle.GREEN_RAIL || particle.type == PB2Particle.BLUE_LASER
                )
			});
		}

        public function render(mainTransform: Matrix3D, pass:uint) : void{
			const mainBuffer:Vector.<PB2Particle> = game.effects;

			// Resize buffer if needed.
			renderRail.checkToResizeBuffer(railsToRender.length);

			if(mainBuffer.length == 0){
				return;
			}

			// Debug
			// debug("Particles", particlesToRender, "Fixed");
			// debug("Rails", railsToRender, renderRail.bufferSize.toString());

			if(pass == RENDER_ON_GAME_LAYER){
				// update the main buffer with new properties.
				// updates the buffer once per frame, since this render function is invoked twice.
				updateBuffer(mainBuffer);
			}
			else if(pass == RENDER_ON_3D_FRONT_LAYER){
				if(railsToRender.length != 0) renderRail.render(mainTransform, railsToRender, rotatedTexturedShader);
			}
			else{
				// assert
				trace("Unknown value of pass in RenderParticles: " + pass);
			}

        }

        public function free() : void{

        }
    }
}