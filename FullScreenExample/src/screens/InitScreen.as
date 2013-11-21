// ===============================================================================
//	Copyright (c) 2013 Brinkbit Apps & Games
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

package screens
{		
	import core.RootClass;
	
	import feathers.controls.Screen;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	
	
	public class InitScreen extends Screen
	{
		// ----------------- public API --------------------- //
		
		public function InitScreen()
		{
			super();	
		}	
		
		// ----------------- protected API --------------------- //
		
		override protected function initialize():void {
			super.initialize();
			
			FullScreenExtension.stageColor = 0xffffff;
			FullScreenExtension.addEventListener(TouchEvent.TOUCH, touched);
			
			// we add this listener so when the device reorients the objects automatically get repositioned
			FullScreenExtension.addEventListener(starling.events.Event.RESIZE, onResize);
			
			// create a bunch of images
			battleStartImg = new Image(RootClass.assets.getTexture("BattleStart"));
			addChild(battleStartImg);
			
			leftUIImg = new Image(RootClass.assets.getTexture("UILeft"));
			addChild(leftUIImg);
			
			rightUIImg = new Image(RootClass.assets.getTexture("UIRight"));
			addChild(rightUIImg);
			
			spaceBarLogo = new Image(RootClass.assets.getTexture("SpaceBarLogo"));
			addChild(spaceBarLogo);
			
			positionImages();
		}
		
		// ----------------- private API --------------------- //
		
		private var battleStartImg:Image;
		private var leftUIImg:Image;
		private var rightUIImg:Image;
		private var spaceBarLogo:Image;	
		
		private function positionImages():void {
			
			// align to the top center of the stage
			battleStartImg.x = (FullScreenExtension.stageWidth - battleStartImg.width) >> 1;
			battleStartImg.y = FullScreenExtension.stageTop;
			
			// align to the bottom left of the screen
			leftUIImg.x = FullScreenExtension.screenLeft;
			leftUIImg.y = FullScreenExtension.screenBottom - leftUIImg.height;
			
			// align to the bottom right of the screen
			rightUIImg.x = FullScreenExtension.screenRight - rightUIImg.width;
			rightUIImg.y = FullScreenExtension.screenBottom - rightUIImg.height;
			
			// align to the center of the stage
			spaceBarLogo.x = (FullScreenExtension.stageWidth - spaceBarLogo.width) >> 1;
			spaceBarLogo.y = (FullScreenExtension.stageHeight - spaceBarLogo.height) >> 1;
		}
		
		private function touched(event:TouchEvent):void {
			var touch:Touch = event.getTouch(Starling.current.stage);
			if (touch && touch.phase == TouchPhase.ENDED) {
				// show and hide the stage bounds when the screen is touched
				FullScreenExtension.showStageBounds = FullScreenExtension.showStageBounds ? false : true;
			}
		}
		
		private function onResize(event:ResizeEvent):void {
			positionImages();
		}
		
	}
}