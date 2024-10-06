package com.pb2.renderer{
    import flash.display3D.textures.RectangleTexture;
	import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DTextureFormat;
    import flash.geom.Rectangle;
    import flash.geom.Point;

    // WallTextures is a class that provides the management of loaded textures, to be used for rendering.
    public class WallTextures {
        // https://eaglepb2.gitbook.io/pb2-editor-manual/tools/add-wall
        /*
            Regular   = 0, 3, 4, 7, 8, 9, 10, 
                        11, 12, 13, 14, 17, 18, 19
            Grasses   = 1, 5, 6
            Rough     = 2, 15, 16, 20

            From Regular:
            No Corners = 12, 19, 4, 7, 8, 9, 17
            Corners = 14, 0, 3, 10, 11, 13, 18
            Bottom = 4, 7, 8, 9, 17, 0, 3, 10, 11, 13, 18
            No Bottom = 12, 19, 14
        */
        public static const CONCRETE:uint           =  0;
        public static const GRASS:uint              =  1;
        public static const SAND:uint               =  2;
        public static const BROWN_CONCRETE:uint     =  3;
        public static const DARK_PLATE:uint         =  4;
        public static const DRY_GRASS:uint          =  5;
        public static const DARK_GRASS:uint         =  6;
        public static const CLEAN_DARK_PLATE:uint   =  7;
        public static const BRIGHT_PLATE:uint       =  8;
        public static const CLEAN_BRIGHT_PLATE:uint =  9;
        public static const USURPATION_PLATE:uint   = 10;
        public static const STRIPES:uint            = 11;
        public static const ASPHALT:uint            = 12;
        public static const WHITE_CONCRETE:uint     = 13;
        public static const PBFTTP_CONCRETE:uint    = 14;
        public static const WET_SAND:uint           = 15;
        public static const MUD:uint                = 16;
        public static const USURPATION_TILE:uint    = 17;
        public static const STONE:uint              = 18;
        public static const WOODS:uint              = 19;
        public static const ROCKS:uint              = 20;
        public static const TOTAL:uint              = 21;

        public static const TOP:uint          = 0;
        public static const BOTTOM:uint       = 1;
        public static const TOP_LEFT:uint     = 2;
        public static const TOP_RIGHT:uint    = 3;
        public static const BOTTOM_LEFT:uint  = 4;
        public static const BOTTOM_RIGHT:uint = 5;

        public var bitMapList:Vector.<Vector.<BitmapData>>;
        public var roughTextureAtlas:RectangleTexture; 
        public var regularTextureAtlas:RectangleTexture;
        public var grassTextureAtlas:RectangleTexture;

        // Loads the required wall texture bitmap for a particular level to bitMapList.
        // Will check if a particular texture is loaded.
        // If a particular texture does not have corner / bottom, it is set to null.
        public function loadBitmap(id: int) : void {
            if(id == -1) return;
            if(bitMapList == null) bitMapList = new Vector.<Vector.<BitmapData>>(21);

            if(bitMapList[id] != null) return; // texture is already loaded.
            bitMapList[id] = new Vector.<BitmapData>(6); // set everything to null at the start.

            switch(id){
                case CONCRETE:
                    bitMapList[id][TOP] = new panel_top();
                    bitMapList[id][BOTTOM] = new panel_bottom();
                    bitMapList[id][TOP_LEFT] = new panel_top_left();
                    bitMapList[id][TOP_RIGHT] = new panel_top_right();
                    bitMapList[id][BOTTOM_LEFT] = new panel_bottom_left();
                    bitMapList[id][BOTTOM_RIGHT] = new panel_bottom_right();
                    break;
                case GRASS:
                    // bitMapList[id][TOP] = new panel_top2();
                    bitMapList[id][TOP] = new panel_top2();
                    bitMapList[id][TOP_LEFT] = new panel_top2a();
                    bitMapList[id][TOP_RIGHT] = new panel_top2b();
                    break;
                case SAND:
                    bitMapList[id][TOP] = new panel_top3();
                    break;
                case BROWN_CONCRETE:
                    bitMapList[id][TOP] = new panel2_top();
                    bitMapList[id][BOTTOM] = new panel2_bottom();
                    bitMapList[id][TOP_LEFT] = new panel_top_left();
                    bitMapList[id][TOP_RIGHT] = new panel_top_right();
                    bitMapList[id][BOTTOM_LEFT] = new panel_bottom_left();
                    bitMapList[id][BOTTOM_RIGHT] = new panel_bottom_right();
                    break;
                case DARK_PLATE:
                    bitMapList[id][TOP] = new panel4_top();
                    bitMapList[id][BOTTOM] = new panel4_bottom();
                    break;
                case DRY_GRASS:
                    bitMapList[id][TOP] = new grass2();
                    bitMapList[id][TOP_LEFT] = new grass2b();
                    bitMapList[id][TOP_RIGHT] = new grass2a();
                    break;
                case DARK_GRASS:
                    bitMapList[id][TOP] = new grass3();
                    bitMapList[id][TOP_LEFT] = new grass3b();
                    bitMapList[id][TOP_RIGHT] = new grass3a();
                    break;
                case CLEAN_DARK_PLATE:
                    bitMapList[id][TOP] = new dark_panel_clean();
                    bitMapList[id][BOTTOM] = new dark_panel_clean_low();
                    break;
                case BRIGHT_PLATE:
                    bitMapList[id][TOP] = new light_panel();
                    bitMapList[id][BOTTOM] = new light_panel_low();
                    break;
                case CLEAN_BRIGHT_PLATE:
                    bitMapList[id][TOP] = new light_panel_clean();
                    bitMapList[id][BOTTOM] = new light_panel_clean_low();
                    break;
                case USURPATION_PLATE:
                    bitMapList[id][TOP] = new usurper_floor();
                    bitMapList[id][BOTTOM] = new usurper_bottom();
                    bitMapList[id][TOP_LEFT] = new usurper_top_left();
                    bitMapList[id][TOP_RIGHT] = new usurper_top_right();
                    bitMapList[id][BOTTOM_LEFT] = new usurper_bottom_left();
                    bitMapList[id][BOTTOM_RIGHT] = new usurper_bottom_right();
                    break;
                case STRIPES:
                    bitMapList[id][TOP] = new industrial();
                    bitMapList[id][BOTTOM] = new industrial();
                    bitMapList[id][TOP_LEFT] = new indrustrial_left();
                    bitMapList[id][TOP_RIGHT] = new indrustrial_right();
                    bitMapList[id][BOTTOM_LEFT] = new indrustrial_bottom_left();
                    bitMapList[id][BOTTOM_RIGHT] = new indrustrial_bottom_right();
                    break;
                case ASPHALT:
                    bitMapList[id][TOP] = new asphalt();
                    break;
                case WHITE_CONCRETE:
                    bitMapList[id][TOP] = new white_concrete();
                    bitMapList[id][BOTTOM] = new white_concrete_underside();
                    bitMapList[id][TOP_LEFT] = new white_concrete_top_right(); // not a typo, eric named it wrongly.
                    bitMapList[id][TOP_RIGHT] = new white_concrete_top_left();
                    bitMapList[id][BOTTOM_LEFT] = new white_concrete_bottom_left();
                    bitMapList[id][BOTTOM_RIGHT] = new white_concrete_bottom_right();
                    break;
                case PBFTTP_CONCRETE:
                    bitMapList[id][TOP] = new pbfttp_concrete();
                    bitMapList[id][TOP_LEFT] = new pbfttp_corner_left();
                    bitMapList[id][TOP_RIGHT] = new pbfttp_corner_right();
                    break;
                case WET_SAND:
                    bitMapList[id][TOP] = new wet_sand();
                    break;
                case MUD:
                    bitMapList[id][TOP] = new mud();
                    break;
                case USURPATION_TILE:
                    bitMapList[id][TOP] = new usurper2_bottom(); // not a typo, eric named it wrongly.
                    bitMapList[id][BOTTOM] = new usurper2_ceiling();
                    break;
                case STONE:
                    bitMapList[id][TOP] = new stone_bricks();
                    break;
                case WOODS:
                    bitMapList[id][TOP] = new wood_tex();
                    break;
                case ROCKS:
                    bitMapList[id][TOP] = new rocks();
                    break;
                default:
                    throw new Error("Invalid wall texture ID provided! ID: " + id);
                    break;
            }
        }

        // Allows us to get the offset value from a given texture ID.
        public function regularIDtoIndex(id: uint): int{
            const MAP:Object = {
                0:  0,
                3:  1,
                4:  2,
                7:  3,
                8:  4,
                9:  5,
                10: 6,
                11: 7,
                12: 8,
                13: 9,
                14: 10,
                17: 11,
                18: 12,
                19: 13
            };

            return MAP[id];
        }

        // Allows us to loop through regularIDs.
        private function indexToRegularID(id: uint): int{
            const MAP:Object = {
                0:  0,
                1:  3,
                2:  4,
                3:  7,
                4:  8,
                5:  9,
                6:  10,
                7:  11,
                8:  12,
                9:  13,
                10: 14,
                11: 17,
                12: 18,
                13: 19
            };

            return MAP[id];
        }

        public function grassIDtoIndex(id: uint): uint{
            const MAP:Object = {
                1: 0,
                5: 1,
                6: 2
            };

            return MAP[id];
        }

        private function indexToGrassID(id: uint): uint{
            const MAP:Object = {
                0: 1,
                1: 5,
                2: 6
            };

            return MAP[id];
        }

        public function getGrassTextureAtlasWidth() : uint {
            return 133 + 28 + 44;
        }

        public function getGrassTextureAtlasHeight() : uint {
            return 37 * 3; // height of all 3 grass tex
        }

        private function createGrassTextureAtlas(c3d: Context3D) : void {
            const HEIGHT:uint = 37;
            const TOTAL_HEIGHT:uint = HEIGHT * 3; // 3 types of grass
            const TOP_WIDTH:uint = 133;
            const TOP_LEFT_WIDTH:uint = 28;
            const TOP_RIGHT_WIDTH:uint = 44;

            const finalBmp:BitmapData = new BitmapData(TOP_WIDTH + TOP_LEFT_WIDTH + TOP_RIGHT_WIDTH, TOTAL_HEIGHT, true, 0);

            var startPoint:Point;
            var grassID:uint;

            // Create the main texture atlas bitmap.
            // Loops through all the grass texture and draw it's respective top and corners
            for(var i:uint = 0; i < 3; i++){
                grassID = indexToGrassID(i);
                if(bitMapList[grassID] == null) continue; // texture not loaded.

                // We will start drawing texture's top.
                startPoint = new Point(0, i * HEIGHT);
                finalBmp.copyPixels(bitMapList[grassID][TOP], new Rectangle(0, 0, TOP_WIDTH, HEIGHT), startPoint);

                // Drawing texture's top corners.
                if(bitMapList[grassID][TOP_LEFT]){
                    startPoint = new Point(TOP_WIDTH, i * HEIGHT); // after top
                    finalBmp.copyPixels(bitMapList[grassID][TOP_LEFT], new Rectangle(0, 0, TOP_WIDTH, HEIGHT), startPoint);

                    startPoint = new Point(TOP_WIDTH + TOP_LEFT_WIDTH, i * HEIGHT); // after top + 1 corner
                    finalBmp.copyPixels(bitMapList[grassID][TOP_RIGHT], new Rectangle(0, 0, TOP_WIDTH, HEIGHT), startPoint);
                }       
            }

            // Create RectangleTexture from texture atlas bitmap.
            grassTextureAtlas = c3d.createRectangleTexture(TOP_WIDTH + TOP_LEFT_WIDTH + TOP_RIGHT_WIDTH, TOTAL_HEIGHT, Context3DTextureFormat.BGRA, false);
            grassTextureAtlas.uploadFromBitmapData(finalBmp);
        }

        // Creates rough wall texture atlas. Dimensions: From top to bottom.   
        public function createRoughTextureAtlas(c3d: Context3D) : void {
            const WIDTH:uint = 219;
            const HEIGHT:uint = 4 * 26; // 4 rough surfaces stored vertically. Each texture is offset by 26 pixels.
            const finalBmp:BitmapData = new BitmapData(WIDTH, HEIGHT, true, 0);
            const areaDrawn:Rectangle = new Rectangle(0, 0, WIDTH, 26);
            var startPoint:Point;

            if(bitMapList[SAND] != null){
                startPoint = new Point(0, 0);
                finalBmp.copyPixels(bitMapList[SAND][TOP], areaDrawn, startPoint);
            }
            
            if(bitMapList[WET_SAND] != null){
                startPoint = new Point(0, 26);
                finalBmp.copyPixels(bitMapList[WET_SAND][TOP], areaDrawn, startPoint);
            }

            if(bitMapList[MUD] != null){
                startPoint = new Point(0, 52);
                finalBmp.copyPixels(bitMapList[MUD][TOP], areaDrawn, startPoint);
            }

            if(bitMapList[ROCKS] != null){
                startPoint = new Point(0, 78);
                finalBmp.copyPixels(bitMapList[ROCKS][TOP], areaDrawn, startPoint);
            }

            roughTextureAtlas = c3d.createRectangleTexture(WIDTH, HEIGHT, Context3DTextureFormat.BGRA, false);
            roughTextureAtlas.uploadFromBitmapData(finalBmp);
        }

        public function getRegTextureAtlasWidth() : uint {
            return (2 * 120) + (4 * 12); // top & bottom texture width = 120, corners = 12 each.
        }

        public function getRegTextureAtlasHeight() : uint {
            return 16 * 14; // height of all 14 reg tex = 16
        }

        private function createRegularTextureAtlas(c3d: Context3D) : void {
            const WIDTH:uint = getRegTextureAtlasWidth();
            const HEIGHT:uint = getRegTextureAtlasHeight();
            const SURFACEAREA:Rectangle = new Rectangle(0, 0, 120, 16);
            const CORNERAREA:Rectangle = new Rectangle(0, 0, 12, 16); 
            const SURFACE_WIDTH:uint = 120;
            const CORNER_WIDTH:uint = 12;

            const finalBmp:BitmapData = new BitmapData(WIDTH, HEIGHT, true, 0);

            var startPoint:Point;
            var regularID:int;

            // Create the main texture atlas bitmap.
            // Loops through all the regular and draw it's respective top, bottom and corner texture if it exist.
            for(var i:uint = 0; i < 14; i++){
                regularID = indexToRegularID(i);
                if(bitMapList[regularID] == null) continue; // texture not loaded.

                // We will start drawing texture's top.
                startPoint = new Point(0, i * 16);
                finalBmp.copyPixels(bitMapList[regularID][TOP], SURFACEAREA, startPoint);

                // Drawing texture's top corners.
                if(bitMapList[regularID][TOP_LEFT]){
                    startPoint = new Point(SURFACE_WIDTH, i * 16); // after top
                    finalBmp.copyPixels(bitMapList[regularID][TOP_LEFT], CORNERAREA, startPoint);

                    startPoint = new Point(SURFACE_WIDTH + 12, i * 16); // after top + 1 corner
                    finalBmp.copyPixels(bitMapList[regularID][TOP_RIGHT], CORNERAREA, startPoint);
                }

                // Drawing texture's bottom.
                if(bitMapList[regularID][BOTTOM]){
                    startPoint = new Point(SURFACE_WIDTH + 2 * CORNER_WIDTH, i * 16); // after top and 2 corners.
                    finalBmp.copyPixels(bitMapList[regularID][BOTTOM], SURFACEAREA, startPoint);
                }

                // Drawing texture's bottom corners.
                if(bitMapList[regularID][BOTTOM_LEFT]){
                    startPoint = new Point(2 * SURFACE_WIDTH + 2 * CORNER_WIDTH, i * 16); // after top & bottom + 2 corners
                    finalBmp.copyPixels(bitMapList[regularID][BOTTOM_LEFT], CORNERAREA, startPoint);

                    startPoint = new Point(2 * SURFACE_WIDTH + 3 * CORNER_WIDTH, i * 16); // after top & bottom + 3 corners
                    finalBmp.copyPixels(bitMapList[regularID][BOTTOM_RIGHT], CORNERAREA, startPoint);
                }          
            }

            // Create RectangleTexture from texture atlas bitmap.
            regularTextureAtlas = c3d.createRectangleTexture(WIDTH, HEIGHT, Context3DTextureFormat.BGRA, false);
            regularTextureAtlas.uploadFromBitmapData(finalBmp);
        }

        // Creates the required texture after loading all the bitmaps.
        public function createTextures(c3d: Context3D) : void {
            if(bitMapList == null) throw new Error("Texture bitmap has not been loaded!");
            
            createRoughTextureAtlas(c3d);
            createRegularTextureAtlas(c3d);
            createGrassTextureAtlas(c3d);
        }

        public function unloadTexture() : void {
            for each (var list:Vector.<BitmapData> in bitMapList) {
                if (list == null) continue;
                for each (var bmp:BitmapData in list) {
                    if (bmp == null) continue;
                    bmp.dispose();
                }
            }
            bitMapList = null;

            roughTextureAtlas.dispose();
            roughTextureAtlas = null;
            regularTextureAtlas.dispose();
            regularTextureAtlas = null;
            grassTextureAtlas.dispose();
            grassTextureAtlas = null;
        }

        public function isGrass(id:int) : Boolean {
            if(id == -1) return false;
            return id == GRASS || id == DRY_GRASS || id == DARK_GRASS;
        }

        public function isRough(id:int) : Boolean {
            if(id == -1) return false;
            return id == SAND || id == WET_SAND || id == MUD || id == ROCKS;
        }

        public function isRegular(id:int) : Boolean {
            if(id == -1) return false;
            return !(isGrass(id) || isRough(id));
        }
        
        public function hasCorner(id: int) : Boolean {
            if(id == -1 || !isRegular(id)) throw new Error("Wall texture is not of regular type! ID: " + id);

            if(
                id == ASPHALT || id == WOODS || id == DARK_PLATE || id == CLEAN_DARK_PLATE || 
                id == BRIGHT_PLATE || id == CLEAN_BRIGHT_PLATE || id == USURPATION_TILE
            ) return false;
            return true;
        }

        public function hasBottom(id: int) : Boolean {
            if(id == -1 || !isRegular(id)) throw new Error("Wall texture is not of regular type! ID: " + id);
            if(id == ASPHALT || id == WOODS || id == PBFTTP_CONCRETE) return false;
            return true;
        }
    }
}