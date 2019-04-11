package code 
{
	import laya.d3.math.Vector3;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Color 
	{
		
		public function Color() 
		{
			
		}
		
		public static function getRandomColor():Vector3{
			return fromHSV(Math.random(), 1, 1);
		}
		
		public static function fromHSV(h:Number, s:Number, v:Number):Vector3{
			var R:Number, G:Number, B:Number;
			if (s == 0) {
				R = G = B = v;
			}else{
				var h6:Number = h * 6;
				var i:int = h6>>0;
				var f:Number = h6 - i;
				var a:Number = v * ( 1 - s )
				var b:Number = v * ( 1 - s * f )
				var c:Number = v * ( 1 - s * (1 - f ) )
				switch(i){
					case 0: R = v; G = c; B = a; break;
					case 1: R = b; G = v; B = a;break;
					case 2: R = a; G = v; B = c;break;
					case 3: R = a; G = b; B = v;break;
					case 4: R = c; G = a; B = v;break;
					case 5: R = v; G = a; B = b;break;
				}
			}
			return new Vector3(R, G, B);
		}
		
	}

}