# ngx_http_ssl_module

## 指令

Syntax: **ssl_pass_phrase_dialog** [builtin | exec:/path/to/exec]

Default: ssl_pass_phrase_dialog builtin

Context: http, server

设置tengine处理使用密钥加密的证书时，通过指定方式获取证书密钥。
类似于apache指令：SSLPassPhraseDialog
支持的参数：

*   builtin
通过控制台交互方式获得密钥
*   exec:/path/to/exec
执行/path/to/exec，将其输出结果作为密钥

