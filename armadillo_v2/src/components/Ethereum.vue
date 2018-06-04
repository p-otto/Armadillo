<template>
  <div class="ethereum">
    <div class="connect-to-node">
      <div v-if="!connected">
        <label for="node-address">Ethereum node address:</label>
        <input type="text" id="node-address" v-model="nodeAddress">
        <button v-on:click="submitAddress">Submit</button>

        <label for="connect-local">or,</label>
        <button v-on:click="connectToLocal" id="connect-local">Connect to your local ethereum node</button>
      </div>
      <p v-if="connected">Ethereum node address: {{ nodeAddress }}</p>
    </div>

    <!--<div class="contract">
      <label for="contract-select">Upload Solidity contract:</label>
      <input type="file" id="contract-select" @change="loadContract($event)">
      <button v-bind:disabled="!connected" v-on:click="submitContract">Submit</button>
    </div>-->

    <div class="contract">
      <div v-if="!contractSubmitted">
        <label for="abi-select">Upload contract ABI:</label>
        <input type="file" id="abi-select" @change="loadContract('abi', $event)" />

        <label for="bin-select">Upload contract binary:</label>
        <input type="file" id="bin-select" @change="loadContract('bin', $event)" />

        <button v-on:click="submitContract">Submit</button>
      </div>
      <div v-else>
        <p>Contract deployed at: {{ contractAddress }}</p>
      </div>
    </div>

    <div v-if="paramsNeeded" class="inputs">
        <label v-for="(functionInput, index) in contractFunction.inputs">
          {{ functionInput.name }} ({{ functionInput.type }}):
          <input type="text" v-model="contractFunction.inputs[index].value">
        </label>
      <button v-on:click="submitParams">Submit</button>
    </div>
  </div>
</template>

<script>
import Web3 from 'web3'
import contract from 'truffle-contract'

export default {
  name: 'Ethereum',
  props: ['bus'],
  data: () => {
    return {
      connected: false,
      nodeAddress: '',
      contractSubmitted: false,
      contractAddress: '',
      contractFunction: { inputs: [] },
      paramsNeeded: false
    }
  },
  mounted: function() {
    this.bus.$on('task-triggered', (task) => this.callContract(task))
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

    connectToLocal: function() {
      this.nodeAddress = 'http://127.0.0.1:9545'
      this.submitAddress()
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
        newContract.new().then(instance => this.handleContractDeployed(instance))
      } else {
        // get the deployed contract
        newContract.deployed().then(instance => this.handleContractDeployed(instance))
      }
    },

    handleContractDeployed: function(instance) {
      this.contractInstance = instance

      this.contractSubmitted = true
      this.contractAddress = instance.address

      this.contractInstance.allEvents().watch((err, event) => {
        if (!err) {
            console.log('Event observed: ' + event.event)
            console.log('Address: ' + event.address)
            this.bus.$emit('eth-event-triggered', event.event)
          }
      })
    },

    callContract: function(task) {
      if (!this.contractInstance) {
        alert('No contract instance found!')
        return
      }

      const contractFunctions = this.contractInstance.abi
        .filter(entry => entry.type === 'function')
        
      const contractFunctionNames = contractFunctions.map(entry => entry.name)

      const taskName = task.businessObject.name

      if (!contractFunctionNames.includes(taskName)) {
        alert('No contract method to call found')
      } else {
        const contractFunction = contractFunctions.filter(func => func.name === taskName)[0]
        if (contractFunction.inputs.length > 0) {
          // collect input parameters from user
          this.contractFunction = contractFunction
          this.paramsNeeded = true
        } else {
          // call directly
          this.contractInstance[taskName]()
        }
      }
    },

    submitParams: function() {
      const paramValues = this.contractFunction.inputs.map(input => input.value)
      this.paramsNeeded = false
      this.contractInstance[this.contractFunction.name](...paramValues).then(receipt => console.log(receipt))
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

.inputs {
  padding-top: 40px
}
</style>
