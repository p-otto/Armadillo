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

    <div class="contract">
      <div v-if="!contractSubmitted">
        <label for="contract-select">Upload contract code:</label>
        <input type="file" id="contract-select" @change="loadContract($event)" />

        <div v-if="solcReady">
          <button v-on:click="submitContract">Submit</button>
        </div>
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
import browserSolc from 'browser-solc';


export default {
  name: 'Ethereum',
  props: ['bus'],
  data: () => {
    return {
      connected: false,
      solcReady: false,
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
    initSolc: function() {
      BrowserSolc.loadVersion("soljson-v0.4.24+commit.e67f0147.js", function(compiler) {
        this.compiler = compiler
        this.solcReady = true;
      }.bind(this))
    },

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

      this.contractName = file.name.split(".")[0]

      const reader = new FileReader()
      reader.readAsText(file.slice())
      reader.onload = loadEvent => {
        this.contractCode = loadEvent.target.result
      }

      if (!this.solcReady) {
        this.initSolc()
      }
    },

    deployContract: function(contract) {
      if (!contract.isDeployed()) {
        // contract was not yet deployed, deploy it here
        return contract.new().then(instance => this.handleContractDeployed(instance))
      } else {
        // get the deployed contract
        return contract.deployed().then(instance => this.handleContractDeployed(instance))
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

    submitContract: function() {
      if (!this.solcReady) {
        alert("Solc is not initialized yet.")
        return
      }

      var contractObject = this.compiler.compile(this.contractCode, 0)
      if (!contractObject) {
        alert('Contract could not be compiled.')
        return
      }
      if (contractObject.errors.length > 0) {
        console.log('Contract errors: ' + contractObject.errors)
      }

      var rawContract = contractObject.contracts[":" + this.contractName]

      const wrappedContract = contract({
        abi: JSON.parse(rawContract.interface),
        unlinked_binary: '0x' + rawContract.bytecode
      })

      wrappedContract.setProvider(this.web3.currentProvider)
      wrappedContract.defaults({from: this.web3.eth.coinbase, gas: 1000000})

      this.deployContract(wrappedContract)
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
      } else {
        const contractFunction = contractFunctions.filter(func => func.name === taskName)[0]
        if (contractFunction.inputs.length > 0) {
          // collect input parameters from user
          this.contractFunction = contractFunction
          this.paramsNeeded = true
        } else {
          // call directly
          this.contractInstance[taskName]().then(receipt => this.logReceipt(receipt))
          this.logBlockchainCall(taskName)
        }
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
