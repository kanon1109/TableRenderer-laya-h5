package components 
{
import laya.ui.Label;
import laya.utils.Ease;
import laya.utils.Handler;
import laya.utils.Tween;
/**
 * ...翻页滚动组件
 * bug [] 为解决
 * 加到第4个page时不显示。
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
	//总的可显示页数
	private static const MAX_SHOW_PAGE_COUNT:int = 3;
	public var curPageIndex:int = 0;
	public var updateTableCell:Handler;
	public var updatePageCell:Handler;
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
			this.dspColumns = Math.floor(this.viewWidth / this.itemWidth);
			this.dspRows = Math.floor(this.viewHeight / this.itemHeight);//行
		}
		else
		{
			this.dspColumns = Math.floor(this.viewWidth / this.itemWidth); //列
			this.dspRows = Math.floor(this.viewHeight / this.itemHeight);
		}
		trace("this.dspColumns", this.dspColumns);
		trace("this.dspRows", this.dspRows);
	}
	
	/**
	 * 更新页数
	 * @param	count	数据数量
	 */
	private function updatePages(count:int):void
	{
		this.count = count;
		this.totalPageCount = Math.ceil(this.count / (this.dspColumns * this.dspRows));
		this.showPageCount = MAX_SHOW_PAGE_COUNT;
		if (this.totalPageCount < this.showPageCount) this.showPageCount = this.totalPageCount;
		if (!this._isHorizontal)
			this.setContentSize(this.viewWidth, this.viewHeight * this.totalPageCount);
		else
			this.setContentSize(this.viewWidth * this.totalPageCount, this.viewHeight);
	}
	
	/**
	 * 创建cell
	 */
	private function createCell():void
	{
		this.removeAllCell();
		this.cellList = [];
		this.curPageIndex = 0;
		for (var i:int = 0; i < this.showPageCount; i++) 
		{
			this.createOnePageCell(i, this._isHorizontal);
		}
		this.debugDrawContentBound();
	}
	
	/**
	 * 创建一个新页
	 * @param	pageIndex		页数索引
	 * @param	isHorizontal	是否横向
	 */
	private function createOnePageCell(pageIndex:int, isHorizontal:Boolean):void
	{
		var cell:Cell = new Cell();
		cell.width = this.viewWidth;
		cell.height = this.viewHeight;
		cell.index = pageIndex;
		if (isHorizontal) cell.x = pageIndex * cell.width;
		else cell.y = pageIndex * cell.height;
		//创建行列
		for (var j:int = 0; j < this.dspRows; j++) 
		{
			for (var k:int = 0; k < this.dspColumns; k++) 
			{
				var c:Cell = new Cell();
				c.width = this.itemWidth;
				c.height = this.itemHeight;
				c.x = k * this.itemHeight;
				c.y = j * this.itemWidth;
				c.row = j;
				c.column = k;
				c.name = "c" + j + "_" + k; 
				cell.addChild(c);
			}
		}
		this.content.addChild(cell);
		this.cellList.push(cell);
	}
	
	/**
	 * cell帧循环
	 */
	private function updateCell():void
	{
		if (!this.cellList || this.cellList.length == 0) return;
		for (var i:int = 0; i < this.cellList.length; ++i) 
		{
			var cell:Cell = this.cellList[i];
			var index:int = cell.index * this.dspColumns * this.dspRows;
			var isLastPage:Boolean = cell.index == this.totalPageCount - 1;
			for (var j:int = 0; j < this.dspRows; j++) 
			{
				for (var k:int = 0; k < this.dspColumns; k++) 
				{
					var c:Cell = cell.getChildByName("c" + j + "_" + k) as Cell;
					c.row = j;
					c.column = k;
					c.index = index;
					if (isLastPage) c.visible = index < this.count;
					else c.visible = true;
					index++;
					//最后一行或一列
					if (this.updateTableCell && c.visible) 
						this.updateTableCell.runWith(c);
				}
			}
		}
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
				trace("this.curPageIndex", this.curPageIndex);
				trace("this.content.x + this.viewWidth * this.curPageIndex", this.content.x + this.viewWidth * this.curPageIndex);
				trace("-this.viewWidth / 2", -this.viewWidth / 2);
				//下一页
				this.curPageIndex++;
				this.updatePageCell.run();
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
				}
			}
			else if (this.content.x + this.viewWidth * this.curPageIndex >= this.viewWidth / 2 && this.curPageIndex > 0)
			{
				//上一页
				this.curPageIndex--;
				this.updatePageCell.run();
				this.removeTween();
				this.speed = 0;
				this.tween = Tween.to(this.content, { x : -this.viewWidth * this.curPageIndex }, this.bounceDuration, Ease.circOut);
				//trace("this.curPageIndex, this.showPageCount, this.totalPageCount", this.curPageIndex, this.showPageCount, this.totalPageCount);
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
				}
			}
			else
			{
				//弹回
				this.speed = 0;
				if (!this.tween) 
					this.tween = Tween.to(this.content, { x : -this.viewWidth * this.curPageIndex }, this.bounceDuration, Ease.circOut, this.updatePageCell);
			}
		}
		else
		{
			if (this.content.y + this.viewHeight * this.curPageIndex <= -this.viewHeight / 2 && this.curPageIndex < this.totalPageCount - 1)
			{
				//下一页
				this.curPageIndex++;
				this.updatePageCell.run();
				this.removeTween();
				this.speed = 0;
				this.tween = Tween.to(this.content, { y : -this.viewHeight * this.curPageIndex }, this.bounceDuration, Ease.circOut);
				//trace("this.curPageIndex, this.showPageCount, this.totalPageCount", this.curPageIndex, this.showPageCount, this.totalPageCount);
				if (this.curPageIndex >= this.showPageCount - 1 && 
					this.curPageIndex < this.totalPageCount - 1 &&
					this.showPageCount < this.totalPageCount)
				{
					//交换cell
					trace("交换cell");
					cell = this.cellList.shift();
					this.cellList.push(cell);
					cell.index = this.curPageIndex + 1;
					cell.y = (this.curPageIndex + 1) * this.viewHeight;
				}
			}
			else if (this.content.y + this.viewHeight * this.curPageIndex >= this.viewHeight / 2 && this.curPageIndex > 0)
			{
				//上一页
				this.curPageIndex--;
				this.updatePageCell.run();
				this.removeTween();
				this.speed = 0;
				this.tween = Tween.to(this.content, { y : -this.viewHeight * this.curPageIndex }, this.bounceDuration, Ease.circOut);
				//trace("this.curPageIndex, this.showPageCount, this.totalPageCount", this.curPageIndex, this.showPageCount, this.totalPageCount);
				if (this.curPageIndex > 0 && 
					this.curPageIndex <= this.totalPageCount - this.showPageCount && 
					this.showPageCount < this.totalPageCount)
				{
					//交换cell
					trace("上一页 交换cell");
					cell = this.cellList.pop();
					this.cellList.unshift(cell);
					cell.index = this.curPageIndex - 1;
					cell.y = (this.curPageIndex - 1) * this.viewHeight;
				}
			}
			else
			{
				//弹回
				this.speed = 0;
				if (!this.tween) 
					this.tween = Tween.to(this.content, { y : -this.viewHeight * this.curPageIndex }, this.bounceDuration, Ease.circOut, this.updatePageCell);
			}
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
		this.updateCell();
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
				for (var j:int = 0; j < this.dspRows; j++) 
				{
					for (var k:int = 0; k < this.dspColumns; k++) 
					{
						var c:Cell = cell.getChildByName("c" + j + "_" + k) as Cell;
						c.graphics.clear(true);
					}
				}
				if (this._isShowDebug) 
				{
					cell.graphics.drawRect(0, 0, this.viewWidth, this.viewHeight, null, "#00FFFF");
					for (var j:int = 0; j < this.dspRows; j++) 
					{
						for (var k:int = 0; k < this.dspColumns; k++) 
						{
							var c:Cell = cell.getChildByName("c" + j + "_" + k) as Cell;
							c.graphics.drawRect(0, 0, this.itemWidth, this.itemHeight, null, "#FFFF00", .5);
						}
					}
				}
			}
		}
	}
	
	/**
	 * 更新数据数量
	 * @param	count	数量
	 */
	public function reloadData(count:int):void
	{
		if (count < 0) return;
		this.stopScroll();
		var diffCount:int = count - this.count;
		if (diffCount == 0) return;
		var prevX:Number = this.content.x;
		var prevY:Number = this.content.y;
		this.content.x = 0;
		this.content.y = 0;
		//新的总页数
		var newShowPageCount:int = MAX_SHOW_PAGE_COUNT; //新的可显示的页数 范围在 1-3
		var newTotalPageCount:int = Math.ceil(count / (this.dspColumns * this.dspRows));
		if (newTotalPageCount < newShowPageCount) newShowPageCount = newTotalPageCount;
		if (diffCount > 0)
		{
			//trace("newShowPageCount", newShowPageCount);
			//trace("newTotalPageCount", newTotalPageCount);
			//trace("totalPageCount", totalPageCount);
			//增加
			var addPage:int = newShowPageCount - this.totalPageCount;
			if (addPage < 0) addPage = 0; //新的一屏行数与总行数相减
			trace("addpage", addPage);
			for (var i:int = 0; i < addPage; i++)
			{
				var lineIndex:int = this.showPageCount + i;
				this.createOnePageCell(lineIndex, this._isHorizontal);
			}
			
			if (this.curPageIndex >= this.totalPageCount - 1 && 
				newTotalPageCount > this.totalPageCount && 
				addPage == 0)
			{
				//如果当前是最后一页，则使用page循环来代替增加新的一页
				//trace("curPageIndex", this.curPageIndex);
				var cell:Cell = this.cellList.shift();
				this.cellList.push(cell);
				cell.index = this.curPageIndex + 1;
				cell.x = (this.curPageIndex + 1) * this.viewWidth;
			}
		}
		else if (diffCount < 0)
		{
			//减少
			trace("newShowPageCount ", newShowPageCount);
			trace("this.curPageIndex ", this.curPageIndex);
			trace("this.totalPageCount ", this.totalPageCount);
			trace("newTotalPageCount ", newTotalPageCount);
			
			var reducePage:int = this.showPageCount - newTotalPageCount;
			if (reducePage < 0) reducePage = 0;
			trace("删除的页数", reducePage);
			trace("curPageIndex", this.curPageIndex);
			for (var i:int = 0; i < reducePage; i++)
			{
				var cell:Cell = this.cellList.pop();
				cell.removeSelf();
			}
			
			if (this.curPageIndex >= newTotalPageCount - 1)
			{
				this.curPageIndex = newTotalPageCount - 1;
				var cell:Cell = this.cellList.pop();
				this.cellList.unshift(cell);
				cell.index = this.curPageIndex - 2;
				cell.x = cell.index * this.viewWidth;
				
			}
			trace("新curPageIndex", this.curPageIndex);

			if (newTotalPageCount <= 1)
			{
				prevX = 0;
				prevY = 0;
			}
		}
		this.content.x = prevX;
		this.content.y = prevY;
		//更新页数
		this.updatePages(count);
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