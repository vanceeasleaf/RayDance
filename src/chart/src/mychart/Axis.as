package mychart{

	public class Axis {
		private var series:Array;
		public var tickPositions:Array;//标签的物理值
		private var isXAxis:Boolean;
		public var needRedraw:Boolean;
		private var min:Number;
		private var max:Number;
		private var oldMax:Number;
		private var oldMin:Number;
		private var transA:Number;
		private var oldTransA:Number;
		private var dataMin:Number;//用于在用户输入值和计算所得值之间选择
		private var dataMax:Number;
		private var userMin:Number;
		private var userMax:Number;
		private var axisLength:Number;
		private var tickInterval:Number;
		private var tickPixelInterval:int=60;//象素间隔初始值
		public var plotWidth:int;
		public var plotHeight:int;
		public function Axis(isXAxis:Boolean,series:Array,plotWidth:int,plotHeight:int,userMin:Number ,userMax:Number ) {
			this.series=series;
			this.plotWidth=plotWidth;
			this.plotHeight=plotHeight;
			this.userMax=userMax;
			this.userMin=userMin;
			this.isXAxis=isXAxis;
			setScale();
		}
		/**
		 * Set the scale based on data min and max, user set min and max or options
		 *
		 */
		function setScale() {
			oldMin=min;
			oldMax=max;
			getSeriesExtremes();
			setTickPositions();
			oldTransA=transA;
			transA=axisLength/((max-min)||1);
			this.needRedraw = (min !== oldMin || max !== oldMax);
		}//end of function
		/**
		 * Set the tick positions to round values and optionally extend the extremes
		 * to the nearest tick
		 */
		function setTickPositions() {
			axisLength=isXAxis?plotWidth:plotHeight;
			min=isNaN(userMin)?(isNaN(dataMin)?(isNaN(oldMin)?oldMin:0):dataMin):userMin;
			max=isNaN(userMax)?(isNaN(dataMax)?(isNaN(oldMax)?oldMax:1):dataMax):userMax;
			if (min === max) {
				tickInterval=1;//物理间隔
			} else {
				tickInterval = (max - min) * tickPixelInterval / axisLength;
			}
			tickInterval=normalizeTickInterval(tickInterval);
			// find the tick positions
			setLinearTickPositions();
			var roundedMin = tickPositions[0],
			roundedMax = tickPositions[tickPositions.length - 1];
			if (min > roundedMin) {
				tickPositions.shift();
			}
			if (max < roundedMax) {
				tickPositions.pop();
			}
		}
		//end of function;

		/**
		 * Set the tick positions of a linear axis to round values like whole tens or every five.
		 */
		function setLinearTickPositions() {
			var i,
			roundedMin = correctFloat(Math.floor(min / tickInterval) * tickInterval),
			roundedMax = correctFloat(Math.ceil(max / tickInterval) * tickInterval);
			tickPositions=[];
			// populate the intermediate values
			i=correctFloat(roundedMin);
			while (i <= roundedMax) {
				tickPositions.push(i);
				i = correctFloat(i + tickInterval);
			}

		}//endof function
		/**
		 * Fix JS round off float errors
		 * @param {Number} num
		 */
		function correctFloat(num) {
			var invMag,ret=num;
			var magnitude=Math.pow(10,Math.floor(Math.log(tickInterval)/Math.LN10));

			if (magnitude < 1) {
				invMag = Math.round(1 / magnitude)  * 10;
				ret = Math.round(num * invMag) / invMag;
			}
			return ret;
		}//endof function
		/**
		 * Take an interval and normalize it to multiples of 1, 2, 2.5 and 5
		 * @param {Number} interval正规化的物理间隔
		 */
		function normalizeTickInterval(interval) {
			//输入必为正数
			// round to a tenfold of 1, 2, 2.5 or 5
			var magnitude=Math.pow(10,Math.floor(Math.log(interval)/Math.LN10));//数量级，对1到10为1，对11到100为10，对101到1000为100等
			var normalized=interval/magnitude;//取到了科学计数法的小数部分
			// multiples for a linear scale
			var multiples=[1,2,2.5,5,10];
			// normalize the interval to the nearest multiple
			for (var i = 0; i < multiples.length; i++) {
				interval=multiples[i];
				if (normalized <= (multiples[i] + (multiples[i + 1] || multiples[i])) / 2) {
					break;
				}
			}//对5而言，3.75<x<=7.5
			// multiply back to the correct magnitude
			interval*=magnitude;
			return interval;
		}//endof function
		/**
		 * Get the minimum and maximum for the series of each axis
		 */
		function getSeriesExtremes() {
			var run;
			// reset dataMin and dataMax in case we're redrawing
			dataMin=dataMax=NaN;
			for each (var serie in series) {
				run=true;//决定是否要找出这个SERIE的最大最小值
				// ignore hidden series if opted
				if (! serie.visible) {
					run=false;
				}
				if (run) {
					for each (var point in serie.data) {
						var pointValue;
						// x axis
						if (isXAxis) {
							pointValue=point[0];
						} else {
							pointValue=point[1];
						}
						// initial values
						if (isNaN(dataMin)) {
							// start out with the first point
							dataMin=dataMax=pointValue;
						}
						if (pointValue> dataMax) {
							dataMax=pointValue;
						} else if (pointValue < dataMin) {
							dataMin=pointValue;
						}
					}
					// For column, areas and bars, set the minimum automatically to zero
					if (/(area|column|bar)/.test(serie.type)&&! isXAxis) {
						var threshold=0;// use series.options.threshold?
						if (dataMin >= threshold) {
							dataMin=threshold;
						} else if (dataMax < threshold) {
							dataMax=threshold;
						}
					}
				}
			}
		}//end of function
		/**
		 * Translate from axis value to pixel position on the chart, or back
		 *
		 */
		function translate(val:Number, backwards:Boolean=false,old:Boolean=false) {
			var sign = 1,
			cvsOffset = 0,
			localA = old ? oldTransA : transA,
			localMin = old ? oldMin : min,
			returnValue;
			if (! localA) {
				localA=transA;
			}
			if (! isXAxis) {
				sign*=-1;// canvas coordinates inverts the value
				cvsOffset=axisLength;
			}
			if (backwards) {// reverse translation
				returnValue=val/localA+localMin;// from chart pixel to value 
			} else {// normal translation
				returnValue=sign*(val-localMin)*localA+cvsOffset;// from value to chart pixel
			}
			return returnValue;
		}//endof function

	}
}