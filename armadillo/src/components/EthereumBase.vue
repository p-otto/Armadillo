<template>
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
      loading: false,
      connected: false,
      factoriesLinked: false,
      nodeAddress: '',
      contractSelected: false,
      factoryDeployed: false,
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
        this.loading = true
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
      const compiledFactory = compiledContracts.contracts[":" + this.contractName]
      const compiledInstance = compiledContracts.contracts[":" + this.contractName.replace('Factory', '')]

      if (!compiledFactory || !compiledInstance) {
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

      const factoryWrapper = contract({
        abi: JSON.parse(compiledFactory.interface),
        unlinked_binary: '0x' + compiledFactory.bytecode
      })

      this.instanceWrapper = contract({
        abi: JSON.parse(compiledInstance.interface),
        unlinked_binary: '0x' + compiledInstance.bytecode
      })

      factoryWrapper.setProvider(this.web3.currentProvider)
      factoryWrapper.defaults({from: this.web3.eth.coinbase, gas: 1000000})

      this.instanceWrapper.setProvider(this.web3.currentProvider)
      this.instanceWrapper.defaults({from: this.web3.eth.coinbase, gas: 1000000})

      // TODO always deploy a new factory? What if there is already one on the blockchain
      return factoryWrapper.new().then(factory => this.handleFactoryDeployed(factory))
    },

    handleFactoryDeployed: function(factory) {
      this.loading = false
      this.factoryDeployed = true
      this.factoryContract = factory

      // watch for instance creation events
      this.factoryContract.allEvents().watch((err, event) => {
        if (!err) {
          this.handleInstanceDeployed(event)
        }
      })
    },

    handleInstanceDeployed: function(event) {
      this.instanceWrapper.at(event.args.instanceAddress).then(instanceContract => {
        this.instanceContract = instanceContract
        this.instanceRunning = true
        this.loading = false
        // watch for actual process events
        this.instanceContract.allEvents().watch((err, event) => {
          if (err) {
            console.log('Error during watching event')
            return
          }

          console.log('Event observed: ' + event.event)
          console.log('Address: ' + event.address)
          if (event.event === 'Selfdestructed') {
            this.instanceRunning = false
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
