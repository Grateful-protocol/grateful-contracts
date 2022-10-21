# <h1 align="center"> Synthetix Router Proxy Template | Hardhat + Foundry </h1>

![Github Actions](https://github.com/agusduha/router-proxy-template/workflows/test/badge.svg)

This project demonstrates a basic use case (Lock), using [Synthetix Router Proxy](https://sips.synthetix.io/sips/sip-307/) architecture. It comes with sample contracts representing modules, storages and interfaces. Also a Hardhat test for the whole system contracts, a Foundry test for an individual module, and a script that deploys the system.

Using:

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

- Use cannon

```bash
npx @usecannon/cli build
npx hardhat cannon:build
npx hardhat cannon:deploy --network hardhat
```

### Notes

Whenever you install new libraries using Foundry, make sure to update your `remappings.txt` file by running `forge remappings > remappings.txt`. This is required because we use `hardhat-preprocessor` and the `remappings.txt` file to allow Hardhat to resolve libraries you install with Foundry.
