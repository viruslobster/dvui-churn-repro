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
> git clone git@github.com:viruslobster/dvui-churn-repro.git
> git clone git@github.com:david-vanderson/dvui.git
> cd dvu-churn-repro && zig build run &| grep -v resize
```

This fixes the problem:
```
diff --git a/src/Window.zig b/src/Window.zig
index 39ce183bd2..0e58c0625f 100644
--- a/src/Window.zig
+++ b/src/Window.zig
@@ -1816,23 +1816,9 @@
     // event to the end this will print a debug message.
     self.positionMouseEventRemove();

-    {
-        const cap = self._arena.queryCapacity();
-        //std.log.debug("_arena capacity {d}", .{cap});
-        _ = self._arena.reset(.{ .retain_with_limit = cap - @divTrunc(cap, 10) });
-    }
-
-    {
-        const cap = self._lifo_arena.queryCapacity();
-        //std.log.debug("_lifo_arena capacity {d}", .{cap});
-        _ = self._lifo_arena.reset(.{ .retain_with_limit = cap - @divTrunc(cap, 10) });
-    }
-
-    {
-        const cap = self._widget_stack.arena.queryCapacity();
-        //std.log.debug("_widget_stack capacity {d}", .{cap});
-        _ = self._widget_stack.reset(.{ .retain_with_limit = cap - @divTrunc(cap, 10) });
-    }
+    _ = self._arena.reset(.retain_capacity);
+    _ = self._lifo_arena.reset(.retain_capacity);
+    _ = self._widget_stack.reset(.retain_capacity);

     // Do this here so subwindows that didn't show are gone for events.
     // Prevent mouse event being tagged with a menu that went away this frame.
```
