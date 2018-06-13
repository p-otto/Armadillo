#!/usr/bin/env node

const Web3 = require('web3')
const contract = require('truffle-contract')
const vorpal = require('vorpal')()
const assert = require('assert');

var CONTRACT_ABI = '[{"constant":false,"inputs":[{"name":"_receiver","type":"address"},{"name":"_role","type":"string"}],"name":"removeRights","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"buyerAddress","type":"address"},{"name":"_role","type":"string"}],"name":"isAuthorized","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_receiver","type":"address"},{"name":"_role","type":"string"}],"name":"giveRights","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"}]'

var App = {
    web3: null,
    contract: null,

    connect: function(node_address, contract_address) {
        console.log('Connecting to ' + node_address + '...')
        const web3 = new Web3(new Web3.providers.HttpProvider(node_address))
        if (web3.isConnected()) {
            this.web3 = web3
        }

        assert(this.web3, 'Could not connect to ethereum node.')

        var contractWrapper = contract({
            abi: CONTRACT_ABI,
        })
        contractWrapper.setProvider(this.web3.currentProvider)
        contractWrapper.defaults({from: this.web3.eth.accounts[0], gas: 1000000})

        contractWrapper.at(this.web3.toChecksumAddress(contract_address))
            .then(instance => this.contract = instance)
            .catch(err => console.log('Error during contract loading: ' + err))
    },

    setUserRole: function(userAddress, roleName, hasAccess) {
        if (hasAccess) {
            this.contract.giveRights(userAddress, roleName)
                .catch(err => console.log(err))
                .then(receipt => console.log(receipt))
        }
        else {
            this.contract.removeRights(userAddress, roleName)
                .catch(err => console.log(err))
                .then(receipt => console.log(receipt))
        }
    },

    checkUserRole: function(userAddress, roleName) {
        this.contract.isAuthorized(userAddress, roleName)
            .catch(err => console.log(err))
            .then(receipt => console.log(receipt))
    }
}

vorpal
    .command('connect [node_address]', 'Connects to an ethereum node.')
    .option('-c, --contract <contract_address>')
    .types({
        string: ['c', 'contract']
    })
    .action(function(args, callback) {
        assert(args.options.contract, 'No contract specified.');

        if (args['node_address']) {
            App.connect(args['node_address'], args.options.contract)
        }
        else {
            App.connect('http://127.0.0.1:9545/', args.options.contract)
        }
        callback()
    })

vorpal
    .command('right <action>')
    .option('-u --user <user_address>')
    .option('-r --role <role_name>')
    .types({
        string: ['u', 'user', 'r', 'role']
    })
    .action(function(args, callback) {
        assert(args.options.user)
        assert(args.options.role)

        var address = App.web3.toChecksumAddress(args.options.user)

        if (args['action'] == 'give') {
            App.setUserRole(address, args.options.role, true)
        }
        else if (args['action'] == 'remove') {
            App.setUserRole(address, args.options.role, false)
        }
        else if (args['action'] == 'check') {
            App.checkUserRole(address, args.options.role)
        }
        else {
            console.log('unkown action: ' + args['action'])
        }

        callback()
    })

vorpal
  .delimiter('$')
  .show()
