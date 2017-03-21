package
{
	import flash.desktop.NativeApplication;
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.filesystem.File;
	
	import spark.components.Button;
	import spark.components.TextArea;

	public class Fit extends Sprite
	{
		private var file:File;
		var X:String
		private  var process:NativeProcess = new NativeProcess();
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;
		private var result:Boolean=false;
		private var trimA:Boolean=false;
		private var tempYstring:String;
		public var info:TextArea;

		public var content1:content;
		public function Fit()
		{
		}
		public function start(band:int,from:String,to:String):void
		{
			NativeApplication.nativeApplication.autoExit=true;
			content1.stage.nativeWindow.addEventListener(Event.CLOSE,closing);
			content1.addEventListener(Event.REMOVED_FROM_STAGE,closing);
			content1.stage.addEventListener("stopFit",closing);
			file = File.applicationDirectory;
			file = file.resolvePath("OES-LS.exe");
			//file = file.resolvePath("aaa.exe");
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = file;
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onStandardOutputData);
			process.start(nativeProcessStartupInfo);
			process.addEventListener(NativeProcessExitEvent.EXIT, onExit);
			process.standardInput.writeMultiByte(band+"\n", "cn-gb")
			process.standardInput.writeMultiByte(from+"\n", "cn-gb")
			process.standardInput.writeMultiByte(to+"\n", "cn-gb")//utf-8ASCII
			addEventListener("data",updateGraph)

			process.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, inputProgressListener);//侦听进程的输入信息
			//process.closeInput();
		}
		import mx.collections.ArrayCollection;
		function updateGraph(e:Event){
			var u=StringUtil.trim(X)
			var b=u.split('\n');

			var l:int=b.length
			var c:Array=[];
			for(var i:int=0;i<l;i++){
				c[i]=parseFloat(b[i]);
			}
			content1.go(c);
		}
		import mx.utils.StringUtil
			private function onStandardOutputData(e:ProgressEvent):void{
				//process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);
				var s:String=process.standardOutput.readMultiByte(process.standardOutput.bytesAvailable,"cn-gb");
				
				
				if(s.match("begin")){
					if(s.match("end")){
						var u:Array=s.split(/begin|end/);
						if(s.search("begin")>s.search("end")){
							tempYstring+=u[0];//4
							X=tempYstring;
							dispatchEvent(new Event('data'));
							tempYstring=u[2];
							a=StringUtil.trim(u[1])
							if(a!=''){
								textAdd(a+'\n')
							}
							result=true;
						}else{
							textAdd(u[0]);//3
							X=u[1];
							dispatchEvent(new Event('data'));
							a=StringUtil.trim(u[2])
							if(a!=''){
								textAdd(a+'\n');
							}
							result=false;
						}
					}else{
						u=s.split(/begin/);//1
						var a:String=StringUtil.trim(u[0]);
						if(a!=''){
							textAdd(a+'\n');
						}
						tempYstring=u[1];
						result=true;
					}	
				}else{
					if(s.match("end")){
						u=s.split(/end/);
						tempYstring+=u[0];//2
						X=tempYstring;
						dispatchEvent(new Event('data'));
						a=StringUtil.trim(u[1]);
						if(a!=''){
							textAdd(a+'\n')
						}
						result=false;
					}else{//0
						if(result){
							tempYstring+=s;
						}else{
							a=StringUtil.trim(s);
							if(a!=''){
								textAdd(a+'\n');
							}
						}
					}
				}
				
				
				//s=process.standardOutput.readMultiByte(process.standardOutput.bytesAvailable,"cn-gb")
				//ww.text+=s//.split("\n")[0];
			}//process.standardOutput.r
			//			public function writeData():void
			//			{
			//				 process.standardInput.writeUTFBytes(num1.text + "\n");//C++方法中需要的两个输入，从这里写入
			//				 process.standardInput.writeUTFBytes(num2.text + "\n");
			//				 }
			import 
			spark.core.IViewport;
			function textAdd(a:String){
				info.text+=a;
				info.validateNow(); 
				var _viewport:IViewport =info.scroller.viewport;
				_viewport.verticalScrollPosition = _viewport.contentHeight+30;
			}
			public function onExit(event:NativeProcessExitEvent):void
			{
				if(event.exitCode.toString()=="0")
				{
					
				}
				else if(event.exitCode.toString()=="1")
				{
					
				}
				this.dispatchEvent(new Event("refresh"));
			}
			function has(s:String,u:String):Boolean{
				return s.search(u)>-1;
			}
			public function inputProgressListener(e:ProgressEvent):void
			{
				process.closeInput();//关闭输入
			}
			//ww.text+=process.standardOutput.readBytes(_processBuffer, _processBuffer.length,process.standardOutput.bytesAvailable);
			
			//nativeProcess.standardInput.writeMultiByte("take\n", "utf-8"
			public function stop(e:MouseEvent=null):void
			{
				
				process.exit(true)
			}
			public function closing(event:Event):void{
				//取消事件的默认行为，在实际使用时可以指定条件来执行这句话
				//event.preventDefault();
				//stage.nativeWindow.close()
				process.exit(true)
			}
	}
}