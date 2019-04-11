package code 
{
	import laya.d3.math.Vector3;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Geom 
	{
		
		public function Geom() 
		{
			
		}
		public static function angleBetween(a:Vector3, b:Vector3) : Number
		{
			var la:Number = Vector3.scalarLength(a);
			var lb:Number = Vector3.scalarLength(b);
			var dot:Number = Vector3.dot(a,b);

			if (la != 0)
			{
				dot /= la;
			}

			if (lb != 0)
			{
				dot /= lb;
			}

			return Math.acos(dot);
		}
		
	}

}