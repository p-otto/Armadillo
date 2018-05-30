# Armadillo

## Setup

- Install [Truffle](http://truffleframework.com/): ```npm install -g truffle```
- cd into armadillo directory
- run ```npm install``` to setup the node project
- build with ```npm run build```
- open ```build/index.html``` in webbrowser
- run ```truffle develop``` to open truffle console
- ```truffle(develop)> migrate```
- ```truffle(develop)> BuyerContract.deployed().then(instance => instance.receiveProduct())```
- Event should trigger, output can be viewed on browser console


