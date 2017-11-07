package components 
{
import laya.ui.Label;
import laya.utils.Ease;
import laya.utils.Handler;
import laya.utils.Tween;
/**
 * ...翻页滚动组件
 * @author ...Kanon
 */
public class PageView extends ScrollView 
{
	private var itemWidth:Number;
	private var itemHeight:Number;
	private var dspRows:int;//一屏显示几行
	private var dspColumns:int;//一屏显示几列
	private var count:int;//数据总数量
	private var totalPageCount:int; //总页数
	private var showPageCount:int; //可显示的总页数
	private var cellList:Array;
	//一行或一列的显示数量
	private var oneLineCellCount:int = 0;
	public var curPageIndex:int;
	public var updateTableCell:Handler;
	public function PageView() 
	{
		super();
	}
	
	public function init(count:int, isHorizontal:Boolean, 
						 tableWidth:Number, tableHeight:Number, 
						 itemWidth:Number, itemHeight:Number):void
	{
		this.setViewSize(tableWidth, tableHeight);
		this._isHorizontal = isHorizontal;
		this.itemWidth = itemWidth;
		this.itemHeight = itemHeight;
		this.updateRowsAndColums();
		this.updatePages(count);
		this.createCell();
	}
	
	/**
	 * 更新行数和列数
	 */
	private function updateRowsAndColums():void
	{
		if (!this._isHorizontal)
		{
			this.dspColumns = Math.ceil(this.viewWidth / this.itemWidth);
			this.dspRows = Math.ceil(this.viewHeight / this.itemHeight);//行
		}
		else
		{
			this.dspColumns = Math.ceil(this.viewWidth / this.itemWidth); //列
			this.dspRows = Math.ceil(this.viewHeight / this.itemHeight);
		}
	}
	
	/**
	 * 更新页数
	 * @param	count	数据数量
	 */
	private function updatePages(count:int):void
	{
		this.count = count;
		this.totalPageCount = Math.floor(this.count / (this.dspColumns * this.dspRows));
		//trace("this.dspColumns", this.dspColumns);
		//trace("this.dspRows", this.dspRows);
		this.showPageCount = 3;
		if (this.totalPageCount < this.showPageCount) this.showPageCount = this.totalPageCount;
		this.curPageIndex = 0;
		if (!this._isHorizontal)
			this.setContentSize(this.viewWidth, this.viewHeight * this.totalPageCount);
		else
			this.setContentSize(this.viewWidth * this.totalPageCount, this.viewHeight);
		trace("this.showPageCount", this.showPageCount);
		trace("this.totalPageCount", this.totalPageCount);
	}
	
	/**
	 * 创建cell
	 */
	private function createCell():void
	{
		this.removeAllCell();
		this.cellList = [];
		for (var i:int = 0; i < this.showPageCount; i++) 
		{
			var cell:Cell = new Cell();
			cell.width = this.viewWidth;
			cell.height = this.viewHeight;
			cell.index = i;
			if (this._isHorizontal) cell.x = i * cell.width;
			else cell.y = i * cell.height;
			var text:Label = new Label(i.toString());
			text.fontSize = 30;
			text.color = "#FF0000";
			text.name = "txt";
			//text.x = this.viewWidth - text.width;
			cell.addChild(text);
			this.content.addChild(cell);
			this.cellList.push(cell);
		}
		this.debugDrawContentBound();
	}
	
	/**
	 * cell帧循环
	 */
	private function updateCell():void
	{
		
	}
	
	/**
	 * 删除所有cell
	 */
	private function removeAllCell():void
	{
		if (!this.cellList) return;
		var count:int = this.cellList.length;
		for (var i:int = count - 1; i >= 0; --i) 
		{
			var cell:Cell = this.cellList[i];
			if(cell) cell.removeSelf();
			this.cellList.splice(i, 1);
		}
	}
	
	/**
	 * 翻页
	 */
	private function scrollPage():void
	{
		if (this.isTouched) return;
		var cell:Cell;
		if (this._isHorizontal)
		{
			if (this.content.x + this.viewWidth * this.curPageIndex <= -this.viewWidth / 2 && this.curPageIndex < this.totalPageCount - 1)
			{
				//下一页
				this.curPageIndex++;
				this.removeTween();
				this.speed = 0;
				this.tween = Tween.to(this.content, { x : -this.viewWidth * this.curPageIndex }, this.bounceDuration, Ease.circOut);
				trace("this.curPageIndex, this.showPageCount, this.totalPageCount", this.curPageIndex, this.showPageCount, this.totalPageCount);
				if (this.curPageIndex >= this.showPageCount - 1 && 
					this.curPageIndex < this.totalPageCount - 1 &&
					this.showPageCount < this.totalPageCount)
				{
					//交换cell
					trace("交换cell");
					cell = this.cellList.shift();
					this.cellList.push(cell);
					cell.index = this.curPageIndex + 1;
					cell.x = (this.curPageIndex + 1) * this.viewWidth;
					var txt:Label = cell.getChildByName("txt") as Label;
					txt.text = cell.index.toString();
				}
			}
			else if (this.content.x + this.viewWidth * this.curPageIndex >= this.viewWidth / 2 && this.curPageIndex > 0)
			{
				//上一页
				this.curPageIndex--;
				this.removeTween();
				this.speed = 0;
				this.tween = Tween.to(this.content, { x : -this.viewWidth * this.curPageIndex }, this.bounceDuration, Ease.circOut);
				trace("this.curPageIndex, this.showPageCount, this.totalPageCount", this.curPageIndex, this.showPageCount, this.totalPageCount);
				if (this.curPageIndex > 0 && 
					this.curPageIndex <= this.totalPageCount - this.showPageCount && 
					this.showPageCount < this.totalPageCount)
				{
					//交换cell
					trace("上一页 交换cell");
					cell = this.cellList.pop();
					this.cellList.unshift(cell);
					cell.index = this.curPageIndex - 1;
					cell.x = (this.curPageIndex - 1) * this.viewWidth;
					var txt:Label = cell.getChildByName("txt") as Label;
					txt.text = cell.index.toString();
				}
			}
			else
			{
				//弹回
				this.speed = 0;
				if (!this.tween) 
					this.tween = Tween.to(this.content, { x : -this.viewWidth * this.curPageIndex }, this.bounceDuration, Ease.circOut);
			}
		}
		else
		{
			
		}
	}
	
	/**
	 * 根据页数索引获取页cell
	 * @param	index	页数索引
	 */
	private function getPageCellByIndex(index:int):void
	{
		if (!this.cellList) return;
		if (index < 0) index = 0
		else if (index > this.cellList.length - 1) index = this.cellList.length - 1;
		return this.cellList[index];
	}
	
	override protected function loopHandler():void 
	{
		super.loopHandler();
		this.scrollPage();
	}
	
	override protected function debugDrawContentBound():void 
	{
		super.debugDrawContentBound();
		if (this.cellList)
		{
			for (var i:int = 0; i < this.cellList.length; i++) 
			{
				var cell:Cell = this.cellList[i];
				cell.graphics.clear(true);
				if (this._isShowDebug) cell.graphics.drawRect(0, 0, this.viewWidth, this.viewHeight, null, "#00FFFF");
			}
		}
	}
	
	override public function get isHorizontal():Boolean{ return super.isHorizontal; }
	override public function set isHorizontal(value:Boolean):void 
	{
		super.isHorizontal = value;
		this.updateRowsAndColums();
		this.updatePages(count);
		this.createCell();
	}
}
}