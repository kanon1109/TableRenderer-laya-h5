package components 
{
	import laya.display.Sprite;
/**
 * ...无限数量虚拟list或table
 * @author ...Kanon
 */
public class TableView extends ScrollView
{
	private var rows:int;//一屏显示几行
	private var columns:int;//一屏显示几列
	private var count:int;//数量
	public function TableView() 
	{
		super();
	}
	
	public function initTable(count:int, tableWidth:Number, tableHeight:Number, itemWidth:Number, itemHeight:Number):void
	{
		this.setViewSize(tableWidth, tableHeight);
		this.count = count;

		this.columns = Math.floor(tableWidth / itemWidth);
		this.rows = Math.floor(tableHeight / itemHeight);
		this.setContentSize(itemWidth * this.columns, itemHeight * this.rows);
		
		trace("this.rows, this.columns", this.rows, this.columns);
		
		var cellContainer:Sprite;
		var cell:Sprite;
		if (!this._isHorizontal)
		{
			for (var i:int = 0; i < this.rows; ++i) 
			{
				cellContainer = new Sprite();
				cellContainer.width = tableWidth;
				cellContainer.height = itemHeight;
				cellContainer.y = i * itemHeight;
				cellContainer.graphics.drawRect(0, 0, tableWidth, itemHeight, null, "#AC59FF");
				this.content.addChild(cellContainer);
				for (var j:int = 0; j < this.columns; ++j) 
				{
					cell = new Sprite();
					cell.width = itemWidth;
					cell.height = itemHeight;
					cell.x = j * itemWidth;
					//cell.graphics.drawRect(0, 0, itemWidth, itemHeight, null, "#1AA8E6");
					cellContainer.addChild(cell);
				}
			}
		}
		else
		{
			for (var i:int = 0; i < this.columns; ++i) 
			{
				cellContainer = new Sprite();
				cellContainer.width = itemWidth;
				cellContainer.height = tableHeight;
				cellContainer.x = i * itemWidth;
				cellContainer.graphics.drawRect(0, 0, itemWidth, tableHeight, null, "#AC59FF");
				this.content.addChild(cellContainer);
				for (var j:int = 0; j < this.rows; ++j) 
				{
					cell = new Sprite();
					cell.width = itemWidth;
					cell.height = itemHeight;
					cell.y = j * itemHeight;
					//cell.graphics.drawRect(0, 0, itemWidth, itemHeight, null, "#1AA8E6");
					cellContainer.addChild(cell);
				}
			}
		}
	}
	
	override protected function loopHandler():void 
	{
		super.loopHandler();
	}
}
}