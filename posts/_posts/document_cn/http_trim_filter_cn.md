## trim 模块

该模块用于删除 html ， 内嵌 javascript 和 css 中的注释以及重复的空白符。

```
location / {
trim on;
trim_js on;
trim_css on;
}
```


**trim** `on` | `off`

**默认:** `trim off`

**上下文:** `http, server, location`

使模块有效（失效），删除 html 的注释以及重复的空白符（\n，\r，\t，' '）。

例外：对于 `pre`，`textarea`，`script`，`style` 和 ie/ssi/esi注释 等标签内的内容不作删除操作。

参数值可以包含变量。

例如：

```
set $flag "off";
if ($condition) {
set $flag "on";
}
trim $flag;
```

**trim_js** `on` | `off`

**默认:** `trim_js off`

**上下文:** `http, server, location`

使模块有效（失效），删除 html 内嵌 javascript 的注释以及重复的空白符（\n，\r，\t，' '）。

例外：对于非javascript代码的 `script` 标签内容不作删除操作。

参数值可以包含变量。

**trim_css** `on` | `off`

**默认:** `trim_css off`

**上下文:** `http, server, location`

使模块有效（失效），删除 html 内嵌 css 的注释以及重复的空白符（\n，\r，\t，' ')。

例外：对于非css代码的 `style` 标签内容不作删除操作。

参数值可以包含变量。

**trim_types** `MIME types`

**默认:** `trim_types: text/html`

**上下文:** `http, server, location`

定义哪些[MIME types](http://en.wikipedia.org/wiki/MIME_type)类型的响应可以被处理。

目前只能处理html格式的页面，js和css只针对于html内嵌的代码，不支持处理单独的js和css页面。

如果这样配置 `trim_type text/javascript;`，js代码将被作为html代码来处理而出错。

添加请求参数http_trim=off，将关闭trim功能，返回原始代码，方便对照调试。

格式如下:

`http://www.xxx.com/index.html?http_trim=off`

原始:

```
&lt;!DOCTYPE html&gt;
&lt;textarea  &gt;
trim
module
&lt;/textarea  &gt;
&lt;!--remove all--&gt;
&lt;!--[if IE]&gt; trim module &lt;![endif]--&gt;
&lt;!--[if !IE ]&gt;--&gt; trim module  &lt;!--&lt;![endif]--&gt;
&lt;!--# ssi--&gt;
&lt;!--esi--&gt;
&lt;pre    style  =
"color:   blue"  &gt;Welcome    to    nginx!&lt;/pre  &gt;
&lt;script type="text/javascript"&gt;
/***  muitl comment
***/
//// single comment
str.replace(/     /,"hello");
&lt;/script&gt;
&lt;style   type="text/css"  &gt;
/*** css comment
! ***/
body
{
font-size:  20px ;
line-height: 150% ;
}
&lt;/style&gt;
```

结果:

```
&lt;!DOCTYPE html&gt;
&lt;textarea&gt;
trim
module
&lt;/textarea&gt;
&lt;!--[if IE]&gt; trim module &lt;![endif]--&gt;
&lt;!--[if !IE ]&gt;--&gt; trim module  &lt;!--&lt;![endif]--&gt;
&lt;!--# ssi--&gt;
&lt;!--esi--&gt;
&lt;pre style="color:   blue"&gt;Welcome    to    nginx!&lt;/pre&gt;
&lt;script type="text/javascript"&gt;str.replace(/     /,"hello");&lt;/script&gt;
&lt;style type="text/css"&gt;body{font-size:20px;line-height:150%;}&lt;/style&gt;
```

### html

##### 空白符

*   正文中的 '\r' 直接删除。*   正文中的 '\t' 替换为空格，然后重复的空格保留一个。*   正文中重复的 '\n' 保留一个。*   标签中的 '\t'，'\n' 替换为空格，重复的空格保留一个，'=' 前后的空格直接删除，'>' 前面的空格直接删除。*   标签的双引号和单引号内的空白符不做删除。\<div class="no &nbsp; &nbsp; &nbsp;  trim"\>
    *   `pre` 和 `texterea` 标签的内容不做删除。*   支持 `pre` 嵌套使用。*   `script` 和 `style` 标签的内容不做删除。*   ie条件注释的内容不做删除。*   ssi/esi注释的内容不做删除。

    ##### 注释

    *   如果是ie条件注释不做删除。
    判断规则：`&lt;!--[if &lt;![endif]--&gt;`  之间的内容判断为ie条件注释。
    *   如果是ssi/esi注释的内容不做删除。
    判断规则：`&lt;!--# --&gt;`  `&lt;!--esi --&gt;`  之间的内容分别判断为ssi和esi注释。
    *   其他正常html注释直接删除.  `&lt;!--  --&gt;`

    ### javascript

    借鉴 jsmin 的处理规则 (http://www.crockford.com/javascript/jsmin.html)

    `&lt;script type="text/javascript"&gt;` 或者 `&lt;script&gt;` 标签认为是javascript。

    ##### 空白符

    *   '('，'['，'{'，';'，','，'>'，'=' 后的 '\n'，'\t'，空格 直接删除。
    *   '\r' 直接删除。*   其他情况 重复的 '\n'，'\t'，空格 保留第一个。*   单引号和双引号内不删除。
    如下不做操作：
    "hello   &nbsp;   \\"  &nbsp;   world"
    'hello  &nbsp;       \'  &nbsp;   world'*   正则表达式的内容不删除。
    判断规则：'/' 前的非空字符是 ','，'('，'=' 三种的即认为是正则表达式。( 同jsmin的判断)
    如下不做操作：
    var re=/1 &nbsp; &nbsp; &nbsp;2/;
    data.match(/1  &nbsp;  &nbsp; 2/);

    ##### 注释

    *   删除单行注释。  `//`*   删除多行注释。  `/*   */`
    注意：javascript也有一种条件注释，不过貌似用得很少，jsmin直接删除的，trim也是直接删除。
    http://en.wikipedia.org/wiki/Conditional_comment

    ### css

    借鉴 YUI Compressor 的处理规则 (http://yui.github.io/yuicompressor/css.html)

    `&lt;style type="text/css"&gt;` 或者 `&lt;style&gt;` 标签认为是css。

    ##### 空白符

    *   ';'，'>'，'{'，'}'，':'，',' 前后的 '\n'，'\t'，空格 直接删除。*   '\r' 直接删除。*   其他情况 连续的 '\n'， '\t' 和 空格 保留为一个空格。*   单引号和双引号内不删除。
    如下不做操作：
    "hello   &nbsp;  \\\"  &nbsp;    world"
    'hello  &nbsp;   \'   &nbsp;  &nbsp;   world'

    ##### 注释

    *   child seletor hack的注释不删除。
    `html&gt;/**/body p{color:blue}`*   IE5 /Mac hack 的注释不删除。
    `/*\*/.selector{color:khaki}/**/`*   其他情况删除注释。  `/*    */`
