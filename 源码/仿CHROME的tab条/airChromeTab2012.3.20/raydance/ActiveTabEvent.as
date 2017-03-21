package raydance
{
	import flash.events.Event;

	public class ActiveTabEvent extends Event
	{
		var _index:int;
		public function ActiveTabEvent(index:int)
		{
			this._index = index;
			super("tabActive");
		}
		public function get index():int
		{
			return _index;
		}
	}

}