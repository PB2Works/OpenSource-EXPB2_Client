package
{
   import flash.accessibility.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.net.drm.*;
   import flash.system.*;
   import flash.text.*;
   import flash.text.ime.*;
   import flash.ui.*;
   import flash.utils.*;
   
   public dynamic class gun_arifle extends MovieClip
   {
       
      
      public function gun_arifle()
      {
         super();
      }
      
      public function onmade() : void
      {
         this.wep = 2;
         this.zpos = 7;
         this.ready = true;
         this.attachment = 1;
         this.xpos1 = 0.5;
         this.xpos2 = 1;
         this.stat_power = 1.3;
         this.stat_count = 1;
         this.stat_averange = 0.02;
         this.stat_averange_min = 0;
         this.stat_averange_max = 0.2;
         this.stat_averange_add = 0.08;
         this.stat_averange_substract = 0.01;
         this.stat_bullets = 4;
         this.stat_class = 0;
         this.sou = MovieClip(root).s_wea_rifle_alt;
         this.stat_cursor = 0;
         if(!MovieClip(root).MP_mode)
         {
            if(this.upg == 0)
            {
               this.stat_averange *= 1.5;
               this.stat_power *= 0.5;
            }
            if(this.upg == 1)
            {
               this.stat_averange *= 1.25;
               this.stat_power *= 0.75;
            }
            if(this.upg == 2)
            {
               this.stat_averange *= 1;
               this.stat_power *= 1;
            }
            if(this.upg == 3)
            {
               this.stat_averange *= 0.5;
               this.stat_power *= 1.2;
            }
         }
         this.len1 = 0;
         this.len2 = 30;
         this.size1 = 7;
         this.size2 = 4;
         this.cost = 1400;
         this.costupg = 300;
         this.forcars = false;
         MovieClip(root).create_gun(this);
         this.gotoAndStop(2);
      }
      
      public function frame1() : *
      {
      }
      
      public function frame12() : *
      {
         this.ready = true;
         this.gotoAndStop(2);
      }
   }
}
