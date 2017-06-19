package mvc
{
	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	import mvc.controller.AppCommand;
	public class AppFacade extends Facade implements IFacade 
	{
		public static const STARTUP:String = "startup";
		public function AppFacade()
		{
		}
		public static function getInstance():AppFacade
		{
			if(instance==null)
			{
				instance=new AppFacade();
			}
			return instance as AppFacade;
		}
		override protected function initializeController():void
		{
			super.initializeController();
			registerCommand(STARTUP, AppCommand);
		}
		public function startup(_main:Main):void
		{
			sendNotification(STARTUP, _main);
		}
	}
}