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
      submitRemote: function() {
        this.factoryContract.setSellerFactoryContract(this.remoteAddress)
        this.currentState = this.states.factoriesLinked
      },

      createContractInstance: function() {
        this.loading = true
        this.factoryContract.createInstance(this.accessContract.address, this.remoteAccessAddress).then(_ => {
          console.log('Contract instance created')
        })
      }
    }
  }]
}
</script>
