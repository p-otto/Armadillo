# Notes & Ideas

## On-Chain Access Rights

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
