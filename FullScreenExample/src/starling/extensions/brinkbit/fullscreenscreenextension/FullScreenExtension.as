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

package starling.extensions.brinkbit.fullscreenscreenextension
{
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.utils.HAlign;
	import starling.utils.MatrixUtil;
	import starling.utils.RectangleUtil;
	import starling.utils.ScaleMode;
	import starling.utils.VAlign;
	
	/**
	 * A static class to simplify multi-resolution support in Starling. When creating a new instance of Starling, call
	 * <code>ScreenExtension.createStarling()</code> instead of <code>new Starling()</code>.
	 * 
	 * <p>See <a href="http://spacebarup.com">http://spacebarup.com</a> for tutorials and more information.</p>
	 */
	public class FullScreenExtension {
		
		// ----------------- public API --------------------- //
		
		/**
		 * Creates a new instance of Starling and initializes the stage.
		 * 
		 * @param rootClass A subclass of a Starling display object. It will be created as soon as initialization 
		 * is finished and will become the first child of the Starling stage.
		 * @param flashStage The Flash (2D) stage.
		 * @param width The width of the ScreenExtension stage.
		 * @param height The height of the ScreenExtension stage.
		 * @param horizontalGravity The horizontal alignment of the stage relative to the screen. Accepts HAlign constants.
		 * @default "center"
		 * @param verticalGravity The vertical alignment of the stage relative to the screen. Accepts VAlign constants.
		 * @default "center"
		 * @param manuallySize Turns off autoResizing. If true, the screen and stage will not be positioned or sized until you manually
		 * call resize();
		 * @default false
		 */
		static public function createStarling(rootClass:Class, 
											  flashStage:flash.display.Stage, 
											  width:int, 
											  height:int, 
											  horizontalGravity:String="center",
											  verticalGravity:String="center", 
											  manuallySize:Boolean=false):Starling {
			if (_starling != null)
				return _starling;
			if (horizontalGravity != HAlign.LEFT && horizontalGravity != HAlign.CENTER && horizontalGravity != HAlign.RIGHT)
				throw new Error("Illegal horizontal gravity: '"+horizontalGravity+"'");
			if (verticalGravity != VAlign.TOP && verticalGravity != VAlign.CENTER && verticalGravity != VAlign.BOTTOM)
				throw new Error("Illegal vertical gravity: '"+verticalGravity+"'");
			if (width <= 0)
				throw new Error("Illegal width: '"+width+"'");
			if (height <= 0)
				throw new Error("Illegal height: '"+height+"'");
			
			// we don't actually do anything with the size yet, instead we wait for the resize event
			// which will be triggered in starling's constructor. For now we just create everything
			// and add it to the stage.
			var screenViewPort:Rectangle = new Rectangle(0, 0, 1, 1);
			_starling = new Starling(rootClass, flashStage, screenViewPort);
			_stage = new starling.extensions.brinkbit.fullscreenscreenextension.Stage(1, 1, flashStage.color);
			autoResize = !manuallySize;
			
			// we need this inBetweener so that we can position the stage object because
			// Starling obscures the x and y properties from us
			_inBetweener = new Sprite();
			_inBetweener.addChild(_stage);
			
			// set stage variables
			_stageWidth = width;
			_stageHeight = height;
			_horizontalGravity = horizontalGravity;
			_verticalGravity = verticalGravity;
			_starling.stage.addChild(_inBetweener);
			_bounds = new Shape();
			
			return _starling;
		}
		
		/**
		 * Resize and position the stage. Optionally resize the viewport of the screen.
		 * 
		 * @param width The width of the stage.
		 * @param height The height of the stage.
		 * @param horizontalGravity The horizontal alignment of the stage.
		 * @param verticalGravity The vertical alignment of the stage.
		 * @param newScreenWidth The width of the starling viewport. If less than or equal to zero, the current screenWidth value
		 * will be used.
		 * @default 0
		 * @param newScreenHeight The height of the starling viewport. If less than or equal to zero, the current screenHeight value
		 * will be used.
		 * @default 0
		 */
		static public function resize(width:Number, 
									  height:Number, 
									  horizontalGravity:String,
									  verticalGravity:String, 
									  newScreenWidth:Number=0, 
									  newScreenHeight:Number=0):void {	
			var updateScreenViewport:Boolean = newScreenWidth > 0 || newScreenHeight > 0;
			if (newScreenWidth <= 0)
				newScreenWidth = _screenWidth;
			if (newScreenHeight <= 0)
				newScreenHeight = _screenHeight;
			
			var screenViewPort:Rectangle = new Rectangle(0, 0, newScreenWidth, newScreenHeight);
			var stageViewPort:Rectangle = RectangleUtil.fit(
				new Rectangle(0, 0, width, height), 
				screenViewPort,
				ScaleMode.SHOW_ALL);
			
			// round everything up
			width = Math.ceil(width);
			height = Math.ceil(height);
			screenViewPort.width = Math.ceil(screenViewPort.width);
			screenViewPort.height = Math.ceil(screenViewPort.height);
			stageViewPort.width = Math.ceil(stageViewPort.width);
			stageViewPort.height = Math.ceil(stageViewPort.height);
			
			if (updateScreenViewport)
				Starling.current.viewPort = screenViewPort;
			_screenWidth = Math.ceil((screenViewPort.width-stageViewPort.width)*height/screenViewPort.height+width);
			_screenHeight = Math.ceil((screenViewPort.height-stageViewPort.height)*width/screenViewPort.width+height);
			_starling.stage.stageWidth = _screenWidth;
			_starling.stage.stageHeight = _screenHeight;
			_stage.stageWidth = width;
			_stage.stageHeight = height;
			
			if (horizontalGravity == null)
				horizontalGravity = _horizontalGravity;
			if (verticalGravity == null)
				verticalGravity = _verticalGravity;
			
			switch (horizontalGravity) { 
				case HAlign.LEFT: 
					_inBetweener.x = 0;
					_screenLeft = 0;
					_screenRight = _starling.stage.stageWidth;
					break; 
				case HAlign.CENTER: 
					_inBetweener.x = Math.round((_starling.stage.stageWidth-width)>>1); 
					_screenLeft = -_inBetweener.x;
					_screenRight = width+_inBetweener.x;
					break;
				case HAlign.RIGHT: 
					_inBetweener.x = _starling.stage.stageWidth-width;
					_screenLeft = -_inBetweener.x*2;
					_screenRight = width;
					break;
				default:
					throw new Error("Illegal horizontal gravity: '"+horizontalGravity+"'");
			}
			switch (verticalGravity) {
				case VAlign.TOP: 
					_inBetweener.y = 0; 
					_screenTop = 0;
					_screenBottom = _starling.stage.stageHeight;
					break;
				case VAlign.CENTER: 
					_inBetweener.y = Math.round((_starling.stage.stageHeight-height)>>1); 
					_screenTop = -_inBetweener.y;
					_screenBottom = height+_inBetweener.y;
					break;
				case VAlign.BOTTOM: 
					_inBetweener.y = _starling.stage.stageHeight-height; 
					_screenTop = -_inBetweener.y*2;
					_screenBottom = height;
					break;
				default:
					throw new Error("Illegal vertical gravity: '"+verticalGravity+"'");
			}
			_stageWidth = width;
			_stageHeight = height;
			_horizontalGravity = horizontalGravity;
			_verticalGravity = verticalGravity;
			
			// update bounds drawing
			_bounds.graphics.clear();
			_bounds.graphics.lineStyle(1, 0xFF0000, 1);
			_bounds.graphics.drawRect(-_screenLeft, -_screenTop, _stageWidth, _stageHeight);
		}
		
		/**
		 * Indicates if the view should automatically update its dimensions when the device changes orientation.
		 * @default true
		 */
		static public function get autoResize():Boolean { return _autoResize; }
		
		/**
		 * Translates native stage coordinates to FullScreenExtension.stage coordinates
		 * 
		 * @param x The native x coordinate to transform
		 * @param y The native y coordinate to transform
		 * @param result The result coordinates in local space
		 */
		static public function nativeToLocal(x:Number, y:Number, result:Point=null):Point {
			if (result == null)
				result = new Point();
			
			const starlingViewPort:Rectangle = Starling.current.viewPort;
			result.x = map((x - starlingViewPort.x), 0, _nativeWidth, 0, screenWidth);
			result.y = map((y - starlingViewPort.y), 0, _nativeHeight, 0, screenHeight);
			
			return result;
		}
		
		/**
		 * Translates FullScreenExtension.stage coordinates to native stage coordinates
		 * 
		 * @param x The local starling x coordinate to transform
		 * @param y The local starling y coordinate to transform
		 * @param result The result coordinates in native stage space
		 */
		static public function localToNative(x:Number, y:Number, result:Point=null):Point {
			if (result == null)
				result = new Point();
			
			const starlingViewPort:Rectangle = Starling.current.viewPort;
			const savedNativeStage:flash.display.Stage = Starling.current.nativeStage;
			
			_stage.getTransformationMatrix(_stage, HELPER_MATRIX);
			MatrixUtil.transformCoords(HELPER_MATRIX, x, y, HELPER_POINT);
			result.x = starlingViewPort.x + (HELPER_POINT.x * Starling.contentScaleFactor);
			result.y = starlingViewPort.y + (HELPER_POINT.y * Starling.contentScaleFactor);
			
			return null;
		}
		
		/**
		 * Pans the top-most Starling stage by the given values.
		 * 
		 * @param x The amount to pan horizontally
		 * @param y The amount to pan vertically
		 */
		static public function pan(x:int, y:int):void {
			_inBetweener.x += x;
			_inBetweener.y += y;
		}
		
		/**
		 * @private
		 */
		static public function set autoResize(value:Boolean):void {
			if (value == _autoResize)
				return;
			_autoResize = value;
			if (_autoResize)
				_starling.stage.addEventListener(starling.events.Event.RESIZE, onResize);
			else
				_starling.stage.removeEventListener(starling.events.Event.RESIZE, onResize);
		}
		
		/**
		 * Adds an event listener to the stage.
		 */
		static public function addEventListener(type:String, listener:Function):void {
			Starling.current.stage.addEventListener(type, listener);
		}
		
		// public non-static
		
		/**
		 * @private
		 */
		public function FullScreenExtension(singletonEnforcer:SingletonEnforcer) {
			// empty constructor
		}
		
		// GETTERS AND SETTERS
		
		/**
		 * Sets the color of both stages.
		 */
		static public function set stageColor(value:int):void { 
			Starling.current.stage.color = value;
			_stage.color = value;
		}
		
		/**
		 * Draws an outline around the boundary of the stage.
		 */
		static public function get showStageBounds():Boolean { return _showStageBounds; }
		
		/**
		 * @private
		 */
		static public function set showStageBounds(value:Boolean):void {
			if (_showStageBounds == value)
				return;
			_showStageBounds = value;
			if (_showStageBounds)
				Starling.current.nativeOverlay.addChild(_bounds);
			else
				Starling.current.nativeOverlay.removeChild(_bounds);
		}
		
		/**
		 * The horizontal alignment of the stage.
		 */
		static public function get stageHorizontalGravity():String { return _horizontalGravity; }
		
		/**
		 * The vertical alignment of the stage.
		 */
		static public function get stageVerticalGravity():String { return _verticalGravity; }
		
		/**
		 * Replaces the Starling stage object as the root of the display tree that is rendered.
		 */
		static public function get stage():starling.display.Stage { return _stage; }
		
		/**
		 * The x coordinate of the left of the screen relative to the stage.
		 */
		static public function get screenLeft():int { return _screenLeft; }
		
		/**
		 * The y coordinate of the top of the screen relative to the stage.
		 */
		static public function get screenTop():int { return _screenTop; }
		
		/**
		 * The x coordinate of the right of the screen relative to the stage.
		 */
		static public function get screenRight():int { return _screenRight; }
		
		/**
		 * The y coordinate of the bottom of the screen relative to the stage.
		 */
		static public function get screenBottom():int { return _screenBottom; }
		
		/**
		 * The width of the screen.
		 */
		static public function get screenWidth():int { return _screenWidth; }
		
		/**
		 * The height of the screen.
		 */
		static public function get screenHeight():int { return _screenHeight; }
		
		/**
		 * The x coordinate of the left of the stage relative to the stage. Will always equal zero.
		 */
		static public function get stageLeft():int { return 0; }
		
		/**
		 * The y coordinate of the top of the stage relative to the stage. Will always equal zero.
		 */
		static public function get stageTop():int { return 0; }
		
		/**
		 * The x coordinate of the right of the stage relative to the stage. Equal to the stageWidth;
		 */
		static public function get stageRight():int { return _stageWidth; }
		
		/**
		 * The y coordinate of the bottom of the stage relative to the stage. Equal to the stageHeight;
		 */
		static public function get stageBottom():int { return _stageHeight; }
		
		/**
		 * The width of the stage object.
		 */
		static public function get stageWidth():int { return _stageWidth; }
		
		/**
		 * The height of the stage object.
		 */
		static public function get stageHeight():int { return _stageHeight; }
		
		// ----------------- private API --------------------- //
		
		static private var _autoResize:Boolean;
		// screen variables
		static private var _screenLeft:int;
		static private var _screenTop:int;
		static private var _screenRight:int;
		static private var _screenBottom:int;
		static private var _screenWidth:int;
		static private var _screenHeight:int;
		private static var _nativeWidth:int;
		private static var _nativeHeight:int;
		// stage variables
		static private var _stageWidth:int;
		static private var _stageHeight:int;
		static private var _horizontalGravity:String;
		static private var _verticalGravity:String;
		
		static private var _starling:Starling;
		static private var _inBetweener:Sprite;
		static private var _stage:starling.display.Stage;
		
		static private var _showStageBounds:Boolean;
		static private var _bounds:Shape;
		
		static private var HELPER_MATRIX:Matrix = new Matrix();
		static private var HELPER_POINT:Point = new Point();
		
		// helper function
		static private function map(value:Number,
									low1:Number,
									high1:Number,
									low2:Number = 0,
									high2:Number = 1):Number {
			if (value == low1)
				return low2;
			var range1:Number = high1 - low1;
			var range2:Number = high2 - low2;
			var result:Number = value - low1;
			var ratio:Number = result / range1;
			result = ratio * range2;
			result += low2;
			return result;
		}
		
		static private function onResize(event:ResizeEvent):void {
			_nativeWidth = event.width;
			_nativeHeight = event.height;
			resize(_stageWidth, _stageHeight, null, null, event.width, event.height);
		}
		
	}
}

class SingletonEnforcer {}