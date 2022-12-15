import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import {
  GratefulProfile,
  GratefulProfile__factory,
  OwnerModule,
  ProfilesModule,
  VaultsModule,
  AaveV2Vault__factory,
  FundsModule,
  AaveV2Vault,
  BalancesModule,
} from "../typechain-types";
import { BigNumber } from "ethers";

const hre = require("hardhat");
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

  const fundsModule = (await ethers.getContractAt(
    "FundsModule",
    proxyAddress
  )) as FundsModule;

  const balancesModule = (await ethers.getContractAt(
    "BalancesModule",
    proxyAddress
  )) as BalancesModule;

  return {
    proxyAddress,
    ownerModule,
    vaultsModule,
    profileModule,
    fundsModule,
    balancesModule,
  };
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

const setupUser = async (
  user: SignerWithAddress,
  gratefulProfile: GratefulProfile,
  profileModule: ProfilesModule
) => {
  await mintDAIMumbaiTokens(user);

  const tokenId = await gratefulProfile.totalSupply();
  await gratefulProfile.safeMint(user.address);

  const profileId = await profileModule.getProfileId(
    gratefulProfile.address,
    tokenId
  );

  return { signer: user, address: user.address, tokenId, profileId };
};

const deploySystemWithOwner = async () => {
  // Contracts are deployed using the first signer/account by default
  const [owner] = await ethers.getSigners();

  const { ownerModule, ...modules } = await deploySystemFixture();

  await initializeOwnerModule(ownerModule, owner);

  return { ownerModule, owner, ...modules };
};

type System = {
  proxyAddress: string;
  owner: SignerWithAddress;
  ownerModule: OwnerModule;
  vaultsModule: VaultsModule;
  profileModule: ProfilesModule;
  fundsModule: FundsModule;
  balancesModule: BalancesModule;
  vault: AaveV2Vault;
  vaultId: string;
  gratefulProfile: GratefulProfile;
  giver: {
    signer: SignerWithAddress;
    address: string;
    tokenId: BigNumber;
    profileId: string;
  };
};

const deployCompleteSystem = async (): Promise<System> => {
  const modules = await deploySystemWithOwner();

  const { vaultsModule, profileModule } = modules;

  const vault = await addAaveV2DAIMumbaiVault(vaultsModule);

  const profile = await addGratefulProfile(profileModule);

  // Setup users
  const { gratefulProfile } = profile;
  const [, giverSigner] = await ethers.getSigners();
  const giver = await setupUser(giverSigner, gratefulProfile, profileModule);

  return { ...modules, ...vault, ...profile, giver };
};

const deposit = async (fixture: System) => {
  // Load initial fixture
  const { vault, vaultId, fundsModule, giver, gratefulProfile } = fixture;

  // Set token data
  const tokenAddress = await vault.asset();
  const token = await ethers.getContractAt("ERC20", tokenAddress);
  const decimals = await token.decimals();
  const DEPOSIT_AMOUNT = ethers.utils.parseUnits("10", decimals);

  // User token balance before depositing
  const balanceBefore = await token.balanceOf(giver.address);

  // Approve token to grateful contract
  await token
    .connect(giver.signer)
    .approve(fundsModule.address, DEPOSIT_AMOUNT);

  // Expected shares to be minted before depositing
  const DECIMALS_DIVISOR = 10 ** (20 - decimals);
  const previewDeposit = await vault.previewDeposit(DEPOSIT_AMOUNT);
  const expectedShares = previewDeposit.mul(DECIMALS_DIVISOR);

  // User deposit tx
  const tx = await fundsModule
    .connect(giver.signer)
    .depositFunds(
      gratefulProfile.address,
      giver.tokenId,
      vaultId,
      DEPOSIT_AMOUNT
    );

  await tx.wait();

  return {
    ...fixture,
    token,
    DEPOSIT_AMOUNT,
    balanceBefore,
    expectedShares,
    tx,
  };
};

const depositFixture = async () => {
  const fixture = await loadFixture(deployCompleteSystem);
  return deposit(fixture);
};

const withdraw = async (fixture: System) => {
  // Load initial fixture
  const {
    vault,
    vaultId,
    fundsModule,
    giver,
    gratefulProfile,
    balancesModule,
  } = fixture;

  // Set token data
  const tokenAddress = await vault.asset();
  const token = await ethers.getContractAt("ERC20", tokenAddress);
  const decimals = await token.decimals();
  const WITHDRAW_AMOUNT = ethers.utils.parseUnits("1", decimals);
  const DECIMALS_DIVISOR = 10 ** (20 - decimals);
  const WITHDRAW_SHARES = WITHDRAW_AMOUNT.mul(DECIMALS_DIVISOR);

  // User balance before withdrawing
  const tokenBalanceBefore = await token.balanceOf(giver.address);
  const gratefulBalanceBefore = await balancesModule.balanceOf(
    giver.profileId,
    vaultId
  );

  // Expected amount to be withdrawn before withdrawing
  const expectedWithdrawal = await vault.previewRedeem(WITHDRAW_AMOUNT);

  // User withdraw tx
  const tx = await fundsModule
    .connect(giver.signer)
    .withdrawFunds(
      gratefulProfile.address,
      giver.tokenId,
      vaultId,
      WITHDRAW_SHARES
    );

  await tx.wait();

  return {
    ...fixture,
    token,
    WITHDRAW_SHARES,
    tokenBalanceBefore,
    gratefulBalanceBefore,
    expectedWithdrawal,
    tx,
  };
};

const withdrawFixture = async () => {
  const fixture = await loadFixture(depositFixture);
  return withdraw(fixture);
};

export {
  deployCompleteSystem,
  deploySystemFixture,
  deploySystemWithOwner,
  addAaveV2DAIMumbaiVault,
  System,
  depositFixture,
  withdrawFixture,
};
