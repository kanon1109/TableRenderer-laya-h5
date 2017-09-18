package 
{
import laya.display.Sprite;
import laya.events.Event;
import laya.events.MouseManager;
import laya.net.Loader;
import laya.ui.Image;
import laya.utils.Handler;
import laya.utils.Timer;
/**
 * ...测试
 * @author ...Kanon
 */
public class Test 
{
	private var touchY:Number;
	private var timer:Timer;
	private var content:Sprite;
	public function Test() 
	{
		Laya.init(1136, 640);
		var arr:Array = [];
		arr.push({url:"res/bg.png", type:Loader.IMAGE});
		arr.push({url:"res/yellow.png", type:Loader.IMAGE});
		Laya.loader.load(arr, Handler.create(this, loadImgComplete), null, Loader.IMAGE);
	}
	
	private function loadImgComplete():void
	{
		var spt:Sprite = new Sprite();
		Laya.stage.addChild(spt);
		spt.x = 200;
		spt.y = 0;
		var maskImg:Image = new Image("res/yellow.png");
		spt.width = 129;
		spt.height = 352;
		//Laya.stage.addChild(maskImg);
		content = new Sprite();
		content.width = 129;
		spt.addChild(content);
		for (var i:int = 0; i < 5; i++) 
		{
			var img:Image = new Image("res/bg.png");
			img.y = i * 130;
			content.addChild(img);
		}
		content.height = i * 130;
		spt.mask = maskImg;
		spt.on(Event.MOUSE_DOWN, this, contentMouseDown);
		Laya.stage.on(Event.MOUSE_UP, this, contentMouseUp);
		this.timer = new Timer();
	}
	
	private function loopHandler():void 
	{
		var y:Number = MouseManager.instance.mouseY - this.touchY;
		content.y -= 2;
	}
	
	private function contentMouseUp():void 
	{
		this.timer.clear(this, loopHandler);
	}
	
	private function contentMouseDown():void 
	{
		trace("touch");
		this.timer.frameLoop(1, this, loopHandler);
		this.touchY = MouseManager.instance.mouseY;
	}
}
}