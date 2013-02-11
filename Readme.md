PUMP AXI4 to AXI4 (PipeWork Example) 
------------------------------------

###概要###

いわゆるスキャッターギャザーDMAです.
入力、出力、スキャッターギャザーテーブルの読み込みは AXI4 マスターインターフェース、   
レジスタアクセスには AXI4 スレーブインターフェースを持っています.

###使用コンポーネント###

PipeWork のコンポーネントのうち、次のものを使ってます.
PUMP_AXI4 のほとんどのモジュールは PipeWork のものを使っています.

  * AXI4_REGISTER_INTERFACE
    レジスタアクセス用のAXI4スレーブインターフェースモジュール.   
    ./PipeWork/src/axi4/axi4_register_interface.vhd

  * AXI4_REGISTER_READ_INTERFACE
    レジスタリード用のAXI4スレーブインターフェースモジュール.   
    ./PipeWork/src/axi4/axi4_register_read_interface.vhd

  * AXI4_REGISTER_WRITE_INTERFACE
    レジスタライト用のAXI4スレーブインターフェースモジュール.   
    ./PipeWork/src/axi4/axi4_register_write_interface.vhd

  * AXI4_MASTER_READ_INTERFACE
    AXI4マスターリードインターフェースモジュール.   
    ./PipeWork/src/axi4/axi4_master_read_interface.vhd

  * AXI4_MASTER_WRITE_INTERFACE
    AXI4マスターライトインターフェースモジュール.     
    ./PipeWork/src/axi4/axi4_master_write_interface.vhd

  * PUMP_CONTROLLER
    汎用のポンプ(DMA)のコントローラーモジュール.   
    ./PipeWork/src/pump/pump_controller.vhd

  * PUMP_OPERATION_PROCESSOR
    汎用のポンプ(DMA)をスキャッターギャザー対応にするための簡易プロセッサ.   
    ./PipeWork/src/pump/pump_controller.vhd

  * PUMP_CONTROL_REGISTER
    汎用のポンプ(DMA)の制御レジスタモジュール.   
    ./PipeWork/src/pump/pump_control_register.vhd

  * PUMP_COUNT_DOWN_REGISTER
    汎用のポンプ(DMA)のカウントダウンレジスタ.   
    ./PipeWork/src/pump/pump_count_down_register.vhd

  * PUMP_COUNT_UP_REGISTER
    汎用のポンプ(DMA)のカウントアップレジスタ.   
    ./PipeWork/src/pump/pump_count_up_register.vhd

  * PUMP_FLOW_SYNCRONIZER
    汎用のポンプ(DMA)の入力側と出力側の同期をとるためのクロック同期化モジュール.  
    ./PipeWork/src/pump/pump_flow_syncronizer.vhd

  * PUMP_INTAKE_VALVE
    汎用ポンプ(DMA)の入力側のフロー制御をするモジュール.  
    ./PipeWork/src/pump/pump_intake_valve.vhd

  * PUMP_OUTLET_VALVE
    汎用ポンプ(DMA)の出力側のフロー制御をするモジュール.  
    ./PipeWork/src/pump/pump_outlet_valve.vhd

  * CHOPPER
    先頭アドレスとサイズで示されたブロックを指定された大きさのピースに分割するモジュール.   
    ./PipeWork/src/components/chopper.vhd

  * REDUCER
    異なるデータ幅のパスを継ぐためのアダプタ.   
    ./PipeWork/src/components/reducer.vhd

  * QUEUE_REGISTER
    フリップフロップベースの比較的浅いキュー.   
    ./PipeWork/src/components/queue_register.vhd

  * QUEUE_ARBITER
    キュー(ファーストインファーストアウト)方式の調停回路.   
    ./PipeWork/src/components/queue_arbiter.vhd
    ./PipeWork/src/components/queue_arbiter_integer_arch.vhd

  * SYNCRONIZER  
    異なるクロックで動作するパスを継ぐアダプタのクロック同期化モジュール.  
    ./PipeWork/src/components/syncronizer.vhd  

  * SYNCRONIZER_INPUT_PENDING_REGISTER  
    異なるクロックで動作するパスを継ぐアダプタの入力側レジスタ.  
    ./PipeWork/src/components/syncronizer_input_pending_register.vhd  

  * DELAY_REGISTER  
    入力データを指定したクロックだけ遅延して出力するパイプラインレジスタ.  
    ./PipeWork/src/components/delay_register.vhd  

  * DELAY_ADJUSTER  
    入力データを DELAY REGISTER の出力に合わせてタイミング調整して出力するモジュール.  
    ./PipeWork/src/main/vhdl/components/delay_adjuster.vhd  

  * SDPRAM  
    1W1Rの同期メモリ.  
    ./PipeWork/src/components/sdpram.vhd  
    ./PipeWork/src/components/sdpram_model.vhd  

####開発環境####

以下の開発環境で合成出来ることを確認しています.

* Xilinx ISE14.2

###シミュレーション###

シミュレーションには GHDL (<http://ghdl.free.fr/>) を使いました。    

このモジュールをコンパイルする前に ./PipeWork/sim/ghdl/ および ./Dummy_Plug/sim/ghdl/dummy_plug にカレントディレクトリを移動して、其々のディレクトリで make を実行してライブラリを作っておく必要があります.  

検証用のシナリオファイルは src/test/scenarios/make_scenario.rb という Ruby スクリプトで生成します.   

このモジュールのコンパイルおよびシミュレーションは、Makefile を用意していますので、make コマンドを実行してください.  

###注意###

とりあえず簡単なテストはしていますが、完璧ではありません. 特に異常系は手つかずです. 

###ライセンス###

二条項BSDライセンス (2-clause BSD license) で公開しています。

