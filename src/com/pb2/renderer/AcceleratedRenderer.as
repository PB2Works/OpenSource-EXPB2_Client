package com.pb2.renderer {
	import com.adobe.utils.PerspectiveMatrix3D;
	import com.pb2.renderer.Shader;
	import com.pb2.Projectile;

	// Can't import flash.display.* because of conflict with flash.display.Shader
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageQuality;
	
	import flash.display3D.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.desktop.NativeApplication;

	import com.pb2.PB2Game;

	import com.pb2.renderer.rendergroup.*;
	import com.pb2.renderer.rendergroup.Particles.PB2Particle;

	public class AcceleratedRenderer extends EventDispatcher
	{
		// Singleton
		private static var RENDERER:AcceleratedRenderer = null;
		
		// State
		public static var frames:uint = 0;
		public var stage3D:Stage3D;
		public var viewWidth:Number = 800;
		public var viewHeight:Number = 400;
		public var newViewWidth:Number = 800;
		public var newViewHeight:Number = 400;
		public var toChangeSize:Boolean;
		private var READY_TO_DRAW:Boolean;
		private var INITED:Boolean;
		
		// Objects
		private var game:PB2Game;
		private var c3d:Context3D;
		private var stage:Stage;
		private var renderGroups:Vector.<IRenderGroup>;
		private var renderGroupIDs:Vector.<uint>;
		private var renderGroupPasses:Vector.<uint>;
		
		// Drawing
		private var projection:PerspectiveMatrix3D = new PerspectiveMatrix3D();
		private var viewMatrix:Matrix3D = new Matrix3D();
		private var mainTransform:Matrix3D = new Matrix3D();
		
		// Shaders
		private var allShaders:Vector.<Shader>;
		private var regionShader:Shader;
		private var texturedShader:Shader;
		private var simpleShader:Shader;
		private var texturedFractionalShader:Shader;
		private var textureAtlasShader:Shader;
		private var simpleColorShader:Shader;
		private var coloredTexturedShader:Shader;
		private var simpleMultTexturedShader:Shader;
		private var rotatedTexturedShader:Shader;
		// AIR ONLY
		/* public function DEBUG( value: Boolean ) : void {
			if ( value )
			c3d.setFillMode( Context3DFillMode.WIREFRAME );
			else
			c3d.setFillMode( Context3DFillMode.SOLID );
		} */
		
		public function get LEVEL_LOADED() : Boolean {
			return READY_TO_DRAW;
		}
		
		public static function rasterize(obj:DisplayObject, quality:Number=1.0) : BitmapData {
			var bounds:Rectangle = obj.getBounds(obj);
			// AS3 throws ambigious error so i made a clearer one here.
			if(bounds.width == 0 || bounds.height == 0) throw new Error("The bounds of display object: " + obj + " is 0! width: " + bounds.width + ", height: " + bounds.height);

			var bmp:BitmapData = new BitmapData(bounds.width * quality, bounds.height * quality, true, 0);
			var mtx:Matrix = new Matrix();
			bmp.fillRect(new Rectangle(0, 0, bmp.width, bmp.height), 0);
			mtx.translate(-bounds.x, -bounds.y);
			mtx.scale(quality, quality);
			bmp.drawWithQuality(obj, mtx, null, BlendMode.NORMAL, null, true, StageQuality.BEST);
			return bmp;
		}
		
		public function AcceleratedRenderer(game:PB2Game) {
			if (RENDERER != null) {
				throw new Error("AcceleratedRenderer already exists", 5000);
			}
			this.game = game;
			stage = game.stage;
			READY_TO_DRAW = false;
			INITED = false;
			RENDERER = this;
		}

		public function init() : void {
			if (READY_TO_DRAW) return;
			
			// Sets the initial object of movieclip stats for rendering of PB2Particle
			PB2Particle.setMcStats();
			
			// =================================== Compile shaders ===================================
			texturedShader = new Shader("Textured");
			texturedShader.addVertexCode(Shader.TEXTURED_VERTEX);
			texturedShader.addFragmentCode(Shader.TEXTURED_FRAGMENT);

			rotatedTexturedShader = new Shader("Rotated Textured");
			rotatedTexturedShader.addVertexCode(Shader.ROTATED_TEXTURED_VERTEX);
			rotatedTexturedShader.addFragmentCode(Shader.ROTATED_TEXTURED_FRAGMENT);

			simpleShader = new Shader("Simple");
			simpleShader.addVertexCode(Shader.SIMPLE_VERTEX);
			simpleShader.addFragmentCode(Shader.SIMPLE_FRAGMENT);

			texturedFractionalShader = new Shader("Regularly Textured");
			texturedFractionalShader.addVertexCode(Shader.TEXTURED_FRACTIONAL_VERTEX);
			texturedFractionalShader.addFragmentCode(Shader.TEXTURED_FRACTIONAL_FRAGMENT);

			regionShader = new Shader("Region Shader");
			regionShader.addVertexCode(Shader.REGION_SHADER_VERTEX);
			regionShader.addFragmentCode(Shader.REGION_SHADER_FRAGMENT);

			textureAtlasShader = new Shader("Texture Atlas Wall Shader");
			textureAtlasShader.addVertexCode(Shader.TEXTURE_ATLAS_SHADER_VERTEX);
			textureAtlasShader.addFragmentCode(Shader.TEXTURE_ATLAS_SHADER_FRAGMENT);

			coloredTexturedShader = new Shader("Textured and Colored");
			coloredTexturedShader.addVertexCode(Shader.COLORED_TEXTURED_VERTEX);
			coloredTexturedShader.addFragmentCode(Shader.COLORED_TEXTURED_FRAGMENT);

			simpleColorShader = new Shader("Texture Atlas Wall Shader");
			simpleColorShader.addVertexCode(Shader.SIMPLE_COLOR_VERTEX);
			simpleColorShader.addFragmentCode(Shader.SIMPLE_COLOR_FRAGMENT);
			
			simpleMultTexturedShader = new Shader("Simple Multiply Blending Textured");
			simpleMultTexturedShader.addVertexCode(Shader.SIMPLE_MULT_TEXTURED_VERTEX);
			simpleMultTexturedShader.addFragmentCode(Shader.SIMPLE_MULT_TEXTURED_FRAGMENT);

			allShaders = new <Shader>[texturedShader, simpleShader, texturedFractionalShader, regionShader, textureAtlasShader, coloredTexturedShader, simpleMultTexturedShader, simpleColorShader, rotatedTexturedShader];
			for each (var shader:Shader in allShaders) {
				try {
					shader.build();
				} catch(err:Error) {
					trace("Shader \"" + shader.name + "\" error: " + err.message);
				}
			}
			// ------------------------------------------------------------------------------------------

			// Replicate Flash resizing behavior so that GUI/DisplayList lines up with Stage3D output
			if (stage.stageWidth != 800 || stage.stageHeight != 400) resizeEvent(null);
			NativeApplication.nativeApplication.activeWindow.addEventListener(Event.RESIZE, resizeEvent);
			
			// Set up projection matrix
			// This one converts PB2/Flash coordinates to OpenGL/Stage3D coordinates
			projection.identity();
			projection.appendScale(2/viewWidth, -2/viewHeight, 1);
			projection.appendTranslation(-1, 1, 0);
			
			// Set up Stage3D now
			stage3D = stage.stage3Ds[0];
			stage3D.visible = false;

			//Add event listener before requesting the context
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, contextCreated);
			stage3D.addEventListener(ErrorEvent.ERROR, contextCreationError);

			stage3D.requestContext3D(Context3DRenderMode.AUTO, "standardExtended");

			// stage3D.requestContext3D(Context3DRenderMode.AUTO, "enhanced"); // supposed to be Context3DProfile.ENHANCED. It's present in the libary.swf of libs/airglobal.swc, but under [API("723")]
		}

		private function resizeEvent(ev:Event) : void {
			const w_h:Number = 800/400;
			const h_w:Number = 400/800;
			
			newViewWidth = int(Math.min(stage.stageWidth, stage.stageHeight * w_h));
			newViewHeight = int(Math.min(stage.stageHeight, stage.stageWidth * h_w));
			toChangeSize = true;
		}
		
		//Note, context3DCreate event can happen at any time, such as when the hardware resources are taken by another process
		private function contextCreated( event:Event ):void
		{
			c3d = Stage3D(event.target).context3D;
			c3d.enableErrorChecking = true; //Can slow rendering - only turn on when developing/testing
			c3d.configureBackBuffer( viewWidth, viewHeight, 0, false );
			c3d.setCulling( Context3DTriangleFace.NONE ); // TODO: Maybe change to Context3DTriangleFace.BACK for better performance

			try { 
				for each(var shader:Shader in allShaders) shader.upload(c3d); 
			} 
			catch(err:Error) { 
				trace("Error uploading shaders: " + err.message); 
			}

			/* ====== DRAW ORDER ======
			sky
			graphics_3d
				backgrounds   (O)
				doors         (O)
				walls         (O)
				wall textures (O)
			game
				buttons       (O)
				vehicles      (X)
				barrels       (X)
				players       (O)
				some decors   (X)
				guns          (X)
				bullets       (O)
				some effects  (X)
			graphics_3d_front
				shadowmap     (O)
				some decors   (X)
				flares        (O)
				water         (X)
				bullets       (O)
				some effects  (X)
			*/
			// Set up resources that only need to be loaded in VRAM once for the respective renderGroups, defined in their constructor.
			// These will have to be recreated safely when the GPU context is lost

			// These will have 2 or more render passes
			var projectileGroup:IRenderGroup = new RenderProjectiles (game,  c3d, rotatedTexturedShader.program, texturedShader.program);
			var particleGroup:IRenderGroup 	 = new RenderParticles   (game,  c3d, rotatedTexturedShader.program);

			renderGroups = new <IRenderGroup>[
				// ORDER HERE IS IMPORTANT!
				new RenderSky         (game,  c3d, texturedShader.program, projection),
				new RenderBackgrounds (game,  c3d, texturedFractionalShader.program),
				new RenderDoors       (game,  c3d, simpleColorShader.program),
				new RenderWalls       (game,  c3d, simpleShader.program, texturedFractionalShader.program, textureAtlasShader.program),
				// game
				new RenderRegions     (game,  c3d, regionShader.program),
				new RenderCharacters  (game,  c3d, texturedShader.program),
				projectileGroup,
				particleGroup,
				// graphics_3d_front
				new RenderShadowmap   (game,  c3d, texturedShader.program),
				new RenderFlares      (game,  c3d, simpleMultTexturedShader.program),
				new RenderWaters      (game,  c3d, simpleColorShader.program),
				projectileGroup,
				particleGroup,
			];

			renderGroupIDs = new Vector.<uint>(renderGroups.length);

			var i:int;

			for (i = 0; i < renderGroupIDs.length; i++) {
				renderGroupIDs[i] = 999;
			}

			var id:uint = 0;
			for (i = 0; i < renderGroupIDs.length; i++) {
				if (renderGroupIDs[i] != 999) continue;

				renderGroupIDs[i] = id;
				for (var j:int = i + 1; j < renderGroupIDs.length; j++) {
					if (renderGroups[j] == renderGroups[i]) renderGroupIDs[j] = id;
				}

				id++;
			}

			renderGroupPasses = new Vector.<uint>(id);
			
			INITED = true;
			// TODO: Recreate dynamic resources if they were loaded previously
			// Which would be kind of hard, tbh
		}
		
		// Transfer / get references to game data
		public function readyLevel() : void {
			if (READY_TO_DRAW) {
				throw new Error("GPU: Trying to load another level");
			}

			var biggestID:int = -1;
			for (var i:int = 0; i < renderGroups.length; i++) {
				var renderGroup:IRenderGroup = renderGroups[i];
				var id:uint = renderGroupIDs[i];
				if (id > biggestID) {
					biggestID = id;
					renderGroup.setup();
				}
			}

			stage3D.visible = true;
			READY_TO_DRAW = true;
			trace("Ready level");
		}
		
		public function unloadLevel() : void {
			if (!READY_TO_DRAW) {
				throw new Error("GPU: Trying to free unloaded level");
			}
			stage3D.visible = false;

			var biggestID:int = -1;
			for (var i:int = 0; i < renderGroups.length; i++) {
				var renderGroup:IRenderGroup = renderGroups[i];
				var id:uint = renderGroupIDs[i];
				if (id > biggestID) {
					biggestID = id;
					renderGroup.free();
				}
			}

			READY_TO_DRAW = false;
		}

		public function render() : void
		{
			if (!READY_TO_DRAW) return;

			// Change's drawing size when there is a screen size change.
			if (toChangeSize) {
				c3d.configureBackBuffer(Math.max(32, Math.min(16384, newViewWidth)), Math.max(32, Math.min(16384, newViewHeight)), 0, false);
				viewWidth = newViewWidth;
				viewHeight = newViewHeight;
				toChangeSize = false;
				c3d.setScissorRectangle(new Rectangle(0, 0, viewWidth, viewHeight));
			}

			// Start of rendering.
			c3d.clear(0.3, 0.3, 0.3);

			mainTransform.identity();
			mainTransform.appendTranslation(game.game.x, game.game.y, 0);
			mainTransform.append(projection);

			var i:int;

			for (i = 0; i < renderGroupPasses.length; i++) {
				renderGroupPasses[i] = 0;
			}

			for (i = 0; i < renderGroups.length; i++) {
				var renderGroup:IRenderGroup = renderGroups[i];
				renderGroup.render(mainTransform, renderGroupPasses[renderGroupIDs[i]]++);
			}

			c3d.present();
			frames++;
		}
		
		private function contextCreationError( error:ErrorEvent ):void
		{
			trace( error.errorID + ": " + error.text );
		}
	}
}
