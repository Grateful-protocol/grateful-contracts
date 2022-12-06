import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { VaultsModule, AaveV2Vault__factory } from "../../../typechain-types";

const hre = require("hardhat");

const addAaveV2DAIMumbaiVault = async (vaultsModule: VaultsModule) => {
  const DAI_MUMBAI_ADDRESS = "0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F";
  const aDAI_MUMBAI_ADDRESS = "0x639cB7b21ee2161DF9c882483C9D55c90c20Ca3e";
  const AAVE_V2_POOL_MUMBAI_ADDRESS =
    "0x9198F13B08E299d85E096929fA9781A1E3d5d827";
  const AAVE_V2_INCENTIVES_MUMBAI_ADDRESS =
    "0xd41aE58e803Edf4304334acCE4DC4Ec34a63C644";

  const aaveV2VaultFactory = (await ethers.getContractFactory(
    "AaveV2Vault"
  )) as AaveV2Vault__factory;

  const [deployer] = await ethers.getSigners();

  const vault = await aaveV2VaultFactory.deploy(
    DAI_MUMBAI_ADDRESS,
    aDAI_MUMBAI_ADDRESS,
    AAVE_V2_INCENTIVES_MUMBAI_ADDRESS,
    deployer.address,
    AAVE_V2_POOL_MUMBAI_ADDRESS
  );

  await vault.transferOwnership(vaultsModule.address);

  const vaultId = ethers.utils.formatBytes32String("AAVE_V2_DAI");

  const minRate = 38580246913580; // 1e20 per month
  const maxRate = 3858024691358024; // 100e20 per month

  await vaultsModule.addVault(vaultId, vault.address, minRate, maxRate);

  return { vaultId, vault };
};

const mintTokens = async (
  tokenAddress: string,
  whaleAddress: string,
  user: SignerWithAddress
) => {
  const token = await ethers.getContractAt("ERC20", tokenAddress);

  const decimals = await token.decimals();
  const INITIAL_BALANCE = ethers.utils.parseUnits("1000", decimals);

  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [whaleAddress],
  });

  const whaleSigner = await ethers.getSigner(whaleAddress);

  await token.connect(whaleSigner).transfer(user.address, INITIAL_BALANCE);

  await hre.network.provider.request({
    method: "hardhat_stopImpersonatingAccount",
    params: [whaleAddress],
  });
};

const mintDAIMumbaiTokens = async (user: SignerWithAddress) => {
  const DAI_MUMBAI_ADDRESS = "0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F";
  const DAI_MUMBAI_WHALE_ADDRESS = "0xda8ab4137fe28f969b27c780d313d1bb62c8341e";

  await mintTokens(DAI_MUMBAI_ADDRESS, DAI_MUMBAI_WHALE_ADDRESS, user);
};

export { addAaveV2DAIMumbaiVault, mintDAIMumbaiTokens };
