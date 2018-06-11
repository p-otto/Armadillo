<template>
  <div class="main">
    <h1>Armadillo</h1>
    <h2>BPMN processes on the blockchain</h2>
    <div class="container">
      <button v-if="!isClient && !isServer" v-on:click="isClient = true">Client</button>
      <button v-if="!isClient && !isServer" v-on:click="isServer = true">Server</button>

      <process-client v-if="isClient" v-bind:bus="bus"></process-client>
      <process-server v-if="isServer" v-bind:bus="bus"></process-server>

      <bpmn v-bind:bus="bus"></bpmn>
    </div>
  </div>
</template>

<script>
import Bpmn from './components/Bpmn.vue'
import ProcessClient from './components/EthereumClient.vue'
import ProcessServer from './components/EthereumServer.vue'

import Vue from 'vue'

export default {
  name: 'app',
  data: () => {
    return {
      bus: new Vue(),
      isClient: false,
      isServer: false
    }
  },
  components: {
      Bpmn,
      ProcessClient,
      ProcessServer
  }
}
</script>

<style src="./styles/app.css">

</style>
