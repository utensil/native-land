# Zig aio exploration

Created by

```bash
just new aio-xp
cd aio-xp
just dep git+https://github.com/Cloudef/zig-aio.git
```

Then modify `build.zig` per https://cloudef.github.io/zig-aio/integration/

And update `main.zig` to use `aio` per its README example.

Currently failing with:

```
zig build
install
└─ install aio_xp
   └─ zig build-exe aio_xp Debug native 2 errors
/Users/utensil/.cache/zig/p/aio-0.0.0-776t3qVVBQCS5e6tiQ2qs6ds8N3NaEvbxqLg6womBPI_/src/coro/Frame.zig:7:21: error: type 'type' not a
 function
pub const List = std.DoublyLinkedList(Link(@This(), "link", .double));
                 ~~~^~~~~~~~~~~~~~~~~
/Users/utensil/.cache/zig/p/aio-0.0.0-776t3qVVBQCS5e6tiQ2qs6ds8N3NaEvbxqLg6womBPI_/src/minilib/dynamic_thread_pool.zig:27:25: error:
 type 'type' not a function
    const RunQueue = std.SinglyLinkedList(Runnable);
                     ~~~^~~~~~~~~~~~~~~~~
```
