package code 
{
	import laya.d3.math.Vector3;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Geometry 
	{
		public var faces:Array;
		public var vertices:Vector.<Vector3>;
		public function Geometry() 
		{
			
		}
		
		/*
		 * Checks for duplicate vertices with hashmap.
		 * Duplicated vertices are removed
		 * and faces' vertices are updated.
		 */

		public function mergeVertices () {

			var verticesMap:Object = {}; // Hashmap for looking up vertice by position coordinates (and making sure they are unique)
			var unique:Vector.<Vector3> = new Vector.<Vector3>, changes:Array = [];

			var v:Vector3, key:String;
			var precisionPoints:int = 4; // number of decimal points, eg. 4 for epsilon of 0.0001
			var precision:int = Math.pow( 10, precisionPoints );
			var i, il, face;
			var indices, j, jl;

			for ( i = 0, il = this.vertices.length; i < il; i ++ ) {

				v = this.vertices[ i ];
				key = Math.round( v.x * precision ) + '_' + Math.round( v.y * precision ) + '_' + Math.round( v.z * precision );

				if ( verticesMap[ key ] ==null) {

					verticesMap[ key ] = i;
					unique.push(v);
					changes[ i ] = unique.length - 1;

				} else {

					//console.log('Duplicate vertex found. ', i, ' could be using ', verticesMap[key]);
					changes[ i ] = changes[ verticesMap[ key ] ];

				}

			};


			// if faces are completely degenerate after merging vertices, we
			// have to remove them from the geometry.
			var faceIndicesToRemove:Array = [];

			for ( i = 0, il = this.faces.length; i < il; i ++ ) {

				face = this.faces[ i ];

				face.a = changes[ face.a ];
				face.b = changes[ face.b ];
				face.c = changes[ face.c ];

				indices = [ face.a, face.b, face.c ];

				var dupIndex:int = - 1;

				// if any duplicate vertices are found in a Face3
				// we have to remove the face as nothing can be saved
				for ( var n:int = 0; n < 3; n ++ ) {
					if ( indices[ n ] == indices[ ( n + 1 ) % 3 ] ) {

						dupIndex = n;
						faceIndicesToRemove.push( i );
						break;

					}
				}

			}

			for ( i = faceIndicesToRemove.length - 1; i >= 0; i -- ) {
				var idx:int = faceIndicesToRemove[ i ];

				this.faces.splice( idx, 1 );

				/*for ( j = 0, jl = this.faceVertexUvs.length; j < jl; j ++ ) {

					this.faceVertexUvs[ j ].splice( idx, 1 );

				}*/

			}

			// Use unique set of vertices

			var diff:int = this.vertices.length - unique.length;
			this.vertices = unique;
			return diff;

		}

		
	}

}