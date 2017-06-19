package 
{   
	import com.symantec.premiumServices.asyncThreading.abstract.AbstractAsyncThread;   
	import com.symantec.premiumServices.asyncThreading.interfaces.IAsyncThreadResponder;   
	
	/**
	 *  自定义线程   
	 */  
	public class SelfDefinedThread extends AbstractAsyncThread implements IAsyncThreadResponder   
	{   
		private var f:Function;   
		
		public function SelfDefinedThread(f:Function)   
		{   
			super();   
			this.f = f;   
		}   
		
		public function execute():void  
		{   
			f.call();   
		}   
	}   
}  