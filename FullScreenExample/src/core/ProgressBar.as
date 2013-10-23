// ===============================================================================
//	Copyright (c) 2013 SpaceBar Apps & Games
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//		
//		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
// ===============================================================================

package core
{
    import flash.display.BitmapData;
    import flash.display.Shape;
    
    import starling.core.Starling;
    import starling.display.Image;
    import starling.display.Quad;
    import starling.display.Sprite;
    import starling.textures.Texture;

    public class ProgressBar extends Sprite
    {
        private var mBar:Quad;
        private var mBackground:Image;
		
        public function ProgressBar(width:int, height:int)
        {
            init(width, height);
        }
		
        
        private function init(width:int, height:int):void
        {	
			
			var scale:Number = Starling.contentScaleFactor;
            var padding:Number = height * 0.2;
            var cornerRadius:Number = padding * scale * 2;
            
            // create black rounded box for background
            
            var bgShape:Shape = new Shape();
            bgShape.graphics.beginFill(0x0, 0.6);
            bgShape.graphics.drawRoundRect(0, 0, width*scale, height*scale, cornerRadius, cornerRadius);
            bgShape.graphics.endFill();
            
            var bgBitmapData:BitmapData = new BitmapData(width*scale, height*scale, true, 0x0);
            bgBitmapData.draw(bgShape);
            var bgTexture:Texture = Texture.fromBitmapData(bgBitmapData, false, false, scale);
            
            mBackground = new Image(bgTexture);
            addChild(mBackground);
            
            // create progress bar quad
            
            mBar = new Quad(width - 2*padding, height - 2*padding, 0xe41e25);
            mBar.setVertexColor(2, 0x8e191c);
            mBar.setVertexColor(3, 0x8e191c);
            mBar.x = padding;
            mBar.y = padding;
            mBar.scaleX = 0;
            addChild(mBar);
        }
        
        public function get ratio():Number { return mBar.scaleX; }
        public function set ratio(value:Number):void 
        { 
            mBar.scaleX = Math.max(0.0, Math.min(1.0, value)); 
        }
    }
}