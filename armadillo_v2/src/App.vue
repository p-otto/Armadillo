<template>
  <div class="main">
    <h1>Armadillo</h1>
    <h2>BPMN processes on the blockchain</h2>
    <div class="container">
      <ethereum v-bind:bus="bus"></ethereum>
      <bpmn v-bind:bus="bus"></bpmn>
    </div>
  </div>
</template>

<script>
import Bpmn from './components/Bpmn.vue'
import Ethereum from './components/Ethereum.vue'

import Vue from 'vue'

export default {
  name: 'app',
  data: () => {
    return {
      bus: new Vue()
    }
  },
  components: {
      Bpmn,
      Ethereum
  }
}
</script>

<style src="./styles/app.css">

</style>
