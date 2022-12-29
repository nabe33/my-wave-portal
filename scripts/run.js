// run.js
const main = async () => {
  const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");
  // 0.1ETHをコントラクトに提供してデプロイ
  const waveContract = await waveContractFactory.deploy({
    value: hre.ethers.utils.parseEther("0.1"),
  });
  await waveContract.deployed();
  console.log("Contract deployed to:", waveContract.address);

  // コントラクトの残高を取得し，結果を取得（0.1ETHであることを確認）
  let contractBalance = await hre.ethers.provider.getBalance(
    waveContract.address
  );
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  /*
  let waveCount;
  waveCount = await waveContract.getTotalWaves();
  console.log(waveCount.toNumber());
*/

  // 2回waveを送ってトランザクションが完了するまで待機
  let waveTxn = await waveContract.wave("This is wave #1");
  await waveTxn.wait(); // トランザクションが承認されるのを待つ
/*
  let waveTxn2 = await waveContract.wave("This is wave #2");
  await waveTxn2.wait(); // トランザクションが承認されるのを待つ
*/
  // waveした後のコントラクトの残高を取得し，結果を出力
  contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  let allWaves = await waveContract.getAllWaves();
  console.log(allWaves);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch(error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();