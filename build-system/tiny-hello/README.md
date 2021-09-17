# Building tiny-hello


- Build and output an exectuble

```console
zig build-exe ./tiny-hello.zig -O ReleaseSmall --strip --single-threaded
```

- Break down of each flag:

- `build-exe` - build an executable bin but don't execute it on completion
- `-O ReleaseSmall` - Run time saftey is off and is optimized for a smaller bin size
- `--strip` - removes dbug info from the binary
- `--single-threaded` - Asserts the binary is single-threaded. This will turn thread saftey measures
such as mutexes into `no-ops`.

- Diagram of each release build:

| Release Type   | Runtime Safety | Optimizations |
| :---           | :---           | :---          |
| Debug          | Yes            | No            |
| Release-Safe   | Yes            | Yes, Speed    |
| Release-Small  | No             | Yes, Size     |
| Release-Fast   | No             | Yes, Speed    |

- `Release-Safe` is encouraged despite its speed disadvantage

- Other flags:

- `--dynamic` - Is used with `zig build-lib` to output a dynamic/shared library
