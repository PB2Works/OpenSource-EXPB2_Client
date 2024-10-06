package com.pb2.renderer.rendergroup{

    import flash.geom.Matrix3D;

    public interface IRenderGroup
    {
        function getName() : String;
        function setup() : void;
        function render(mainTransform: Matrix3D, pass:uint) : void;
        function free() : void;
    }
}