package code 
{
	import laya.d3.component.Script;
	import laya.d3.component.physics.BoxCollider;
	import laya.d3.core.PhasorSpriter3D;
	import laya.d3.core.render.RenderState;
	import laya.d3.math.OrientedBoundBox;
	import laya.d3.math.Vector3;
	import laya.d3.math.Vector4;
	import laya.webgl.WebGLContext;
	/**
	 * ...
	 * @author ...
	 */
	public class DrawLineScript extends Script
	{
		private var phasorSpriter3D:PhasorSpriter3D;
		public var path:Vector.<Vector3>;
		private var _color:Vector4 = new Vector4(1, 0, 1, 1);

		
		public function DrawLineScript() 
		{
			super();
			phasorSpriter3D = new PhasorSpriter3D();
		}
		
		public function _postRenderUpdate(state:RenderState):void {
			if (path&&path.length>=2){
				phasorSpriter3D.begin(WebGLContext.LINES, state.camera);
				for (var i:int = 0; i < path.length-1;i++ ){
					phasorSpriter3D.line(path[i], _color, path[i+1], _color);
				}
				phasorSpriter3D.end();
			}
			
		}
		
	}

}