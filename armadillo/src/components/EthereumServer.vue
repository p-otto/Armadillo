<script>
import EthereumBase from './EthereumBase.vue'

export default {
  extends: EthereumBase,
  mixins: [{
    name: 'EthereumServer',
    data: () => {
      return {
        isClient: false,
      }
    }
  }]
}
</script>
