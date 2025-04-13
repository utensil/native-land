# libxev exploration

Created by

```bash
just new xev-xp
cd xev-xp
just dep git+https://github.com/mitchellh/libxev.git
```

Then modify `build.zig` per https://github.com/mitchellh/libxev/pull/133 .

And update `main.zig` to use `libxev` per its README example except for adding a log for timer timeout.

Currently `just run` works.
