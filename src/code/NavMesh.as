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
	import laya.d3.math.Vector4;
	import laya.d3.resource.models.PrimitiveMesh;
	import laya.webgl.WebGLContext;
	/**
	 * ...
	 * @author lizhi
	 */
	public class NavMesh extends PrimitiveMesh
	{
		private var g:Geometry;
		public function NavMesh(g:Geometry) 
		{
			this.g = g;
			activeResource();
			
			_positions = _getPositions();
			_generateBoundingObject();
		}
		
		override protected function recreateResource():void {
			_numberIndices = g.faces.length*3;// i.length / 5 * 3;
			var vertexDeclaration:VertexDeclaration = VertexPositionNormalColor.vertexDeclaration;
			
			var p2:Array = [];
			var i2:Array = [];
			var k:int = 0;
			for (var j:int = 0; j <_numberIndices/3;j++ ){
				i2.push(k++);
				i2.push(k++);
				i2.push(k++);
				var a:int = g.faces[j].a;
				var b:int = g.faces[j].c;
				var c:int = g.faces[j].b;
				
				
				p2.push(g.vertices[a].x);
				p2.push(g.vertices[a].y);
				p2.push(g.vertices[a].z);
				p2.push(0);
				p2.push(0);
				p2.push(0);
				var cc:Vector4 =  getColor(g.vertices[a]);
				p2.push(cc.x);
				p2.push(cc.y);
				p2.push(cc.z);
				p2.push(cc.w);
				
				p2.push(g.vertices[b].x);
				p2.push(g.vertices[b].y);
				p2.push(g.vertices[b].z);
				p2.push(0);
				p2.push(0);
				p2.push(0);
				cc =  getColor(g.vertices[b]);
				p2.push(cc.x);
				p2.push(cc.y);
				p2.push(cc.z);
				p2.push(cc.w);
				
				
				p2.push(g.vertices[c].x);
				p2.push(g.vertices[c].y);
				p2.push(g.vertices[c].z);
				p2.push(0);
				p2.push(0);
				p2.push(0);
				cc=  getColor(g.vertices[c]);
				p2.push(cc.x);
				p2.push(cc.y);
				p2.push(cc.z);
				p2.push(cc.w);
			}
			
			computeNormal(p2, i2);
			
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
		
		private function getColor(v):Vector4{
			//return new Vector4(1, 1, 1, 1);
			var c3:Vector3=Color.fromHSV((Vector3.scalarLength(v)/20+100)%1, 1,1);
			return new Vector4(c3.x, c3.y, c3.z, 1);
		}
		
		public static function computeNormal(vin:Array,idata:Array):void
		{
			for (var i:int = 0; i < idata.length;i+=3 ) {
				var i0:int = idata[i]*10;
				var i1:int = idata[i + 1]*10;
				var i2:int = idata[i + 2]*10;
				var x0:Number = vin[i0 ];
				var y0:Number = vin[i0 +1];
				var z0:Number = vin[i0 +2];
				var x1:Number = vin[i1];
				var y1:Number = vin[i1+1];
				var z1:Number = vin[i1+2];
				var x2:Number = vin[i2];
				var y2:Number = vin[i2+1];
				var z2:Number = vin[i2+2];
				var nx:Number = (y0 - y2) * (z0 - z1) - (z0 - z2) * (y0 - y1);
				var ny:Number = (z0 - z2) * (x0 - x1) - (x0 - x2) * (z0 - z1);
				var nz:Number = (x0 - x2) * (y0 - y1) - (y0 - y2) * (x0 - x1);
				vin[i0+3] += nx;
				vin[i1+3] += nx;
				vin[i2+3] += nx;
				vin[i0+4] += ny;
				vin[i1+4] += ny;
				vin[i2+4] += ny;
				vin[i0+5] += nz;
				vin[i1+5] += nz;
				vin[i2 + 5] += nz;
			}
			for (i = 3; i < vin.length;i+=10 ) {
				nx = vin[i];
				ny = vin[i+1];
				nz = vin[i+2];
				var distance:Number = Math.sqrt(nx * nx + ny * ny + nz * nz);
				vin[i] /= distance;
				vin[i+1] /= distance;
				vin[i + 2] /= distance;
			}
		}
	}

}