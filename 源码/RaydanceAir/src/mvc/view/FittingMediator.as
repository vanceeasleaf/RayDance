package mvc.view
{
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	public class FittingMediator extends Mediator implements IMediator
	{public static const NAME:String="FittingMediator";
		public function FittingMediator(viewComponent:Object=null)
		{
			super(NAME, viewComponent);
		}
	}
}