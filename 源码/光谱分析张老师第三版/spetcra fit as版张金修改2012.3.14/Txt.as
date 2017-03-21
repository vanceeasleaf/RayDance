package 
{
	import flash .events .Event 
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	//定义一个类用于数据的传输
	public class Txt
	{
		private static var X:Array;
		private static var Y:Array;
		private static var callBack:Function 
		public function Txt()
		{
			
		}
		//文本数据读取函数
		public static function read(name:String,_X:Array,_Y:Array ,_callBack:Function ):void 
		{
			X = _X;
			Y = _Y;
			callBack=_callBack;
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE,OnComplete);
			/*load方法需要URLRequest 实例作为参数，以指向文本文件的URL
			在默认情况下URLLoader把下载的数据当成文本处理*/
			loader.load(new URLRequest(name));

		}
		static function OnComplete(e:Event):void
		{
			/*数据加载成功后解码储存在URLLoader的data属性中*/
			var a:Array = e.target.data.split('\n'); //以回车符分数据字符
			var pointsNumber:int = parseInt(a[0]);  //读取数据个数
			for (var i:int=1; i<=pointsNumber; i++)
			{
				var b:Array = a[i].split(String.fromCharCode(9));//9对应的ASCII码字符：" "
				X[i] = b[0];
				Y[i] = b[1];
			}
			/* 数据传递后执行calBack函数 */
			callBack();
			e.target.removeEventListener(Event.COMPLETE,OnComplete);
		}
	}

}