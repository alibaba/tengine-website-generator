# Simple example

To install Tengine, just follow these three steps:

```
$ ./configure

$ make

# make install
```


By default, it will be installed to /usr/local/nginx. You can use the '--prefix' option to specify the root directory.



## Configure script options
Most of the options are compatible with Nginx. Here we just list the specific options in Tengine. If you want to know all the options supported by Tengine, you can run './configure --help' for help.


#### `--dso-path`

Set the installation directory for the DSO modules.

#### `--dso-tool-path`

Set the installation path for the dso_tool script.

#### `--without-dso`

Disable the DSO (Dynamic Shared Object) feature.

#### `--with-jemalloc`

Enable Tengine to link the jemalloc library for memory management.

#### `--with-jemalloc=path`

Set the path to the source code of the jemalloc library.


## Make targets
Most of the targets are compatible with Nginx. We just list the specific targets in Tengine.


#### `make test`

Run the test cases of Tengine. You might need to install perl to run the them.


#### `make dso_install`

It will copy the shared module library files to the destination directory specified by '--dso-path'. By default, it's in the directory named 'modules' under the Tengine installation directory.
 
