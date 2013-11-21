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

package core
{
	import feathers.controls.ScreenNavigatorItem;
	import feathers.motion.transitions.ScreenSlidingStackTransitionManager;
	
	import screens.InitScreen;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.utils.AssetManager;
	
	
	public class RootClass extends Sprite
	{
		// ----------------- public API --------------------- //
		
		public static const SCREEN_INIT:String = "SCREEN_INIT";
		
		public static function get assets():AssetManager { return sAssets; }
		
		// public non-static
		
		public function RootClass()
		{
			//init
		}
		
		public function start(assets:AssetManager):void
		{
			sAssets = assets;
			
			var progressBar:ProgressBar = new ProgressBar(175, 20);
			progressBar.x = (FullScreenExtension.stageWidth  - progressBar.width)  / 2;
			progressBar.y = FullScreenExtension.stageHeight * 0.85;
			addChild(progressBar);
			
			assets.loadQueue(function onProgress(ratio:Number):void { 
				progressBar.ratio = ratio;
				if (ratio == 1)
					Starling.juggler.delayCall(function():void {
						Starling.current.nativeStage.color=0x000000;
						progressBar.removeFromParent(true);
						
						initScreens();
					}, 0.15);
			});
				
		}
		
		// ----------------- private API --------------------- //
		
		private static var sAssets:AssetManager;
		
		// private non-static
		
		private var _transitionManager:ScreenSlidingStackTransitionManager;
		
		private function initScreens():void
		{
			FullScreenExtension.stage.addChild(ScreenNavigator.instance);
			
			//add all the screens
			ScreenNavigator.instance.addScreen(SCREEN_INIT, new ScreenNavigatorItem(InitScreen))
			
			//setup transition manager
			this._transitionManager = new ScreenSlidingStackTransitionManager(ScreenNavigator.instance);
			this._transitionManager.duration = 1;
			
			//go to first view
			ScreenNavigator.instance.showScreen(SCREEN_INIT);
		}
	}
}