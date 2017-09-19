package 
{
import laya.display.Sprite;
import laya.display.Stage;
import laya.events.Event;
import laya.events.MouseManager;
import laya.net.Loader;
import laya.ui.Image;
import laya.utils.Handler;
import laya.utils.Timer;
import components.ScorllContainer;
/**
 * ...测试
 * @author ...Kanon
 */
public class Test 
{
	private var scroll:ScorllContainer;
	public function Test() 
	{
		Laya.init(1136, 640);
		
		this.scroll = new ScorllContainer();
		this.scroll.setViewSize(500, 500);
		this.scroll.gap = 10;
		Laya.stage.addChild(this.scroll);
		
		var arr:Array = [];
		arr.push({url:"res/bg.png", type:Loader.IMAGE});
		arr.push({url:"res/yellow.png", type:Loader.IMAGE});
		Laya.loader.load(arr, Handler.create(this, loadImgComplete), null, Loader.IMAGE);
	}
	
	private function loadImgComplete():void
	{
		this.scroll.x = 300;
		this.scroll.y = 20;
		for (var i:int = 0; i < 5; i++) 
		{
			var img:Image = new Image("res/bg.png");
			this.scroll.addNode(img);
		}
		this.scroll.isHorizontal = true;
		Laya.stage.on(Event.CLICK, this, clickHandler);
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