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
        <label for="contract-select">Upload factory contract code:</label>
        <input type="file" id="contract-select" @change="loadContract($event)" />
      </div>

      <div v-if="factoryDeployed">
        <span>Factory contract deployed at: {{ factoryContract.address }}</span>

        <div v-if="!factoriesLinked">
          <label for="remote-factory">Remote factory address:</label>
          <input type="text" id="remote-factory" v-model="remoteAddress"/>
          <button v-on:click="submitRemote">Submit</button>
        </div>
        <span v-else>Remote factory linked at: {{ remoteAddress }}</span>

        <span v-if="instanceRunning">Contract instance deployed at: {{ instanceContract.address }}</span>
        <button v-else-if="!loading && factoriesLinked" v-on:click="createContractInstance">Create contract instance</button>
      </div>

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
import EthereumBase from "./EthereumBase.vue";

var mixin = {
  name: 'EthereumClient',

  data: () => {
    return {
      remoteAddress: '',
      instanceRunning: false,
    }
  },

  methods: {
    submitRemote: function() {
      this.factoryContract.setSellerFactoryContract(this.remoteAddress)
      this.factoriesLinked = true
    },

    createContractInstance: function(instance) {
      this.loading = true
      this.factoryContract.createInstance().then(_ => {
        console.log('Contract instance created')
      })
    }
  }
}

export default {
  mixins: [mixin],
  extends: EthereumBase
}
</script>
