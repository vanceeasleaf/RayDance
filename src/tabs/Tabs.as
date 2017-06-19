package {
	import mx.flash.UIMovieClip;
	import flash.events.MouseEvent;
	import com.greensock.*;
	import flash.events.Event;
	import raydance .*
	import flash.display.Sprite;

	public class Tabs extends UIMovieClip {
		var tabs:Array 
		private var _activeIndex:int = 0;
		private var 交叠:Number = 8;
		private var oriWidth:Number 
		private var curWidth:Number ;
		private var scaleWidth:Number=700;
		private var edge=8;
		private var _num:int=0;
		public function Tabs() {
			tabs= [tab0];
		oriWidth= tab0.scaleWidth;
		curWidth=oriWidth
			newTab.addEventListener(MouseEvent.CLICK, onNewTab);
			tab0.x = 5;
			tab0.y=tab0.height;
			tab0.index=0
			tab0.num=0;
			tab0.close.addEventListener(MouseEvent.CLICK, onTabClose);
			tab0.tab_inactive.addEventListener(MouseEvent.MOUSE_DOWN, activeControl);
			tab0.addEventListener(MouseEvent.MOUSE_DOWN,down);
		}
		public function get activeNum():int{
			return tabs[ _activeIndex].num;
		}
		public function get activeIndex():int{
			return  _activeIndex
		}
		public function createNewTab(){
			var tab = new Tab  ;tab.label="New Empty Tab"
			addChild(tab);
			tabs.push(tab);
			tab.active = true;
			tabs[_activeIndex].active = false;
			_activeIndex = tabs.length - 1;
			tab.draging=false;
			tab.y =tab0.height;
			tab.close.addEventListener(MouseEvent.CLICK, onTabClose);
			tab.index = _activeIndex;
			_num++;
			tab.num=_num;
			tab.tab_inactive.addEventListener(MouseEvent.MOUSE_DOWN, activeControl);
			tab.addEventListener(MouseEvent.MOUSE_DOWN,down);
			var temp=curWidth;
			calWidth(this.scaleWidth);
			if(curWidth!=temp){tab.scaleWidth=40
				tab.x=5+(tabs.length)*( curWidth - 交叠)
				newTab.x=tab.x + 交叠
				//setChildIndex(newTab, this.numChildren - 1);
				for (var i:int=0; i<tabs.length; i++)
				{
					TweenMax.to(tabs[i],.2, {x:5+i*( curWidth - 交叠),scaleWidth:curWidth
								});
				}
			}else{tab.x=tabs[_activeIndex-1].x+curWidth- 交叠
				//tabBarResize(this.scaleWidth);
				TweenMax.from(tab, .2, {scaleWidth:40});
				TweenMax.to(newTab,.2, {x:tabs[_activeIndex].x + curWidth
								});
			}
		}
		function onNewTab(e:MouseEvent )
		{
			createNewTab();
					dispatchEvent(new Event("newTab"));

		}

		function down(e:MouseEvent ){
			e.currentTarget.mX=e.stageX ;
			e.currentTarget.oldX=e.currentTarget.x
			stage.addEventListener(MouseEvent.MOUSE_MOVE,drag);
			stage.addEventListener(MouseEvent.MOUSE_UP,dragUp);
		}
		function dragUp(e:MouseEvent ){
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,drag);
			stage.removeEventListener(MouseEvent.MOUSE_UP,dragUp);
			TweenMax.to(tabs[_activeIndex],.2,{x:5+_activeIndex*( curWidth - 交叠)})
		}
		function drag(e:MouseEvent ){
			tabs[_activeIndex].x=tabs[_activeIndex].oldX+e.stageX -tabs[_activeIndex].mX;
			if(tabs[_activeIndex].x<5)tabs[_activeIndex].x=5;
			if(tabs[_activeIndex].x>scaleWidth-curWidth)tabs[_activeIndex].x=scaleWidth-curWidth
			if(_activeIndex<tabs.length -1){
				var a=e.stageX-edge -(.5+(_activeIndex+1)*( curWidth - 交叠))
				if(a>0){
					exchange(true);
				}
			}
			if(_activeIndex>0){
				a=e.stageX-edge -(.5+(_activeIndex-1)*( curWidth - 交叠)+curWidth*.75)
				if(a<0){
					exchange(false);
				}
			}
		}
		function exchange(goForth:Boolean ){
			if(goForth){
				TweenMax.to(tabs[_activeIndex+1],.2,{x:5+_activeIndex*( curWidth - 交叠)})
				var a=tabs[_activeIndex].index
				tabs[_activeIndex].index=tabs[_activeIndex+1].index
				tabs[_activeIndex+1].index=a
				var temp=tabs[_activeIndex];
				tabs[_activeIndex]=tabs[_activeIndex+1]
				tabs[_activeIndex+1]= temp;
				_activeIndex=_activeIndex+1;
			}else{
				TweenMax.to(tabs[_activeIndex-1],.2,{x:5+_activeIndex*( curWidth - 交叠)})
				a=tabs[_activeIndex].index
				tabs[_activeIndex].index=tabs[_activeIndex-1].index
				tabs[_activeIndex-1].index=a
				temp=tabs[_activeIndex];
				tabs[_activeIndex]=tabs[_activeIndex-1]
				tabs[_activeIndex-1]= temp;
				_activeIndex=_activeIndex-1;
			}
		}
		function onTabClose(e:MouseEvent )
		{
			var index:int = e.currentTarget.parent.index;
			if (e.currentTarget.parent.num==0)
			{
				return;
			}
			for (i=index+1; i<tabs.length; i++)
			{
				tabs[i].index--;
			}	tabs.splice(index,1);
			
			
			var i:int;calWidth(this.scaleWidth)
			TweenMax.to(e.currentTarget.parent, .2, {scaleWidth:30,alpha:0,x:5+index*(curWidth-交叠)+交叠,onComplete:function(){
				removeChild(e.currentTarget.parent);
				if (_activeIndex==index&&index!=0)
				{
					_activeIndex = index - 1;
					var tab = tabs[_activeIndex];
					tab.active = true;
					tab.parent.setChildIndex(tab, tab.parent.numChildren - 1);
				}
				if(_activeIndex==index&&index==0){
					_activeIndex = index;
					tab = tabs[_activeIndex];
					tab.active = true;
					tab.parent.setChildIndex(tab, tab.parent.numChildren - 1);
				}
				if (_activeIndex>index)
				{
					_activeIndex--;
				}
			dispatchEvent(new CloseTabEvent(e.currentTarget.parent.num));
			}
			}
			);
			for (i=0; i<tabs.length; i++)
			{
				TweenMax.to(tabs[i], .2, {x:5+(i)*(curWidth-交叠),scaleWidth:curWidth});
			}
			TweenMax.to(newTab, .2, {x:5+(tabs.length)*(curWidth-交叠)+交叠});
			e.stopImmediatePropagation();
		}
		public function tabBarResize(barSize:Number )
		{
			this.scaleWidth =barSize;
			calWidth(barSize);
			tabs[0].scaleWidth = curWidth;
			tabs[0].y=tab0.height
			for (var i:int=1; i<tabs.length; i++)
			{
				tabs[i].x = tabs[i - 1].x + curWidth - 交叠;
				tabs[i].y=tab0.height
				tabs[i].scaleWidth = curWidth;
			}
			i = tabs.length - 1;
			newTab.x = tabs[i].x + tabs[i].scaleWidth;
			newTab.y=tab0.height-3-newTab.height
		}
		function calWidth(barSize:Number ){
			curWidth = (barSize-5-交叠) / tabs.length+交叠;
			curWidth = oriWidth > curWidth ? curWidth:oriWidth;
		}
		function activeControl(e:MouseEvent )
		{
			e.currentTarget.parent.parent.setChildIndex(e.currentTarget.parent, e.currentTarget.parent.parent.numChildren - 1);
			tabs[_activeIndex].active = false;
			_activeIndex = e.currentTarget.parent.index;
			tabs[_activeIndex].active = true;
			dispatchEvent(new ActiveTabEvent(e.currentTarget.parent.num));
		}
	}
}
