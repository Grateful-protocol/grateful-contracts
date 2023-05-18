import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { deploySystemFixture } from "../../../fixtures/fixtures";
import { ethers } from "hardhat";

describe("Profiles - Profile transfering", () => {
  const withdrawPermission = ethers.utils.formatBytes32String("WITHDRAW");
  const subscribePermission = ethers.utils.formatBytes32String("SUBSCRIBE");
  const unsubscribePermission = ethers.utils.formatBytes32String("UNSUBSCRIBE");

  const transferProfileFixture = async () => {
    const fixture = await loadFixture(deploySystemFixture);

    const { profilesModule, gratefulProfile, giver, owner, creator } = fixture;

    // Grant some permissions
    await profilesModule
      .connect(giver.signer)
      .grantPermission(giver.profileId, withdrawPermission, giver.address);
    await profilesModule
      .connect(giver.signer)
      .grantPermission(giver.profileId, subscribePermission, owner.address);
    await profilesModule
      .connect(giver.signer)
      .grantPermission(giver.profileId, unsubscribePermission, owner.address);

    // Transfer profile
    await gratefulProfile
      .connect(giver.signer)
      .transferFrom(giver.address, creator.address, giver.tokenId);

    return fixture;
  };

  it("Should record the new owner in the profile system", async () => {
    const { gratefulProfile, giver, creator } = await loadFixture(
      transferProfileFixture
    );

    const owner = await gratefulProfile.ownerOf(giver.tokenId);
    expect(owner).to.be.equal(creator.address);

    const giverBalance = await gratefulProfile.balanceOf(giver.address);
    expect(giverBalance).to.be.equal(0);

    const creatorBalance = await gratefulProfile.balanceOf(creator.address);
    expect(creatorBalance).to.be.equal(2);
  });

  it("Should record the new owner in the core system", async () => {
    const { profilesModule, giver, creator } = await loadFixture(
      transferProfileFixture
    );

    const owner = await profilesModule.getProfileOwner(giver.profileId);
    expect(owner).to.be.equal(creator.address);
  });

  it("Should show the previous owner permissions have been revoked", async () => {
    const { profilesModule, giver, creator } = await loadFixture(
      transferProfileFixture
    );

    expect(
      await profilesModule.hasPermission(
        giver.profileId,
        withdrawPermission,
        giver.address
      )
    ).to.be.false;
  });

  it("Should show that other accounts permissions have been revoked", async () => {
    const { profilesModule, giver, owner } = await loadFixture(
      transferProfileFixture
    );

    expect(
      await profilesModule.hasPermission(
        giver.profileId,
        subscribePermission,
        owner.address
      )
    ).to.be.false;

    expect(
      await profilesModule.hasPermission(
        giver.profileId,
        unsubscribePermission,
        owner.address
      )
    ).to.be.false;
  });

  describe("when a user tries to call notifyProfileTransfer from outside the system", () => {
    it("reverts", async () => {
      const { profilesModule, giver, creator } = await loadFixture(
        transferProfileFixture
      );

      const tx = profilesModule
        .connect(creator.signer)
        .notifyProfileTransfer(creator.address, giver.tokenId);

      await expect(tx).to.be.revertedWithCustomError(
        profilesModule,
        "OnlyGratefulProfileProxy"
      );
    });
  });
});
