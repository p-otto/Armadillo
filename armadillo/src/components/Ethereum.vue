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
      <span v-if="connected">Ethereum node address: {{ nodeAddress }}</span>
    </div>

    <div class="contract">
      <div v-if="!contractSelected">
        <label for="contract-select">Upload contract code:</label>
        <input type="file" id="contract-select" @change="loadContract($event)" />
      </div>
      <div v-else-if="contractSelected && (!contractDeployed || !solcReady)" class="cssload-container">
        <div class="cssload-speeding-wheel" />
      </div>
      <div v-else>
        <span>Contract deployed at: {{ contractInstance.address }}</span>
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
import browserSolc from 'browser-solc';


export default {
  name: 'Ethereum',
  props: ['bus'],
  data: () => {
    return {
      connected: false,
      contractSelected: false,
      contractDeployed: false,
      solcReady: false,
      nodeAddress: '',
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

    loadContract: function(changeEvent) {
      const file = changeEvent.target.files.item(0)
      if (file === null) {
        return
      }

      this.contractSelected = true
      this.contractName = file.name.split(".")[0]

      const reader = new FileReader()
      reader.readAsText(file.slice())
      reader.onload = loadEvent => {
        this.contractCode = loadEvent.target.result
        if (!this.solcReady) {
          this.initSolc()
        } else {
          this.submitContract()
        }
      }
    },

    initSolc: function() {
      BrowserSolc.loadVersion("soljson-v0.4.24+commit.e67f0147.js", function(compiler) {
        this.compiler = compiler
        this.solcReady = true
        this.submitContract()
      }.bind(this))
    },

    submitContract: function() {
      const compiledContracts = this.compiler.compile(this.contractCode, 0)
      const compiledContract = compiledContracts.contracts[":" + this.contractName]

      if (!compiledContract) {
        alert('Contract named ' + this.contractName + ' could not be compiled. See console for errors.')
        console.log('Contract code:')
        console.log(this.contractCode)
        console.log('Errors:')
        console.log(compiledContracts.errors)
        this.contractSelected = false
        return
      } else if (compiledContracts.errors.length > 0) {
        console.log('Warnings:')
        console.log(compiledContracts.errors)
      }

      const contractWrapper = contract({
        abi: JSON.parse(compiledContract.interface),
        unlinked_binary: '0x' + compiledContract.bytecode
      })

      contractWrapper.setProvider(this.web3.currentProvider)
      contractWrapper.defaults({from: this.web3.eth.coinbase, gas: 1000000})

      // TODO always deploy a new instance?
      return contractWrapper.new().then(instance => this.handleContractDeployed(instance))
    },

    handleContractDeployed: function(instance) {
      this.contractDeployed = true
      this.contractInstance = instance

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
        alert('No contract method named ' + taskName + ' was found.')
        return
      }

      const contractFunction = contractFunctions.filter(func => func.name === taskName)[0]
      if (contractFunction.inputs.length > 0) {
        // collect input parameters from user
        this.contractFunction = contractFunction
        this.paramsNeeded = true
      } else {
        // call directly
        this.logBlockchainCall(taskName)
        this.contractInstance[taskName]().then(receipt => this.logReceipt(receipt))
      }
    },

    submitParams: function() {
      const paramValues = this.contractFunction.inputs.map(input => input.value)
      this.paramsNeeded = false
      this.contractInstance[this.contractFunction.name](...paramValues).then(receipt => this.logReceipt(receipt))
      this.logBlockchainCall(this.contractFunction.name)
    },

    logBlockchainCall: function(functionName) {
      console.log('[Blockchain] execute ' + functionName + ' on ' + this.contractInstance.address)
    },

    logReceipt: function(receipt) {
      console.log('[Blockchain] received receipt:')
      console.log(receipt)
    }
  }
}
</script>

<style scoped src="../styles/ethereum.css">
</style>
