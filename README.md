Repro arena churn behavior in dvui, e.g.
```
info(DebugAllocator): [1791642582] small alloc 2008 bytes at 0x1156c7800
info(DebugAllocator): [1791642582] small free 2228 bytes at u8@117300000
info(DebugAllocator): [1791642582] small alloc 3460 bytes at 0x1172e0000
info(DebugAllocator): [1791642582] small free 3460 bytes at u8@1172e0000
info(DebugAllocator): [1791642582] small alloc 4172 bytes at 0x1172e0000
info(DebugAllocator): [1791642582] small free 1198 bytes at u8@1156c7800
info(DebugAllocator): [1791642582] small alloc 3758 bytes at 0x117300000
info(DebugAllocator): [1791642582] small free 4172 bytes at u8@1172e0000
info(DebugAllocator): [1791642582] small alloc 2008 bytes at 0x1156c8000
info(DebugAllocator): [1791642582] small free 2228 bytes at u8@117300000
info(DebugAllocator): [1791642582] small alloc 3460 bytes at 0x1172e0000
info(DebugAllocator): [1791642582] small free 3460 bytes at u8@1172e0000
info(DebugAllocator): [1791642582] small alloc 4172 bytes at 0x1172e0000
info(DebugAllocator): [1791642582] small free 1198 bytes at u8@1156c8000
info(DebugAllocator): [1791642582] small alloc 3758 bytes at 0x117300000
info(DebugAllocator): [1791642582] small free 4172 bytes at u8@1172e0000
info(DebugAllocator): [1791642582] small alloc 2008 bytes at 0x1156c8800
info(DebugAllocator): [1791642582] small free 2228 bytes at u8@117300000
info(DebugAllocator): [1791642582] small alloc 3460 bytes at 0x1172e0000
info(DebugAllocator): [1791642582] small free 3460 bytes at u8@1172e0000
info(DebugAllocator): [1791642582] small alloc 4172 bytes at 0x1172e0000
info(DebugAllocator): [1791642582] small free 1198 bytes at u8@1156c8800
info(DebugAllocator): [1791642582] small alloc 3758 bytes at 0x117300000
info(DebugAllocator): [1791642582] small free 4172 bytes at u8@1172e0000
info(DebugAllocator): [1791642582] small alloc 2008 bytes at 0x1156c9000
info(DebugAllocator): [1791642582] small free 2228 bytes at u8@117300000
info(DebugAllocator): [1791642582] small alloc 3460 bytes at 0x1172e0000
info(DebugAllocator): [1791642582] small free 3460 bytes at u8@1172e0000
info(DebugAllocator): [1791642582] small alloc 4172 bytes at 0x1172e0000
info(DebugAllocator): [1791642582] small free 1198 bytes at u8@1156c9000
info(DebugAllocator): [1791642582] small alloc 3758 bytes at 0x117300000
```
^ dvui's arena allocators are constantly freeing 10% of capacity:
```zig
    _ = self._arena.reset(.{ .retain_with_limit = cap - @divTrunc(cap, 10) });
```
So they constantly need to alloc memory from the backing allocator.

To repro:

```fish
> git clone $this-project
> git clone git@github.com:david-vanderson/dvui.git
> cd dvu-churn-repro && zig build run &| grep -v resize
```
