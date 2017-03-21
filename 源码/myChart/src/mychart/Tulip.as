package mychart
{ import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
	public class Tulip extends Sprite
	{	private var textFormat:TextFormat;
		private  var round:int=20;
		private var _label:TextField;
		private var color:int;
		public function Tulip(color:int)
		{
			textFormat=new TextFormat  ;
			textFormat.color=0xffffff;
			textFormat.font="Lucida Sans Unicode";
			_label=new TextField;
			_label.selectable=false;
			_label.autoSize="center";
			this.addChild(_label);
			this.color= color;
		}
		public function set label(a:String):void{
			this._label.text=a;
			_label.setTextFormat(textFormat);
			var l:int=_label.textWidth+23;
			var h:int=_label.textHeight+10;
			_label.x=10;
			_label.y=3;
			_label.setTextFormat(textFormat);
			this.graphics.clear();
			this.graphics.lineStyle(2,0xFFFFFF);
			this.graphics.beginFill(color);
			this.graphics.drawRoundRect(0,0,l,h,round,round);
			this.graphics.endFill();
			
		}
	}
}