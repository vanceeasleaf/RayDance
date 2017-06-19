package mvc.view
{
import flash.events.Event;
import flash.events.MouseEvent;

import org.puremvc.as3.interfaces.IMediator;
import org.puremvc.as3.patterns.mediator.Mediator;

import spark.components.WindowedApplication;
import mvc.event.Notifications;
	public class AppMediator extends Mediator implements IMediator
	{
		public static const NAME:String="AppMediator";
		public function AppMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
			init();
		}
		function init():void{
			main.btnOpen.addEventListener(MouseEvent.CLICK,onOpen);
			main.Fit.addEventListener(MouseEvent.CLICK,onFit);
			main.btn_stop.addEventListener(MouseEvent.CLICK,onStop);
		}
		function onOpen(e:Event):void{
			sendNotification(Notifications.OPEN);
		}
		function onStop(e:Event):void{
			sendNotification(Notifications.STOP);
		}
		function onFit(e:Event):void{
			sendNotification(Notifications.FIT);
		}
		function get main():Main{
			return viewComponent as Main
		}
	}
}