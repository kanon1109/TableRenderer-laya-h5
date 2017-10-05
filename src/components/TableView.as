package components 
{
import laya.display.Sprite;
import laya.utils.Handler;
/**
 * ...无限数量虚拟list或table
 * @author ...Kanon
 * 
 * 
 * bug
 * [第0为的cell不执行update]
 * [最后一位的cell不执行update]
 */
public class TableView extends ScrollView
{
	private var dspRows:int;//一屏显示几行
	private var dspColumns:int;//一屏显示几列
	private var totalRows:int //实际总行数
	private var totalColumns:int //实际总列数
	private var vRows:int;//虚拟行数
	private var vColumns:int;//虚拟列数
	private var count:int;//数量
	private var itemWidth:Number;
	private var itemHeight:Number;
	//当前索引
	private var curIndex:int;
	private var cellList:Array;
	//可显示的数量
	private var showCount:int;
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
		//trace("this.dspRows, this.dspColumns", this.dspRows, this.dspColumns);
		//trace("this.totalRows, this.totalColumns", this.totalRows, this.totalColumns);
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
		}
		else
		{
			this.dspColumns = Math.ceil(this.viewWidth / this.itemWidth);//列
			this.dspRows = Math.floor(this.viewHeight / this.itemHeight);
		}
	}
	
	/**
	 * 创建cell
	 */
	private function createCell():void
	{
		this.removeAllCell();
		this.curIndex = 0;
		var cell:Cell;
		var spt:Sprite;
		if (!this._isHorizontal)
		{
			for (var i:int = 0; i < this.totalRows; ++i) 
			{
				if (i < this.vRows)
				{
					cell = new Cell();
					cell.width = this.viewWidth;
					cell.height = this.itemHeight;
					cell.index = i;
					cell.y = i * this.itemHeight;
					cell.graphics.drawRect(0, 0, this.viewWidth, this.itemHeight, null, "#00FFFF");
					this.content.addChild(cell);
					this.cellList.push(cell);
					for (var j:int = 0; j < this.vColumns; ++j) 
					{
						spt = new Sprite();
						spt.width = this.itemWidth;
						spt.height = this.itemHeight;
						spt.x = j * this.itemWidth;
						spt.graphics.drawRect(0, 0, this.itemWidth, this.itemHeight, null, "#FFFFFF");
						cell.addChild(spt);
					}
				}
				else
				{
					this.cellList.push(null);
				}
			}
		}
		else
		{
			for (var i:int = 0; i < this.totalColumns; ++i) 
			{
				if (i < this.vColumns)
				{
					cell = new Cell();
					cell.width = this.itemWidth;
					cell.height = this.viewHeight;
					cell.index = i;
					cell.x = i * this.itemWidth;
					cell.graphics.drawRect(0, 0, this.itemWidth, this.viewHeight, null, "#00FFFF");
					this.content.addChild(cell);
					this.cellList.push(cell);
					for (var j:int = 0; j < this.vRows; ++j) 
					{
						spt = new Sprite();
						spt.width = this.itemWidth;
						spt.height = this.itemHeight;
						spt.y = j * this.itemHeight;
						spt.graphics.drawRect(0, 0, this.itemWidth, this.itemHeight, null, "#FFFFFF");
						cell.addChild(spt);
					}
				}
				else
				{
					this.cellList.push(null);
				}
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
		if (!this._isHorizontal)
		{
			//根据count计算出行数
			this.totalRows = Math.ceil(this.count / this.dspColumns);
			this.totalColumns = this.dspColumns;
			this.vRows = this.dspRows;
			this.vColumns = this.dspColumns;
			if (this.totalRows > this.dspRows) this.vRows++;
			else this.vRows = this.totalRows;
			this.showCount = this.vRows;
			this.setContentSize(this.viewWidth, this.itemHeight * this.totalRows);
		}
		else
		{
			//根据count计算出列数
			this.totalRows = this.dspRows;
			this.totalColumns = Math.ceil(this.count / this.dspRows);
			this.vRows = this.dspRows;
			this.vColumns = this.dspColumns;
			if (this.totalColumns > this.dspColumns) this.vColumns++;
			else this.vColumns = this.totalColumns;
			this.showCount = this.vColumns;
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
				cell.index = this.curIndex + this.dspRows;
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
				cell.index = this.curIndex;
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
		for (var i:int = this.curIndex; i < this.curIndex + this.showCount; i++) 
		{
			var cell:Cell = this.cellList[i];
			if (this.updateTableCell);
				this.updateTableCell.runWith(cell);
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
