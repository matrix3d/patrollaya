package code 
{
	import laya.d3.component.Component3D;
	import laya.d3.core.ComponentNode;
	import laya.d3.core.Sprite3D;
	import laya.d3.core.render.RenderState;
	import laya.d3.math.Vector3;
	import laya.utils.Browser;
	/**
	 * ...
	 * @author lizhi
	 */
	public class NavMeshAgent extends Component3D
	{
		public var navMeshGroup:Object;
		private var target:Sprite3D;
		public var enabled:Boolean = false;
		public var updateRotation:Boolean = false;
		public var pathPending:Boolean = false;//路线进行中
		private var _path:Array;
		private var pathp:int = 0;
		private var pathlen:Number = 0;
		private var _remainingDistance:Number = 1;
		public var steeringTarget:Vector3 = new Vector3;
		private var _velocity:Vector3 = new Vector3;
		public var destination:Vector3;
		public var speed:Number = 1;
		private var out:Vector3 = new Vector3;
		public function NavMeshAgent() 
		{
		}
		
		override public function _load(owner:ComponentNode):void 
		{
			target = _owner as Sprite3D;
		}
		
		override public function _update(state:RenderState):void 
		{
			if (enabled){
				var now:Vector3 = target.transform.position;
				if (_path){
					var v:Vector3 = new Vector3;
					var tp:Vector3 = null;
					for (var i:int = pathp; i < _path.length-1;i++ ){
						var p0:Vector3 = _path[i];
						var p1:Vector3 = _path[i + 1];
						pathlen = pathlen + speed/60;
						var tlen:Number = Vector3.distance(p0, p1);
						if (pathlen>tlen){
							pathlen -= tlen;
							pathp++;
						}else{
							tp = p0.clone();
							p1.cloneTo(steeringTarget);
							Vector3.subtract(p1, p0, v);
							Vector3.normalize(v, v);
							Vector3.scale(v, pathlen, v);
							Vector3.add(p0, v, tp);
							break;
						}
					}
					if (tp==null){
						pathPending = false;
						tp = _path[_path.length - 1];
						_path[_path.length - 1].cloneTo(steeringTarget);
					}
					//trace(tp.x.toFixed(1),tp.y.toFixed(1),tp.z.toFixed(1),Vector3.distance(tp,target.transform.position),speed);
					target.transform.position = tp;
				}else{
					//out.x = now.x + velocity.x / 60;
					//out.y = now.y + velocity.y / 60;
					//out.z = now.z + velocity.z / 60;
					
					out.x = now.x + velocity.x *Laya.timer.delta/1000;
					out.y = now.y + velocity.y *Laya.timer.delta/1000;
					out.z = now.z + velocity.z *Laya.timer.delta/1000;
					if (navMeshGroup==null||Browser.window.patrol.findPath(now, out, 'level', navMeshGroup)){
						out.cloneTo(now);
						target.transform.position = now;
					}
				}
			}
		}
		
		public function get remainingDistance():Number 
		{
			if (destination&&target){
				return Vector3.distance(destination, target.transform.position);
			}
			return _remainingDistance;
		}
		
		public function set remainingDistance(value:Number):void 
		{
			_remainingDistance = value;
		}
		
		public function get velocity():Vector3 
		{
			return _velocity;
		}
		
		public function set velocity(value:Vector3):void 
		{
			_velocity = value;
			destination = null;
		}
		
		public function get path():Array 
		{
			return _path;
		}
		
		public function set path(value:Array):void 
		{
			//trace("设置path",value);
			_path = value;
			if(value){
				pathPending = true;
			}else{
				pathPending = false;
			}
			pathp = 0;
			pathlen = 0;
		}
	}

}