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
