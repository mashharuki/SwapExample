import { SwapWidget } from '@uniswap/widgets';
import React, { useEffect, useState } from "react";
import { providers, ethers } from 'ethers';
import './App.css';
import '@uniswap/widgets/fonts.css'
import detectEthereumProvider from "@metamask/detect-provider";

function App() {

  // Infura endpoint
  const jsonRpcEndpoint = process.env.REACT_APP_API_ENDPOINT;
  const jsonRpcProvider = new providers.JsonRpcProvider(jsonRpcEndpoint);
  // create provider
  const provider = new ethers.providers.Web3Provider(jsonRpcProvider);
  // ステート変数
  const [account, setAccount] = useState({
    address: '',
    provider: provider,
  })

  async function connectWallet() {
    const ethereumProvider = await detectEthereumProvider();

    if (ethereumProvider) {
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      })

      const address = accounts[0];
      setAccount({
        address: address,
        provider: ethereumProvider
      })
    }
  }

  return (
    <div className="App">
      <div>
        <button onClick={connectWallet}>
          Connect Wallet
        </button>
      </div>
      <div className="Uniswap">
        <SwapWidget
              provider={account.provider}
              jsonRpcEndpoint={jsonRpcEndpoint}
        />
      </div>
    </div>
  );
}

export default App;
