<template>
  <div id="contract">
    <label for="contract-select">Upload Solidity contract:</label>
    <input type="file" id="contract-select" @change="loadContract($event)">
    <button v-on:click="submitContract">Submit</button>
  </div>
</template>

<script>
import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'

// Import our contract artifacts 
import buyer_artifacts from '../../build/contracts/BuyerContract.json'
import seller_artifacts from '../../build/contracts/SellerContract.json'

export default {
  name: 'Contract',
  mounted() {
    // turn contracts into usable abstractions
    this.sellerContract = contract(seller_artifacts)
    this.buyerContract = contract(buyer_artifacts)

    // TODO use exported nodeAddress from ConnectToNode.vue
    const web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:9545/'))

    this.buyerContract.setProvider(web3.currentProvider)

    this.buyerContract.deployed().then(orchestrationInstance => {
      orchestrationInstance.allEvents().watch((err, event) => {
        if (!err) {
          console.log('Event observed: ' + event.event)
          console.log('Address: ' + event.address)
        }
      })
    })
  },
  methods: {
    loadContract(event) {
      const file = event.target.files.item(0)
      if (file === null) {
        return
      }

      const reader = new FileReader()
      reader.readAsText(file.slice())
      reader.onload = event => {
        this.contract = event.target.result
      }
    },
    submitContract() {
      console.log(this.contract)
      alert('contract printed to console')
    }
  }
}
</script>
