package mvc.modal
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.*;
	import flash.filesystem.File;
	import mvc.event.Notifications;
	import mx.utils.StringUtil;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;
	
	public class FittingProxy extends Proxy implements IProxy
	{
		public static const NAME:String="FittingProxy";
		private var OSEcore:File;
		var X:String
		var band:int, from:String, to:String
		private  var process:NativeProcess = new NativeProcess();
		private var nativeProcessStartupInfo:NativeProcessStartupInfo;
		private var result:Boolean=false;
		private var trimA:Boolean=false;
		private var tempYstring:String;
		private var displayText:String
		public function  FittingProxy(data:Object=null)
		{	
			super(NAME, data);
		}
		public function start(band:int,from:String,to:String):void
		{
			this.band=band;
			this.from=from;
			this.to=to;
			OSEcore = File.applicationDirectory;
			OSEcore= OSEcore.resolvePath("OES-LS.exe");
			nativeProcessStartupInfo = new NativeProcessStartupInfo();
			nativeProcessStartupInfo.executable = OSEcore;
			process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onStandardOutputData);
			process.start(nativeProcessStartupInfo);
		}
		function inputInit():void{
			process.standardInput.writeMultiByte(band+"\n", "utf-8")
			process.standardInput.writeMultiByte(from+"\n", "utf-8")
			process.standardInput.writeMultiByte(to+"\n", "utf-8")
			//process.addEventListener(ProgressEvent.STANDARD_INPUT_PROGRESS, inputProgressListener);//侦听进程的输入信息
			//process.closeInput();
		}
		private function onStandardOutputData(e:ProgressEvent):void{
			var s:String=process.standardOutput.readMultiByte(process.standardOutput.bytesAvailable,"cn-gb");
			if(s.match("ready")){
				inputInit();
			}
				extract(s);
		}
		private function extract(s:String):void{
			displayText="";
			if(s.match("begin")){
				if(s.match("end")){
					var u:Array=s.split(/begin|end/);
					if(s.search("begin")>s.search("end")){
						tempYstring+=u[0];//4
						X=tempYstring;
						sendData();
						tempYstring=u[2];
						a=StringUtil.trim(u[1])
						if(a!=''){
							displayText=a+'\n';
						}
						result=true;
					}else{
						displayText+=u[0];//3
						X=u[1];
						sendData();
						a=StringUtil.trim(u[2])
						if(a!=''){
							displayText+=a+'\n';
						}
						result=false;
					}
				}else{
					u=s.split(/begin/);//1
					var a:String=StringUtil.trim(u[0]);
					if(a!=''){
						displayText=a+'\n';
					}
					tempYstring=u[1];
					result=true;
				}	
			}else{
				if(s.match("end")){
					u=s.split(/end/);
					tempYstring+=u[0];//2
					X=tempYstring;
					sendData();
					a=StringUtil.trim(u[1]);
					if(a!=''){
						displayText=a+'\n';
					}
					result=false;
				}else{//0
					if(result){
						tempYstring+=s;
					}else{
						a=StringUtil.trim(s);
						if(a!=''){
							displayText=a+'\n';
						}
					}
				}
			}
			if(displayText!=""){
				sendInfo();
			}
		}
		public function stopFit():void{
			process.exit(true)
		}
		function sendInfo(){
			sendNotification(Notifications.FITTED_INFO,displayText);
		}
		function sendData(){
			var u=StringUtil.trim(X)
			var b=u.split('\n');	
			var l:int=b.length
			var c:Array=[];
			for(var i:int=0;i<l;i++){
				c[i]=parseFloat(b[i]);
			}
			setData(c);
			sendNotification(Notifications.FITTED_ONCE);
		}
	}
}