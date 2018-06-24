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
        this.factoryContract.createInstance().then(_ => {
          console.log('Contract instance created')
        })
      }
    }
  }]
}
</script>
