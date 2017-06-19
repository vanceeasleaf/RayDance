package mvc.controller
{
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
import mvc.modal.TxtProxy;
import mvc.modal.FittingProxy;
import mvc.view.AppMediator;
import mvc.view.FittingMediator;
import mvc.AppFacade;
	public class AppCommand  extends SimpleCommand
	{
		public function AppCommand()
		{
			super();
		}
		override public function execute(note:INotification):void
		{
			var main:Main = note.getBody() as Main;
			facade.registerProxy(new TxtProxy());
			facade.registerProxy(new FittingProxy());
			facade.registerMediator(new AppMediator(main));
			facade.registerMediator(new FittingMediator());
			facade.registerCommand(AppFacade.OPEN,OpenCommand);
			facade.registerCommand(AppFacade.BTNS_CHANGE,BtnCommand);
			facade.registerCommand(AppFacade.IMAGE_COM,ImageComCommand);
		}
	}
}