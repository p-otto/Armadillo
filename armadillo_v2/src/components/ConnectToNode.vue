<template>
  <div id="connect-to-node">
    <div v-if="!submitted">
      <label for="node-address">Ethereum node address:</label>
      <input type="text" id="node-address" v-model="nodeAddress">
      <button v-on:click="submitAddress">Submit</button>
    </div>
    <p v-if="submitted">Ethereum node address: {{ nodeAddress }}</p>
  </div>
</template>

<script>
export default {
  name: 'ConnectToNode',
  data() {
    return {
      submitted: false,
      nodeAddress: ''
    }
  },
  methods: {
    submitAddress() {
      this.submitted = true
    }
  }
}
</script>