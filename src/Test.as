package 
{
import components.Cell;
import components.ListView;
import components.PageView;
import components.ScrollView;
import components.TableView;
import laya.debug.DebugPanel;
import laya.display.Stage;
import laya.events.Event;
import laya.net.Loader;
import laya.ui.Button;
import laya.ui.Image;
import laya.ui.Label;
import laya.utils.Handler;
import test.Random;
/**
 * ...测试
 * @author ...Kanon
 */
public class Test 
{
	private var label:Label;
	private var pageLabel:Label;
	private var scrollList:ListView;
	private var scroll:ScrollView;
	private var tableView:TableView;
	private var pageView:PageView;
	
	private var itemList:Array;
	private var count:int;
	public function Test() 
	{
		Laya.init(1136, 640);
		Laya.stage.scaleMode = Stage.SCALE_SHOWALL;
		Laya.stage.screenMode = Stage.SCREEN_HORIZONTAL;
		Laya.stage.bgColor = "#0F1312";
		//DebugPanel.init()
		
		this.count = Random.randint(0, 130);
		//this.count = 0;
		this.updateData();
		trace("count", count)

		//this.scrollList = new ListView();
		//this.scrollList.setViewSize(200, 500);
		//this.scrollList.gap = 10;
		//this.scrollList.x = 100;
		//this.scrollList.y = 50;
		//this.scrollList.isShowDebug = true;
		//Laya.stage.addChild(this.scrollList);
		//
		//this.scroll = new ScrollView();
		//this.scroll.setViewSize(200, 500);
		//this.scroll.setContentSize(200, 1800);
		//this.scroll.x = 900;
		//this.scroll.y = 50;
		//this.scroll.isShowDebug = true;
		//this.scroll.isHorizontal = true;
		//Laya.stage.addChild(this.scroll);
		
		this.tableView = new TableView();
		this.tableView.initTable(this.itemList.length, false, 700, 500, 124 + 10, 124 + 10);
		this.tableView.x = 100;
		this.tableView.y = 50;
		//this.tableView.isShowDebug = false;
		this.tableView.updateTableCellHandler = new Handler(this, updateTableCellHandler);
		//this.tableView.isHorizontal = false;
		Laya.stage.addChild(this.tableView);
		/*this.pageView = new PageView();
		this.pageView.init(this.itemList.length, false, 700, 500, 124 + 10, 124 + 10);
		this.pageView.x = 100;
		this.pageView.y = 50;
		this.pageView.isShowDebug = true;
		this.pageView.isBounce = false;
		this.pageView.isHorizontal = true;
		this.pageView.updateTableCellHandler = new Handler(this, updateTableCellHandler);
		this.pageView.updatePageCellHandler = new Handler(this, updatePageCellHandler);
		Laya.stage.addChild(this.pageView);*/

		this.label = new Label();
		this.label.color = "#FF0000";
		this.label.fontSize = 20;
		Laya.stage.addChild(this.label);
		this.label.text = "数量:" + this.count;
		
		this.pageLabel = new Label();
		this.pageLabel.color = "#FF0000";
		this.pageLabel.fontSize = 20;
		Laya.stage.addChild(this.pageLabel);
		this.pageLabel.x = 300;
		this.pageLabel.text = "第0页";

		var arr:Array = [];
		arr.push({url:"res/bg.png", type:Loader.IMAGE});
		arr.push({url:"res/yellow.png", type:Loader.IMAGE});
		Laya.loader.load(arr, Handler.create(this, loadImgComplete), null, Loader.IMAGE);
		
	}
	
	private function updatePageCellHandler():void 
	{
		this.pageLabel.text = "第" + this.pageView.curPageIndex + "页";
	}
	
	private function updateTableCellHandler(cell:Cell):void 
	{
		var label:Label;
		var bg:Image;
		if (!cell.getChildByName("txt"))
		{
			bg = new Image("res/bg.png");
			cell.addChild(bg);
			bg.x = 10;
			bg.y = 10;
			label = new Label();
			label.name = "txt";
			label.fontSize = 24;
			label.color = "#FF0000";
			label.x = cell.width / 2
			label.y = cell.height / 2
			cell.addChild(label);
		}
		else
		{
			label = cell.getChildByName("txt") as Label;
		}
		var itemVo:ItemVo = this.itemList[cell.index];
		label.text = "r: " + cell.row + ", i" + (cell.index + 1);
		label.text = "r: " + cell.column + ", i" + (cell.index + 1);
		label.text = cell.index.toString();
	}
	
	private function loadImgComplete():void
	{
		var btn:Button = new Button("res/bg.png");
		btn.x = 300;
		btn.y = 600;
		btn.on(Event.CLICK, this, addBtnClickHandler);
		Laya.stage.addChild(btn);
		
		var btn:Button = new Button("res/bg.png");
		btn.x = 100;
		btn.y = 600;
		btn.on(Event.CLICK, this, reduceBtnClickHandler);
		Laya.stage.addChild(btn);
		
		var btn:Button = new Button("res/bg.png");
		btn.x = 500;
		btn.y = 600;
		btn.on(Event.CLICK, this, gotoBtnClickHandler);
		Laya.stage.addChild(btn);
		
		/*for (var i:int = 0; i < 15; i++) 
		{
			var img:Image = new Image("res/bg.png");
			if (this.scrollList) this.scrollList.addToContent(img);
		}
		
		var img:Image = new Image("res/bg.png");
		img.x = 0;
		img.y = 20;
		if (this.scroll) this.scroll.addToContent(img);
		
		img = new Image("res/bg.png");
		img.x = 20;
		img.y = 60;
		if (this.scroll) this.scroll.addToContent(img);*/

		Laya.stage.on(Event.CLICK, this, clickHandler);
		Laya.stage.on(Event.MOUSE_DOWN, this, stageMouseDownHandler);
		Laya.stage.on(Event.MOUSE_UP, this, stageMouseUpHandler);
		Laya.stage.on(Event.MOUSE_OUT, this, stageMouseUpHandler);
	}
	
	private function gotoBtnClickHandler():void 
	{
		if (this.tableView)
		{
			var cellIndex:int = Random.randint(0, this.count - 1);
			trace("cellIndex", cellIndex);
			this.label.text = "数量:" + this.count + " cellIndex:" + (cellIndex + 1);
			this.tableView.scrollToIndex(cellIndex);
		}
		if (this.pageView) 
		{
			var pageIndex:int = Random.randint(0, this.pageView.totalPageCount - 1);
			this.label.text = "页数:" + pageIndex;
			this.pageView.gotoPage(pageIndex);
			//var cellIndex:int = Random.randint(0, this.count - 1);
			//this.label.text = "cellIndex:" + cellIndex;
			//this.pageView.gotoPageByIndex(cellIndex);
		}
		
	}
	
	private function reduceBtnClickHandler():void 
	{
		//this.count -= 3;
		this.count -= Random.randint(0, 130);
		if (this.count < 0) this.count = 0;
		this.updateData();
		if (this.tableView) 
		{
			//this.tableView.isShowDebug = !this.tableView.isShowDebug;
			this.tableView.reloadData(this.itemList.length);
		}
		if (this.pageView) this.pageView.reloadData(this.itemList.length);
		this.label.text = "数量:" + this.count;
	}
	
	private function addBtnClickHandler():void 
	{
		//this.count += 44;
		//this.count += 50;
		trace("上一次数量" + this.count);
		this.count += Random.randint(0, 130);
		//this.count = 16;
		this.updateData();
		if (this.tableView) this.tableView.reloadData(this.itemList.length);
		if (this.pageView) this.pageView.reloadData(this.itemList.length);
		this.label.text = "数量:" + this.count;
	}
	
	private function stageMouseDownHandler():void 
	{
		//this.label.text = "stage mouse down";
	}
	
	private function stageMouseUpHandler():void 
	{
		//this.label.text = "数量:" + this.count;
	}
	
	private function clickHandler():void 
	{
		//trace("clickHandler")
		//var img:Image = new Image("res/bg.png");
		//this.scroll.addNode(img);
		//this.scroll.removeAllChild();
		//this.scroll.setViewSize(500, 200);
		//this.scroll.isHorizontal = true;
	}
	
	private function updateData():void
	{
		this.itemList = [];
		for (var i:int = 0; i < this.count; i++) 
		{
			var itemVo:ItemVo = new ItemVo();
			itemVo.index = i;
			itemVo.name = "item" + (i + 1);
			this.itemList.push(itemVo);
		}
	}
}
}

class ItemVo
{
	public var index:int;
	public var name:String;
}