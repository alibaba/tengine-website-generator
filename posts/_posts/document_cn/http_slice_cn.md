# ngx_http_slice_module

This module can be thought out as a _reverse byte-range_ request header. It's main utility is to allow Nginx to slice a big file in small pieces (byte-ranges) while permitting to use on-the-fly gzip compression.

A typical example is for allowing someone to download a large video file while keeping the bandwith usage minimal. This might also be used as device for selling a video file by pieces where each link points to different zones of the file splitted by file ranges.

Other use would be to use a generic CSS file and use only part of it for each section of a site. Granted that byte-range slicing isn't the most intuitive for such.

Note also that using arguments is more **useful** than byte-ranges in the sense that they can be set in a normal link, while byte ranges require a special [HTTP header](https://en.wikipedia.org/wiki/Byte_serving).

## Examples

```
location ^~ /video-dump/ {
    slice; # enable slicing
    slice_start_arg s;
    slice_end_arg e;
}

```

So we would request the first 1k of the file like this:

`http://example.com/video-dump/large_vid.mp4?s=0&amp;e=1024`


Notice `s=0`, start at `0` and `e=1024`, stop at `1024` bytes (1k).

## Directives

> 
> **slice**
> **context:** `location`

It enables the content slicing in a given location.

---

> **slice_arg_begin** `string`
> **default:** `begin`
> **context:** `http, server, location`

Defines the argument that defines the request range of bytes **start**.

---

> **slice_arg_end** `string`
> **default:** `end`
> **context:** `http, server, location`

---

> Defines the argument that defines the request range of bytes **end**.
> **slice_header** `string`
> **context:** `http, server, location`


---
Defines the string to be used as the **header** of each slice being
> served by Nginx.
> **slice_footer** `string`
> **context:** `http, server, location`

Defines the string to be used as the **footer** of each slice being
served by Nginx.

---

> **slice_header_first** `on` | `off`
> **default:** `on`
> **context:** `http, server, location`

If set to `off` and when requesting the **first** byte of the file do **not
serve** the header.

This directive is particularly useful to differentiate the **first**
slice from the remaining slices. The first slice is the one which has
**no** header.

---

> **slice_footer_last** `on` |  `off`
> **default:** `on`
> **context:** `http, server, location`

If set to `off` and when requesting the **last** byte of the file do **not
serve** the header.

This directive is particularly useful to differentiate the **last**
slice from the remaining slices. The last slice is the one which has
**no** footer.

Here's some examples that explore all the options.

### Serve a huge DB file while sending headers except on the first slice


```
location ^~ /dbdumps/ {
    slice; # enable slicing
    slice_start_arg first;
    slice_end_arg last;
    slice_header '-- **db-slice-start**';
    slice_header_first off;
}
```

Then a request like this:


```
http://example.com/dbdumps/somedb.sql?first=0&amp;last=1048576

```

Send the first 1M and skip the `-- **db-slice-start**` header.

### Serve a huge DB file while sending headers except on the first slice


```
location ^~ /dbdumps/ {
    slice; # enable slicing
    slice_start_arg first;
    slice_end_arg last;
    slice_header '-- **db-slice-start**';
    slice_header_first off;
    slice_footer '-- **db-slice-end**';
}

```

This differs from the previous in the sense that it sends a footer.

### Serve a huge DB file while sending headers except on the first slice and send footer except on the last slice


```
location ^~ /dbdumps/ {
    slice; # enable slicing
    slice_start_arg first;
    slice_end_arg last;
    slice_header '-- **db-slice-start**';
    slice_header_first off;
    slice_footer '-- **db-slice-end**';
    slice_footer_last off;
}

```

Then a request like this:



`http://example.com/dbdumps/somedb.sql?first=0&amp;last=1048576`

Send the first 1M and skip the `-- **db-slice-start**` header.

If the file is 200MB, we get the last slice with:


`http://example.com/dbdumps/somedb.sql?first=208666624&amp;last=209715200`

this last slice has no footer.
