package mychart{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.filters.GlowFilter;
	import flash.events.Event;

	public class LegendLabel extends Sprite {
		public var lengthLabel:Number;
		public var serie:Serie;
		private var textFormat:TextFormat;
		private var defaultTextFormat;
		private var scatter:Scatter;
		public var words:TextField;
		public function LegendLabel(serie:Serie) {
			textFormat=new TextFormat  ;
			textFormat.color=0x666688;
			defaultTextFormat=new TextFormat  ;
			defaultTextFormat.color=0x000000;
			this.serie=serie;
			lengthLabel=0;
			words=new TextField  ;
			words.text=serie.words;
			words.selectable=false;
			words.autoSize="center";
			if (serie.type==='line') {
				graphics.lineStyle(2,serie.color);
				graphics.moveTo(10,12);
				graphics.lineTo(25,12);

				words.x=30;
				words.y=12-words.height/2;

			} else if (serie.type==='scatter') {
				 scatter=new Scatter(serie.color,3);
				scatter.x=10;
				scatter.y=12;
				this.addChild(scatter);
				words.x=20;
				words.y=12-words.height/2;
				this.addChild(words);

			} else if (serie.type==='area') {
				graphics.lineStyle(1,serie.color);
				graphics.beginFill(serie.color,serie.alpha);
				graphics.drawRoundRect(7.5,7,15,10,3,3);
				this.graphics.endFill();
				words.x=30;
				words.y=12-words.height/2;
			}
			this.addChild(words);
			words.addEventListener(MouseEvent.ROLL_OVER,onLabel);
			words.addEventListener(MouseEvent.ROLL_OUT,outLabel);
			words.addEventListener(MouseEvent.CLICK,onClick);
			words.setTextFormat(textFormat);
			lengthLabel=words.x+words.width;
		}
		function onLabel(e:MouseEvent) {
			e.target.setTextFormat(defaultTextFormat);
			var filters:Array=serie.filters;
			filters.push(new GlowFilter(serie.color,1,2,2,1.5));
			serie.filters=filters;//这个是个setter;
		}
		function outLabel(e:MouseEvent) {
			e.target.setTextFormat(textFormat);
			var filters:Array=serie.filters;
			filters.pop();
			serie.filters=filters;
		}
		function onClick(e:MouseEvent) {
			serie.visible=!serie.visible;
			if(!serie.visible){
				serie.tulip.visible=false
					serie.marker.visible=false;
			}
			dispatchEvent(new Event("update"));
			if(!serie.visible){
				textFormat.color=0x999999;
				if(serie.type==='line'){
					graphics.lineStyle(2,0x999999);
				graphics.moveTo(10,12);
				graphics.lineTo(25,12);
				}
				else if(serie.type==='scatter'){
				scatter.color=0x999999;
				}else if(serie.type==='area')
				{
				graphics.lineStyle(1,0x999999);
				graphics.beginFill(0x999999);
				graphics.drawRoundRect(7.5,7,15,10,3,3);
				this.graphics.endFill();}
			}else{
			textFormat.color=0x666688;
			if(serie.type==='line'){
				graphics.lineStyle(2,serie.color);
				graphics.moveTo(10,12);
				graphics.lineTo(25,12);
				}else if(serie.type==='scatter')
				{
				scatter.color=serie.color;
				}else if(serie.type==='area')
				{
				graphics.lineStyle(0,serie.color);
				graphics.beginFill(serie.color,serie.alpha);
				graphics.drawRoundRect(7.5,7,15,10,3,3);
				this.graphics.endFill();}
				}
		}
	}

}