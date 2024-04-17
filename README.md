# 関数呼び出しにかかるオーバーヘッドの計測と原因究明

本リポジトリは、各種関数呼び出しにかかるオーバーヘッドの計測を行うためのサンプルプログラムと、
そのコストの要因を解析するためのツールを提供する。

## 検証環境

純粋に関数呼び出しのオーバーヘッドを計測するため、
システムコールは極力使わず、関数内で実行する処理もFPUを使わない最低限としている。
さらに、OSのCPUスケジューリングによる影響も極力除くために、`SCHED_FIFO`の最高優先度を設定した上で実行時間を計測している。

### time

実時間・user空間・kernel空間の時間を確認できるので、
上記の意図通りuser空間だけで処理が完結しているか、IO待ちが発生していないかを確認することができる。

### perf

下記コマンドで、99Hzでframe pointerを使い、スタックトレースをサンプリングする。

```
$ sudo perf record -F 99 -g ./std_func_clang
$ sudo perf report -n --stdio
```

さらに、`perf stat`を使うことでPMC (Performance Monitoring Counter)の情報を得ることもできる。

### cachegrind (valgrind)

ほとんどメモリを使わないプログラムなので、CPU cacheが問題になる可能性は低いが、
念の為に確認する場合は、cachegrindで確認できる。

```
$ valgrind --tool=cachegrind ./std_func_clang 
==2965917== Cachegrind, a cache and branch-prediction profiler
==2965917== Copyright (C) 2002-2017, and GNU GPL'd, by Nicholas Nethercote et al.
==2965917== Using Valgrind-3.15.0 and LibVEX; rerun with -h for copyright info
==2965917== Command: ./std_func_clang
==2965917== 
--2965917-- warning: L3 cache found, using its data for the LL simulation.
==2965917== 
==2965917== I   refs:      72,002,286,500
==2965917== I1  misses:             1,153
==2965917== LLi misses:             1,133
==2965917== I1  miss rate:           0.00%
==2965917== LLi miss rate:           0.00%
==2965917== 
==2965917== D   refs:      48,000,691,298  (25,000,514,690 rd   + 23,000,176,608 wr)
==2965917== D1  misses:            14,501  (        12,275 rd   +          2,226 wr)
==2965917== LLd misses:             9,569  (         8,106 rd   +          1,463 wr)
==2965917== D1  miss rate:            0.0% (           0.0%     +            0.0%  )
==2965917== LLd miss rate:            0.0% (           0.0%     +            0.0%  )
==2965917== 
==2965917== LL refs:               15,654  (        13,428 rd   +          2,226 wr)
==2965917== LL misses:             10,702  (         9,239 rd   +          1,463 wr)
==2965917== LL miss rate:             0.0% (           0.0%     +            0.0%  )
```

### lstopo (hwloc)

ハードウェアトポロジの確認


### vTune

CPUについて更に深堀するのであれば、Intel製プロファイラであるvTuneも選択肢に入れるべきである。


## `std::function`はなぜ遅いのか？

### `std::function` (gcc 9.4.0)

`increment`は`std::function`なので、`increment(ret)`は
`std::function<uint64_t(uint64_t)>::operator()`を呼び出す。

```std_func.cc
    ret = increment(ret);
```

今回のケースでは、inline展開されておらず、`callq`命令が発行されるので、真の関数呼び出し一回目。

```asm
00000000000011f3 <main>:
int main(int argc, char *argv[]) {
    11f3:	f3 0f 1e fa          	endbr64 
    11f7:	53                   	push   %rbx
  for (uint64_t i = 0; i < kLoopCount; i++) {
    11f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  uint64_t ret = 0;
    11fd:	be 00 00 00 00       	mov    $0x0,%esi
  for (uint64_t i = 0; i < kLoopCount; i++) {
    1202:	48 39 1d 07 2e 00 00 	cmp    %rbx,0x2e07(%rip)        # 4010 <kLoopCount>
    1209:	76 15                	jbe    1220 <main+0x2d>
    ret = increment(ret);
    120b:	48 8d 3d 2e 2e 00 00 	lea    0x2e2e(%rip),%rdi        # 4040 <increment>
    1212:	e8 4f 00 00 00       	callq  1266 <std::function<unsigned long (unsigned long)>::operator()(unsigned long) const>
    1217:	48 89 c6             	mov    %rax,%rsi
  for (uint64_t i = 0; i < kLoopCount; i++) {
    121a:	48 83 c3 01          	add    $0x1,%rbx
    121e:	eb e2                	jmp    1202 <main+0xf>
}
    1220:	b8 00 00 00 00       	mov    $0x0,%eax
    1225:	5b                   	pop    %rbx
    1226:	c3                   	retq
```

``std::function<uint64_t(uint64_t)>::operator()`の定義は以下の通り。
`_M_invoker`に`_M_functor`と完全転送した引数群を渡す。

```bits/std_function.h
  template<typename _Res, typename... _ArgTypes>
    _Res
    function<_Res(_ArgTypes...)>::
    operator()(_ArgTypes... __args) const
    {
      if (_M_empty())
        __throw_bad_function_call();
      return _M_invoker(_M_functor, std::forward<_ArgTypes>(__args)...);
    }

```

ここで、`_M_invoker`は第一引数のファンクタを、完全転送した引数群を引数に呼び出す関数の、関数ポインタ。


```bits/std_function.h
      using _Invoker_type = _Res (*)(const _Any_data&, _ArgTypes&&...);
      _Invoker_type _M_invoker;

  ...

            _M_invoker = &_My_handler::_M_invoke;

  ...

  template<typename _Res, typename _Functor, typename... _ArgTypes>
    class _Function_handler<_Res(_ArgTypes...), _Functor>
    : public _Function_base::_Base_manager<_Functor>
    {
      typedef _Function_base::_Base_manager<_Functor> _Base;

    public:
      static _Res
      _M_invoke(const _Any_data& __functor, _ArgTypes&&... __args)
      {
        return (*_Base::_M_get_pointer(__functor))(
            std::forward<_ArgTypes>(__args)...);
      }
    };
```

ここでも、inline展開はされておらず、`callq`命令が発行されるので、真の関数呼び出し二回目。

```asm
0000000000001266 <std::function<unsigned long (unsigned long)>::operator()(unsigned long) const>:

  template<typename _Res, typename... _ArgTypes>
    _Res
    function<_Res(_ArgTypes...)>::
    1266:	f3 0f 1e fa          	endbr64 
    126a:	48 83 ec 18          	sub    $0x18,%rsp
    126e:	48 89 74 24 08       	mov    %rsi,0x8(%rsp)
    operator()(_ArgTypes... __args) const
    {
      if (_M_empty())
    1273:	48 83 7f 10 00       	cmpq   $0x0,0x10(%rdi)
    1278:	74 0d                	je     1287 <std::function<unsigned long (unsigned long)>::operator()(unsigned long) const+0x21>
	__throw_bad_function_call();
      return _M_invoker(_M_functor, std::forward<_ArgTypes>(__args)...);
    127a:	48 8d 74 24 08       	lea    0x8(%rsp),%rsi
    127f:	ff 57 18             	callq  *0x18(%rdi)
    }
    1282:	48 83 c4 18          	add    $0x18,%rsp
    1286:	c3                   	retq   
	__throw_bad_function_call();
    1287:	e8 d4 fd ff ff       	callq  1060 <std::__throw_bad_function_call()@plt>
    128c:	0f 1f 40 00          	nopl   0x0(%rax)
```



```bits/std_function.h
  template<typename _Res, typename... _ArgTypes>
    template<typename _Functor, typename, typename>
      function<_Res(_ArgTypes...)>::
      function(_Functor __f)
      : _Function_base()
      {
        typedef _Function_handler<_Res(_ArgTypes...), _Functor> _My_handler;

        if (_My_handler::_M_not_empty_function(__f))
          {
            _My_handler::_M_init_functor(_M_functor, std::move(__f));
            _M_invoker = &_My_handler::_M_invoke;
            _M_manager = &_My_handler::_M_manager;
          }
      }
```

```bits/std_function.h
  /// Base class of all polymorphic function object wrappers.
  class _Function_base
  {
    ...
    template<typename _Functor>
      class _Base_manager
      {
        ...
        bool _M_empty() const { return !_M_manager; }
```


```bits/std_function.h
  template<typename _Res, typename _Functor, typename... _ArgTypes>
    class _Function_handler<_Res(_ArgTypes...), _Functor>
    : public _Function_base::_Base_manager<_Functor>
    {
      typedef _Function_base::_Base_manager<_Functor> _Base;

    public:
      static _Res
      _M_invoke(const _Any_data& __functor, _ArgTypes&&... __args)
      {
        return (*_Base::_M_get_pointer(__functor))(
            std::forward<_ArgTypes>(__args)...);
      }
    };
```
