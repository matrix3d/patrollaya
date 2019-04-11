package 
{
	import code.DrawLineScript;
	import code.Face;
	import code.Geometry;
	import code.NavMesh;
	import code.NavMeshAgent;
	import code.nav.DrawLine;
	import common.CameraMoveScript;
	import common.DrawBoxColliderScript;
	import laya.d3.component.Script;
	import laya.d3.component.physics.BoxCollider;
	import laya.d3.component.physics.Collider;
	import laya.d3.component.physics.MeshCollider;
	import laya.d3.core.Camera;
	import laya.d3.core.MeshSprite3D;
	import laya.d3.core.PhasorSpriter3D;
	import laya.d3.core.Sprite3D;
	import laya.d3.core.light.DirectionLight;
	import laya.d3.core.material.StandardMaterial;
	import laya.d3.core.scene.Scene;
	import laya.d3.math.Collision;
	import laya.d3.math.Plane;
	import laya.d3.math.Ray;
	import laya.d3.math.Vector2;
	import laya.d3.math.Vector3;
	import laya.d3.resource.models.BaseMesh;
	import laya.d3.resource.models.BoxMesh;
	import laya.d3.utils.Physics;
	import laya.d3.utils.RaycastHit;
	import laya.display.Stage;
	import laya.events.Event;
	import laya.events.MouseManager;
	import laya.net.Loader;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import laya.utils.Stat;
	import laya.webgl.shapes.GeometryData;
	import laya.webgl.shapes.Line;
	/**
	 * ...
	 * @author lizhi
	 */
	public class NavTest 
	{
		
		//private var levelUrl:String = "res/unity/level.ls";
		private var navUrl:String = "meshes/level.nav.js";
		private var scene:Scene;
		private var camera:Camera;
		private var playerNavMeshGroup;
		private var player:MeshSprite3D;
		private var target:MeshSprite3D;
		private var pathLine:DrawLineScript;
		private var mesh:BoxMesh;
		private var material:StandardMaterial;
		private var agent:NavMeshAgent;
		private var meshC:MeshCollider;
		public function NavTest() 
		{
			//初始化引擎
			Laya3D.init(0, 0, true);
			
			
			//适配模式
			Laya.stage.scaleMode = Stage.SCALE_FULL;
			Laya.stage.screenMode = Stage.SCREEN_NONE;
			Laya3D.debugMode = true;
			Laya3D._debugPhasorSprite = new PhasorSpriter3D;

			//开启统计信息
			Stat.show();
			
			scene = Laya.stage.addChild(new Scene()) as Scene;
			
			//添加照相机
			camera = (scene.addChild(new Camera( 0, 0.1, 10000))) as Camera;
			camera.transform.translate(new Vector3( -10, 14, 10));
			camera.transform.lookAt(Vector3.ZERO,Vector3.Up);
			camera.clearColor = null;
			camera.addComponent(CameraMoveScript);

			//添加方向光
			var directionLight:DirectionLight = scene.addChild(new DirectionLight()) as DirectionLight;
			directionLight.color = new Vector3(0.6, 0.6, 0.6);
			directionLight.direction = new Vector3(1, -1, 0);

			//添加自定义模型
			mesh = new BoxMesh(.3, .3, .3);
			player = new MeshSprite3D(mesh) as MeshSprite3D;
			agent = player.addComponent(NavMeshAgent);
			agent.speed = 10;
			material = new StandardMaterial();
			player.meshRender.material = material;
			scene.addChild(player);
			player.transform.position = new Vector3( -3.5, 0.5, 5.5);
			target = new MeshSprite3D(mesh);
			target.meshRender.material = material;
			scene.addChild(target);
			target.transform.position = player.transform.position.clone();
			
			pathLine = new Sprite3D;
			scene.addChild(pathLine);
			Laya.loader.load(navUrl, Handler.create(this, onNavLoaded),null,Loader.JSON);
		}
		
		private function onNavLoaded():void{
			var json:Object = Laya.loader.getRes(navUrl);
			
			var nUvLayers:int = 0;

			if ( json.uvs ) {

				// disregard empty arrays

				for (var i:int = 0; i < json.uvs.length; i ++ ) {
					if ( json.uvs[ i ].length ) nUvLayers ++;
				}
			}
			
			var p2:Array = json.vertices;
			var ii:Array =  json.faces;
			var faces:Array = [];
			/*for (var i:int = 0; i < ii.length/5;i++ ){
				faces.push(new Face(ii[i*5+1],ii[i*5+2],ii[i*5+3]));
			}*/
			
			var offset:int = 0;
			var zLength:int = ii.length;
			while (offset<zLength){
				var type:int = ii[ offset ++ ];
				var isQuad:Boolean              = isBitSet( type, 0 );
				var hasMaterial:Boolean         = isBitSet( type, 1 );
				var hasFaceVertexUv:Boolean     = isBitSet( type, 3 );
				var hasFaceNormal:Boolean       = isBitSet( type, 4 );
				var hasFaceVertexNormal:Boolean = isBitSet( type, 5 );
				var hasFaceColor:Boolean	     = isBitSet( type, 6 );
				var hasFaceVertexColor:Boolean  = isBitSet( type, 7 );
				if (isQuad){
					// todo
				}else{
					faces.push(new Face(ii[offset], ii[offset+1], ii[offset+2]));
					offset += 3;
					if (hasMaterial){
						offset++;
					}
					if (hasFaceVertexUv){
						offset += 3 * nUvLayers;
					}
					if (hasFaceNormal){
						offset++;
					}
					if (hasFaceVertexNormal){
						offset += 3;
					}
					if (hasFaceColor){
						offset++;
					}
					if (hasFaceVertexColor){
						offset += 3;
					}
				}
			}
			
			var p = [];
			var vscale:Number = 1 ;
			for (i = 0; i < p2.length;i+=3 ){
				p.push(new Vector3(p2[i]*vscale,p2[i+1]*vscale,p2[i+2]*vscale));
			}
			var g:Geometry = new Geometry;
			g.faces = faces;
			g.vertices = p;
			var zoneNodes = Browser.window.patrol.buildNodes(g);

			Browser.window.patrol.setZoneData('level', zoneNodes);
			
			// Set the player's navigation mesh group
			playerNavMeshGroup = Browser.window.patrol.getGroup('level', new Vector3( -3.5, 0.5, 5.5));
			
			Laya.stage.on(Event.CLICK, this, onClick);
			
			var mesh:MeshSprite3D = new MeshSprite3D(new NavMesh(g));
			//mesh.transform.scale = new Vector3(10, 10, 10);
			mesh.meshRender.material = new StandardMaterial;
			(mesh.meshRender.material as StandardMaterial).diffuseColor = new Vector3(1, 0, 0);
			pathLine = mesh.addComponent(DrawLineScript);
			meshC = mesh.addComponent(MeshCollider) as MeshCollider;
			meshC.mesh = mesh.meshFilter.sharedMesh;
			
			scene.addChild(mesh);
		}
		
		private function onClick():void 
		{
			var ray:Ray = new Ray(new Vector3, new Vector3);
			camera.viewportPointToRay(new Vector2(MouseManager.instance.mouseX, MouseManager.instance.mouseY), ray);
			
			///
			var out:Vector3 = new Vector3;
			var plane:Plane = new Plane(Vector3.Up, 0);
			Collision.intersectsRayAndPlaneRP(ray, plane, out);
			////plane
			
			var _outHitInfo:RaycastHit = new RaycastHit();
			//Physics.rayCast(ray, _outHitInfo, 30, 0);
			var flag:Boolean= meshC.raycast(ray, _outHitInfo);
			if (flag){
				out = _outHitInfo.position;
				target.transform.position = out;
				
				//bug
				
				/*start 1.075693130493164 0.10000000149011612 -43.812816619873052
				crowdcitylaya.max.js:1364 0 0.09000000357627869 -56.31999969482422
				crowdcitylaya.max.js:1364 10.970426559448242 0 -11.572933197021484
				crowdcitylaya.max.js:1373 end 10.970426559448242 0 -11.572933197021484*/
				
				trace("寻找路径",player.transform.position,target.transform.position);
				var calculatedPath = Browser.window.patrol.findPath(player.transform.position, target.transform.position, 'level', playerNavMeshGroup);

				
				if (calculatedPath && calculatedPath.length) {

					// Draw debug cubes except the last one. Also, add the player position.
					var debugPath =/* [player.transform.position].concat*/(calculatedPath);
					trace("start", player.transform.position.x, player.transform.position.y, player.transform.position.z);
					var p:Array = [];
					for (var i = 0; i < debugPath.length; i++) {
						trace(debugPath[i].x, debugPath[i].y, debugPath[i].z);
						p.push(new Vector3(debugPath[i].x, debugPath[i].y+.1, debugPath[i].z));
						//var geometry = new //THREE.BoxGeometry( 0.3, 0.3, 0.3 );
						//var material = new THREE.MeshBasicMaterial( {color: 0x00ffff} );
						var node:MeshSprite3D = new MeshSprite3D(mesh);//new THREE.Mesh( geometry, material );
						node.transform.position=(debugPath[i]);
						node.meshRender.material = material;
					}
					pathLine.path = [player.transform.position].concat(p);
					agent.path = pathLine.path;
					agent.enabled = true;
					trace("end",target.transform.position.x,target.transform.position.y,target.transform.position.z);
				}else{
					agent.enabled = false;
					player.transform.position = out;
					trace("找不到路径");
				}
			}
		
		}
		
		//threejs model
		public function isBitSet( value:Number, position:Number ):Boolean {
			return value & ( 1 << position );

		}
	}

}