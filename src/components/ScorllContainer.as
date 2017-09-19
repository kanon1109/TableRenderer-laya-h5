package components 
{
import laya.display.Sprite;
import laya.events.Event;
import laya.events.MouseManager;
import laya.maths.Point;
import laya.utils.Ease;
import laya.utils.Tween;
/**
 * ...滚动容器 实现基本的拖动滚动，回弹效果
 * @author ...Kanon
 */
public class ScorllContainer extends Sprite 
{
	protected var content:Sprite;
	protected var maskSpt:Sprite;
	//是否横向
	protected var _isHorizontal:Boolean;
	//可显示的大小
	protected var viewWidth:Number = 100;
	protected var viewHeight:Number = 100;
	//间隔
	protected var _gap:Number = 0;
	//内容列表
	protected var contentList:Array;
	//是否点击
	protected var isTouched:Boolean;
	//点击坐标
	protected var touchPos:Point;
	protected var contentPos:Point;
	//释放后是否有弹性效果
	protected var _isBounce:Boolean;
	//回弹时间
	protected var bounceDuration:int;
	//动画
	protected var tween:Tween;
	public function ScorllContainer() 
	{
		this.init();
		this.initEvent();
	}
	
	/**
	 * 初始化
	 */
	protected function init():void
	{
		this.content = new Sprite();
		this.addChild(this.content);
		this.maskSpt = new Sprite();
		this.mask = this.maskSpt;
		this.setViewSize(this.viewWidth, this.viewHeight);
		
		this.bounceDuration = 400;
		this.isBounce = true;
		this.contentList = [];
		this.touchPos = new Point();
		this.contentPos = new Point();
	}
	
	/**
	 * 初始化事件
	 */
	protected function initEvent():void
	{
		this.on(Event.MOUSE_DOWN, this, contentMouseDownHandler);
		Laya.stage.on(Event.MOUSE_UP, this, contentMouseUpHandler);
		Laya.stage.on(Event.MOUSE_OUT, this, contentMouseUpHandler);
		this.frameLoop(1, this, loopHandler)
	}
	
	/**
	 * 更新内容的显示大小
	 */
	public function updateContentView():void
	{
		var pos:Number = 0;
		for (var i:int = 0; i < this.contentList.length; i++) 
		{
			var node:Sprite = this.contentList[i];
			if (!this._isHorizontal)
			{
				node.x = 0;
				node.y = pos;
				if(i < this.contentList.length - 1)
					pos += node.height + this._gap;
				else
					pos += node.height;
			}
			else
			{
				node.x = pos;
				node.y = 0;
				if(i < this.contentList.length - 1)
					pos += node.width + this._gap;
				else
					pos += node.width;
			}
		}
		if (this._isHorizontal)
		{
			this.content.width = pos;
			this.content.height = this.viewHeight;
		}
		else
		{
			this.content.width = this.viewWidth;
			this.content.height = pos;
		}
		this.debugDrawContentBound();
	}
	
	/**
	 * 用于调试绘制内容的范围
	 */
	protected function debugDrawContentBound():void
	{
		this.content.graphics.clear(true);
		this.content.graphics.drawRect(this.content.x, this.content.y, this.content.width, this.content.height, null, "#ff00ff");
		
		this.graphics.clear(true);
		this.graphics.drawRect(0, 0, this.width, this.height, null, "#ffff00");
	}
	
	/**
	 * 添加到内容容器中
	 * @param	node	显示对象
	 */
	public function addNode(node:Sprite):void
	{
		this.content.addChild(node);
		this.contentList.push(node); 
		this.updateContentView();
	}
	
	/**
	 * 根据索引删除节点
	 * @param	index	索引
	 */
	public function removeNodeByIndex(index:int):void
	{
		if (index < 0 || index > this.contentList.length - 1) return;
		this.contentList.splice(index, 1);
		this.updateContentView();
	}
	
	/**
	 * 删除所有子对象
	 */
	public function removeAllChild():void
	{
		var count:int = this.contentList.length;
		for (var i:int = count - 1; i >= 0; --i)
		{
			var node:Sprite = this.contentList[i];
			node.removeSelf();
			this.contentList.splice(i, 1);
		}
	}
	
	/**
	 * 设置显示区域大小
	 * @param	width	宽度
	 * @param	height	高度
	 */
	public function setViewSize(width:Number, height:Number):void
	{
		this.viewWidth = width;
		this.viewHeight = height;
		this.width = width;
		this.height = height;
		if (this.maskSpt)
		{
			this.maskSpt.graphics.clear(true);
			this.maskSpt.graphics.drawRect(0, 0, this.viewWidth, this.viewHeight, "#000000");
		}
		this.debugDrawContentBound();
	}
	
	/**
	 * 回弹
	 */
	private function bounce():void
	{
		if (this.tween) this.tween.clear();
		if (!this._isHorizontal)
		{
			if (this.content.y > 0)
				this.tween = Tween.to(this.content, { y : 0 }, this.bounceDuration, Ease.circOut);
			else if (this.content.y < this.viewHeight - this.content.height)
				this.tween = Tween.to(this.content, { y : this.viewHeight - this.content.height }, this.bounceDuration, Ease.circOut);
		}
		else
		{
			
		}
	}
	
	/**
	 * 是否横向滚动
	 */
	public function get isHorizontal():Boolean {return _isHorizontal;}
	public function set isHorizontal(value:Boolean):void 
	{
		_isHorizontal = value;
		this.updateContentView();
	}
	
	/**
	 * 间隔
	 */
	public function get gap():Number {return _gap;}
	public function set gap(value:Number):void 
	{
		_gap = value;
	}
	
	/**
	 * 设置是否有回弹
	 */
	public function get isBounce():Boolean {return _isBounce;}
	public function set isBounce(value:Boolean):void 
	{
		_isBounce = value;
	}
	
	private function contentMouseDownHandler():void 
	{
		this.isTouched = true;
		if (this.tween) 
			this.tween.clear();
		this.touchPos.x = MouseManager.instance.mouseX;
		this.touchPos.y = MouseManager.instance.mouseY;
		this.contentPos.x = this.content.x;
		this.contentPos.y = this.content.y;
	}
	
	private function contentMouseUpHandler():void 
	{
		this.isTouched = false;
		this.bounce();
	}
	
	private function loopHandler():void 
	{
		if (this.isTouched)
		{
			if (!this.isHorizontal)
			{
				this.content.y = this.contentPos.y + (MouseManager.instance.mouseY - this.touchPos.y) / 1.5;
				if (!this.isBounce)
				{
					if (this.content.y > 0) this.content.y = 0;
					else if (this.content.y < this.viewHeight - this.content.height) this.content.y = this.viewHeight - this.content.height;
				}
			}
			else
			{
				
			}
		}
	}
}
}