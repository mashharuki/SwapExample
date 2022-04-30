import { SwapWidget } from '@uniswap/widgets';
import React, { useEffect, useState } from "react";
import './App.css';
import '@uniswap/widgets/fonts.css'
import detectEthereumProvider from "@metamask/detect-provider";

// Infura endpoint
const jsonRpcEndpoint = process.env.REACT_APP_API_ENDPOINT;

function App() {
  return (
    <div className="Uniswap">
      <SwapWidget
            provider={detectEthereumProvider}
            jsonRpcEndpoint={jsonRpcEndpoint}
      />
    </div>
  );
}

export default App;
