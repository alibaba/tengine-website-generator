---
title: "ngx_http_ssl_module"
date: "2016-12-02 03:37:32"
---


The SSL module is enhanced with pass-phase dialog support, which is very similar to Apache's [SSLPassPhraseDialog](http://httpd.apache.org/docs/2.0/mod/mod_ssl.html#sslpassphrasedialog).

## Directives

Syntax: **ssl_pass_phrase_dialog** [builtin | exec:/path/to/exec]

Default: ssl_pass_phrase_dialog builtin

Context: http, server


Specify the method to fetch the encrypted private key file.

It's very similar to Apache's [SSLPassPhraseDialog](http://httpd.apache.org/docs/2.0/mod/mod_ssl.html#sslpassphrasedialog):

*   builtin
This is the default where an interactive terminal dialog occurs at startup time just before Nginx detaches from the terminal. Here the administrator needs to manually enter the pass-phrase for each encrypted private key file.
*   exec:/path/to/exec
Here an external program is configured which is called at startup for each encrypted private key file.
It is called with two arguments (the first is of the form "servername:portnumber", the second is either "RSA" or "DSA"), which indicate for which server and algorithm it has to print the corresponding pass-phrase to stdout. The intent is that this external program first runs security checks to make sure that the system is not compromised by an attacker, and only when these checks were passed successfully it provides the pass-phrase.
