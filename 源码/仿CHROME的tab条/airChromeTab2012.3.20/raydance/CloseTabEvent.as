package raydance
{
	import flash.events.Event;
	public class CloseTabEvent extends Event
	{
		var _index:int;
		public function CloseTabEvent(index:int)
		{
			this._index = index;
			super("tabClose");
		}
		public function get index():int
		{
			return _index;
		}
	}

}