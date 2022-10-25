# <h1 align="center"> Grateful protocol v2</h1>

![Github Actions](https://github.com/Grateful-protocol/grateful-v2/workflows/test/badge.svg)

Using:

- [Synthetix Router Proxy](https://sips.synthetix.io/sips/sip-307/) architecture
- [Hardhat Toolbox](https://hardhat.org/hardhat-runner/plugins/nomicfoundation-hardhat-toolbox)
- Any NPM dependencies (like OpenZeppelin contracts)
- Any Foundry libs (like solmate contracts)
- [Hardhat Cannon](https://usecannon.com/docs)

### Getting Started

- Use Foundry:

```bash
forge install
forge test
```

- Use Hardhat:

```bash
npm install
npx hardhat test --network hardhat
REPORT_GAS=true npx hardhat test --network hardhat
```

- Use both:

```bash
npm test
```

- Use cannon:

```bash
npx @usecannon/cli build
npx hardhat cannon:build
npx hardhat cannon:deploy --network hardhat
```

### Notes

Whenever you install new libraries using Foundry, make sure to update your `remappings.txt` file by running `forge remappings > remappings.txt`. This is required because we use `hardhat-preprocessor` and the `remappings.txt` file to allow Hardhat to resolve libraries you install with Foundry.
