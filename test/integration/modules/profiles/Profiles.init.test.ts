import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { deploySystemFixture } from "../../../fixtures/fixtures";

describe("Profiles - Initialization", () => {
  it("Should return the correct grateful profile address", async () => {
    const { profilesModule, gratefulProfile } = await loadFixture(
      deploySystemFixture
    );

    const gratefulProfileAddress =
      await profilesModule.getGratefulProfileAddress();

    expect(gratefulProfileAddress).to.be.equal(gratefulProfile.address);
  });

  it("Initializes the grateful profile correctly", async () => {
    const { gratefulProfile } = await loadFixture(deploySystemFixture);

    const name = await gratefulProfile.name();
    const symbol = await gratefulProfile.symbol();

    expect(name).to.be.equal("Grateful Protocol Profile");
    expect(symbol).to.be.equal("GPP");
  });
});
