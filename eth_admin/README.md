# Armadillo

## Prerequisites

- Have [Yarn](https://yarnpkg.com/en/docs/install) installed
- For automation, have [Expect](https://core.tcl.tk/expect/index) installed
- An ethereum chain node is running (i.e. with `truffle dev`)
- An access contract is deployed and its address is known

## Usage

### Manual

Run `yarn run repl`, or directly execute `./index.js` to start the access management REPL.

#### Manging access rights

When running the REPL, you can add and remove access rights with the following commands:

```
> connect <nodeAddress> -c <accessContractAddress>	# connect to an access contract on a node (if no node address is given, use localhost:9545

> right give -u <userAddress> -r <roleName>		# assign a user to a role

> task <taskName> <roleName>				# assign a task to a role

> right remove -u <userAddress> -r <roleName>		# unassign a user from a role

> right check -u <userAddress> -r <taskName>		# verify wether a user has the right to execute a task
```

### Automated

For adding access rights in an automated way, provide the statements you want to execute in `setup_input_instance`, then execute `./setup`.
This will read each line of the provided input, execute it in the repl and wait for the resulting log, before executing the next statement.
Waiting for the responses is necessary, as the blockchain calls are asynchronous.
When you want to connect to different access contracts, you want to be sure that the connection was established before setting any rights.
