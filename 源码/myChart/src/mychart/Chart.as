package mychart{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class Chart{
		public var series:Array=[];
		private var xAxis:Axis;
		private var yAxis:Axis;
		private var renderTo:MovieClip;
		private var chart:Sprite;
		private var chartMask:Sprite;
		private var cavasMask:Sprite;
		private var seriesCavas:Sprite;
		private var plotWidth:int;
		private var plotHeight:int;
		private var tickLength:int=4;
		private var marginTop:Number;
		private var marginLeft:Number;
		private var marginRight;
		private var marginBottom;
		private var cavas:Sprite;
		private var zoomRect:Sprite;
		private var tulipCavas:Sprite;
		private var legend:Sprite;
		private var axisCavas:Sprite;
		private var textFormat:TextFormat;
		public var hasRendered:Boolean=false;
		private var animation:Number=0;
		private var sketch:Boolean;
		private var data:Array=[];
		public var scaleWidth:Number;
		public var scaleHeight:Number;
		private var zoomX1:Number;
		private var zoomX2:Number;
		public var zoomed:Boolean;
		private var  shouldZoom:Boolean=false;
		private var zoomer:Zoomer;
		public function Chart(options:Object) {
			this.renderTo=options.renderTo;//仅仅做为一个容器;
			chart=new Sprite
			this.scaleWidth=options.scaleWidth||300;
			this.scaleHeight=options.scaleHeight||300;
			renderTo.addChild (chart);
			this.marginTop=options.margin[0];
			marginRight=options.margin[1];
			marginBottom=options.margin[2];
			this.marginLeft=options.margin[3];
			plotWidth=Math.round(scaleWidth-marginLeft-marginRight);
			plotHeight=Math.round(scaleHeight-marginTop-marginBottom);
			initCavas();
			for each (var serieOptions in options.series||[]) {
				initSeries(serieOptions);
			}
			if(!options.axis){
				options.axis=[];
			}
			this.xAxis=new Axis(true,this.series,plotWidth,plotHeight,options.axis[0]||NaN,options.axis[1]||NaN);
			this.yAxis=new Axis(false,this.series,plotWidth,plotHeight,options.axis[2]||NaN,options.axis[3]||NaN);
			render();
		}
		function initSeries(serieOptions:Object) {
			var serie:Serie=new Serie(serieOptions);
			this.series.push(serie);
		}
		public function resize(scaleWidth,scaleHeight):void{trace("resizeME");
			this.scaleWidth=scaleWidth;
			this.scaleHeight=scaleHeight;
			plotWidth=Math.round(scaleWidth-marginLeft-marginRight);
			plotHeight=Math.round(scaleHeight-marginTop-marginBottom);
			chartMask.graphics.clear();
			chartMask.graphics.lineStyle(0);
			chartMask.graphics.beginFill(0);
			chartMask.graphics.drawRect(0,0,scaleWidth,scaleHeight);
			chartMask.graphics.endFill();
			cavasMask.graphics.clear();
			cavasMask.graphics.lineStyle(0);
			cavasMask.graphics.beginFill(0);
			cavasMask.graphics.drawRect(- tickLength,- tickLength,plotWidth+2*tickLength,plotHeight+2*tickLength);
			cavasMask.graphics.endFill();
			legend.x=scaleWidth/2-legend.width/2;
			legend.y=scaleHeight-20-legend.height;
			cavas.graphics.clear();//画一根线
			cavas.graphics.lineStyle(0,0x009999,0.3);
			cavas.graphics.moveTo(- tickLength,plotHeight);
			cavas.graphics.lineTo((plotWidth+tickLength),plotHeight);
			xAxis.plotWidth=plotWidth;
			xAxis.plotHeight=plotHeight;
			yAxis.plotWidth=plotWidth;
			yAxis.plotHeight=plotHeight;
			xAxis.setScale();
			yAxis.setScale();
			for each (var serie:Serie in series){
				serie.needRedraw=true;
			}
			drawNow();
			redrawTicks();
			zoomer.x=scaleWidth-zoomer.width;
			zoomer.y=marginTop;
			
		}
		function setMask() {
			chartMask=new Sprite  ;
			chart.addChild(chartMask);
			chartMask.graphics.lineStyle(0);
			chartMask.graphics.beginFill(0);
			chartMask.graphics.drawRect(0,0,scaleWidth,scaleHeight);
			chartMask.graphics.endFill();
			chart.mask=chartMask;
		}
		function setCavasMask() {
			cavasMask=new Sprite  ;
			cavasMask.visible=false;
			cavas.addChild(cavasMask);
			cavasMask.graphics.lineStyle(0);
			cavasMask.graphics.beginFill(0);
			cavasMask.graphics.drawRect(- tickLength,- tickLength,plotWidth+2*tickLength,plotHeight+2*tickLength);
			cavasMask.graphics.endFill();
			
		}
		function initCavas() {
			setMask();
			cavas=new Sprite  ;
			cavas.x=marginLeft;
			cavas.y=marginTop;
			chart.addChild(cavas);
			cavas.graphics.lineStyle(0,0x009999,0.3);
			cavas.graphics.moveTo(- tickLength,plotHeight);
			cavas.graphics.lineTo((plotWidth+tickLength),plotHeight);
			
			seriesCavas=new Sprite 
			cavas.addChild(seriesCavas);
			setCavasMask();
			seriesCavas.mask =cavasMask
			textFormat=new TextFormat  ;
			textFormat.font="Lucida Sans Unicode";
			textFormat.size=11;
			textFormat.color=0x666666;
			textFormat.align="right";
			tulipCavas=new Sprite  ;
			cavas.addChild(tulipCavas)
			zoomRect=new Sprite  ;
			zoomRect.mask=cavasMask;	//trace(222);
			cavas.addChild(zoomRect);		
			//cavas.addEventListener(Event.ADDED_TO_STAGE,onStage);	
			renderTo.parent.addEventListener(MouseEvent.MOUSE_DOWN,zoomDown);
			renderTo.parent.addEventListener(MouseEvent.MOUSE_MOVE,moveTulip);
			renderTo.parent.addEventListener(MouseEvent.ROLL_OUT,outChart);
			//trace(renderTo.parent.name);
		}
		function onStage(e:Event){trace("onstage");
			cavas.stage.addEventListener(MouseEvent.MOUSE_DOWN,zoomDown);
			cavas.stage.addEventListener(MouseEvent.MOUSE_MOVE,moveTulip);
		}
		function outChart(e:MouseEvent){
			for each(var serie:Serie in series){
			serie.tulip.visible=false;
			serie.marker.visible=false;
			}
		}
		function moveTulip(e:MouseEvent=null){
			var p:Point=new Point(e.stageX,e.stageY);
			var a:Number=tulipCavas.globalToLocal(p).x;
			var yBefore:Number=10000;//用以防止tulip重叠
			for each(var serie:Serie in series){
				var n:int=serie.data.length;
				if(!serie.visible||n<1){
					continue
				}
				for(var i:int=0;i<n;i++){
					if(a<serie.pixelData[i][0])break;
				}
				if(i==n){
					i=n-1;
				}
				if(Math.abs(a-serie.pixelData[i][0])<20){
					serie.tulip.visible=true;
					serie.marker.visible=true;
					var ux:Number=serie.data[i][0]
					var uy:Number=serie.data[i][1]
					serie.tulip.label=serie.words+' x: '+ux.toFixed(2)+'y: '+uy.toFixed(2);
					if(a<plotWidth*.5){
					serie.tulip.x=serie.pixelData[i][0]+10;
					}else{
						serie.tulip.x=serie.pixelData[i][0]-serie.tulip.width-5;
					}
					var y:Number=serie.pixelData[i][1]-serie.tulip.height*.5;
					if(Math.abs(y-yBefore)>serie.tulip.height){			
					serie.tulip.y=y
					}else{
						//if(serie.tulip.y<yBefore){
						//serie.tulip.y=yBefore-40;
					//	}else{
						if(yBefore<20){
							serie.tulip.y=yBefore+serie.tulip.height+5;
						}else{
							serie.tulip.y=yBefore-serie.tulip.height-5;
						}
						//}
					}
					yBefore=serie.tulip.y;
					serie.marker.x=serie.pixelData[i][0];
					serie.marker.y=serie.pixelData[i][1];
				}else{
					serie.tulip.visible=false;
					serie.marker.visible=false;
				}
			}
		}
		function drawTicks() {
			if (axisCavas) {
				cavas.removeChild(axisCavas);
			}
			axisCavas=new Sprite  ;
			cavas.addChildAt(axisCavas,0);
			axisCavas.graphics.lineStyle(0,0x009999,0.3);
			for each (var tick in xAxis.tickPositions) {
				axisCavas.graphics.moveTo(xAxis.translate(tick),plotHeight);
				axisCavas.graphics.lineTo(xAxis.translate(tick),plotHeight+tickLength);
				var la:TextField=new TextField  ;
				la.selectable=false;
				la.autoSize="center";
				la.text=tick;
				if (hasRendered) {
					var oldPos=xAxis.translate(tick,false,true)-la.textWidth/2-2;
					var newPos=xAxis.translate(tick)-la.textWidth/2-2;
					la.x=oldPos
					TweenMax.to(la,.2, {x:newPos, ease:Strong.easeInOut});
					//new Tween(la,"x",Regular.easeOut,oldPos,newPos,5);
				} else {
					la.x=xAxis.translate(tick)-la.textWidth/2-2;
				}
				la.y=plotHeight;
				la.setTextFormat(textFormat);
				axisCavas.addChild(la);
			}
			for each (tick in yAxis.tickPositions) {
				axisCavas.graphics.moveTo(0,yAxis.translate(tick));
				axisCavas.graphics.lineTo(-4,yAxis.translate(tick));
				la=new TextField  ;
				la.selectable=false;
				//la.autoSize="right";
				la.text=tick;
				la.x=- la.width-4;
				if (hasRendered) {
					oldPos=yAxis.translate(tick,false,true)-la.textHeight/2-2;
					newPos=yAxis.translate(tick)-la.textHeight/2-2;
					la.y=oldPos;
					TweenMax.to(la,.2, {y:newPos, ease:Strong.easeInOut});
					//new Tween(la,"y",Regular.easeOut,oldPos,newPos,5);
				} else {
					la.y=yAxis.translate(tick)-la.textHeight/2-2;
				}
				la.setTextFormat(textFormat);
				axisCavas.addChild(la);
			}
		}
		function redrawTicks() {
			if (axisCavas) {
				cavas.removeChild(axisCavas);
			}
			axisCavas=new Sprite  ;
			cavas.addChildAt(axisCavas,0);
			axisCavas.graphics.lineStyle(0,0x009999,0.3);
			for each (var tick in xAxis.tickPositions) {
				axisCavas.graphics.moveTo(xAxis.translate(tick),plotHeight);
				axisCavas.graphics.lineTo(xAxis.translate(tick),plotHeight+tickLength);
				var la:TextField=new TextField  ;
				la.selectable=false;
				la.autoSize="center";
				la.text=tick;
				la.x=xAxis.translate(tick)-la.textWidth/2-2;
				la.y=plotHeight;
				la.setTextFormat(textFormat);
				axisCavas.addChild(la);
			}
			for each (tick in yAxis.tickPositions) {
				axisCavas.graphics.moveTo(0,yAxis.translate(tick));
				axisCavas.graphics.lineTo(-4,yAxis.translate(tick));
				la=new TextField  ;
				la.selectable=false;
				//la.autoSize="right";
				la.text=tick;
				la.x=- la.width-4;
				la.y=yAxis.translate(tick)-la.textHeight/2-2;
				la.setTextFormat(textFormat);
				axisCavas.addChild(la);
			}
		}
		function updatePoint(e:Event) {
			var scatter=new Scatter(e.target.color,e.target.radius);
			scatter.x=xAxis.translate(e.target.data[e.target.data.length-1][0]);
			scatter.y=yAxis.translate(e.target.data[e.target.data.length-1][1]);
			e.target.scatters.push(scatter);
			e.target.addChild(scatter);
			redraw();
		}
		function drawSeries() {
			var serie:Serie;
			var point:Array;
			var data:Array;
			for each (serie in series) {
				serie.addEventListener("addpoint",updatePoint);
				
				seriesCavas.addChild(serie);
				tulipCavas.addChild(serie.tulip);serie.tulip.visible=false;
				tulipCavas.addChild(serie.marker);serie.marker.visible=false;
				data=new Array  ;
				for each (point in serie.data) {
					data.push([xAxis.translate(point[0]),yAxis.translate(point[1])]);
				}
				serie.pixelData=data;
				serie.zero=yAxis.translate(0);
				if (serie.type==='line') {
					serie.graphics.lineStyle(serie.weight,serie.color);
					var needNotLineTo:Boolean=true;
					for each (point in serie.pixelData) {
						if (needNotLineTo) {
							serie.graphics.moveTo(point[0],point[1]);
							needNotLineTo=false;
						} else {
							serie.graphics.lineTo(point[0],point[1]);
						}
					}
				} else if (serie.type==='scatter') {
					for each (point in serie.pixelData) {
						var scatter=new Scatter(serie.color,serie.radius );
						scatter.x=point[0];
						scatter.y=point[1];
						serie.scatters.push(scatter);
						serie.addChild(scatter);
					}
				} else if (serie.type==='area'&&serie.data.length>0) {
					serie.graphics.lineStyle(0,serie.color);
					serie.graphics.beginFill(serie.color);
					serie.graphics.moveTo(serie.pixelData[0][0],yAxis.translate(0));
					for each (point in serie.pixelData) {
						serie.graphics.lineTo(point[0],point[1]);
					}
					serie.graphics.lineTo(serie.pixelData[serie.pixelData.length-1][0],yAxis.translate(0));
					serie.graphics.lineTo(serie.pixelData[0][0],yAxis.translate(0));
					serie.graphics.endFill();
				}
			}
		}
		function redrawSerie(serie:Serie,data:Array,zero:Number) {
			serie.graphics.clear();
			if (serie.type==='line') {
				serie.graphics.lineStyle(serie.weight,serie.color);
				var needNotLineTo:Boolean=true;
				for each (var point in data) {
					if (needNotLineTo) {
						serie.graphics.moveTo(point[0],point[1]);
						needNotLineTo=false;
					} else {
						serie.graphics.lineTo(point[0],point[1]);
					}
				}
			} else if (serie.type==='scatter') {
				for (var i:int=serie.scatters.length-1; i>=0; i--) {
					serie.removeChildAt(i);
					serie.scatters.pop();
				}
				for each (point in data) {
					var scatter=new Scatter(serie.color,serie.radius);
					scatter.x=point[0];
					scatter.y=point[1];
					serie.scatters.push(scatter);
					serie.addChild(scatter);
				}
			} else if (serie.type==='area'&&data.length>0) {
				serie.graphics.lineStyle(0,serie.color);
				serie.graphics.beginFill(serie.color);
				serie.graphics.moveTo(data[0][0],zero);
				for each (point in data) {
					serie.graphics.lineTo(point[0],point[1]);
				}
				serie.graphics.lineTo(data[data.length-1][0],zero);
				serie.graphics.lineTo(data[0][0],zero);
				serie.graphics.endFill();
			}
		}
		function drawLegend() {
			var legend:Legend=new Legend(this.series);
			this.legend=legend;
			for each (var legendLabel in legend.legendLabels) {
				legendLabel.addEventListener("update",updateScale);
			}
			chart.addChild(legend);
			legend.x=scaleWidth/2-legend.width/2+marginLeft/4;
			legend.y=scaleHeight-20-legend.height;
		}
		function updateScale(e:Event=null) {
			
			redraw();
		}
		function updateData() {
			var point;
			xAxis.setScale();
			yAxis.setScale();
			var isScaled:Boolean=xAxis.needRedraw||yAxis.needRedraw;
			var choose:Boolean;
			if (isScaled) {
				drawTicks();
			}
			for each (var serie in series) {
				choose=serie.needRedraw||isScaled;
				if (choose) {
					if (serie.visible) {
						serie.oldPixelData=serie.pixelData.concat();
						serie.oldZero=serie.zero;
						var data:Array=new Array  ;
						for each (point in serie.data) {
							data.push([xAxis.translate(point[0]),yAxis.translate(point[1])]);
						}
						serie.pixelData=data;
						serie.zero=yAxis.translate(0);
					}
				}
			}
			//var a:Tween=new Tween(this,"animation",Regular.easeOut,0,1,10);
			//a.addEventListener(TweenEvent.MOTION_FINISH,tweenStop1);
			cavas.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			animation=0;
		}
		
		function onEnterFrame(e:Event) {
			var serie:Serie,data:Array,x,y,u,v,i;
			var isScaled:Boolean=xAxis.needRedraw||yAxis.needRedraw;
			var choose:Boolean;
			for each (serie in series) {
				choose=sketch?(! serie.needRedraw)&&isScaled:serie.needRedraw||isScaled;
				if (choose&&serie.visible) {
					data=[];
					for (i in serie.pixelData) {
						x=serie.pixelData[i][0];
						y=serie.pixelData[i][1];
						if ((i<serie.oldPixelData.length)) {
							u=isNaN(serie.oldPixelData[i][0])?x:serie.oldPixelData[i][0];
							v=isNaN(serie.oldPixelData[i][1])?y:serie.oldPixelData[i][1];
						} else {
							u=x;
							v=y;
						}
						x=x*animation+(1-animation)*u;
						y=y*animation+(1-animation)*v;
						data.push([x,y]);
					}
					var zero=serie.zero;
					zero=zero*animation+(1-animation)*serie.oldZero;
					redrawSerie(serie,data,zero);
				}
			}
			if ((animation==1)) {
				cavas.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
				for each (serie in series) {
					serie.needRedraw=false;
				}
			}
			animation+=.2;
			if ((animation>1)) {
				animation=1;
			}
		}
		public function redraw(sketch:Boolean=false) {
			this.sketch=sketch;
			updateData();
			if (sketch) {
				drawSeriesWithAnimation();
			}
		}
		public function drawNow(){
			for each (var serie in series) {
				if (serie.needRedraw) {
					
					serie.oldPixelData=serie.pixelData.concat();
					serie.oldZero=serie.zero;
					var data:Array=new Array  ;
					for each (var point in serie.data) {
						data.push([xAxis.translate(point[0]),yAxis.translate(point[1])]);
					}
					serie.pixelData=data;
					serie.zero=yAxis.translate(0);
					
				}
				serie.needRedraw=false;
				redrawSerie(serie,serie.pixelData,serie.zero);
			}
		}
		function drawSeriesWithAnimation() {
			var serie:Serie;
			var point:Array;
			for each (serie in series) {
				if (serie.needRedraw&&serie.visible) {
					serie.graphics.clear();
					if (serie.type==='line') {
						serie.graphics.lineStyle(2,serie.color);
						var needNotLineTo:Boolean=true;
						for each (point in serie.pixelData) {
							if (needNotLineTo) {
								serie.graphics.moveTo(point[0],point[1]);
								needNotLineTo=false;
							} else {
								serie.graphics.lineTo(point[0],point[1]);
							}
						}
						serie.mask=cavasMask;
					} else if (serie.type==='scatter') {
						for (var i:int=serie.scatters.length-1; i>=0; i--) {
							serie.removeChildAt(i);
							serie.scatters.pop();
						}
						for each (point in serie.pixelData) {
							var scatter=new Scatter(serie.color);
							scatter.x=point[0];
							scatter.y=point[1];
							serie.scatters.push(scatter);
							serie.addChild(scatter);
						}
					} else if (serie.type==='area'&&serie.data.length>1) {
						serie.graphics.lineStyle(0,serie.color);
						serie.graphics.beginFill(serie.color);
						serie.graphics.moveTo(serie.pixelData[0][0],serie.zero);
						for each (point in serie.pixelData) {
							serie.graphics.lineTo(point[0],point[1]);
						}
						serie.graphics.lineTo(serie.pixelData[serie.pixelData.length-1][0],serie.zero);
						serie.graphics.lineTo(serie.pixelData[0][0],serie.zero);
						serie.graphics.endFill();
					}
					serie.mask=cavasMask;
				}
			}cavasMask.x=tickLength;
			TweenMax.from(cavasMask, .5, {x:-plotWidth, ease:Sine.easeInOut});
			//var a:Tween=new Tween(cavasMask,"x",Regular.easeOut,-plotWidth,tickLength,12);
			//a.addEventListener(TweenEvent.MOTION_FINISH,tweenStop1);
			
		}
		function render() {
			drawTicks();
			drawSeries();
			drawLegend();
			hasRendered=true;
			zoomer=new Zoomer;
			zoomer.x=scaleWidth-zoomer.width;
			zoomer.y=marginTop;
			zoomer.visible=false;
			chart.addChild(zoomer);
			zoomer.showAll.addEventListener(MouseEvent.CLICK,unZoom);//unZoom
			zoomer.zoomOut.addEventListener(MouseEvent.CLICK,zoomOut);//unZoom
			
		}//endof function
		function zoomDown(e:MouseEvent){
			var a:Point=new Point(e.stageX,e.stageY);
			zoomX1=zoomRect.globalToLocal(a).x;trace(zoomX1)
			cavas.stage.addEventListener(MouseEvent.MOUSE_MOVE,zoomMove);
			cavas.stage.addEventListener(MouseEvent.MOUSE_UP,zoomUp);
		}
		function  zoomMove(e:MouseEvent){
			var a:Point=new Point(e.stageX,e.stageY);
			zoomX2=zoomRect.globalToLocal(a).x;shouldZoom=true
			var left:Number=Math.min(zoomX1,zoomX2);
			var width:Number=Math.abs(zoomX1-zoomX2);
			with(zoomRect.graphics){
				clear();
				lineStyle();
				beginFill(0x001111,.3);
				drawRect(left,0,width,plotHeight);
				endFill();
			}
		}
		function  zoomUp(e:MouseEvent){
			zoomX2=Math.max(0,zoomX2);
			zoomX2=Math.min(zoomX2,plotWidth);
			zoomX1=Math.max(0,zoomX1);
			zoomX1=Math.min(zoomX1,plotWidth);
			var a:Number=Math.min(zoomX1,zoomX2);
			var b:Number=Math.max(zoomX1,zoomX2);
			trace(a+' '+b);
			if(shouldZoom&&(b-a>10)){
			zoom(a,b);
			}
			shouldZoom=false;
			zoomRect.graphics.clear();
			cavas.stage.removeEventListener(MouseEvent.MOUSE_MOVE,zoomMove);
			cavas.stage.removeEventListener(MouseEvent.MOUSE_UP,zoomUp);
		}
		function zoom(a:Number,b:Number){
			zoomer.visible=true;
			for each(var serie:Serie in series){
				if(!zoomed){
					serie.zoomData=serie.data.concat();//保存原始数据
				}
				var n:int=serie.data.length;
				for(var i:int=0;i<n;i++){
					if(a<serie.pixelData[i][0])break;
				}
				for(var j:int=i;j<n;j++){
					if(b<serie.pixelData[j][0])break;
				}
				serie.zoomInfo.push([i,j]);
				serie.setData(serie.data.slice(i,j));
			}
			redraw();
			zoomed=true;
		}
		function zoomOut(e:MouseEvent=null){
			if(zoomed){
				for each(var serie:Serie in series){
					serie.zoomInfo.pop();
					var u:int=serie.zoomInfo.length
					if(u==0){
						unZoom();return;
					}
					var n:int=serie.data.length;
					var i:int=serie.zoomInfo[u-1][0]
					var j:int=serie.zoomInfo[u-1][1];
					serie.setData(serie.zoomData.slice(i,j));
				}
				xAxis.setScale();
				yAxis.setScale();
				drawNow();
				drawTicks();
			}
		}
		public function unZoom(e:MouseEvent=null){
			zoomed=false;
			for each(var serie:Serie in series){
				serie.zoomInfo=[];
				serie.setData(serie.zoomData.concat());
				serie.zoomData=[];
				serie.tulip.visible=false;
				serie.marker.visible=false;
			}
			xAxis.setScale();
			yAxis.setScale();
			drawNow();
			drawTicks();
			zoomer.visible=false;

		}
		public function dispose(){
			
		}
	}
}