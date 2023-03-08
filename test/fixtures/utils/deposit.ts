import { ethers } from "hardhat";
import { System } from "../fixtures";

const deposit = async (fixture: System) => {
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
  const DEPOSIT_AMOUNT = ethers.utils.parseUnits("10", decimals);

  // User token balance before depositing
  const balanceBefore = await token.balanceOf(giver.address);
  const gratefulBalanceBefore = await balancesModule.balanceOf(
    giver.profileId,
    vaultId
  );

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
    gratefulBalanceBefore,
    expectedShares,
    tx,
  };
};

export { deposit };
