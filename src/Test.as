package 
{
import laya.display.Sprite;
import laya.display.Stage;
import laya.events.Event;
import laya.events.MouseManager;
import laya.net.Loader;
import laya.ui.Image;
import laya.ui.Label;
import laya.utils.Handler;
import laya.utils.Timer;
import components.ScorllContainer;
/**
 * ...测试
 * @author ...Kanon
 */
public class Test 
{
	private var label:Label;
	private var scroll:ScorllContainer;
	public function Test() 
	{
		Laya.init(1136, 640);
		Laya.stage.scaleMode = Stage.SCALE_SHOWALL;
		Laya.stage.screenMode = Stage.SCREEN_HORIZONTAL;
		Laya.stage.bgColor = "#0F1312";
		
		this.scroll = new ScorllContainer();
		this.scroll.setViewSize(500, 500);
		this.scroll.gap = 10;
		Laya.stage.addChild(this.scroll);
		
		this.label = new Label();
		this.label.color = "#FF0000";
		this.label.fontSize = 20;
		Laya.stage.addChild(this.label);
		
		var arr:Array = [];
		arr.push({url:"res/bg.png", type:Loader.IMAGE});
		arr.push({url:"res/yellow.png", type:Loader.IMAGE});
		Laya.loader.load(arr, Handler.create(this, loadImgComplete), null, Loader.IMAGE);
	}
	
	private function loadImgComplete():void
	{
		this.scroll.x = 300;
		this.scroll.y = 20;
		for (var i:int = 0; i < 15; i++) 
		{
			var img:Image = new Image("res/bg.png");
			this.scroll.addNode(img);
		}
		//this.scroll.isHorizontal = true;
		Laya.stage.on(Event.CLICK, this, clickHandler);
		Laya.stage.on(Event.MOUSE_DOWN, this, stageMouseDownHandler);
		Laya.stage.on(Event.MOUSE_UP, this, stageMouseUpHandler);
		Laya.stage.on(Event.MOUSE_OUT, this, stageMouseUpHandler);
		
		var img:Image = new Image("res/bg.png");
		img.x = 900
		img.y = 20
		Laya.stage.addChild(img);

	}
	
	private function stageMouseDownHandler():void 
	{
		this.label.text = "stage mouse down";
	}
	
	private function stageMouseUpHandler():void 
	{
		this.label.text = "stage mouse up";
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
}
}