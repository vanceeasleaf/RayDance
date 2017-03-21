package mvc.modal
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.*;
	import flash.net.FileFilter;
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
import mvc.event.Notifications;
	public class TxtProxy extends Proxy implements IProxy
	{
		public static const NAME:String="TxtProxy";
		var filePath:String;
		var fileStream:FileStream=new FileStream
		var fileName:String
		var file:File ;
		public function TxtProxy(data:Object=null)
		{			
			super(NAME, data);

		}
		function load():void{
			file= new File(); 			 
			var fileFilter:FileFilter=new FileFilter("Text file","*.txt;");
			file.browseForOpen("Select a directory",[fileFilter]); 
			file.addEventListener(Event.SELECT, Selected);
		}
		function Selected(e:Event):void { 			
			filePath=e.target.nativePath;			
			var a:Array=filePath.split("\\");
			fileName=a[a.length-1];	
			fileStream.addEventListener(Event.COMPLETE,onComplete);
			fileStream.addEventListener(IOErrorEvent.IO_ERROR,onError);
			fileStream.openAsync(e.target as File, FileMode.READ);	
		} 
		function onComplete(e:Event):void{
			var data:String=fileStream.readUTFBytes(fileStream.bytesAvailable);
			sendNotification(Notifications.FILE_READY,{filePath:filePath,fileName:fileName,data:data});
		}
		private function onError(e:IOErrorEvent):void
		{
			
		}
	}
}