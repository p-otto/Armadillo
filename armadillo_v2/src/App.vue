<template>
  <div id="mainApp">
    <h1>Armadillo</h1>
    <h2>BPMN processes on the blockchain</h2>
    
    <connect-to-node></connect-to-node>
    <bpmn></bpmn>
    <contract></contract>
  </div>
</template>

<script>
import ConnectToNode from './components/ConnectToNode.vue'
import Bpmn from './components/Bpmn.vue'
import Contract from './components/Contract.vue'

export default {
  name: 'app',
  components: {
      ConnectToNode,
      Bpmn,
      Contract
  }    
}
</script>

<style src="./styles/app.css">

</style>
