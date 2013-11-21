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

package
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.system.Capabilities;
	
	import core.RootClass;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.extensions.brinkbit.fullscreenscreenextension.FullScreenExtension;
	import starling.utils.AssetManager;
	
	public class FullScreenExample extends Sprite
	{
		public function FullScreenExample()
		{
			super();
			// just some odd air exception handling
			if (stage)
				start();
			else 
				addEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:flash.events.Event):void {
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToStage);
			start();
		}
		
		private function start():void {
			Starling.handleLostContext = true;
			
			//load assets
			var appDir:File = File.applicationDirectory;
			var assets:AssetManager = new AssetManager();
			assets.verbose = Capabilities.isDebugger;
			assets.enqueue(
				appDir.resolvePath("textures")
			);
			
			// create the Starling instance
			var mStarling:Starling = FullScreenExtension.createStarling(RootClass, stage, 760, 1180);
			mStarling.enableErrorChecking = Capabilities.isDebugger;
			
			// load assets and start Starling
			mStarling.addEventListener(starling.events.Event.ROOT_CREATED, 
				function onRootCreated(event:Object, root:RootClass):void
				{
					root.start(assets);
					mStarling.start();
				});
			
			// handle application stopping and starting
			NativeApplication.nativeApplication.addEventListener(flash.events.Event.ACTIVATE, 
				function (e:flash.events.Event):void { mStarling.start(); });
			
			NativeApplication.nativeApplication.addEventListener(flash.events.Event.DEACTIVATE, 
				function (e:flash.events.Event):void { mStarling.stop(); });
			
		}
	}
}