package components 
{
import laya.display.Sprite;
/**
 * ...滚动列表（并非虚拟滚动列表）
 * @author ...Kanon
 */
public class ListView extends ScrollView 
{
	//内容列表
	protected var contentList:Array;
	//间隔
	public var gap:Number = 0;
	public function ListView() 
	{
		super();
	}
	
	/**
	 * 初始化数据
	 */
	override protected function initData():void 
	{
		super.initData();
		this.contentList = [];
	}
	
	/**
	 * 添加到内容容器中
	 * @param	node	显示对象
	 */
	public function addToContent(node:Sprite):void
	{
		super.addToContent(node);
		this.contentList.push(node); 
		this.updateContentSize();
	}
	
	/**
	 * 更新内容的显示大小
	 */
	override protected function updateContentSize():void
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
					pos += node.height + this.gap;
				else
					pos += node.height;
			}
			else
			{
				node.x = pos;
				node.y = 0;
				if(i < this.contentList.length - 1)
					pos += node.width + this.gap;
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
		super.updateContentSize();
	}
	
		
	/**
	 * 根据索引删除节点
	 * @param	index	索引
	 */
	public function removeNodeByIndex(index:int):void
	{
		if (index < 0 || index > this.contentList.length - 1) return;
		this.contentList.splice(index, 1);
		this.updateContentSize();
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
}
}