package components 
{
import laya.display.Sprite;
import laya.events.Event;
import laya.events.MouseManager;
import laya.maths.Point;
import laya.maths.Rectangle;
import laya.utils.Ease;
import laya.utils.Tween;
/**
 * ...滚动容器 实现基本的拖动滚动，回弹效果
 * @author ...Kanon
 */
public class ScrollView extends Sprite 
{
	protected var content:Sprite;
	//是否横向
	protected var _isHorizontal:Boolean;
	//可显示的大小
	protected var viewWidth:Number = 100;
	protected var viewHeight:Number = 100;
	//是否点击
	protected var isTouched:Boolean;
	//点击坐标
	protected var touchPos:Point;
	protected var contentPos:Point;
	//释放后是否有弹性效果
	protected var isBounce:Boolean;
	//动画
	protected var tween:Tween;
	//最大速度
	private const SPEED_MAX:int = 40;
	//是否显示调试模式
	private var isDebug:Boolean;
	//回弹时间
	private var bounceDuration:int;
	//速度
	private var speed:Number;
	//运动摩擦力
	private var friction:Number;
	//上一次鼠标位置
	private var prevMousePos:Point;
	//是否显示调试内容框
	private var _isShowDebug:Boolean;
	public function ScrollView() 
	{
		this.initData();
		this.initUI();
		this.initEvent();
	}
	
	/**
	 * 初始化数据
	 */
	protected function initData():void
	{
		this.speed = 0;
		this.friction = .98;
		this.bounceDuration = 400;
		this.isBounce = true;
		this.isTouched = false;
		this.isShowDebug = false;
		this.optimizeScrollRect = true;
		this.touchPos = new Point();
		this.contentPos = new Point();
		this.prevMousePos = new Point();
	}
	
	/**
	 * 初始化UI
	 */
	protected function initUI():void
	{
		this.content = new Sprite();
		this.addChild(this.content);
		this.content.width = 0;
		this.content.height = 0;
		this.setViewSize(this.viewWidth, this.viewHeight);
	}
	
	/**
	 * 初始化事件
	 */
	protected function initEvent():void
	{
		this.on(Event.MOUSE_DOWN, this, contentMouseDownHandler);
		this.on(Event.MOUSE_UP, this, contentMouseUpHandler);
		Laya.stage.on(Event.MOUSE_UP, this, contentMouseUpHandler);
		Laya.stage.on(Event.MOUSE_OUT, this, contentMouseUpHandler);
		this.frameLoop(1, this, loopHandler)
	}
	
	/**
	 * 更新内容的显示大小
	 */
	protected function updateContentSize():void
	{
		this.debugDrawContentBound();
	}
	
	/**
	 * 用于调试绘制内容的范围
	 */
	protected function debugDrawContentBound():void
	{
		trace("this.isShowDebug", this.isShowDebug);
		if (!this.isShowDebug) return;
		trace(this.content.x, this.content.y, this.content.width, this.content.height);
		this.content.graphics.clear(true);
		this.content.graphics.drawRect(this.content.x, this.content.y, this.content.width, this.content.height, null, "#ff00ff");
		this.graphics.clear(true);
		this.graphics.drawRect(0, 0, this.width, this.height, null, "#ffff00");
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
		this.scrollRect = new Rectangle(0, 0, this.viewWidth, this.viewHeight);
		this.debugDrawContentBound();
	}
	
	/**
	 * 设置内容高宽
	 * @param	width	宽度
	 * @param	height	高度
	 */
	public function setContentSize(width:Number, height:Number):void
	{
		if (!this.content) return;
		this.content.width = width;
		this.content.height = height;
		this.debugDrawContentBound();
	}
	
	/**
	 * 滚动回弹
	 */
	private function scorllBounce():void
	{
		if (this.isTouched || !this.isBounce) return;
		if (!this._isHorizontal)
		{
			if (this.content.height == 0) return;
			if (this.content.y > 0)
			{
				this.speed = 0;
				if (!this.tween) this.tween = Tween.to(this.content, { y : 0 }, this.bounceDuration, Ease.circOut);
			}
			else if (this.content.y < this.viewHeight - this.content.height)
			{
				this.speed = 0;
				if (!this.tween) this.tween = Tween.to(this.content, { y : this.viewHeight - this.content.height }, this.bounceDuration, Ease.circOut);
			}
		}
		else
		{
			if (this.content.width == 0) return;
			if (this.content.x > 0)
			{
				this.speed = 0;
				if (!this.tween) this.tween = Tween.to(this.content, { x : 0 }, this.bounceDuration, Ease.circOut);
			}
			else if (this.content.x < this.viewWidth - this.content.width)
			{
				this.speed = 0;
				if (!this.tween) this.tween = Tween.to(this.content, { x : this.viewWidth - this.content.width }, this.bounceDuration, Ease.circOut);
			}
		}
	}
	
	/**
	 * 是否横向滚动
	 */
	public function get isHorizontal():Boolean {return _isHorizontal; }
	public function set isHorizontal(value:Boolean):void 
	{
		_isHorizontal = value;
		this.updateContentSize();
	}
	
	/**
	 * 是否显示调试
	 */
	public function get isShowDebug():Boolean {return _isShowDebug;}
	public function set isShowDebug(value:Boolean):void 
	{
		_isShowDebug = value;
		this.debugDrawContentBound();
	}
	
	/**
	 * 更新滚动速度
	 */
	private function updateScrollSpeed():void
	{
		if (this.isTouched)
		{
			if (!this._isHorizontal)
				this.speed = MouseManager.instance.mouseY - this.prevMousePos.y;
			else
				this.speed = MouseManager.instance.mouseX - this.prevMousePos.x;
		}
		if (this.speed > SPEED_MAX) this.speed = SPEED_MAX;
		else if (this.speed < -SPEED_MAX) this.speed = -SPEED_MAX;
		this.prevMousePos.x = MouseManager.instance.mouseX;
		this.prevMousePos.y = MouseManager.instance.mouseY;
		this.speed *= this.friction;
		if (Math.abs(this.speed) < .1) this.speed = 0;
	}
	
	/**
	 * 更新位置
	 */
	protected function updatePos():void
	{
		if (this.isTouched)
		{
			if (!this._isHorizontal)
			{
				this.content.y = this.contentPos.y + (MouseManager.instance.mouseY - this.touchPos.y) ;
				if (!this.isBounce)
				{
					if (this.content.y > 0) this.content.y = 0;
					else if (this.content.y < this.viewHeight - this.content.height) this.content.y = this.viewHeight - this.content.height;
				}
			}
			else
			{
				this.content.x = this.contentPos.x + (MouseManager.instance.mouseX - this.touchPos.x) ;
				if (!this.isBounce)
				{
					if (this.content.x > 0) this.content.x = 0;
					else if (this.content.x < this.viewWidth - this.content.width) this.content.x = this.viewWidth - this.content.width;
				}
			}
		}
		else
		{
			if (!this._isHorizontal)
				this.content.y += this.speed;
			else
				this.content.x += this.speed;
		}
	}
	
	/**
	 * 删除tween
	 */
	private function removeTween():void
	{
		if (this.tween)
		{
			this.tween.clear();
			this.tween = null;
		}
	}
	
	/**
	 * 添加到内容容器中
	 * @param	node	显示对象
	 */
	public function addToContent(node:Sprite):void
	{
		this.content.addChild(node);
	}
		
	//------点击事件--------
	private function contentMouseDownHandler():void 
	{
		this.isTouched = true;
		this.removeTween();
		this.touchPos.x = MouseManager.instance.mouseX;
		this.touchPos.y = MouseManager.instance.mouseY;
		this.prevMousePos.x = this.touchPos.x;
		this.prevMousePos.y = this.touchPos.y;
		this.contentPos.x = this.content.x;
		this.contentPos.y = this.content.y;
	}
	
	private function contentMouseUpHandler():void 
	{
		this.updateScrollSpeed();
		this.isTouched = false;
		
	}
	
	//帧循环
	protected function loopHandler():void 
	{
		this.updateScrollSpeed();
		this.scorllBounce();
		this.updatePos();
	}
	//------------------------------

}
}