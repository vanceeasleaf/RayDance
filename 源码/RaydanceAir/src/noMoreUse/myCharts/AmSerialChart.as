package myCharts
{
	import com.amcharts.AmSerialChart
	public class AmSerialChart extends com.amcharts.AmSerialChart
	{
		public function AmSerialChart()
		{
			super();
		}
		public function onClick():void{
			this;
		}
		override protected function createChildren():void{
			super.createChildren();
			if (_amchartsLink){
				_amchartsLink.visible=false;
				/*
				_amchartsLink.alpha=0;
				_amchartsLink.width=0;
				_amchartsLink.height=0;
				*/
			}
		}
	}
}
