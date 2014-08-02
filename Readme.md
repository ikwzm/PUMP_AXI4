PUMP AXI4 to AXI4 (PipeWork Example) 
------------------------------------

###概要###

いわゆるスキャッターギャザーDMAです.  
入力、出力、スキャッターギャザーテーブルの読み込みは AXI4 マスターインターフェース、   
レジスタアクセスには AXI4 スレーブインターフェースを持っています.

####開発環境####

以下の開発環境で合成出来ることを確認しています.

* Xilinx ISE14.2
* Xilinx Vivado 2014.1

###IP for Xilinx###

./target/xilinx/ip/ikwzm_pipework_pump_axi4_to_axi4_0.8.zip     
./target/xilinx/ip/ikwzm_pipework_pump_axi3_to_axi3_0.8.zip 

###シミュレーション###

シミュレーションには GHDL (<http://ghdl.free.fr/>) を使いました。    

このモジュールをコンパイルする前に ./PipeWork/sim/ghdl/ および ./Dummy_Plug/sim/ghdl/dummy_plug にカレントディレクトリを移動して、其々のディレクトリで make を実行してライブラリを作っておく必要があります.  

検証用のシナリオファイルは src/test/scenarios/make_scenario.rb という Ruby スクリプトで生成します.   

このモジュールのコンパイルおよびシミュレーションは、Makefile を用意していますので、make コマンドを実行してください.  

###注意###

とりあえず簡単なテストはしていますが、完璧ではありません. 特に異常系は手つかずです. 

###ライセンス###

二条項BSDライセンス (2-clause BSD license) で公開しています。

