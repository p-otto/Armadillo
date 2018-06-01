<template>
  <div class="main">
    <h1>Armadillo</h1>
    <h2>BPMN processes on the blockchain</h2>
    
    <bpmn></bpmn>
    <ethereum></ethereum>
  </div>
</template>

<script>
import Bpmn from './components/Bpmn.vue'
import Ethereum from './components/Ethereum.vue'

export default {
  name: 'app',
  components: {
      Bpmn,
      Ethereum
  }    
}
</script>

<style src="./styles/app.css">

</style>
