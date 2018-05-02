# Notes & Ideas

## On-Chain Access Rights

### Requirements

#### Functional

To enable the management of users with specific access rights, we need to introduce two mappings: a __user-to-role mapping__, making it possible to group users with similar functions, and a __role-to-function mapping__, for giving groups specific rights to execute specific functions. It should be possible to __create and modify__ these mappings, and to __query__ the mapped values for a given entity. Only users with __admin privileges__ should be able to create and modify these mappings.

Depending on the application, the role-to-function mapping should be __generated automatically__. In a BPM engine, for example, it should be possible to generate the mapping from a BPMN model containing lanes with specific tasks.
The user-to-role-mapping should be __modifyable at run time__, i.e. by an admin user adding another user to a specific role.

The implementation should be __benchmarkable__ in terms of transaction and execution costs in ether, as well as number of needed transactions.

#### Non-Functional

The solution should be __modular__ and __reusable__, so that other contracts can call it without modification.  
It should be __cheap__ in terms of execution and transaction costs.  
It should be __secure__ regarding the modification of user rights.
If possible, it should be __anonymous__, so that the user rights data is not visible to anyone in the network.

### Approaches

#### Address-to-Bitmask Mapping

Hold a `mapping` from account address to access rights bitmask.
There can be several roles:

- one super-admin creating the contract
- admins that can see and change access rights of other users
- users that have access rights

A bitmask of three bits describes what rights are given to an account:
the first bit is for superadmin, the second for admin, the third for user.
This of course can be extended for different subcategories of users, e.g. different roles in a process.

Example: bitmask `001` describes that an account has normal user rights

This contract can then be called by other contracts prior to executing their scripts, in order to check if the sender has the needed access rights.

See `bitmask.sol` files for implementation.

#### Colored Coins / Tokens


#### Hierarchical Wallets
