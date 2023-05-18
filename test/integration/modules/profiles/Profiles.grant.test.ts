import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { deploySystemFixture } from "../../../fixtures/fixtures";
import { ethers } from "hardhat";

describe("Profiles - Granting, revoking, and renouncing permissions", () => {
  const adminPermission = ethers.utils.formatBytes32String("ADMIN");
  const withdrawPermission = ethers.utils.formatBytes32String("WITHDRAW");
  const subscribePermission = ethers.utils.formatBytes32String("SUBSCRIBE");
  const unsubscribePermission = ethers.utils.formatBytes32String("UNSUBSCRIBE");
  const editPermission = ethers.utils.formatBytes32String("EDIT");

  describe("before permissions have been granted", function () {
    it("shows that certain permissions have not been granted", async () => {
      const { profilesModule, giver, creator } = await loadFixture(
        deploySystemFixture
      );

      expect(
        await profilesModule.hasPermission(
          giver.profileId,
          withdrawPermission,
          creator.address
        )
      ).to.be.false;

      expect(
        await profilesModule.hasPermission(
          giver.profileId,
          adminPermission,
          creator.address
        )
      ).to.be.false;
    });

    it("shows that the owner is authorized", async () => {
      const { profilesModule, giver } = await loadFixture(deploySystemFixture);

      expect(
        await profilesModule.isAuthorized(
          giver.profileId,
          adminPermission,
          giver.address
        )
      ).to.be.true;
    });

    it("shows that the other user not authorized", async () => {
      const { profilesModule, giver, creator } = await loadFixture(
        deploySystemFixture
      );

      expect(
        await profilesModule.isAuthorized(
          giver.profileId,
          adminPermission,
          creator.address
        )
      ).to.be.false;

      expect(
        await profilesModule.isAuthorized(
          giver.profileId,
          withdrawPermission,
          creator.address
        )
      ).to.be.false;
    });
  });

  describe("when a non-authorized user attempts to grant permissions", async () => {
    it("reverts", async () => {
      const { profilesModule, giver, creator } = await loadFixture(
        deploySystemFixture
      );

      const tx = profilesModule
        .connect(creator.signer)
        .grantPermission(giver.profileId, withdrawPermission, creator.address);

      await expect(tx).to.be.revertedWithCustomError(
        profilesModule,
        "PermissionDenied"
      );
    });
  });

  describe("when a an authorized user attempts to grant an invalid permission", async () => {
    it("reverts", async () => {
      const { profilesModule, giver, creator } = await loadFixture(
        deploySystemFixture
      );

      const invalidPermission = ethers.utils.formatBytes32String("INVALID");

      const tx = profilesModule
        .connect(giver.signer)
        .grantPermission(giver.profileId, invalidPermission, creator.address);

      await expect(tx).to.be.revertedWithCustomError(
        profilesModule,
        "InvalidPermission"
      );
    });

    it("reverts", async () => {
      const { profilesModule, giver, creator } = await loadFixture(
        deploySystemFixture
      );

      const invalidPermission = ethers.utils.formatBytes32String("");

      const tx = profilesModule
        .connect(giver.signer)
        .grantPermission(giver.profileId, invalidPermission, creator.address);

      await expect(tx).to.be.revertedWithCustomError(
        profilesModule,
        "InvalidPermission"
      );
    });
  });

  describe("when a permission is granted with bad inputs", async () => {
    it("reverts", async () => {
      const { profilesModule, giver, creator } = await loadFixture(
        deploySystemFixture
      );

      const tx = profilesModule
        .connect(giver.signer)
        .grantPermission(
          giver.profileId,
          withdrawPermission,
          ethers.constants.AddressZero
        );

      await expect(tx).to.be.revertedWithCustomError(
        profilesModule,
        "ZeroAddress"
      );
    });
  });

  describe("when a permission is granted by the owner", () => {
    const grantPermissionFixture = async () => {
      const fixture = await loadFixture(deploySystemFixture);

      const { profilesModule, giver, creator } = fixture;

      const tx = await profilesModule
        .connect(giver.signer)
        .grantPermission(giver.profileId, withdrawPermission, creator.address);

      return { ...fixture, tx };
    };

    it("shows that the permission is granted", async () => {
      const { profilesModule, giver, creator } = await loadFixture(
        grantPermissionFixture
      );

      expect(
        await profilesModule.hasPermission(
          giver.profileId,
          withdrawPermission,
          creator.address
        )
      ).to.be.true;

      expect(
        await profilesModule.isAuthorized(
          giver.profileId,
          withdrawPermission,
          creator.address
        )
      ).to.be.true;
    });

    it("shows that the profile permissions are returned", async () => {
      const { profilesModule, giver, creator } = await loadFixture(
        grantPermissionFixture
      );

      const profilePermissions = await profilesModule.getProfilePermissions(
        giver.profileId
      );

      const { user, permissions } = profilePermissions[0];

      expect(user).to.equal(creator.address);
      expect(permissions[0]).to.equal(withdrawPermission);
    });

    it("emits a PermissionGranted event", async function () {
      const { profilesModule, giver, creator, tx } = await loadFixture(
        grantPermissionFixture
      );

      await expect(tx)
        .to.emit(profilesModule, "PermissionGranted")
        .withArgs(
          giver.profileId,
          withdrawPermission,
          creator.address,
          giver.address
        );
    });

    describe("when attempting to renounce a permission that was not granted", async () => {
      it("reverts", async () => {
        const { profilesModule, giver, creator } = await loadFixture(
          grantPermissionFixture
        );

        const tx = profilesModule
          .connect(creator.signer)
          .renouncePermission(giver.profileId, adminPermission);

        await expect(tx).to.be.revertedWithCustomError(
          profilesModule,
          "PermissionNotGranted"
        );
      });

      describe("when a permission is renounced", function () {
        const renouncePermissionFixture = async () => {
          const fixture = await loadFixture(grantPermissionFixture);

          const { profilesModule, giver, creator } = fixture;

          const tx = await profilesModule
            .connect(creator.signer)
            .renouncePermission(giver.profileId, withdrawPermission);

          return { ...fixture, tx };
        };

        it("shows that the permission was renounced", async () => {
          const { profilesModule, giver, creator } = await loadFixture(
            renouncePermissionFixture
          );

          expect(
            await profilesModule.hasPermission(
              giver.profileId,
              withdrawPermission,
              creator.address
            )
          ).to.be.false;
        });

        it("emits a PermissionRevoked event", async () => {
          const { profilesModule, giver, creator, tx } = await loadFixture(
            renouncePermissionFixture
          );

          await expect(tx)
            .to.emit(profilesModule, "PermissionRevoked")
            .withArgs(
              giver.profileId,
              withdrawPermission,
              creator.address,
              creator.address
            );
        });
      });

      describe("when a permission is revoked", function () {
        const revokePermissionFixture = async () => {
          const fixture = await loadFixture(grantPermissionFixture);

          const { profilesModule, giver, creator } = fixture;

          const tx = await profilesModule
            .connect(giver.signer)
            .revokePermission(
              giver.profileId,
              withdrawPermission,
              creator.address
            );

          return { ...fixture, tx };
        };

        it("shows that the permission was revoked", async () => {
          const { profilesModule, giver, creator } = await loadFixture(
            revokePermissionFixture
          );

          expect(
            await profilesModule.hasPermission(
              giver.profileId,
              withdrawPermission,
              creator.address
            )
          ).to.be.false;
        });

        it("emits a PermissionRevoked event", async () => {
          const { profilesModule, giver, creator, tx } = await loadFixture(
            revokePermissionFixture
          );

          await expect(tx)
            .to.emit(profilesModule, "PermissionRevoked")
            .withArgs(
              giver.profileId,
              withdrawPermission,
              creator.address,
              giver.address
            );
        });
      });
    });
  });

  describe("when an Admin permission is granted by the owner", function () {
    const adminPermissionFixture = async () => {
      const fixture = await loadFixture(deploySystemFixture);

      const { profilesModule, giver, creator } = fixture;

      const tx = await profilesModule
        .connect(giver.signer)
        .grantPermission(giver.profileId, adminPermission, creator.address);

      return { ...fixture, tx };
    };

    it("shows that the admin permission is granted by the owner", async function () {
      const { profilesModule, giver, creator } = await loadFixture(
        adminPermissionFixture
      );

      expect(
        await profilesModule.hasPermission(
          giver.profileId,
          adminPermission,
          creator.address
        )
      ).to.be.true;
    });

    it("shows that the admin is authorized to all permissions", async function () {
      const { profilesModule, giver, creator } = await loadFixture(
        adminPermissionFixture
      );

      expect(
        await profilesModule.isAuthorized(
          giver.profileId,
          adminPermission,
          creator.address
        )
      ).to.be.true;

      expect(
        await profilesModule.isAuthorized(
          giver.profileId,
          withdrawPermission,
          creator.address
        )
      ).to.be.true;

      expect(
        await profilesModule.isAuthorized(
          giver.profileId,
          subscribePermission,
          creator.address
        )
      ).to.be.true;

      expect(
        await profilesModule.isAuthorized(
          giver.profileId,
          unsubscribePermission,
          creator.address
        )
      ).to.be.true;

      expect(
        await profilesModule.isAuthorized(
          giver.profileId,
          editPermission,
          creator.address
        )
      ).to.be.true;
    });

    describe("admin is able to grant permission", async () => {
      const adminGrantPermissionFixture = async () => {
        const fixture = await loadFixture(adminPermissionFixture);

        const { profilesModule, giver, creator, owner } = fixture;

        const tx = await profilesModule
          .connect(creator.signer)
          .grantPermission(giver.profileId, withdrawPermission, owner.address);

        return { ...fixture, tx };
      };

      it("shows that the permission is granted", async function () {
        const { profilesModule, giver, creator, owner } = await loadFixture(
          adminGrantPermissionFixture
        );

        expect(
          await profilesModule.hasPermission(
            giver.profileId,
            withdrawPermission,
            owner.address
          )
        ).to.be.true;
      });
    });

    describe("admin is able to revoke a permission", async () => {
      it("shows that the admin can revoke the permission", async function () {
        const { profilesModule, giver, creator, owner } = await loadFixture(
          adminPermissionFixture
        );

        await profilesModule
          .connect(giver.signer)
          .grantPermission(giver.profileId, adminPermission, owner.address);

        await profilesModule
          .connect(creator.signer)
          .revokePermission(giver.profileId, adminPermission, owner.address);

        expect(
          await profilesModule.hasPermission(
            giver.profileId,
            adminPermission,
            owner.address
          )
        ).to.be.false;
      });
    });

    describe("admin is able to grant and revoke the same permission", async () => {
      it("shows that the admin can revoke the permission to itself", async function () {
        const { profilesModule, giver, creator } = await loadFixture(
          adminPermissionFixture
        );

        await profilesModule
          .connect(creator.signer)
          .grantPermission(
            giver.profileId,
            withdrawPermission,
            creator.address
          );

        expect(
          await profilesModule.hasPermission(
            giver.profileId,
            withdrawPermission,
            creator.address
          )
        ).to.be.true;

        await profilesModule
          .connect(creator.signer)
          .revokePermission(
            giver.profileId,
            withdrawPermission,
            creator.address
          );

        expect(
          await profilesModule.hasPermission(
            giver.profileId,
            withdrawPermission,
            creator.address
          )
        ).to.be.false;
      });
    });
  });
});
