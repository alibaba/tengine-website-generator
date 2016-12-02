# proc

provides a mechanism to support standalone processes

you can find the sample at [http://tengine.taobao.org/examples/ngx_proc_daytime_module](../../examples/ngx_proc_daytime_module)

## Examples

```
processes {
    process echo {
        echo on;
        echo_str "hello, world";
        listen 8888;
        count 1;
        priority 1;
        delay_start 10s;
        respawn off;
    }
    
    process example {
        count 1;
        priority 0;
        delay_start 0s;
        respawn on;
    }
}
```

## Directives

> Syntax: **process** `name { }`
> Default: `none`
> Context: `processes`


---

> Syntax: **count** `num`
> Default: `1`
> Context: `process`


Specify the number of processes which will be forked.

---

> Syntax: **priority** `num`
> Default: `0`
> Context: `process`


Priority is a value in the range -20 to 20. Lower priorities cause more favorable scheduling.

---

> Syntax: **delay_start** `time`
> Default: `0s`
> Context: `process`


The directive specifies the time to wait before process starts.

---

> Syntax: **respawn** `on | off`
> Default: `on`
> Context: `process`


The directive specifies whether the process will be restarted by nginx when it encounters some errors and exits.
