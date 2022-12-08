// imports
// main functions
// calling main functions

const { network } = require("hardhat")
const { networkConfig, developmentChains } = require("../helper-hardhat-config")

// module.exports.default = deployFunc()

// module.exports = async (hre) => {
//     const { getNamedAccounts, deployments } = hre
//SAME AS:
// const helperConfig = require("../helper-hardhat-config")
// const networkConfig = helperConfig.networkConfig

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    // If chainId x use y address

    // const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    let ethUsdPriceFeedAddress
    if (chainId == 31337) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    // When going for localhost or hardhat network we want to use a mock
    const fundMe = await deploy("FundMe", {
        _from: deployer,
        args: [ethUsdPriceFeedAddress], //Put price feed address
        log: true
    })
    log(
        "------------------------------------------------------------------------"
    )
}

module.exports.tags = ["all", "fund me"]
