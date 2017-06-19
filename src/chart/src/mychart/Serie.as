package mychart{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	public class Serie extends Sprite {
		public var type:String;
		public var words:String;
		public var data:Array;
		public var pixelData:Array;
		public var oldData:Array;
		public var oldPixelData:Array;
		public var zoomData:Array=[];
		public var zoomInfo:Array=[];
		public var tulip:Tulip;
		public var zero:Number;
		public var oldZero:Number;
		public var color:uint;
		public var radius:Number;
		public var weight:Number;
		public var pointIndex:int;
		public var scatters:Array=[];
		public var marker:Scatter;
		public var needRedraw:Boolean=false;
		private var _animate:Boolean;
		public function Serie(options:Object) {
			this.filters=[new DropShadowFilter(.5,45,0,1,2.5,2.5,1)];
			this.data=options.data.concat()||[];
			this.type=options.type||'line';
			this.color=options.color||0x0000FF;
			this.weight=options.weight||2;
			this.alpha=options.alpha||1;
			this.radius =options.radius||3
			this.words=options.name||'未命名';
			tulip=new Tulip(this.color);
			tulip.label=words;
			//tulip.visible=false;
			tulip.filters=[new DropShadowFilter(3,45,0,.5,5,5,1)]
			marker=new Scatter(this.color,5,1);
			marker.filters=[new DropShadowFilter(2,45,0,.5,2.5,2.5,1)];
			
		}
		public function setData(data:Array,animate:Boolean=false) {
			oldData=this.data.concat();
			this.data=data.concat();
			this._animate=animate;
			needRedraw=true;
		}
		public function addPoint(point:*):void {
			data.push(point);
			this.dispatchEvent(new Event("addpoint"));
		}
	}
}