// WavePortal.sol
// SPDX-License-Identifier: MIT
// 2022-11-07 T. Watanabe

pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract WavePortal {

  uint256 totalWaves;
  // 乱数発生のシード
  uint256 private seed;

  // Newwaveイベントの作成
  event NewWave(address indexed from, uint256 timestamp, string message);
  
  // Wave構造体を作成
  struct Wave {
    address waver;     // waveを送ったユーザのアドレス
    string message;    // ユーザが送ったメッセージ
    uint256 timestamp; // ユーザがwaveを送った瞬間のタイムスタンプ
  }
  
  // 構造体の配列を格納する変数waves
  Wave[] waves;
  
  // "address=> uint mapping"は，アドレスと数値を関連付ける
  mapping(address => uint256) public lastWaveAt;

  constructor() payable {
    console.log("We have been constructed!");
    // 初期シード設定
    seed = (block.timestamp + block.difficulty) % 100;
  }

  // _message（ユーザがフロントエンドから送信）という文字列を要求するようにwave関数を更新
  function wave(string memory _message) public {
    // 現在ユーザがwaveを送信している時刻と前回waveを送信した時刻が30sec以上離れていることを確認
    require(
      lastWaveAt[msg.sender] + 30 seconds < block.timestamp,
      "Wait 30sec"
    );

    // ユーザの現在のタイムスタンプを更新
    lastWaveAt[msg.sender] = block.timestamp;

    totalWaves += 1;
    console.log("%s has waved!", msg.sender);
  
    // waveとメッセージを配列に格納
    waves.push(Wave(msg.sender, _message, block.timestamp));

    // ユーザのために乱数を生成
    seed = (block.timestamp + block.difficulty + seed) % 100;
    console.log("Random # generated: %d", seed);

    // ユーザがETHを獲得する確率を50％に設定
    if (seed <= 50) {
      console.log("%s won!", msg.sender);
      
      // waveを送ってくれたユーザに0.0003ETHを送る
      uint256 prizeAmount = 0.0003 ether;
      require(
        prizeAmount <= address(this).balance,
        "Trying to withdraw more money than the contract has."
      );
      (bool success, ) = (msg.sender).call{value: prizeAmount}("");  // 送金
      require(success, "Failed to withdraw money from contract.");   // 送金成功の確認
    } else {
      console.log("%s did not win.", msg.sender);
    }

    // コントラクト側でemitされたイベントに関する通知をフロントエンドで取得できるようにする
    emit NewWave(msg.sender, block.timestamp, _message);
  }

  // 構造体配列のwavesを返してくれるgetAllWavesという関数を追加．
  function getAllWaves() public view returns (Wave[] memory) {
    return waves;
  }
  
  function getTotalWaves() public view returns (uint256) {
    // コンストラクタが出力する値をコンソール表示
    //console.log("We have %d total waves!", totalWaves);
    return totalWaves;
  }
}
