import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  GratefulProfile__factory,
  OwnerModule,
  ProfilesModule,
  VaultsModule,
} from "../typechain-types";
import { AaveV2Vault__factory } from "../typechain-types/factories/contracts/vaults";

const { deploySystem } = require("@synthetixio/hardhat-router/utils/tests");
const {
  getProxyAddress,
} = require("@synthetixio/hardhat-router/utils/deployments");

// We define a fixture to reuse the same setup in every test.
// We use loadFixture to run this setup once, snapshot that state,
// and reset Hardhat Network to that snapshot in every test.
const deploySystemFixture = async () => {
  const deploymentInfo = {
    network: "hardhat",
    instance: "test",
  };

  await deploySystem(deploymentInfo, { clear: true });

  const proxyAddress = getProxyAddress(deploymentInfo);

  const ownerModule = (await ethers.getContractAt(
    "contracts/modules/OwnerModule.sol:OwnerModule",
    proxyAddress
  )) as OwnerModule;

  const vaultsModule = (await ethers.getContractAt(
    "VaultsModule",
    proxyAddress
  )) as VaultsModule;

  const profileModule = (await ethers.getContractAt(
    "ProfilesModule",
    proxyAddress
  )) as ProfilesModule;

  return { proxyAddress, ownerModule, vaultsModule, profileModule };
};

const initializeOwnerModule = async (
  ownerModule: OwnerModule,
  owner: SignerWithAddress
) => {
  // Initialize Owner Module
  const tx = await ownerModule
    .connect(owner)
    .initializeOwnerModule(owner.address);

  await tx.wait();
};

const addAaveV2DAIMumbaiVault = async (vaultsModule: VaultsModule) => {
  const DAI_MUMBAI_ADDRESS = "0x001B3B4d0F3714Ca98ba10F6042DaEbF0B1B7b6F";
  const aDAI_MUMBAI_ADDRESS = "0x639cB7b21ee2161DF9c882483C9D55c90c20Ca3e";
  const AAVE_V2_POOL_MUMBAI_ADDRESS =
    "0x9198F13B08E299d85E096929fA9781A1E3d5d827";
  const AAVE_V2_INCENTIVES_MUMBAI_ADDRESS =
    "0xd41aE58e803Edf4304334acCE4DC4Ec34a63C644";
  //   const DAI_WHALE_MUMBAI_ADDRESS = "0xda8ab4137fe28f969b27c780d313d1bb62c8341e";

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

  await vaultsModule.addVault(vaultId, vault.address);

  return { vaultId, vault };
};

const addGratefulProfile = async (profileModule: ProfilesModule) => {
  const gratefulProfileFactory = (await ethers.getContractFactory(
    "GratefulProfile"
  )) as GratefulProfile__factory;

  const gratefulProfile = await gratefulProfileFactory.deploy();

  await profileModule.allowProfile(gratefulProfile.address);

  return { gratefulProfile };
};

const deploySystemWithOwner = async () => {
  // Contracts are deployed using the first signer/account by default
  const [owner] = await ethers.getSigners();

  const { ownerModule, ...modules } = await deploySystemFixture();

  await initializeOwnerModule(ownerModule, owner);

  return { ownerModule, owner, ...modules };
};

const deployCompleteSystem = async () => {
  const modules = await deploySystemWithOwner();

  const { vaultsModule, profileModule } = modules;

  const vault = await addAaveV2DAIMumbaiVault(vaultsModule);

  const profile = await addGratefulProfile(profileModule);

  return { ...modules, ...vault, ...profile };
};

export {
  deployCompleteSystem,
  deploySystemFixture,
  deploySystemWithOwner,
  addAaveV2DAIMumbaiVault,
};
