<script>
import EthereumBase from './EthereumBase.vue'

export default {
  extends: EthereumBase,
  mixins: [{
    name: 'EthereumClient',

    data: () => {
      return {
        isClient: true,
        remoteAddress: '',
        remoteAccessAddress: ''
      }
    },

    methods: {
      createContractInstance: function() {
        this.loading = true

        this.factoryContract.createInstance(this.accessContract.address, this.remoteAccessAddress)
          .then(result => {
            console.log('[Blockchain] Creating instance contract.')
            this.logTransactionResult(result)
            this.factoryGasUsed += result.receipt.gasUsed
          })
          .catch(err => {
            alert("Error!")
            console.log(err)
          })
      }
    }
  }]
}
</script>
