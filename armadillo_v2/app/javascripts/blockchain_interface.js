// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3 } from 'web3';
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import buyer_artifacts from '../../build/contracts/BuyerContract.json'
var BuyerContract = contract(buyer_artifacts);

import seller_artifacts from '../../build/contracts/SellerContract.json'
var SellerContract = contract(seller_artifacts);

window.App = {
  start: function() {
    //var provider = document.getElementById("provider").value;

    // TODO: use standard address: http://127.0.0.1:9545/
    //var web3 = new Web3(new Web3.providers.HttpProvider(provider));
    var web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:9545/"));

    BuyerContract.setProvider(web3.currentProvider);

    BuyerContract.deployed().then((orchestrationInstance) => {
      orchestrationInstance.allEvents().watch((err, event) => {
        if (!err) {
          console.log("Event observed: " + event.event);
          console.log("Address: " + event.address);
        }
      })
    });
  }
};

window.addEventListener('load', function() {
  App.start();
});