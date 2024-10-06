package com.pb2.renderer.rendergroup.Particles
{
    import flash.geom.Transform;
    import flash.display.MovieClip;
    import flash.text.TextField;

    // Instead of using movieclips to store data, which tends to be extremely laggy, stage3D will use this PB2Particles class
    // which micmick the particle effect movieclips stored in ef. 
    public class PB2Particle{

        public static const BLOOD:uint                 = 0;
        public static const BULLET_HIT:uint            = 1;
        public static const BUBBLE:uint                = 2;
        public static const SPLASH:uint                = 3;
        public static const EXPLOSION:uint             = 4;
        public static const LITE_RAIL:uint             = 5;
        public static const RAIL_HIT:uint              = 6;
        public static const FIRE_SPARK:uint            = 7;
        public static const METAL:uint                 = 8;
        public static const BLOOD_SPRITE:uint          = 10;
        public static const EXPLOSION_BFG:uint         = 11;
        public static const WOOD_DEBRIS:uint           = 12;
        public static const KINETIC:uint               = 13;
        public static const TELEPORT:uint              = 14;
        public static const EXPLOSION_UNDERWATER:uint  = 15;
        public static const EXPLOSION_PLASMA:uint      = 16;
        public static const HEAVY_RAIL:uint            = 17;
        public static const EXPLOSION_PLASMA_BAR:uint  = 18;
        public static const NO_VIOLENCE_BLOOD:uint     = 19;
        public static const TEXT_MSG:uint              = 20;
        public static const RED_LASER:uint             = 21;
        public static const ORANGE_RAIL:uint           = 22;
        public static const GREEN_RAIL:uint            = 23;
        public static const BLUE_LASER:uint            = 24;

        // id will equal to bullet's nextef
        public var id: uint;

        // type equals to one of the constants above
        public var type: uint;

        // totalFrames = movieclip.totalFrames - 1. this is because the last frame of every particle effect movieclip is empty and is used for stop().
        public var totalFrames:uint;    

        // we will be manually incrementing currentFrame and animate based on it.
        public var currentFrame:uint;   

        // Movieclip / DisplayObject properties
        public var x:Number;
        public var y:Number;
        public var rotation:Number;
        public var scaleX:Number;
        public var scaleY:Number;
        public var alpha:Number;
        public var transform:Transform;

        // Custom / dynamic properties
        public var life:Number;
        public var tox:Number;
        public var toy:Number;
        public var toang:Number;
        public var typ:uint;        // typ represents classes of particles. Effect logic will handle different typs accordingly. typ = 0 has nothing to update.
        public var float_frame:int;
        public var framespeed:Number;

        // Specifically for wood debris
        public var picc:uint;       // represents rotation of debries. random of 1 2 or 3.

        // TEXT_MSG
        public var msgtext:TextField;
        public var strquad:Object;
        public var attached:int;

        public function PB2Particle(id: uint, type: uint){
            this.currentFrame = 0;  // will range from 1 to totalFrames
            this.id = id;
            this.type = type;

            scaleX = 1;
            scaleY = 1;
            alpha = 1;
            rotation = 0;

            if(type == TEXT_MSG){
                msgtext = new TextField();
                strquad = {};
            }
        }


        private static var initialMcStats:Vector.<Array>;

        // giving my index a name
        public static const TOTALFRAMES:uint = 0;
        public static const TRANSFORM:uint = 1;

        // PB2Particle needs some form of a way to retrieve the inital stats of the particle's movieclip for rendering.
        // For an example, the totalFrames is unique across particle movieclips and needs to be retrieved when game starts,
        // Is invoked in AcceleratedRender.init()
        public static function setMcStats() : void {

            // ok i know its a waste of memory that i didnt use one index (9) but i want this to work nicely with the type variable ok :(
            const listOfParticles:Vector.<MovieClip> = new <MovieClip>[
                new eff_blood(),
                new eff_iskra(),
                new eff_bubble(),
                new eff_splash(),
                new explosion_fire(),
                new rail(),
                new rail_target(),
                new eff_firespark(),
                new eff_metal(),
                null,
                new eff_blood_sprite(),
                new explosion_bfg(),
                new eff_wood_debris(),
                new eff_cinetic(),
                new eff_teleport(),
                new explosion_underwater(),
                new explosion_plasma(),
                new rail2(),
                new explosion_plasma_bar(),
                new altblood(),
                new eff_text_message(),
                new rail3(),
                new rail4(),
                new rail5(),
                new rail6()
            ];
            
            initialMcStats = new Vector.<Array>(listOfParticles.length);

            var particleType:uint = 0;
            for each(var particle:MovieClip in listOfParticles){
                if(particle) {
                    initialMcStats[particleType] = new Array(2);    

                    initialMcStats[particleType][TOTALFRAMES] = particle.totalFrames;
                    initialMcStats[particleType][TRANSFORM] = particle.transform;
                };

                particleType++;
            }
        }

        // retrieves the requested movieclip info based on it's particle type.
        public static function getMcStats(type: uint, info: uint) : *{
            return initialMcStats[type][info];
        }
    }
}