import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import {
  GratefulProfile,
  ProfilesModule,
  VaultsModule,
  FundsModule,
  AaveV2Vault,
  BalancesModule,
  ConfigModule,
  SubscriptionsModule,
  FeesModule,
  GratefulSubscription,
  LiquidationsModule,
  MainCoreModule,
  Proxy,
} from "../../typechain-types";
import { BigNumber } from "ethers";
import { setupUser } from "./utils/users";
import { deposit } from "./utils/deposit";
import { withdraw } from "./utils/withdraw";
import { subscribe } from "./utils/subscribe";
import { advanceTime } from "./utils/advanceTime";
import { unsubscribe } from "./utils/unsubscribe";
import { update } from "./utils/update";
import { advanceToLiquidationTime } from "./utils/advanceToLiquidationTime";
import { liquidate } from "./utils/liquidate";
import { advanceToNegativeBalance } from "./utils/advanceToNegativeBalance";
import { coreBootstrap } from "@synthetixio/router/dist/utils/tests";

type System = {
  proxyAddress: string;
  owner: SignerWithAddress;
  coreModule: MainCoreModule;
  vaultsModule: VaultsModule;
  profilesModule: ProfilesModule;
  fundsModule: FundsModule;
  balancesModule: BalancesModule;
  configModule: ConfigModule;
  subscriptionsModule: SubscriptionsModule;
  feesModule: FeesModule;
  liquidationsModule: LiquidationsModule;
  vault: AaveV2Vault;
  vaultId: string;
  treasuryId: string;
  gratefulProfile: GratefulProfile;
  gratefulSubscription: GratefulSubscription;
  giver: {
    signer: SignerWithAddress;
    address: string;
    tokenId: BigNumber;
    profileId: string;
  };
  creator: {
    signer: SignerWithAddress;
    address: string;
    tokenId: BigNumber;
    profileId: string;
  };
  SOLVENCY_TIME: BigNumber;
  LIQUIDATION_TIME: BigNumber;
  FEE_PERCENTAGE: BigNumber;
};

interface Contracts {
  CoreModule: MainCoreModule;
  VaultsModule: VaultsModule;
  ProfilesModule: ProfilesModule;
  FundsModule: FundsModule;
  BalancesModule: BalancesModule;
  ConfigModule: ConfigModule;
  SubscriptionsModule: SubscriptionsModule;
  FeesModule: FeesModule;
  LiquidationsModule: LiquidationsModule;
  GratefulProfile: GratefulProfile;
  GratefulSubscription: GratefulSubscription;
  AaveV2Vault: AaveV2Vault;
  Proxy: Proxy;
}

const { getContract } = coreBootstrap<Contracts>({
  cannonfile: "cannonfile.test.toml",
});

// We define a fixture to reuse the same setup in every test.
// We use loadFixture to run this setup once, snapshot that state,
// and reset Hardhat Network to that snapshot in every test.
const getModules = () => {
  const Proxy = getContract("Proxy");

  const proxyAddress = Proxy.address;

  const coreModule = getContract("CoreModule", proxyAddress);
  const vaultsModule = getContract("VaultsModule", proxyAddress);
  const profilesModule = getContract("ProfilesModule", proxyAddress);
  const fundsModule = getContract("FundsModule", proxyAddress);
  const balancesModule = getContract("BalancesModule", proxyAddress);
  const configModule = getContract("ConfigModule", proxyAddress);
  const subscriptionsModule = getContract("SubscriptionsModule", proxyAddress);
  const feesModule = getContract("FeesModule", proxyAddress);
  const liquidationsModule = getContract("LiquidationsModule", proxyAddress);
  const gratefulProfile = getContract("GratefulProfile");
  const gratefulSubscription = getContract("GratefulSubscription");
  const vault = getContract("AaveV2Vault");

  return {
    proxyAddress,
    coreModule,
    vaultsModule,
    profilesModule,
    fundsModule,
    balancesModule,
    configModule,
    subscriptionsModule,
    feesModule,
    liquidationsModule,
    gratefulProfile,
    gratefulSubscription,
    vault,
  };
};

const deploySystemFixture = async (): Promise<System> => {
  const [owner] = await ethers.getSigners();

  const modules = getModules();

  const { profilesModule, feesModule, gratefulProfile } = modules;

  // Create vault and add it to the system
  const vaultId = ethers.utils.formatBytes32String("AAVE_V2_DAI");

  // Setup config module
  const SOLVENCY_TIME = BigNumber.from(604800); // 1 week
  const LIQUIDATION_TIME = BigNumber.from(259200); // 3 days

  // Setup fees module
  const FEE_PERCENTAGE = BigNumber.from(4); // 4%
  const treasuryId = await feesModule.getFeeTreasuryId();

  // Setup users
  const [, giverSigner, creatorSigner] = await ethers.getSigners();
  const giver = await setupUser(giverSigner, gratefulProfile, profilesModule);
  const creator = await setupUser(
    creatorSigner,
    gratefulProfile,
    profilesModule
  );

  return {
    ...modules,
    vaultId,
    owner,
    gratefulProfile,
    giver,
    creator,
    LIQUIDATION_TIME,
    SOLVENCY_TIME,
    FEE_PERCENTAGE,
    treasuryId,
  };
};

const depositFixture = async () => {
  const fixture = await loadFixture(deploySystemFixture);
  return deposit(fixture);
};

const withdrawFixture = async () => {
  const fixture = await loadFixture(depositFixture);
  return withdraw(fixture);
};

const subscribeFixture = async () => {
  const fixture = await loadFixture(depositFixture);
  return subscribe(fixture);
};

const advanceTimeFixture = async () => {
  const fixture = await loadFixture(subscribeFixture);
  return advanceTime(fixture);
};

const unsubscribeFixture = async () => {
  const fixture = await loadFixture(advanceTimeFixture);
  return unsubscribe(fixture);
};

const updateFixture = async () => {
  const fixture = await loadFixture(unsubscribeFixture);
  return update(fixture);
};

const advanceToLiquidationTimeFixture = async () => {
  const fixture = await loadFixture(subscribeFixture);
  return advanceToLiquidationTime(fixture);
};

const liquidateFixture = async () => {
  const fixture = await loadFixture(advanceToLiquidationTimeFixture);
  return liquidate(fixture);
};

const advanceToNegativeBalanceFixture = async () => {
  const fixture = await loadFixture(subscribeFixture);
  return advanceToNegativeBalance(fixture);
};

const liquidateSurplusFixture = async () => {
  const fixture = await loadFixture(advanceToNegativeBalanceFixture);
  return liquidate(fixture);
};

export {
  System,
  deploySystemFixture,
  depositFixture,
  withdrawFixture,
  subscribeFixture,
  advanceTimeFixture,
  unsubscribeFixture,
  updateFixture,
  advanceToLiquidationTimeFixture,
  liquidateFixture,
  advanceToNegativeBalanceFixture,
  liquidateSurplusFixture,
};
