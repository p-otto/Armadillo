# Armadillo

## Setup

Prerequisite: Have [Yarn](https://yarnpkg.com/en/docs/install) installed

```
> yarn global add truffle	# globally install truffle
> yarn install 			# install project dependencies
> yarn run build		# build the project
> truffle dev			# start the truffle blockchain wrapper
```

Then, open `index.html` in your web browser

For development, you can use `> yarn run watch` to autobuild on save


## Usage

1. Connect to your ethereum node by entering the node IP address
	- If you have your ethereum node running locally (i.e., started by `truffle dev`), you can also choose "Connect to your local ethereum node"
2. Upload a solidity contract
3. Upload a BPMN diagram in .bpmn format
	- e.g., created in the [bpmn.io](http://demo.bpmn.io/new) modeler

Now, each task can be clicked in the UI, triggering a call in the contract.  
For this to work, the __task label needs to correspond to a contract function name__.

When an event is emitted from your contract, whose __name corresponds to a catch event label__ in your diagram, the BPMN event in the diagram will be highlighted.