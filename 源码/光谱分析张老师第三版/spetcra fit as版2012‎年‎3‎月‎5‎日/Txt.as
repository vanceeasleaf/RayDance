package 
{
	import flash .events .Event 
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	public class Txt
	{
		private static var X:Array;
		private static var Y:Array;
		private static var callBack:Function 
		public function Txt()
		{
		}
		public static function read(name:String,_X:Array,_Y:Array ,_callBack:Function ):void 
		{
			X = _X;
			Y = _Y;
			callBack=_callBack;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,OnComplete);
			loader.load(new URLRequest(name));

		}
		static function OnComplete(e:Event):void
		{
			var a:Array = e.target.data.split('\n');
			var pointsNumber:int = parseInt(a[0]);
			for (var i:int=1; i<=pointsNumber; i++)
			{
				var b:Array = a[i].split(String.fromCharCode(9));
				X[i] = b[0];
				Y[i] = b[1];
			}
			callBack();
			e.target.removeEventListener(Event.COMPLETE,OnComplete);
		}
	}

}