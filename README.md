# CLayoutHelper简介
CLayoutHelper首先读取特定数据结构的json数据，然后根据解析的数据使用Autolayout布局，自动绘制出所需要的页面视图。

CLayoutHelper省去了通过Storyboard、xib或者代码绘制UI的步骤，通过配置json数据，理论上完全可以描绘出任意需要的UI界面。

***
# CLayoutHelper实现细节
*CLayoutHelper绘制步骤如下：</br>
1. 根据每一个UI元素对应的不同json数据，计算出left、width、right、top、height、bottom的值（计算时如果是第一个子view其相对位置的视图取superView，其它view相对位置的视图取上一个子view）；</br>
2. 判断`viewType`，运用runtime机制初始化出对应的view实例；</br>
3. 添加对应的Autolayout约束；</br>
4. 设置当前view的属性；</br>
5. 遍历subviews，重复1-4的步骤*

### 1. Autolayout下的UIView布局
![Autolayout布局](https://o44fado6w.qnssl.com/%E5%9B%BE1.png?imageView/2/w/300/q/100)

如图所示，在Autolayout下，一个UIView能够被绘制需要满足以下约束条件:

* 水平方向满足其中的一个条件：left＋width、width＋right、x＋width、left＋right
* 垂直方向满足其中的一个条件：top＋height、height＋bottom、y＋height、top＋bottom

注意水平方向、垂直方向的约束条件不应该存在重复描述的情况，否则会有警告。约束冲突是可以通过设置约束优先级来解决的，现版本暂时未引入。另外框架暂时只处理了上述中，水平与垂直方向的8种约束条件，其它约束条件待扩展。
### 2. 页面布局与json数据结构
![页面布局](https://o44fado6w.qnssl.com/QQ20160907-0@2x.png?imageView/2/w/400/q/100)

分析页面UI，可以认为其是这样构成的：
页面元素以行为单位，从上往下、从左往右，从外往内绘制。
UIView是最外面的一行，其内部的子view是以垂直方向(vertical)布局的；</br>
UIView1存在子view以水平方向(horizontal)布局；</br>
UILabel1是UIView1的第一个子view；</br>
UIScrollView是UIView1的第二个子view，其存在以水平方向布局的两个子view

**对应的json数据结构图:**

![json数据结构](https://o44fado6w.qnssl.com/QQ20160907-1@2x.png?imageView/2/w/400/q/100)

### 3. 单个UI元素的json数据结构
每一个UI元素对应一段特定的json数据，json数据由两部分构成：

1. layout：用于描述页面布局，格式固定
2. model： 用于描述当前view的一些属性

```
{
"layout":{
    "viewStyleIdentifier": "scrollViewType",//配置文件对应的整体view的标识符，最外层view特有字段（最外层view时必填）
    "viewType": "UIView",                   //当前view的class，对应UIKit中的类型（必填）
    "xSpacing": 0,                          //水平方向的间距，对应Leading、Trailing的值（默认0）
    "horizontallyAlignment": "left",        //水平方向的布局位置，left、center、right（默认left）
    "width": "1p",                          //宽度：0高度固定，宽度随文本内容动态变化； 0p~1p：数字加p表示取父view宽度的百分比；40表示＝40（必填）
    "ySpacing": 0,                          //垂直方向的间距，对应Top、Bottom的值（默认0）
    "verticalAlignment": "top",             //垂直方向的布局位置，top、center、bottom（默认top）
    "height": 44,                           //高度：0宽度固定，高度随文本内容动态变化； 0p~1p：数字加p表示取父view高度的百分比；44表示＝44（必填）
    "autolayoutHeight":true,                //是否自动调整高度，当子view中包含高度未确定的元素时，值为true，默认false
    "layoutDirection":"vertical",           //含有子view时，子view的布局方向，horizontally、vertical（默认horizontally水平布局）
    "subviews": []                          //描述子view的数组
   },
"model":{
    "backgroundColor": "#87CEEB",//背景颜色
    "title": "标题",              //当前绘制的view的标题（如果存在的话）
    "titleFont": 14,             //当前绘制的view的字体，默认取最底层superView的配置信息，如果都没有则默认为：[UIFont systemFontOfSize:14]
    "titleColor": "#000000"      //当前绘制的view的字体颜色，默认取最底层superView的配置信息，如果都没有则默认为：[UIColor blackColor]
    "idDescription": "CJUITextView_dz", //用来描述当前view的id，需要保证唯一性
    "placeholder": "请输入地址"    //默认提示
   }
}
```
***

# Objective-C调用
### 1. ConfigurationModel
数据建模类

```objective-c
/**
 *  初始化model
 *
 *  @param info
 *
 *  @return 
 */
- (instancetype)initConfigurationModelInfo:(NSDictionary *)info;
```
### 2. CLayoutHelper
* CLayoutHelperDelegate代理</br>
 可以在代理回调中根据配置设置不同view的不同属性，比如字体大小、背景颜色、字体颜色等

 ```objective-c
 @protocol CLayoutHelperDelegate <NSObject>

 //配置回调
 - (void)configureView:(UIView *)view withModelInfo:(NSDictionary *)info;

 @end
 ```

* ViewStyleIdentifier</br>
ViewStyleIdentifier，描述当前配置文件对应的整体view的唯一标识符，在UITableView中可以将其作为UITableViewCell的Identifier

 ```objective-c
/**
 *  配置绘制的View的标识符（对应viewStyleIdentifier字段）
 *
 *  @param info
 *
 *  @return 
 */
+ (NSString *)configurationViewStyleIdentifier:(ConfigurationModel *)info;
```
* 获取高度以及初始化

 ```objective-c
/**
 *  获取所要绘制view的整体高度
 *
 *  @param info
 *  @param contentViewWidth  绘制UI的父视图的宽度（比如：ScreenWidth）
 *  @param contentViewHeight 绘制UI的父视图的高度（比如：ScreenHeight）
 *
 *  @return
 */
+ (CGFloat)viewHeightWithInfo:(ConfigurationModel *)info contentViewWidth:(CGFloat)contentViewWidth contentViewHeight:(CGFloat)contentViewHeight;

 /**
 *  根据配置文件初始化view
 *
 *  @param info
 *  @param layoutContentView 绘制UI的父视图（在哪个view上绘制）
 *  @param contentViewWidth  绘制UI的父视图的宽度（比如：ScreenWidth）
 *  @param contentViewHeight 绘制UI的父视图的高度（比如：ScreenHeight）
 *  @param delegate          代理
 */
+ (void)initializeViewWithInfo:(ConfigurationModel *)info
             layoutContentView:(UIView *)layoutContentView
              contentViewWidth:(CGFloat)contentViewWidth
             contentViewHeight:(CGFloat)contentViewHeight
                      delegate:(id<CLayoutHelperDelegate>)delegate;
```

### 3. ConfigurationTool
自定义工具类，其中添加了`UIview（ConfigurationView）`分类，增加`idDescription`属性以及`viewWithIdDescription:`方法，可以通过idDescription获取指定view

```objective-c
@interface UIView (ConfigurationView)
/**
 *  自定义属性，用来描述view的id
 */
@property (nonatomic, copy) NSString *_Nullable idDescription;

/**
 *  根据idDescription获取view，
 *  可以是view本身，也可为nil
 *
 *  @param idDescription view的id声明
 *
 *  @return
 */
- (nullable __kindof UIView *)viewWithIdDescription:(nullable NSString *)idDescription;
@end
```

使用时直接将`CLayoutHelper`文件夹添加到项目中即可，更多详情请参考[demo](https://github.com/lele8446/listDemo)
