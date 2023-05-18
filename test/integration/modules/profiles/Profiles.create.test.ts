import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { deploySystemFixture } from "../../../fixtures/fixtures";
import { ethers } from "hardhat";

const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");

describe("Profiles - Profile creation", () => {
  const createProfileFixture = async () => {
    const fixture = await loadFixture(deploySystemFixture);

    const { profilesModule, gratefulProfile, giver } = fixture;

    const SALT = ethers.utils.formatBytes32String("ANOTHER SALT");

    const tokenId = (await gratefulProfile.totalSupply()).add(1);

    const tx = await profilesModule
      .connect(giver.signer)
      .createProfile(giver.address, SALT);

    return { ...fixture, tx, tokenId, SALT };
  };

  it("Should emit a ProfileCreated event", async () => {
    const { profilesModule, gratefulProfile, giver, tx, tokenId, SALT } =
      await loadFixture(createProfileFixture);

    await expect(tx)
      .to.emit(profilesModule, "ProfileCreated")
      .withArgs(
        giver.address,
        gratefulProfile.address,
        tokenId,
        anyValue,
        SALT
      );
  });

  it("Should emit a Mint event", async () => {
    const { gratefulProfile, giver, tx, tokenId } = await loadFixture(
      createProfileFixture
    );

    await expect(tx)
      .to.emit(gratefulProfile, "Transfer")
      .withArgs(ethers.constants.AddressZero, giver.address, tokenId);
  });

  it("Should record the owner in the profile system", async () => {
    const { gratefulProfile, giver, tokenId } = await loadFixture(
      createProfileFixture
    );

    const owner = await gratefulProfile.ownerOf(tokenId);
    const balance = await gratefulProfile.balanceOf(giver.address);

    expect(owner).to.be.equal(giver.address);
    expect(balance).to.be.equal(2);
  });

  it("Should record the owner in the core system", async () => {
    const { profilesModule, giver, tokenId, gratefulProfile } =
      await loadFixture(createProfileFixture);

    const profileId = await profilesModule.getProfileId(
      gratefulProfile.address,
      tokenId
    );

    const owner = await profilesModule.getProfileOwner(profileId);

    expect(owner).to.be.equal(giver.address);
  });

  it("Should returnt that the profile exists", async () => {
    const { profilesModule, tokenId, gratefulProfile } = await loadFixture(
      createProfileFixture
    );

    const profileId = await profilesModule.getProfileId(
      gratefulProfile.address,
      tokenId
    );

    expect(await profilesModule.exists(profileId)).to.be.true;
  });

  describe("when a user tries to create a profile with a profileId that already exists", () => {
    it("reverts", async () => {
      const { profilesModule, giver, SALT } = await loadFixture(
        createProfileFixture
      );

      const tx = profilesModule
        .connect(giver.signer)
        .createProfile(giver.address, SALT);

      await expect(tx).to.be.revertedWithCustomError(
        profilesModule,
        "ProfileAlreadyCreated"
      );
    });
  });
});
