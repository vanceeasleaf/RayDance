package mychart{
	import flash.display.Sprite;
	public class Scatter extends Sprite {
		public var radius:Number;
		private var colour:uint;
		private var alph:Number;
		public function Scatter(colour:uint=0xFF0000,radius:Number=3,alph:Number=.7) {
			this.radius=radius;
			this.alph=alph;
			this.color=colour;
		}
		public function set color(value:uint) {
			this.colour=value;
			this.graphics.lineStyle(1,0xffffff,.7);
			this.graphics.beginFill(value,alph);
			this.graphics.drawCircle(0,0,radius);
			this.graphics.endFill();
		}
		public function get color() {
			return colour;
		}
	}
}