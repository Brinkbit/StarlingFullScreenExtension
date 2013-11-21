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
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import starling.display.DisplayObject;
	import starling.display.Stage;
	import starling.utils.MatrixUtil;
	
	public class Stage extends starling.display.Stage
	{
		// ----------------- public API --------------------- //
		
		public function Stage(width:int, height:int, color:uint=0)
		{
			super(width, height, color);
		}
		
		// we need to artificially extend the bounds of hitTesting to allow collisions off the stage
		// and to mask the root stage from being returned
		public override function hitTest(localPoint:Point, forTouch:Boolean=false):DisplayObject
		{
			if (forTouch && (!visible || !touchable))
				return null;
			
			// locations outside of the screen shouldn't be accepted
			if (localPoint.x < FullScreenExtension.screenLeft || localPoint.x > FullScreenExtension.screenRight ||
				localPoint.y < FullScreenExtension.screenTop || localPoint.y > FullScreenExtension.screenBottom)
				return null;
			
			// if nothing else is hit, the stage returns itself as target
			var target:DisplayObject = testChildren(localPoint, forTouch);
			if (target == null) target = this;
			return target;
		}
		
		// ----------------- private API --------------------- //
		
		private var sHelperMatrix:Matrix = new Matrix();
		private var sHelperPoint:Point = new Point();
		
		// replaces what would be a call to super.super.hitTest()
		private function testChildren(localPoint:Point, forTouch:Boolean=false):DisplayObject
		{
			if (forTouch && (!visible || !touchable))
				return null;
			
			var localX:Number = localPoint.x;
			var localY:Number = localPoint.y;
			var numChildren:int = this.numChildren; // unfortunately unavoidably expensive
			for (var i:int=numChildren-1; i>=0; --i) // front to back!
			{
				var child:DisplayObject = this.getChildAt(i);
				getTransformationMatrix(child, sHelperMatrix);
				
				MatrixUtil.transformCoords(sHelperMatrix, localX, localY, sHelperPoint);
				var target:DisplayObject = child.hitTest(sHelperPoint, forTouch);
				
				if (target) return target;
			}
			
			return null;
		}
	}
}