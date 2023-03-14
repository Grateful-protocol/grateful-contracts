import { ethers } from "hardhat";
import { System } from "../fixtures";

const withdraw = async (fixture: System) => {
  // Load initial fixture
  const { vault, vaultId, fundsModule, giver, balancesModule } = fixture;

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
    .withdrawFunds(giver.profileId, vaultId, WITHDRAW_SHARES);

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

export { withdraw };
