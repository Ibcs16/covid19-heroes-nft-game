// script to run when testing
const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["AstraZenica", "Pfizer", "Instituto Butatã", "Jhonson&Jhonson"],
    [
      "https://www.cnnbrasil.com.br/wp-content/uploads/sites/12/2021/06/19383_47D6E4060257885D-12.jpg?w=864&h=484&crop=1",
      "https://exame.com/wp-content/uploads/2021/06/2020-11-10T110335Z_1655816223_RC2B0K9NTFBZ_RTRMADP_3_HEALTH-CORONAVIRUS-VACCINES-PFIZER-ASIA.jpg?quality=70&strip=info&w=1024",
      "https://exame.com/wp-content/uploads/2021/08/FTZ1069-1.jpg",
      "https://imagens.ebc.com.br/EW6kPpcz1WYkGELLbUvgOW6gdMg=/1170x700/smart/https://agenciabrasil.ebc.com.br/sites/default/files/thumbnails/image/2021-02-19t141503z_1_lynxmpeh1i0x2_rtroptp_4_saude-covid-jandj-registroeua.jpg?itok=s52FZ8dT",
    ],
    [100000000, 200000000, 150000000, 120000000],
    ["2020-08-10", "2020-10-20", "2021-01-03", "2021-03-04"],
    [100000, 200000, 300000, 400000],
    "Bolsonaro", //boss name
    "https://catracalivre.com.br/wp-content/uploads/2021/10/bolsonaro-veta-distribuicao-absorventes-porque-jorrar-sangue-suave.jpg", //boss image
    "Brazil", //boss country
    10000 // boss attack
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn;
  txn = await gameContract.mintVaccineLab(0, "2021-10-24");
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

runMain();
