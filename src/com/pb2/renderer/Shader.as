package com.pb2.renderer {
	import com.adobe.utils.AGALMacroAssembler;
	import flash.display3D.*;
	
	public class Shader {
		private var vertex:AGALMacroAssembler = new AGALMacroAssembler();
		private var fragment:AGALMacroAssembler = new AGALMacroAssembler();
		public var code_vertex:String;
		public var code_fragment:String;
		public var name:String;
		public var program:Program3D;

		// ============================================================================================
		// ============================================================================================
		// ============================================================================================

		public static const TEXTURED_VERTEX:String =
		"m44 op, va0, vc0"            + "\n" +       // Matrix multiply vector va0 by 4x4 matrix vc0
		"mov v0, va1"                 + "\n"         // Put texture coordinates in v0 for fragment shader

		public static const TEXTURED_FRAGMENT:String =
		"tex oc, v0, fs0 <2d,linear>" + "\n";        // Output the pixel of texture fs0 at coordinates v0

		// ============================================================================================
		// ============================================================================================
		// ============================================================================================

		/* 	Program expects these parameters
			va0: Corners position, x y 	(FLOAT_2)
			va1: Texture coords, u v	(FLOAT_2)
			va2: Center position, x y	(FLOAT_2) (Should be the same regardless of corner)
			va3: Rotation, x			(FLOAT_1) (Should be the same regardless of corner)
		*/
		public static const ROTATED_TEXTURED_VERTEX:String =
		"alias va0, vPosition"		  						+ "\n" +
		"alias vt3, position"		  						+ "\n" +
		"alias va1, vTexCoord"		  						+ "\n" +
		"alias va2, vCenter"		  						+ "\n" +
		"alias va3, vRotation"		  						+ "\n" +
		"alias vt0, rotMatrixCol1"	  						+ "\n" +
		"alias vt1, rotMatrixCol2"	  						+ "\n" +
		"alias vc0, finalTransform"							+ "\n" +
		"alias vc4, CONST_0( 1, 0 )"						+ "\n" +
		// Translate position to origin.
		"position = vPosition - vCenter"   					+ "\n" +	
		"position.zw = 1"   								+ "\n" +
		// Create rotation matrix based on rotation angle.
		"cos rotMatrixCol1.x vRotation.x"					+ "\n" + 				
		"sin rotMatrixCol1.y vRotation.x"					+ "\n" +
		"neg rotMatrixCol1.y rotMatrixCol1.y"				+ "\n" +
		"sin rotMatrixCol2.x vRotation.x" 					+ "\n" +
		"cos rotMatrixCol2.y vRotation.x" 					+ "\n" +
		// Set 1 for z and w as they are unused and so compiler does not throw error (won't be used at all.)
		// It is important to use 1 instead of a random value as z and w does affect x and y in some way.
		"rotMatrixCol1.zw = 1"								+ "\n" +
		"rotMatrixCol2.zw = 1"								+ "\n" +
		"vt2 = 1"											+ "\n" +
		// // Rotate that bitch!
		"position.xyz = mul3x3(position, rotMatrixCol1)" 	+ "\n" +	
		"position.z = 1" + "\n" +	
		// // Translate position at origin back to original
		"position.xy += vCenter.xy"							+ "\n" +
		"op = mul4x4(position, finalTransform)"         	+ "\n" +
		"v0 = vTexCoord"                 					+ "\n"         

		public static const ROTATED_TEXTURED_FRAGMENT:String =
		"tex oc, v0, fs0 <2d,nearest>" 		+ "\n";  	// Output the pixel of texture fs0 at coordinates v0

		// ============================================================================================
		// ============================================================================================
		// ============================================================================================

		public static const COLORED_TEXTURED_VERTEX:String =
		"alias va0, vPosition"                      + "\n" +
		"alias va1, vColor"                         + "\n" +
		"alias va2, vTexCoord"                      + "\n" +
		"alias vc0, finalTransform"                 + "\n" +
		"alias  v0, fColor"                         + "\n" +
		"alias  v1, fTexCoord"                      + "\n" +

		"op = mul4x4(vPosition, finalTransform)"    + "\n" +
		"fColor    = vColor"                        + "\n" +
		"fTexCoord = vTexCoord"                     + "\n";

		public static const COLORED_TEXTURED_FRAGMENT:String =
		"alias  v0, fColor"                         + "\n" +
		"alias  v1, fTexCoord"                      + "\n" +
		"alias fs0, texture"                        + "\n" +
		"alias ft0, color"                          + "\n" +

		"tex color, fTexCoord, texture <2d,linear>" + "\n" +
		"oc = color + fColor"                       + "\n";

		// ============================================================================================
		// ============================================================================================
		// ============================================================================================

		public static const SIMPLE_MULT_TEXTURED_VERTEX:String =
		"alias va0, vPosition"                      + "\n" +
		"alias va1, vTexCoord"                      + "\n" +
		"alias vc0, finalTransform"                 + "\n" +
		"alias  v0, fTexCoord"                      + "\n" +

		"op = mul4x4(vPosition, finalTransform)"    + "\n" +
		"fTexCoord = vTexCoord"                     + "\n";

		public static const SIMPLE_MULT_TEXTURED_FRAGMENT:String =
		"alias fc0, fColor"                         + "\n" +
		"alias  v0, fTexCoord"                      + "\n" +
		"alias fs0, texture"                        + "\n" +
		"alias ft0, color"                          + "\n" +

		"tex color, fTexCoord, texture <2d,linear>" + "\n" +
		"oc = color * fColor"                       + "\n";

		// ============================================================================================
		// ============================================================================================
		// ============================================================================================

		public static const SIMPLE_VERTEX:String =
		"op = mul4x4(va0, vc0)" + "\n";

		public static const SIMPLE_FRAGMENT:String =
		"oc = fc0"              + "\n";

		// ============================================================================================
		// ============================================================================================
		// ============================================================================================

		public static const SIMPLE_COLOR_VERTEX:String =
		"m44 op, va0, vc0\n" +
		"v0 = va1\n"	// va1 representing rgba

		public static const SIMPLE_COLOR_FRAGMENT:String =
		"oc = v0\n"

		// ============================================================================================
		// ============================================================================================
		// ============================================================================================

		public static const TEXTURED_FRACTIONAL_VERTEX:String =
		"alias va0, pos"                                      + "\n" +
		"alias va1, texCoords"                                + "\n" +
		"alias vc0, finalTransform"                           + "\n" +
		"alias vc4, textureTransform"                         + "\n" + 

		"op = mul4x4(pos, finalTransform)"                    + "\n" +
		"v0 = mul4x4(texCoords, textureTransform)"            + "\n";  // Scale texture coordinates according to the width 

		public static const TEXTURED_FRACTIONAL_FRAGMENT:String =
		"alias v0, texCoords"                                 + "\n" +
		"alias ft0, repeatedTexCoords"                        + "\n" +
		"alias fs0, textureAltas"                             + "\n" +

		"frc repeatedTexCoords, texCoords"                    + "\n" +
		"tex oc, repeatedTexCoords, textureAltas <2d,linear>" + "\n";

		// ============================================================================================
		// ============================================================================================
		// ============================================================================================

		public static const REGION_SHADER_VERTEX:String =
		"m44 op, va0, vc0\n" + 			// matrix transformation for projection and translation.
		"mov v0, va1\n" 				// move tex coords of base panel to frag shader

		public static const REGION_SHADER_FRAGMENT:String =
		"alias fs0, baseTexture\n" +
		"alias fs1, useTexture\n" +
		"alias v0, UV\n" +
		
		"tex ft0, v0, baseTexture <2d>\n" + 	// ft0 = texture of gray base panel.
		// USE button offset logic.
		"sge ft6, fc7, v0\n" +			// fc7 is offset. set ft6 to 1 only if u or v < 0.
		"add ft6, UV, ft6\n" + 			// add 1 ONLY if u or v < offset.
		"sub ft6, ft6, fc7\n" +			// subtract offset from texture coord stored at ft6 (u or v is 1 if it was originally 0.)
		"tex ft5, ft6, useTexture <2d>\n" +	// get USE button texture
		// Panel colour render logic (alpha blend the corners).
		// ft1, ft2, ft3 and ft4 represents boolean (0 or 1) which indicates whether render the green texture. if any is false, the green's alpha will be 0.
		// vc1.x and vc1.y are offsets defined in the renderRegions function.
		// all it checks is whether the vertices' x and y coords is within the offset's boundary.
		"sge ft1, v0.xxxx, fc2\n" +		// fc2 represents left bound of x
		"sge ft2, v0.yyyy, fc3\n" +		// fc3 represents top bound of y
		"slt ft3, v0.xxxx, fc4\n" +		// fc4 represents right bound of x
		"slt ft4, v0.yyyy, fc5\n" +		// fc5 represents bottom bound of y
		// combines all into one boolean.
		"ft1 *= ft2\n" +
		"ft1 *= ft3\n" +
		"ft1 *= ft4\n" +
		"mul ft1, ft1, ft2\n" +
		"mul ft1, ft1, ft3\n" +
		"mul ft1, ft1, ft4\n" +
		// set the alpha value of the colour to 0 if outside the offset boundary. ft1 now stores the update color.
		"mul ft1, ft1, fc0\n" +
		// multiply colour by a percentage, to simulate animation and idle color
		"mul ft1, ft1, fc6\n" +
		"sub ft2, fc1, ft0.wwww\n" +	// fc1 is (1,1,1,1), use it to obtain 1 - ALPHA and store it in ft2
		"mul ft2, ft1, ft2 \n" +		// ft2 should equal to color OR 0, depending on texture's alpha value. (alpha? = 0 : color)
		"add ft1, ft0, ft2\n" +			// add color to texture. this should effectively alpha blend both color set in fc0 and texture set in fs0.
		"mul ft5, ft5, fc8\n" +			// multiply USE text's alpha by a percentage to simulate animation.
		"add oc, ft1, ft5\n"			// add USE text to texture. this should effectively overwrite other colours as it is white.	

		// ============================================================================================
		// ============================================================================================
		// ============================================================================================

		public static const TEXTURE_ATLAS_SHADER_VERTEX:String =
		"alias va0, pos\n" +
		"alias va1, texCoords\n" +
		"alias va2, textureTypeOffset\n" +
		"alias va3, texLength\n" +
		"alias vc0, finalTransform\n" +

		"op = mul4x4(pos, finalTransform)\n" +
		"v0 = texCoords\n" +
		"v1 = textureTypeOffset\n" +
		"v2 = texLength\n" 

		/* PARAMETER EXPLANATION 
			v0: Texture Coords, FLOAT_2 - Used to determine texture coordinates.
			x Value is expected to be expressed in terms of u = box.w / ATLAS_WIDTH, to get texture coords across the wall.

			v1: textureTypeOffset, FLOAT_1 - Used to get the offset from the left of the texture atlas.
			This is used to get specific textures, like 0 for top texture, 0.7 for corner texture for an example.

			v2: texLength, FLOAT_1 - Used to determine when to loop a texture coords.
			Example: If texLength is 0.7, u will be mapped from 0 - 0.7.
			You can then use textureTypeOffset to get the texture you want.
		*/
		public static const TEXTURE_ATLAS_SHADER_FRAGMENT:String =
		"alias v0,  texCoords\n" +
		"alias v1,  textureTypeOffset\n" +
		"alias v2,  texLength\n" + 
		"alias fc0, CONST_0(1, 0)\n" +
		"alias fs0, textureAtlas\n" +
		//  ===== Repeat the texture coord. ======
		// 1. Scale to 1
		"ft2.x = 1 / texLength.x\n" + 
		"ft1.x = texCoords.x * ft2.x\n" +
		// 2. Get fractional
		"frc ft1.x, ft1.x\n" +
		// 3. Scale back to original
		"ft2.x = 1 / texLength.x\n" +
		"ft1.x = ft1.x / ft2.x\n" +
		// ----------------- End -----------------
		"ft1.x += textureTypeOffset.x\n" +
		"ft1.y = texCoords.y\n" +
		"ft1.zw = 0\n" + // stupid compiler needs me to set all numbers or will count it as invalid register.
		"tex oc, ft1, textureAtlas<2d,linear>\n"

		// ============================================================================================
		// ============================================================================================
		// ============================================================================================

		public function Shader(name:String) {
			this.name = name;
		}
		
		public function addVertexCode(code:String) : void {
			code_vertex = code;
		}
		
		public function addFragmentCode(code:String) : void {
			code_fragment = code;
		}
		
		public function build() : void {
			vertex.assemble(Context3DProgramType.VERTEX, code_vertex, 1);
			fragment.assemble(Context3DProgramType.FRAGMENT, code_fragment, 1);
		}
		
		public function upload(c3d:Context3D) : void {
			program = c3d.createProgram();
			program.upload(vertex.agalcode, fragment.agalcode);
		}
	}
}