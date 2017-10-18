package components 
{
import laya.display.Sprite;
import laya.utils.Handler;
/**
 * ...无限数量虚拟list或table
 * @author ...Kanon
 * 
 * bug [] 为解决
 * [第0为的cell不执行update]
 * [最后一位的cell不执行update]
 */
public class TableView extends ScrollView
{
	private var itemWidth:Number;
	private var itemHeight:Number;
	private var dspRows:int;//一屏显示几行
	private var dspColumns:int;//一屏显示几列
	private var totalRows:int //实际总行数
	private var totalColumns:int //实际总列数
	private var count:int;//数据的数量
	//当前索引
	private var curIndex:int;
	private var cellList:Array;
	//一屏可显示的行或列的数量
	private var showLineCount:int = 0;
	//根据数据数量计算出总的行或列的数量
	private var totalLineCount:int = 0;
	//最后一行或者一列的显示数量
	private var lastLineCellCount:int = 0;
	//一行或一列的显示数量
	private var oneLineCellCount:int = 0;
	public var updateTableCell:Handler;
	public function TableView() 
	{
		super();
	}
	
	public function initTable(count:int, isHorizontal:Boolean, 
							  tableWidth:Number, tableHeight:Number, 
							  itemWidth:Number, itemHeight:Number):void
	{
		this.setViewSize(tableWidth, tableHeight);
		this._isHorizontal = isHorizontal;
		this.itemWidth = itemWidth;
		this.itemHeight = itemHeight;
		this.cellList = [];
		this.updateRowsAndColums();
		this.updateCount(count);
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
			this.dspRows = Math.ceil(this.viewHeight / this.itemHeight);//行
			this.oneLineCellCount = this.dspColumns;
		}
		else
		{
			this.dspColumns = Math.ceil(this.viewWidth / this.itemWidth); //列
			this.dspRows = Math.floor(this.viewHeight / this.itemHeight);
			this.oneLineCellCount = this.dspRows;
		}
		
		trace("this.dspRows",this.dspRows);
		trace("this.dspColumns",this.dspColumns);
	}
	
	/**
	 * 创建cell
	 */
	private function createCell():void
	{
		this.removeAllCell();
		this.curIndex = 0;
		if (count <= 0) return;
		if (!this._isHorizontal)
		{
			for (var i:int = 0; i < this.totalRows; ++i) 
			{
				if (i < this.showLineCount)
					this.createOneLineCell(i, this._isHorizontal);
			}
		}
		else
		{
			for (var i:int = 0; i < this.totalColumns; ++i) 
			{
				if (i < this.showLineCount)
					this.createOneLineCell(i, this._isHorizontal);
			}
		}
	}
	
	/**
	 * 创建一行或一列的cell
	 * @param	lineIndex		行或列的索引
	 * @param	isHorizontal	横或竖
	 */
	private function createOneLineCell(lineIndex:int, isHorizontal:Boolean):void
	{
		var cell:Cell;
		if (!isHorizontal)
		{
			cell = new Cell();
			cell.width = this.viewWidth;
			cell.height = this.itemHeight;
			cell.row = lineIndex;
			cell.y = lineIndex * this.itemHeight;
			cell.graphics.drawRect(0, 0, this.viewWidth, this.itemHeight, null, "#00FFFF");
			this.content.addChild(cell);
			this.cellList.push(cell);
			for (var j:int = 0; j < this.totalColumns; ++j)
			{
				var columnsCell:Cell = new Cell();
				columnsCell.width = this.itemWidth;
				columnsCell.height = this.itemHeight;
				columnsCell.x = j * this.itemWidth;
				columnsCell.row = lineIndex;
				columnsCell.column = j;
				columnsCell.graphics.drawRect(0, 0, this.itemWidth, this.itemHeight, null, "#FFFFFF");
				columnsCell.name = "cell" + j;
				columnsCell.index = (cell.row * this.dspColumns) + columnsCell.column;
				cell.addChild(columnsCell);
			}
		}
		else
		{
			cell = new Cell();
			cell.width = this.itemWidth;
			cell.height = this.viewHeight;
			cell.column = lineIndex;
			cell.x = lineIndex * this.itemWidth;
			cell.graphics.drawRect(0, 0, this.itemWidth, this.viewHeight, null, "#00FFFF");
			this.content.addChild(cell);
			this.cellList.push(cell);
			for (var j:int = 0; j < this.totalRows; ++j) 
			{
				var rowsCell:Cell = new Cell();
				rowsCell.width = this.itemWidth;
				rowsCell.height = this.itemHeight;
				rowsCell.y = j * this.itemHeight;
				rowsCell.column = lineIndex;
				rowsCell.row = j;
				rowsCell.graphics.drawRect(0, 0, this.itemWidth, this.itemHeight, null, "#FFFFFF");
				rowsCell.name = "cell" + j;
				rowsCell.index = (cell.column * this.dspColumns) + rowsCell.row;
				cell.addChild(rowsCell);
			}
		}
	}
	
	/**
	 * 更新数量
	 * @param	count	数量
	 */
	private function updateCount(count:int):void
	{
		this.count = count;
		//计算一屏可显示的行列数
		this.showLineCount = this.getShowLineCount();
		if (!this._isHorizontal)
		{
			//根据count计算出行数
			this.totalRows = Math.ceil(this.count / this.dspColumns);
			this.totalColumns = this.dspColumns;
			//总行列数包括虚拟行列数
			this.totalLineCount = this.totalRows;
			if (this.totalRows < this.showLineCount) this.showLineCount = this.totalRows;
			//计算最后一行数量
			this.lastLineCellCount = this.count % this.dspColumns;
			if (this.lastLineCellCount == 0 && this.count > 0) this.lastLineCellCount = this.dspColumns;
			this.setContentSize(this.viewWidth, this.itemHeight * this.totalRows);
		}
		else
		{
			//根据count计算出列数
			this.totalRows = this.dspRows;
			this.totalColumns = Math.ceil(this.count / this.dspRows);
			//总行列数包括虚拟行列数
			this.totalLineCount = this.totalColumns;
			if (this.totalColumns < this.showLineCount) this.showLineCount = this.totalColumns;
			//计算最后一列数量
			this.lastLineCellCount = this.count % this.dspRows;
			if (this.lastLineCellCount == 0 && this.count > 0) this.lastLineCellCount = this.dspRows;
			this.setContentSize(this.itemWidth * this.totalColumns, this.viewHeight);
		}
	}
	
	/**
	 * cell循环滚动
	 */
	private function scrollCell():void
	{
		var cell:Cell;
		if (!this._isHorizontal)
		{
			//纵
			if (this.curIndex < this.totalRows - this.dspRows - 1 && 
				this.content.y < -this.itemHeight * (this.curIndex + 1))
			{
				//将第一行转入最后一行
				cell = this.cellList[this.curIndex];
				this.cellList[this.curIndex] = null;
				this.curIndex++;
				this.cellList[this.curIndex + this.dspRows] = cell;
				cell.row = this.curIndex + this.dspRows;
				cell.y = (this.curIndex + this.dspRows) * this.itemHeight;
			}
			else if (this.curIndex > 0 && 
					 this.content.y > -this.itemHeight * this.curIndex)
			{
				//将最后一行转入第一行
				cell = this.cellList[this.curIndex + this.dspRows];
				this.cellList[this.curIndex + this.dspRows] = null;
				this.curIndex--;
				this.cellList[this.curIndex] = cell;
				cell.row = this.curIndex;
				cell.y = this.curIndex * this.itemHeight;
			}
		}
		else
		{
			//横
			if (this.curIndex < this.totalColumns - this.dspColumns - 1 && 
				this.content.x < -this.itemWidth * (this.curIndex + 1))
			{
				//将第一行转入最后一行
				cell = this.cellList[this.curIndex];
				this.cellList[this.curIndex] = null;
				this.curIndex++;
				this.cellList[this.curIndex + this.dspColumns] = cell;
				cell.column = this.curIndex + this.dspColumns;
				cell.x = (this.curIndex + this.dspColumns) * this.itemWidth;
			}
			else if (this.curIndex > 0 && 
					 this.content.x > -this.itemWidth * this.curIndex)
			{
				//将最后一行转入第一行
				cell = this.cellList[this.curIndex + this.dspColumns];
				this.cellList[this.curIndex + this.dspColumns] = null;
				this.curIndex--;
				this.cellList[this.curIndex] = cell;
				cell.column = this.curIndex;
				cell.x = this.curIndex * this.itemWidth;
			}
		}
		//trace(this.curIndex, this.totalRows - this.dspRows);
		//trace(this.cellList);
	}
	
	/**
	 * cell帧循环
	 */
	private function updateCell():void
	{
		if (!this.cellList || this.cellList.length == 0) return;
		var totalLine:int = this.totalRows;
		var count:int = this.totalColumns;
		if (this._isHorizontal) 
		{
			totalLine = this.totalColumns;
			count = this.totalRows;
		}
		for (var i:int = this.curIndex; i < this.curIndex + this.showLineCount; ++i) 
		{
			var cell:Cell = this.cellList[i];
			//if (!cell) continue;
			var isLastLine:Boolean = i == totalLine - 1;
			for (var j:int = 0; j < count; ++j) 
			{
				var c:Cell = cell.getChildByName("cell" + j) as Cell;
				if (isLastLine) c.visible = j < this.lastLineCellCount;
				else c.visible = true;
				if (!this._isHorizontal) 
				{
					c.row = cell.row;
					c.index = (cell.row * this.dspColumns) + c.column;
				}
				else
				{
					c.column = cell.column;
					c.index = (cell.column * this.dspRows) + c.row;
				}
				//最后一行或一列
				if (this.updateTableCell && c.visible) this.updateTableCell.runWith(c);
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
	 * 更新数据数量
	 * @param	count	数量
	 */
	public function reloadData(count:int):void
	{
		trace("上一次数量", this.count);
		trace("最新数据数量", count);
		if (count < 0) return;
		this.removeTween();
		var diffCount:int = count - this.count;
		if (diffCount == 0) return;
		var prevX:Number = this.content.x;
		var prevY:Number = this.content.y;
		this.content.x = 0;
		this.content.y = 0;
		//一屏可显示的行数或列数
		var newShowLineCount:int = this.getShowLineCount();
		var newTotalLineCount:int;
		if (!this._isHorizontal)
		{
			var newTotalRows = Math.ceil(count / this.dspColumns);
			if (newTotalRows < newShowLineCount) newShowLineCount = newTotalRows;
			newTotalLineCount = newTotalRows;
		}
		else
		{
			var newTotalColumns = Math.ceil(count / this.dspRows);
			if (newTotalColumns < newShowLineCount) newShowLineCount = newTotalColumns;
			newTotalLineCount = newTotalColumns;
		}
		if (diffCount > 0)
		{
			//增加
			trace("增加");
			var addLine:int = newShowLineCount - this.totalLineCount;
			if (addLine < 0) addLine = 0; //新的一屏行数与总行数相减
			for (var i:int = 0; i < addLine; i++) 
			{
				var lineIndex:int = this.getLastShowLineIndex() + i + 1;
				this.createOneLineCell(lineIndex, this._isHorizontal);
			}
		}
		else if (diffCount < 0)
		{
			//减少
			trace("减少");
			var reduceLine:int = this.totalLineCount - newTotalLineCount;
			if (reduceLine < 0) reduceLine = 0;
			trace("prev cellList ", this.cellList);
			for (var i:int = 0; i < reduceLine; i++) 
			{
				var lineIndex:int = this.totalLineCount - 1 - i;
				trace("lineIndex", lineIndex);
				var cell:Cell = this.cellList[lineIndex];
				if (cell) cell.removeSelf();
				this.cellList.splice(lineIndex, 1);
			}
			trace("当前索引位置", this.curIndex);
			//如果最后一行在可显示的范围内被删除this.curIndex需要减少
			trace("reduceLine", reduceLine);
			//获取最后一个能够被显示的行或列的索引
			if (this.getLastLineIndex() == this.getCurShowLastLineIndex())
			{
				this.curIndex -= reduceLine;
				if (this.curIndex < 0) this.curIndex = 0;
				trace("修正后当前索引位置", this.curIndex);
			}
		}
		this.updateCount(count);
		trace("总行数", this.totalRows);
		trace("最后一行数量", this.lastLineCellCount);
		trace(this.cellList);
		this.content.x = prevX;
		this.content.y = prevY;
	}
	
	/**
	 * 根据行或列的索引获取cell数据
	 * @param	index
	 * @return
	 */
	private function getCellByLineIndex(index:int):Cell
	{
		if (!this.cellList) return null;
		return this.cellList[index];
	}
	
	/**
	 * 获取可显示的最后一行或列的索引
	 * @return
	 */
	private function getLastShowLineIndex():int
	{
		return this.showLineCount - 1;
	}
	
	/**
	 * 获取总数据最后行或列的索引
	 * @return
	 */
	private function getLastLineIndex():int
	{
		return this.totalLineCount - 1;
	}
	
	/**
	 * 获取一屏可显示数量
	 * @return
	 */
	private function getShowLineCount():int
	{
		if (!this._isHorizontal) return this.dspRows + 1;
		return this.dspColumns + 1;
	}
	
	/**
	 * 获取当前可显示的最后一行或列的index
	 * @return
	 */
	private function getCurShowLastLineIndex():int
	{
		return this.curIndex + this.showLineCount - 1;
	}
	
	override protected function loopHandler():void 
	{
		this.scrollCell();
		this.updateCell();
		super.loopHandler();
	}
	
	override public function get isHorizontal():Boolean{ return super.isHorizontal; }
	override public function set isHorizontal(value:Boolean):void 
	{
		super.isHorizontal = value;
		this.updateRowsAndColums();
		this.updateCount(count);
		this.createCell();
	}
}
}
