<template>
  <div class="ethereum">
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
  name: 'EthereumServer',

  methods: {
    //submitRemote: function() {},

    //createContractInstance: function(instance) {}
  }
}

export default {
  mixins: [mixin],
  extends: EthereumBase
}
</script>
