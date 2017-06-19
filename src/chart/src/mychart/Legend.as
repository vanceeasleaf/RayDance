package mychart{
	import flash.display.Sprite;

	import flash.events.MouseEvent;

	public class Legend extends Sprite {
		public var  legendLabels:Array;
		private var series:Array;
		public var xlength:Number;
		public function Legend(series:Array) {
			xlength=0;
			 legendLabels=[] ;
			this.series=series;
			initseries();
			//xlength=series.length*60;
			graphics.lineStyle(1,0x999999);
			graphics.drawRoundRect(0,0,xlength+8,24,10,10);
		}
		function initseries() {
			for each (var serie in series) {
				if(serie.words=="null")return;
				var legendLabel:LegendLabel=new LegendLabel(serie);
				 legendLabel.x=xlength;
				 legendLabel.y=0;
				this.addChild( legendLabel);
				 legendLabels.push( legendLabel);
				xlength+= legendLabel.lengthLabel;
			}
		}//endof funciton

		
	}
}