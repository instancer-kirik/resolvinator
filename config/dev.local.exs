import Config

# Local Ganache configuration
config :resolvinator, Resolvinator.Web3,
  ethereum_rpc: "http://localhost:8545",
  chain_id: "1337",
  contract_addresses: %{
    token: nil,  # Add your token contract address after deployment
    nft: nil     # Add your NFT contract address after deployment
  }

config :resolvinator, Resolvinator.Rewards.CryptoReward,
  use_testnet: true,
  testnet_config: %{
    ethereum: "http://localhost:8545",
    polygon: "http://localhost:8545",  # If you want to use Ganache for all chains
    solana: "http://localhost:8545"
  }
