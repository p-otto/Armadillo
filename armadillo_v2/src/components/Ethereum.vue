<template>
  <div class="ethereum">
    <div class="connect-to-node">
      <div v-if="!connected">
        <label for="node-address">Ethereum node address:</label>
        <input type="text" id="node-address" v-model="nodeAddress">
        <button v-on:click="submitAddress">Submit</button>
      </div>
      <p v-if="connected">Ethereum node address: {{ nodeAddress }}</p>
    </div>

    <!--<div class="contract">
      <label for="contract-select">Upload Solidity contract:</label>
      <input type="file" id="contract-select" @change="loadContract($event)">
      <button v-bind:disabled="!connected" v-on:click="submitContract">Submit</button>
    </div>-->

    <div class="contract">
      <label for="abi-select">Upload contract ABI:</label>
      <input type="file" id="abi-select" @change="loadContract('abi', $event)" />

      <label for="bin-select">Upload contract binary:</label>
      <input type="file" id="bin-select" @change="loadContract('bin', $event)" />
      <button v-on:click="submitContract">Submit</button>
    </div>
  </div>
</template>

<script>
import Web3 from 'web3'
import contract from 'truffle-contract'

export default {
  name: 'Ethereum',
  data: () => {
    return {
      connected: false,
      nodeAddress: ''
    }
  },
  methods: {
    submitAddress: function() {
      const web3 = new Web3(new Web3.providers.HttpProvider(this.nodeAddress))
      if (web3.isConnected()) {
        this.web3 = web3
        this.connected = true
      } else {
        alert('Connection failed!')
      }
    },

    loadContract: function(type, changeEvent) {
      const file = changeEvent.target.files.item(0)
      if (file === null) {
        return
      }

      const reader = new FileReader()
      reader.readAsText(file.slice())
      reader.onload = loadEvent => {
        if (type === 'abi') {
          this.abi = loadEvent.target.result
        } else if (type === 'bin') {
          this.bin = loadEvent.target.result
        }
      }
    },
    
    submitContract: function() {
      
      const newContract = contract({
        abi: JSON.parse(this.abi),
        unlinked_binary: '0x' + this.bin
      })

      newContract.setProvider(this.web3.currentProvider)
      newContract.defaults({from: this.web3.eth.coinbase, gas: 1000000})

      if (!newContract.isDeployed()) {
        // contract was not yet deployed, deploy it here
        newContract.new().then(instance => this.contractInstance = instance)
      } else {
        // get the deployed contract
        newContract.deployed().then(instance => this.contractInstance = instance)
      }

      this.contractInstance.allEvents().watch((err, event) => {
        if (!err) {
            console.log('Event observed: ' + event.event)
            console.log('Address: ' + event.address)
            alert('ethereum event watched! check the console')
          }
      })
    }
  }
}
</script>

<style scoped>
.ethereum {
  flex-grow: 1;
  padding-top: 150px;
}

label {
  padding-bottom: 10px;
}

.contract {
  padding-top: 40px;
}
</style>
