package starling.extensions.spacebar.fullscreenscreenextension
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