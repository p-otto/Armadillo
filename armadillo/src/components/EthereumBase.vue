<template>
  <div class="ethereum">
    <!-- general user interface -->
    <div class="connect-to-node">
      <div v-if="currentState <= states.init">
        <label for="node-address">Ethereum node address:</label>
        <input type="text" id="node-address" v-model="nodeAddress">
        <button v-on:click="submitAddress">Submit</button>

        <label for="connect-local">or,</label>
        <button v-on:click="connectToLocal" id="connect-local">Connect to your local ethereum node</button>
      </div>
      <span v-else>Ethereum node address: {{ nodeAddress }}</span>
    </div>

    <div class="contract">
      <div v-if="currentState === states.connected">
        <label for="contract-select">Upload factory contract code:</label>
        <input type="file" id="contract-select" @change="loadContract($event, 'factory')" />
      </div>

      <span v-if="currentState >= states.factoryDeployed">Factory contract deployed at: {{ factoryContract.address }}</span>

      <div v-if="currentState === states.factoryDeployed">
        <label for="access-select">Upload access contract code:</label>
        <input type="file" id="access-select" @change="loadContract($event, 'access')" />
      </div>

      <span v-if="currentState >= states.accessDeployed">Access contract deployed at: {{ accessContract.address }}</span>

      <!-- client specific user interface -->
      <div v-if="isClient">
        <div v-if="currentState >= states.accessDeployed">
          <div v-if="currentState < states.factoriesLinked">
            <label for="remote-factory">Remote factory address:</label>
            <input type="text" id="remote-factory" v-model="remoteAddress" />
            <label for="remote-access">Remote access address:</label>
            <input type="text" id="remote-access" v-model="remoteAccessAddress" />
            <button v-on:click="submitRemote">Submit</button>
          </div>
          <div v-else>
            <span>Remote factory linked at: {{ remoteAddress }}</span>

            <span v-if="currentState >= states.instanceRunning">Contract instance deployed at: {{ instanceContract.address }}</span>
            <button v-else v-on:click="createContractInstance">Create contract instance</button>
          </div>
        </div>
      </div>

      <!-- server specific user interface -->
      <div v-if="!isClient">
      </div>

      <!-- general user interface -->
      <div v-if="loading" class="cssload-container">
        <div class="cssload-speeding-wheel" />
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
  name: 'EthereumBase',
  props: ['bus'],
  data: () => {
    return {
      states: Object.freeze({ init: 1, connected: 2, factoryDeployed: 3, accessDeployed: 4, factoriesLinked: 5, instanceRunning: 6 }),
      currentState: 1,
      nodeAddress: '',
      loading: false,
      solcReady: false,
      contractFunction: { inputs: [] },
      paramsNeeded: false
    }
  },
  mounted: function() {
    this.bus.$on('role-validation-required', roleName => this.validateRole(roleName))
    this.bus.$on('task-triggered', taskName => this.callContract(taskName))
  },
  methods: {
    submitAddress: function() {
      this.currentState = this.states.connected
      const web3 = new Web3(new Web3.providers.HttpProvider(this.nodeAddress))
      if (web3.isConnected()) {
        this.web3 = web3
      } else {
        this.currentState = this.states.init
        alert('Connection failed!')
      }
    },

    connectToLocal: function() {
      this.nodeAddress = 'http://127.0.0.1:9545'
      this.submitAddress()
    },

    loadContract: function(changeEvent, target) {      
      this.loading = true
      this.loadFile(changeEvent, loadEvent => {
        this.compileContract(loadEvent.target.result, target)
      })
    },

    compileContract: function(contractCode, target) {
      if (!this.solcReady) {
        this.initSolc(contractCode, target)
      } else {
        this.submitContract(contractCode, target)
      }
    },

    loadAccessContract: function(changeEvent) {
      this.accessSelected = true

      this.loadFile(changeEvent, loadEvent => {
        this.submitAccessContract(loadEvent.target.result)
      })
    },

    loadFile: function(changeEvent, callback) {
      const file = changeEvent.target.files.item(0)
      if (file === null) {
        return
      }

      this.contractName = file.name.split(".")[0]

      const reader = new FileReader()
      reader.readAsText(file.slice())
      reader.onload = callback
    },

    initSolc: function(contractCode, target) {
      BrowserSolc.loadVersion("soljson-v0.4.24+commit.e67f0147.js", function(compiler) {
        this.compiler = compiler
        this.solcReady = true
        this.submitContract(contractCode, target)
      }.bind(this))
    },

    submitContract: function(contractCode, target) {
      const compiledContracts = this.compiler.compile(contractCode, 0)
      const compiledContract = compiledContracts.contracts[":" + this.contractName]
      const wrapper = this.wrapCompiledContract(compiledContract, compiledContracts.errors)
      let handleDeployed

      if (target === 'access') {
        handleDeployed = this.handleAccessDeployed
      } else if (target === 'factory') {
        handleDeployed = this.handleFactoryDeployed
        const compiledInstance = compiledContracts.contracts[":" + this.contractName.replace('Factory', '')]
        this.instanceWrapper = this.wrapCompiledContract(compiledInstance, compiledContracts.errors)
      } else {
        console.log('Error: unknown contract target ' + target)
        return
      }

      // TODO always deploy a new factory? What if there is already one on the blockchain
      wrapper.new().then(instance => handleDeployed(instance))
    },

    wrapCompiledContract: function(compiledContract, compileErrors) {
      if (!compiledContract) {
        alert('Contract named ' + this.contractName + ' could not be compiled. See console for errors.')
        console.log('Contract code:')
        console.log(this.contractCode)
        console.log('Errors:')
        console.log(compileErrors)
        return
      } else if (compileErrors.length > 0) {
        console.log(this.contractName + ' warnings:')
        console.log(compileErrors)
      }

      const wrapper = contract({
        abi: JSON.parse(compiledContract.interface),
        unlinked_binary: '0x' + compiledContract.bytecode
      })

      // TODO use address given by user
      wrapper.setProvider(this.web3.currentProvider)
      wrapper.defaults({from: this.web3.eth.coinbase, gas: 1000000})

      return wrapper
    },

    handleFactoryDeployed: function(factory) {
      this.factoryContract = factory
      this.loading = false
      this.currentState = this.states.factoryDeployed

      // watch for instance creation events
      this.factoryContract.allEvents().watch((err, event) => {
        if (!err) {
          this.handleInstanceDeployed(event)
        }
      })
    },

    handleAccessDeployed: function(accessContract) {
      this.accessContract = accessContract
      this.loading = false
      this.currentState = this.states.accessDeployed
    },

    handleInstanceDeployed: function(event) {
      this.instanceWrapper.at(event.args.instanceAddress).then(instanceContract => {
        this.instanceContract = instanceContract
        this.loading = false
        this.currentState = this.states.instanceRunning
        // watch for actual process events
        this.instanceContract.allEvents().watch((err, event) => {
          if (err) {
            console.log('Error during watching event')
            return
          }

          console.log('Event observed: ' + event.event)
          console.log('Address: ' + event.address)
          if (event.event === 'Selfdestructed') {
            this.currentState = this.states.accessDeployed
            this.bus.$emit('instance-terminated')
          } else {
            this.bus.$emit('eth-event-triggered', event.event)
          }
        })
      })
    },

    validateRole: function(roleName) {

    },

    callContract: function(taskName) {
      if (!this.instanceContract) {
        alert('No contract instance found!')
        return
      }

      const contractFunctions = this.instanceContract.abi
        .filter(entry => entry.type === 'function')
      const contractFunctionNames = contractFunctions.map(entry => entry.name)

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
        this.instanceContract[taskName]().then(receipt => this.logReceipt(receipt))
      }
    },

    submitParams: function() {
      const paramValues = this.contractFunction.inputs.map(input => input.value)
      this.paramsNeeded = false
      this.instanceContract[this.contractFunction.name](...paramValues).then(receipt => this.logReceipt(receipt))
      this.logBlockchainCall(this.contractFunction.name)
    },

    logBlockchainCall: function(functionName) {
      console.log('[Blockchain] execute ' + functionName + ' on ' + this.instanceContract.address)
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
