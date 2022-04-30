import { SwapWidget } from '@uniswap/widgets';
import React, { useEffect, useState } from "react";
import { providers, ethers } from 'ethers';
import './App.css';
import '@uniswap/widgets/fonts.css'
import detectEthereumProvider from "@metamask/detect-provider";
// material-ui関連をインポートする。
import AppBar  from '@mui/material/AppBar';
import Toolbar  from '@mui/material/Toolbar';
import Typography  from '@mui/material/Typography';
import AccountBalanceWalletIcon from '@mui/icons-material/AccountBalanceWallet';
import Button from '@mui/material/Button';
import { styled } from "@mui/material/styles";
import Box from "@mui/material/Box";
import Paper from "@mui/material/Paper";


// Swap用のテーマ
const theme = {
  primary: '#001D82',
  secondary: '#6677C1',
  interactive: '#005BAE',
  container: '#ABD6FE',
  module: '#FFF7FB',
  accent: '#FF7BC2',
  outline: '#ABD6FE',
  dialog: '#FFF',
  fontFamily: 'Arvo',
  borderRadius: 1,
}

// StyledPaperコンポーネント
const StyledPaper = styled(Paper)(({ theme }) => ({
  ...theme.typography.body2,
  padding: theme.spacing(2),
  maxWidth: 360
}));

/**
 * Appコンポーネント
 */
const App = () => {
  // RPCのエンドポイントを設定する。
  const jsonRpcEndpoint = process.env.REACT_APP_API_ENDPOINT;
  const jsonRpcProvider = new providers.JsonRpcProvider(jsonRpcEndpoint);
  // create provider
  const provider = new ethers.providers.Web3Provider(jsonRpcProvider);
  // ステート変数
  const [account, setAccount] = useState({
    address: '',
    provider: provider,
  })

  // メタマスクに接続するための関数
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
    <div>
      <AppBar position="static" color="inherit">
        <Toolbar className="toolbar">
          <Typography variant="h6" color="inherit" sx={{ flexGrow: 1 }}>
            <strong>Swap DApp</strong>
          </Typography>
          <Typography variant="h6" color="inherit">
            <Button onClick={connectWallet}>
              <AccountBalanceWalletIcon/>
            </Button>
          </Typography>
        </Toolbar>
      </AppBar>
      <Box sx={{ flexGrow: 1, overflow: "hidden", px: 3, mt: 10}}>
        <StyledPaper sx={{my: 1, mx: "auto", p: 0, borderRadius: 4}}>
          <div className="Uniswap">
            <SwapWidget provider={account.provider} jsonRpcEndpoint={jsonRpcEndpoint} theme={theme} />
          </div>
        </StyledPaper>
      </Box>
    </div>
  );
}

export default App;
