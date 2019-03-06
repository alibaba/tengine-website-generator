# 变量

- `$conn_requests`    当前请求在长连接上的序号

- `$dollar` 表示美元符号本身

- `$request_time_msec` 请求处理时间，单位是毫秒，用于log_format中

- `$request_time_usec`  请求处理时间，单位是微秒，用于log_format中

- `$unix_time`  当前时间戳，其值为1970年1月1日以来的秒数

- `$year`   当前4位年（如2011）

- `$year2`  当前2位年（如11）

- `$month`  当前月份，有前导0（如12）

- `$day`    当前日，有前导0（如22）

- `$hour`   当前24小时制的小时，有前导0（如21）

- `$hour12` 当前12小时制的小时，有前导0（如09）

- `$minute` 当前分钟，有前导0（如55）

- `$second` 当前秒，有前导0（如12）

- `$sent_cookie_XXX`    响应Set-Cookie头中XXX的cookie值

- `$host_comment`   主机名和时戳，内容类似于`<!-- localhost Thu, 29 Dec 2011 10:10:56 GMT -->`

- `$ssl_handshake_time`   用于统计SSL握手时间

  
