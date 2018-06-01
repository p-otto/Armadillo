<template>
  <div class="ethereum">
    <div class="connect-to-node">
      <div v-if="!submitted">
        <label for="node-address">Ethereum node address:</label>
        <input type="text" id="node-address" v-model="nodeAddress">
        <button v-on:click="submitAddress">Submit</button>
      </div>
      <p v-if="submitted">Ethereum node address: {{ nodeAddress }}</p>
    </div>

    <div class="contract">
      <label for="contract-select">Upload Solidity contract:</label>
      <input type="file" id="contract-select" @change="loadContract($event)">
      <button v-bind:disabled="!submitted" v-on:click="submitContract">Submit</button>
    </div>
  </div>
</template>

<script>
import Web3 from 'web3'
import parseContract from 'truffle-contract'

export default {
  name: 'Ethereum',
  data: () => {
    return {
      submitted: false,
      nodeAddress: ''
    }
  },
  methods: {
    submitAddress: function() {
      const web3 = new Web3(new Web3.providers.HttpProvider(this.nodeAddress))
      if (web3.isConnected()) {
        this.submitted = true
        this.web3 = web3
      } else {
        alert('Connection failed!')
      }
    },

    loadContract: function(event) {
      const file = event.target.files.item(0)
      if (file === null) {
        return
      }

      const reader = new FileReader()
      reader.readAsText(file.slice())
      reader.onload = event => {
        this.rawContract = event.target.result
      }
    },
    
    submitContract: function() {
      console.log(this.rawContract)
      alert('contract printed to console')

      this.contract = parseContract(this.rawContract)

      this.contract.setProvider(this.web3.currentProvider)

      if (!this.contract.hasNetwork()) {
        // contract was not yet deployed
        // TODO deploy it here
        
      }

      this.contract.deployed().then(orchestrationInstance => {
        console.log('contract deployed. watching for events...')
        orchestrationInstance.allEvents().watch((err, event) => {
          if (!err) {
            console.log('Event observed: ' + event.event)
            console.log('Address: ' + event.address)
            alert('ethereum event watched! check the console')
          }
        })
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
