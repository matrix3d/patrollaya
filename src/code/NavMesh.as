package code 
{
	import laya.d3.graphics.IndexBuffer3D;
	import laya.d3.graphics.VertexBuffer3D;
	import laya.d3.graphics.VertexDeclaration;
	import laya.d3.graphics.VertexElement;
	import laya.d3.graphics.VertexElementFormat;
	import laya.d3.graphics.VertexElementUsage;
	import laya.d3.graphics.VertexPosition;
	import laya.d3.graphics.VertexPositionNormal;
	import laya.d3.graphics.VertexPositionNormalColor;
	import laya.d3.graphics.VertexPositionNormalTexture;
	import laya.d3.math.Vector3;
	import laya.d3.resource.models.PrimitiveMesh;
	import laya.webgl.WebGLContext;
	/**
	 * ...
	 * @author lizhi
	 */
	public class NavMesh extends PrimitiveMesh
	{
		private var p:Array;
		private var i:Array;
		
		public function NavMesh(p:Array,i:Array) 
		{
			this.i = i;
			this.p = p;
			
			activeResource();
			
			_positions = _getPositions();
			_generateBoundingObject();
		}
		
		override protected function recreateResource():void {
			_numberIndices = i.length / 5 * 3;
			var vertexDeclaration:VertexDeclaration = VertexPositionNormalColor.vertexDeclaration;
			
			var p2:Array = [];
			/*for (var j:int = 0; j < p.length;j+=3 ){
				p2.push(p[j]);
				p2.push(p[j+1]);
				p2.push(p[j + 2]);
				p2.push(0);
				p2.push(1);
				p2.push(0);
				var c:Vector3 = Color.getRandomColor();
				p2.push(c.x);
				p2.push(c.y);
				p2.push(c.z);
				p2.push(1);
			}*/
			
			
			var i2:Array = [];
			var k:int = 0;
			for (var j:int = 0; j <_numberIndices/3;j++ ){
				/*i2.push(i[j*5+2]);
				i2.push(i[j*5+1]);
				i2.push(i[j * 5 + 3]);*/
				i2.push(k++);
				i2.push(k++);
				i2.push(k++);
				var a:int = i[j * 5 + 2];
				var b:int = i[j * 5 + 1];
				var c:int = i[j * 5 + 3];
				
				
				p2.push(p[a * 3]);
				p2.push(p[a * 3 + 1]);
				p2.push(p[a * 3 + 2]);
				p2.push(0);
				p2.push(1);
				p2.push(0);
				var cc:Vector3 = Color.fromHSV(((Math.random()*10)>>0)/10, 1,1);
				p2.push(cc.x);
				p2.push(cc.y);
				p2.push(cc.z);
				p2.push(1);
				
				p2.push(p[b * 3]);
				p2.push(p[b * 3+1]);
				p2.push(p[b * 3 + 2]);
				p2.push(0);
				p2.push(1);
				p2.push(0);
				p2.push(cc.x);
				p2.push(cc.y);
				p2.push(cc.z);
				p2.push(1);
				
				
				p2.push(p[c * 3]);
				p2.push(p[c * 3+1]);
				p2.push(p[c * 3 + 2]);
				p2.push(0);
				p2.push(1);
				p2.push(0);
				p2.push(cc.x);
				p2.push(cc.y);
				p2.push(cc.z);
				p2.push(1);
			}
			var indices:Uint16Array = new Uint16Array(i2);
			var vertices:Float32Array = new Float32Array(p2);
			
			_numberVertices = p2.length / 10;
			_vertexBuffer = new VertexBuffer3D(vertexDeclaration, _numberVertices, WebGLContext.STATIC_DRAW, true);
			_indexBuffer = new IndexBuffer3D(IndexBuffer3D.INDEXTYPE_USHORT, _numberIndices, WebGLContext.STATIC_DRAW, true);
			_vertexBuffer.setData(vertices);
			_indexBuffer.setData(indices);
			memorySize = (_vertexBuffer._byteLength + _indexBuffer._byteLength) * 2;//修改占用内存,upload()到GPU后CPU中和GPU中各占一份内存
			completeCreate();
		}
		
	}

}