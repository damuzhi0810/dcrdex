#!/usr/bin/env bash
# tmux script that sets up an eth simnet harness. It sets up four separate nodes.
# alpha and beta nodes are synced in snap mode. They emulate nodes used by the
# dcrdex server. Either has the authority to mine blocks. They start with
# pre-allocated funds. gamma and delta are synced in light mode and emulate
# nodes used by dexc. They are sent some funds after being created. The harness
# waits for all nodes to sync before allowing tmux input.
set -ex

SESSION="eth-harness"

CHAIN_ADDRESS_JSON_FILE_NAME="UTC--2021-01-27T08-20-38.123221057Z--9ebba10a6136607688ca4f27fab70e23938cd027"
CHAIN_ADDRESS="9ebba10a6136607688ca4f27fab70e23938cd027"
CHAIN_ADDRESS_JSON='{"address":"9ebba10a6136607688ca4f27fab70e23938cd027","crypto":{"cipher":"aes-128-ctr","ciphertext":"dcfbe17de6f315c732855111b782496d76b2d703169afddaaa69e1bc9e02ec51","cipherparams":{"iv":"907e5e050649d1c5c0be782ec7db5cf1"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"060f4e16d601069a6bccae0693a15cd72090baf1ab20e408c89883117d4f7c51"},"mac":"b9ca7dad75a04b77dc7751a814c051f32752603334e4bb4046caf927196a5579"},"id":"74805e39-6a2f-46eb-8125-70c41d12c6d9","version":3}'

ALPHA_ADDRESS="18d65fb8d60c1199bb1ad381be47aa692b482605"
ALPHA_ADDRESS_JSON_FILE_NAME="UTC--2021-01-28T08-47-02.993754951Z--18d65fb8d60c1199bb1ad381be47aa692b482605"
ALPHA_ADDRESS_JSON='{"address":"18d65fb8d60c1199bb1ad381be47aa692b482605","crypto":{"cipher":"aes-128-ctr","ciphertext":"927bc2432492fc4bbe9acfe0042f5cd2cef25aff251ac1fb2f420ee85e3b6ee4","cipherparams":{"iv":"89e7333535aed5284abd52f841d30c95"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"6fe29ea59d166989be533da62d79802a6b0cef26a9766fa363c7a4bb4c263b5f"},"mac":"c7e2b6c4538c373b2c4e0be7b343db618d39cc68fa872909059357ff36743ca0"},"id":"0e2b9cef-d659-4a26-8739-879129ed0b63","version":3}'
ALPHA_NODE_KEY="71d810d39333296b518c846a3e49eca55f998fd7994998bb3e5048567f2f073c"
ALPHA_ENODE="897c84f6e4f18195413c1d02927e6a4093f5e7574b52bdec6f20844c4f1f6dd3f16036a9e600bd8681ab50fd8dd144df4a6ba9dd8722bb578a86aaa8222c964f"
ALPHA_NODE_PORT="30304"
ALPHA_AUTHRPC_PORT="8552"

# BETA_ADDRESS="4f8ef3892b65ed7fc356ff473a2ef2ae5ec27a06"
BETA_ADDRESS_JSON_FILE_NAME="UTC--2021-01-27T08-20-58.179642501Z--4f8ef3892b65ed7fc356ff473a2ef2ae5ec27a06"
BETA_ADDRESS_JSON='{"address":"4f8ef3892b65ed7fc356ff473a2ef2ae5ec27a06","crypto":{"cipher":"aes-128-ctr","ciphertext":"c5672bb829df9e209ca8ce18dbdd1fed69c603d639e06ab09127b672a609c121","cipherparams":{"iv":"24460eb2934c8b61cee3ad0aa7b843c0"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"1f85da881994ca7b4a23f0698da70500a4b79f97a4450b83b129ebf3b4c28f50"},"mac":"1ecea707f1bffa1f6f944cb47e83118d8179e8a5005b83c88610b7e8692a1197"},"id":"56633762-6fb1-4cbf-8396-3a2e4661f7d4","version":3}'
BETA_NODE_KEY="0f3f23a0f14202da009bd59a96457098acea901986629e54d5be1eea32fc404a"
BETA_ENODE="b1d3e358ee5c9b268e911f2cab47bc12d0e65c80a6d2b453fece34facc9ac3caed14aa3bc7578166bb08c5bc9719e5a2267ae14e0b42da393f4d86f6d5829061"
BETA_NODE_PORT="30305"
BETA_AUTHRPC_PORT="8553"

GAMMA_ADDRESS="41293c2032bac60aa747374e966f79f575d42379"
GAMMA_ADDRESS_JSON_FILE_NAME="UTC--2021-03-01T02-12-42.714340074Z--41293c2032bac60aa747374e966f79f575d42379"
GAMMA_ADDRESS_JSON='{"address":"41293c2032bac60aa747374e966f79f575d42379","crypto":{"cipher":"aes-128-ctr","ciphertext":"5191719067513511b07d959de1a86cd37c3f7011dce75f62c791114c3a62b15b","cipherparams":{"iv":"cdfcd9e475f2af7df08a8a36cc0de976"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"5630591da82b8517f1b8f61719fbb552e41f25861cc20bc4671a11a47b427d31"},"mac":"d13259851d78deb70d1273ab151d4a12583b94f5cbdf31d86f02bb549d241d36"},"id":"235ba177-e32c-4d23-8d94-a57bc04b97ca","version":3}'
GAMMA_NODE_KEY="9e102b8ba8cad4c6b9db6c881915d3f1bb206e76113266bf48266de0474844fd"
GAMMA_ENODE="b1c14deee09b9d5549c90b7b30a35c812a56bf6afea5873b05d7a1bcd79c7b0848bcfa982faf80cc9e758a3a0d9b470f0a002840d365050fd5bf45052a6ec313"
GAMMA_NODE_PORT="30306"
GAMMA_AUTHRPC_PORT="8554"

DELTA_ADDRESS="d12ab7cf72ccf1f3882ec99ddc53cd415635c3be"
DELTA_ADDRESS_JSON_FILE_NAME="UTC--2021-03-01T02-31-13.365402148Z--d12ab7cf72ccf1f3882ec99ddc53cd415635c3be"
DELTA_ADDRESS_JSON='{"address":"d12ab7cf72ccf1f3882ec99ddc53cd415635c3be","crypto":{"cipher":"aes-128-ctr","ciphertext":"a0e9a3da5d0c88c922b5d7e817693552fe17dfd4c598e2a8b08ee53a706a8ffc","cipherparams":{"iv":"28b0a443403b7a02001f07a35724f6e6"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"f790f584bf396cacc06f28201aa697825011e84f570759d6108e20c5ee4fffce"},"mac":"529318e5eec2474221912d01e5a534a0b1dbfb19499ffaf942be6375611caa83"},"id":"d8670e33-8094-45b7-9386-d936e6bf4c1b","version":3}'
DELTA_NODE_KEY="725394672587b34bbf15580c59e5199c75c2c7e998ba8df3cb38cc4347d46e2b"
DELTA_ENODE="ca414c361d1a38716170923e4900d9dc9203dbaf8fdcaee73e1f861df9fdf20a1453b76fd218c18bc6f3c7e13cbca0b3416af02a53b8e31188faa45aab398d1c"
DELTA_NODE_PORT="30307"
DELTA_AUTHRPC_PORT="8555"
export DELTA_HTTP_PORT="38556"
export DELTA_WS_PORT="38557"

# TESTING_ADDRESS is used by the client's internal node.
TESTING_ADDRESS="b6de8bb5ed28e6be6d671975cad20c03931be981"
SIMNET_TOKEN_ADDRESS="946dfaB1AD7caCFeF77dE70ea68819a30acD4577"
ETH_SWAP_V0="608060405234801561001057600080fd5b50610b7a806100206000396000f3fe6080604052600436106100555760003560e01c80637249fbb61461005a57806376467cbd1461007c578063a8793f94146100b2578063d0f761c0146100c5578063eb84e7f2146100f5578063f4fd17f914610171575b600080fd5b34801561006657600080fd5b5061007a610075366004610871565b610191565b005b34801561008857600080fd5b5061009c610097366004610871565b6102c9565b6040516100a991906108c2565b60405180910390f35b61007a6100c0366004610927565b6103a4565b3480156100d157600080fd5b506100e56100e0366004610871565b61059b565b60405190151581526020016100a9565b34801561010157600080fd5b5061015e610110366004610871565b60006020819052908152604090208054600182015460028301546003840154600485015460059095015493949293919290916001600160a01b0391821691811690600160a01b900460ff1687565b6040516100a9979695949392919061099c565b34801561017d57600080fd5b5061007a61018c3660046109e8565b6105e3565b3233146101b95760405162461bcd60e51b81526004016101b090610a4b565b60405180910390fd5b6101c28161059b565b6101ff5760405162461bcd60e51b815260206004820152600e60248201526d6e6f7420726566756e6461626c6560901b60448201526064016101b0565b60008181526020819052604080822060058101805460ff60a01b1916600360a01b1790556004810154600182015492519193926001600160a01b03909116918381818185875af1925050503d8060008114610276576040519150601f19603f3d011682016040523d82523d6000602084013e61027b565b606091505b50909150506001811515146102c45760405162461bcd60e51b815260206004820152600f60248201526e1d1c985b9cd9995c8819985a5b1959608a1b60448201526064016101b0565b505050565b6103066040805160e081018252600080825260208201819052918101829052606081018290526080810182905260a081018290529060c082015290565b60008281526020818152604091829020825160e08101845281548152600182015492810192909252600281015492820192909252600380830154606083015260048301546001600160a01b039081166080840152600584015490811660a084015291929160c0840191600160a01b90910460ff169081111561038a5761038a61088a565b600381111561039b5761039b61088a565b90525092915050565b3233146103c35760405162461bcd60e51b81526004016101b090610a4b565b6000805b8281101561056157368484838181106103e2576103e2610a75565b9050608002019050600080600083602001358152602001908152602001600020905060008260600135116104405760405162461bcd60e51b81526020600482015260056024820152640c081d985b60da1b60448201526064016101b0565b81356104825760405162461bcd60e51b815260206004820152601160248201527003020726566756e6454696d657374616d7607c1b60448201526064016101b0565b60006005820154600160a01b900460ff1660038111156104a4576104a461088a565b146104dc5760405162461bcd60e51b8152602060048201526008602482015267064757020737761760c41b60448201526064016101b0565b436002820155813560038201556004810180546001600160a01b0319163317905561050d6060830160408401610a8b565b6005820180546060850135600185018190556001600160a01b03939093166001600160a81b031990911617600160a01b17905561054a9085610aca565b93505050808061055990610ae3565b9150506103c7565b503481146102c45760405162461bcd60e51b8152602060048201526007602482015266189859081d985b60ca1b60448201526064016101b0565b600081815260208190526040812060016005820154600160a01b900460ff1660038111156105cb576105cb61088a565b1480156105dc575080600301544210155b9392505050565b3233146106025760405162461bcd60e51b81526004016101b090610a4b565b6000805b828110156107da573684848381811061062157610621610a75565b6020604091820293909301838101356000908152938490529220919250600190506005820154600160a01b900460ff1660038111156106625761066261088a565b1461069b5760405162461bcd60e51b815260206004820152600960248201526862616420737461746560b81b60448201526064016101b0565b60058101546001600160a01b031633146106e95760405162461bcd60e51b815260206004820152600f60248201526e189859081c185c9d1a58da5c185b9d608a1b60448201526064016101b0565b81602001356002836000013560405160200161070791815260200190565b60408051601f198184030181529082905261072191610afc565b602060405180830381855afa15801561073e573d6000803e3d6000fd5b5050506040513d601f19601f820116820180604052508101906107619190610b2b565b1461079b5760405162461bcd60e51b815260206004820152600a602482015269189859081cd958dc995d60b21b60448201526064016101b0565b60058101805460ff60a01b1916600160a11b1790558135815560018101546107c39085610aca565b9350505080806107d290610ae3565b915050610606565b50604051600090339083908381818185875af1925050503d806000811461081d576040519150601f19603f3d011682016040523d82523d6000602084013e610822565b606091505b509091505060018115151461086b5760405162461bcd60e51b815260206004820152600f60248201526e1d1c985b9cd9995c8819985a5b1959608a1b60448201526064016101b0565b50505050565b60006020828403121561088357600080fd5b5035919050565b634e487b7160e01b600052602160045260246000fd5b600481106108be57634e487b7160e01b600052602160045260246000fd5b9052565b600060e08201905082518252602083015160208301526040830151604083015260608301516060830152608083015160018060a01b0380821660808501528060a08601511660a0850152505060c083015161092060c08401826108a0565b5092915050565b6000806020838503121561093a57600080fd5b823567ffffffffffffffff8082111561095257600080fd5b818501915085601f83011261096657600080fd5b81358181111561097557600080fd5b8660208260071b850101111561098a57600080fd5b60209290920196919550909350505050565b8781526020810187905260408101869052606081018590526001600160a01b038481166080830152831660a082015260e081016109dc60c08301846108a0565b98975050505050505050565b600080602083850312156109fb57600080fd5b823567ffffffffffffffff80821115610a1357600080fd5b818501915085601f830112610a2757600080fd5b813581811115610a3657600080fd5b8660208260061b850101111561098a57600080fd5b60208082526010908201526f39b2b73232b910109e9037b934b3b4b760811b604082015260600190565b634e487b7160e01b600052603260045260246000fd5b600060208284031215610a9d57600080fd5b81356001600160a01b03811681146105dc57600080fd5b634e487b7160e01b600052601160045260246000fd5b80820180821115610add57610add610ab4565b92915050565b600060018201610af557610af5610ab4565b5060010190565b6000825160005b81811015610b1d5760208186018101518583015201610b03565b506000920191825250919050565b600060208284031215610b3d57600080fd5b505191905056fea2646970667358221220d288c9a18362adf67607179f5c8585d0abe014bdb904b6e878451ac0c393a04364736f6c63430008120033"
ERC20_SWAP_V0="60a060405234801561001057600080fd5b50604051610e92380380610e9283398101604081905261002f91610040565b6001600160a01b0316608052610070565b60006020828403121561005257600080fd5b81516001600160a01b038116811461006957600080fd5b9392505050565b608051610df361009f6000396000818160c50152818161029b0152818161066b01526109f30152610df36000f3fe608060405234801561001057600080fd5b506004361061007d5760003560e01c8063a8793f941161005b578063a8793f94146100ff578063d0f761c014610112578063eb84e7f214610135578063f4fd17f9146101a457600080fd5b80637249fbb61461008257806376467cbd146100975780638c8e8fee146100c0575b600080fd5b610095610090366004610ac8565b6101b7565b005b6100aa6100a5366004610ac8565b610376565b6040516100b79190610b19565b60405180910390f35b6100e77f000000000000000000000000000000000000000000000000000000000000000081565b6040516001600160a01b0390911681526020016100b7565b61009561010d366004610b7e565b610451565b610125610120366004610ac8565b61074c565b60405190151581526020016100b7565b610191610143366004610ac8565b60006020819052908152604090208054600182015460028301546003840154600485015460059095015493949293919290916001600160a01b0391821691811690600160a01b900460ff1687565b6040516100b79796959493929190610bf3565b6100956101b2366004610c3f565b6107ac565b3233146101df5760405162461bcd60e51b81526004016101d690610ca2565b60405180910390fd5b6101e88161074c565b6102255760405162461bcd60e51b815260206004820152600e60248201526d6e6f7420726566756e6461626c6560901b60448201526064016101d6565b60008181526020818152604080832060058101805460ff60a01b1916600360a01b17905560018101548251336024820152604480820192909252835180820390920182526064018352928301805163a9059cbb60e01b6001600160e01b0390911617905290519092916060916001600160a01b037f000000000000000000000000000000000000000000000000000000000000000016916102c591610ccc565b6000604051808303816000865af19150503d8060008114610302576040519150601f19603f3d011682016040523d82523d6000602084013e610307565b606091505b5090925090508180156103325750805115806103325750808060200190518101906103329190610cfb565b6103705760405162461bcd60e51b815260206004820152600f60248201526e1d1c985b9cd9995c8819985a5b1959608a1b60448201526064016101d6565b50505050565b6103b36040805160e081018252600080825260208201819052918101829052606081018290526080810182905260a081018290529060c082015290565b60008281526020818152604091829020825160e08101845281548152600182015492810192909252600281015492820192909252600380830154606083015260048301546001600160a01b039081166080840152600584015490811660a084015291929160c0840191600160a01b90910460ff169081111561043757610437610ae1565b600381111561044857610448610ae1565b90525092915050565b3233146104705760405162461bcd60e51b81526004016101d690610ca2565b6000805b82811015610615573684848381811061048f5761048f610d1d565b9050608002019050600080600083602001358152602001908152602001600020905060008260600135116104ed5760405162461bcd60e51b81526020600482015260056024820152640c081d985b60da1b60448201526064016101d6565b813561052f5760405162461bcd60e51b815260206004820152601160248201527003020726566756e6454696d657374616d7607c1b60448201526064016101d6565b60006005820154600160a01b900460ff16600381111561055157610551610ae1565b146105905760405162461bcd60e51b815260206004820152600f60248201526e0c8eae040e6cac6e4cae840d0c2e6d608b1b60448201526064016101d6565b436002820155813560038201556004810180546001600160a01b031916331790556105c16060830160408401610d33565b6005820180546060850135600185018190556001600160a01b03939093166001600160a81b031990911617600160a01b1790556105fe9085610d72565b93505050808061060d90610d8b565b915050610474565b5060408051336024820152306044820152606480820184905282518083039091018152608490910182526020810180516001600160e01b03166323b872dd60e01b17905290516000916060916001600160a01b037f0000000000000000000000000000000000000000000000000000000000000000169161069591610ccc565b6000604051808303816000865af19150503d80600081146106d2576040519150601f19603f3d011682016040523d82523d6000602084013e6106d7565b606091505b5090925090508180156107025750805115806107025750808060200190518101906107029190610cfb565b6107455760405162461bcd60e51b81526020600482015260146024820152731d1c985b9cd9995c88199c9bdb4819985a5b195960621b60448201526064016101d6565b5050505050565b600081815260208190526040812060016005820154600160a01b900460ff16600381111561077c5761077c610ae1565b148015610795575060048101546001600160a01b031633145b80156107a5575080600301544210155b9392505050565b3233146107cb5760405162461bcd60e51b81526004016101d690610ca2565b6000805b828110156109a357368484838181106107ea576107ea610d1d565b6020604091820293909301838101356000908152938490529220919250600190506005820154600160a01b900460ff16600381111561082b5761082b610ae1565b146108645760405162461bcd60e51b815260206004820152600960248201526862616420737461746560b81b60448201526064016101d6565b60058101546001600160a01b031633146108b25760405162461bcd60e51b815260206004820152600f60248201526e189859081c185c9d1a58da5c185b9d608a1b60448201526064016101d6565b8160200135600283600001356040516020016108d091815260200190565b60408051601f19818403018152908290526108ea91610ccc565b602060405180830381855afa158015610907573d6000803e3d6000fd5b5050506040513d601f19601f8201168201806040525081019061092a9190610da4565b146109645760405162461bcd60e51b815260206004820152600a602482015269189859081cd958dc995d60b21b60448201526064016101d6565b60058101805460ff60a01b1916600160a11b17905581358155600181015461098c9085610d72565b93505050808061099b90610d8b565b9150506107cf565b5060408051336024820152604480820184905282518083039091018152606490910182526020810180516001600160e01b031663a9059cbb60e01b17905290516000916060916001600160a01b037f00000000000000000000000000000000000000000000000000000000000000001691610a1d91610ccc565b6000604051808303816000865af19150503d8060008114610a5a576040519150601f19603f3d011682016040523d82523d6000602084013e610a5f565b606091505b509092509050818015610a8a575080511580610a8a575080806020019051810190610a8a9190610cfb565b6107455760405162461bcd60e51b815260206004820152600f60248201526e1d1c985b9cd9995c8819985a5b1959608a1b60448201526064016101d6565b600060208284031215610ada57600080fd5b5035919050565b634e487b7160e01b600052602160045260246000fd5b60048110610b1557634e487b7160e01b600052602160045260246000fd5b9052565b600060e08201905082518252602083015160208301526040830151604083015260608301516060830152608083015160018060a01b0380821660808501528060a08601511660a0850152505060c0830151610b7760c0840182610af7565b5092915050565b60008060208385031215610b9157600080fd5b823567ffffffffffffffff80821115610ba957600080fd5b818501915085601f830112610bbd57600080fd5b813581811115610bcc57600080fd5b8660208260071b8501011115610be157600080fd5b60209290920196919550909350505050565b8781526020810187905260408101869052606081018590526001600160a01b038481166080830152831660a082015260e08101610c3360c0830184610af7565b98975050505050505050565b60008060208385031215610c5257600080fd5b823567ffffffffffffffff80821115610c6a57600080fd5b818501915085601f830112610c7e57600080fd5b813581811115610c8d57600080fd5b8660208260061b8501011115610be157600080fd5b60208082526010908201526f39b2b73232b910109e9037b934b3b4b760811b604082015260600190565b6000825160005b81811015610ced5760208186018101518583015201610cd3565b506000920191825250919050565b600060208284031215610d0d57600080fd5b815180151581146107a557600080fd5b634e487b7160e01b600052603260045260246000fd5b600060208284031215610d4557600080fd5b81356001600160a01b03811681146107a557600080fd5b634e487b7160e01b600052601160045260246000fd5b80820180821115610d8557610d85610d5c565b92915050565b600060018201610d9d57610d9d610d5c565b5060010190565b600060208284031215610db657600080fd5b505191905056fea2646970667358221220a055a4890a5ecf3876dbee91dfbeb46ba11b5f7c09b6d935173932d93f8fb92264736f6c63430008120033"
TEST_TOKEN="608060405234801561001057600080fd5b506040805180820190915260098152682a32b9ba2a37b5b2b760b91b602082015260039061003e90826101f5565b506040805180820190915260038152621514d560ea1b602082015260049061006690826101f5565b506909513ea9de0243800000600255600060208190526902544faa778090e000007f7d4921c2bc32c0110a31d16f4efb43c7a1228f1df7af765f608241dee5c62ebc8190557f59603491850c7d11499afe95b334ccfd92b48b36a15df31ef59ff5813fe370828190557f963f2e057cac0b71a4b8cff76a0e66200ffc6cc5498c1198bc1df3cb2bf751dc8190557fbc10d5a0a531ecf97938db2df6f3f5b59678ae655bd09be1d358f605f79153d481905573d12ab7cf72ccf1f3882ec99ddc53cd415635c3be9091527f5bd8dfce2dbb581d0922a094c40bab2f7d2f0ea9aaf275bf0fcc0f027a2ff91d556102b4565b634e487b7160e01b600052604160045260246000fd5b600181811c9082168061018057607f821691505b6020821081036101a057634e487b7160e01b600052602260045260246000fd5b50919050565b601f8211156101f057600081815260208120601f850160051c810160208610156101cd5750805b601f850160051c820191505b818110156101ec578281556001016101d9565b5050505b505050565b81516001600160401b0381111561020e5761020e610156565b6102228161021c845461016c565b846101a6565b602080601f831160018114610257576000841561023f5750858301515b600019600386901b1c1916600185901b1785556101ec565b600085815260208120601f198616915b8281101561028657888601518255948401946001909101908401610267565b50858210156102a45787850151600019600388901b60f8161c191681555b5050505050600190811b01905550565b61078b806102c36000396000f3fe608060405234801561001057600080fd5b506004361061009e5760003560e01c806370a082311161006657806370a08231146101185780638ba4cc3c1461014157806395d89b4114610156578063a9059cbb1461015e578063dd62ed3e1461017157600080fd5b806306fdde03146100a3578063095ea7b3146100c157806318160ddd146100e457806323b872dd146100f6578063313ce56714610109575b600080fd5b6100ab6101aa565b6040516100b891906105d5565b60405180910390f35b6100d46100cf36600461063f565b61023c565b60405190151581526020016100b8565b6002545b6040519081526020016100b8565b6100d4610104366004610669565b610253565b604051601281526020016100b8565b6100e86101263660046106a5565b6001600160a01b031660009081526020819052604090205490565b61015461014f36600461063f565b610302565b005b6100ab61034a565b6100d461016c36600461063f565b610359565b6100e861017f3660046106c7565b6001600160a01b03918216600090815260016020908152604080832093909416825291909152205490565b6060600380546101b9906106fa565b80601f01602080910402602001604051908101604052809291908181526020018280546101e5906106fa565b80156102325780601f1061020757610100808354040283529160200191610232565b820191906000526020600020905b81548152906001019060200180831161021557829003601f168201915b5050505050905090565b6000610249338484610366565b5060015b92915050565b6000610260848484610455565b6001600160a01b0384166000908152600160209081526040808320338452909152902054828110156102ea5760405162461bcd60e51b815260206004820152602860248201527f45524332303a207472616e7366657220616d6f756e74206578636565647320616044820152676c6c6f77616e636560c01b60648201526084015b60405180910390fd5b6102f78533858403610366565b506001949350505050565b80600260008282546103149190610734565b90915550506001600160a01b03821660009081526020819052604081208054839290610341908490610734565b90915550505050565b6060600480546101b9906106fa565b6000610249338484610455565b6001600160a01b0383166103c85760405162461bcd60e51b8152602060048201526024808201527f45524332303a20617070726f76652066726f6d20746865207a65726f206164646044820152637265737360e01b60648201526084016102e1565b6001600160a01b0382166104295760405162461bcd60e51b815260206004820152602260248201527f45524332303a20617070726f766520746f20746865207a65726f206164647265604482015261737360f01b60648201526084016102e1565b6001600160a01b0392831660009081526001602090815260408083209490951682529290925291902055565b6001600160a01b0383166104b95760405162461bcd60e51b815260206004820152602560248201527f45524332303a207472616e736665722066726f6d20746865207a65726f206164604482015264647265737360d81b60648201526084016102e1565b6001600160a01b03821661051b5760405162461bcd60e51b815260206004820152602360248201527f45524332303a207472616e7366657220746f20746865207a65726f206164647260448201526265737360e81b60648201526084016102e1565b6001600160a01b038316600090815260208190526040902054818110156105935760405162461bcd60e51b815260206004820152602660248201527f45524332303a207472616e7366657220616d6f756e7420657863656564732062604482015265616c616e636560d01b60648201526084016102e1565b6001600160a01b038085166000908152602081905260408082208585039055918516815290812080548492906105ca908490610734565b909155505050505050565b600060208083528351808285015260005b81811015610602578581018301518582016040015282016105e6565b506000604082860101526040601f19601f8301168501019250505092915050565b80356001600160a01b038116811461063a57600080fd5b919050565b6000806040838503121561065257600080fd5b61065b83610623565b946020939093013593505050565b60008060006060848603121561067e57600080fd5b61068784610623565b925061069560208501610623565b9150604084013590509250925092565b6000602082840312156106b757600080fd5b6106c082610623565b9392505050565b600080604083850312156106da57600080fd5b6106e383610623565b91506106f160208401610623565b90509250929050565b600181811c9082168061070e57607f821691505b60208210810361072e57634e487b7160e01b600052602260045260246000fd5b50919050565b8082018082111561024d57634e487b7160e01b600052601160045260246000fdfea2646970667358221220aa979a775ca051b15215b50a2b6c3bd6ed2e1fa78ba3f75335032e582027830c64736f6c63430008120033"

# PASSWORD is the password used to unlock all accounts/wallets/addresses.
PASSWORD="abc"

export NODES_ROOT=~/dextest/eth
export GENESIS_JSON_FILE_LOCATION="${NODES_ROOT}/genesis.json"

if [ -d "${NODES_ROOT}" ]; then
  rm -R "${NODES_ROOT}"
fi

mkdir -p "${NODES_ROOT}/alpha"
mkdir -p "${NODES_ROOT}/beta"
mkdir -p "${NODES_ROOT}/harness-ctl"

echo "Writing ctl scripts"
################################################################################
# Control Scripts
################################################################################

# Write genesis json. ".*Block" fields represent block height where certain
# protocols take effect. "clique" is our proof of authority scheme. One block
# can be mined per second with a signature belonging to the address in
# "extradata". The addresses in the "alloc" field are allocated "balance".
# Values are in wei. 1*10^18 wei is equal to one eth. Addresses are allocated
# 11,000 eth. The addresses belong to alpha and beta nodes and two others are
# used in tests.
cat > "${NODES_ROOT}/genesis.json" <<EOF
{
  "config": {
    "chainId": 42,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "muirGlacierBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0,
    "arrowGlacierBlock": 0,
    "grayGlacierBlock": 0,
    "mergeNetSplitBlock": 0,
    "shanghaiBlock": 0,
    "cancunBlock": 0,
    "clique": {
      "period": 1,
      "epoch": 30000
    }
  },
  "difficulty": "1",
  "gasLimit": "30000000",
  "extradata": "0x00000000000000000000000000000000000000000000000000000000000000009ebba10a6136607688ca4f27fab70e23938cd0270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  "alloc": {
    "18d65fb8d60c1199bb1ad381be47aa692b482605": {
        "balance": "26000000000000000000000"
    },
    "4f8ef3892b65ed7fc356ff473a2ef2ae5ec27a06": {
        "balance": "11000000000000000000000"
    },
    "dd93b447f7eBCA361805eBe056259853F3912E04": {
        "balance": "11000000000000000000000"
    },
    "1D4F2ee206474B136Af4868B887C7b166693c194": {
        "balance": "11000000000000000000000"
    },
    "946dfaB1AD7caCFeF77dE70ea68819a30acD4577": {
        "balance": "11000000000000000000000"
    },
    "3e983c7e08d22CaB842Bd54111087E09C578b3c3": {
        "balance": "11000000000000000000000"
    },
    "653445e4C2f48B370fE10e59940E5e9Cb853D03F": {
        "balance": "11000000000000000000000"
    }
  }
}
EOF

cat > "${NODES_ROOT}/harness-ctl/send.js" <<EOF
function send(from, to, value) {
  from = from.startsWith('0x') ? from : '0x' + from
  to = to.startsWith('0x') ? to : '0x' + to
  return personal.sendTransaction({ from, to, value, gasPrice: 82000000000 }, "${PASSWORD}")
}
EOF

cat > "${NODES_ROOT}/harness-ctl/sendtoaddress" <<EOF
#!/usr/bin/env bash
"${NODES_ROOT}/harness-ctl/alpha" "attach --preload ${NODES_ROOT}/harness-ctl/send.js --exec send(\"${ALPHA_ADDRESS}\",\"\$1\",\$2*1e18)"
EOF
chmod +x "${NODES_ROOT}/harness-ctl/sendtoaddress"

cat > "${NODES_ROOT}/harness-ctl/deploy.js" <<EOF
function deploy(from, contract) {
  tx = personal.sendTransaction({from:"0x"+from,data:"0x"+contract,gasPrice:82000000000}, "${PASSWORD}")
  return tx;
}

function deployERC20Swap(from, contract, tokenAddr) {
  if (tokenAddr.slice(0, 2) === "0x") {
    tokenAddr = tokenAddr.slice(2)
  }
  var paddedAddr = tokenAddr.padStart(64, "0")
  tx = personal.sendTransaction({from:"0x"+from,data:"0x"+contract+paddedAddr,gasPrice:82000000000}, "${PASSWORD}")
  return tx;
}
EOF

cat > "${NODES_ROOT}/harness-ctl/contractAddress.js" <<EOF
function contractAddress(tx) {
  addr = eth.getTransactionReceipt(tx).contractAddress
  return addr;
}
EOF

# Add node script.
HARNESS_DIR=$(dirname "$0")
cp "${HARNESS_DIR}/create-node.sh" "${NODES_ROOT}/harness-ctl/create-node"

# Reorg script
cat > "${NODES_ROOT}/harness-ctl/reorg" <<EOF
#!/usr/bin/env bash
REORG_NODE="alpha"
VALID_NODE="beta"
REORG_DEPTH=2

if [ "\$1" = "beta" ]; then
  REORG_NODE="beta"
  VALID_NODE="alpha"
fi

if [ "\$2" != "" ]; then
  REORG_DEPTH=\$2
fi

echo "Before alpha, beta best blocks"
./alpha attach --exec 'eth.getBlock(eth.blockNumber)'
./beta attach --exec 'eth.getBlock(eth.blockNumber)'


NODES=('alpha' 'beta')
ENODES=($ALPHA_ENODE $BETA_ENODE)
PORTS=($ALPHA_NODE_PORT $BETA_NODE_PORT)

echo "Disconnecting nodes"
for node in "\${NODES[@]}"
do
for i in {0..1}
  do
    "./\$node" "attach --exec admin.removePeer('enode://\${ENODES[i]}@127.0.0.1:\${PORTS[i]}')"
  done
done

sleep 1

# Uncomment to see the effect of reorgs on transactions.
# "./alpha" "attach --exec personal.sendTransaction({from:eth.accounts[0],to:eth.accounts[1],value:1,gasPrice:82000000000},\\"${PASSWORD}\\")"
# "./beta" "attach --exec personal.sendTransaction({from:eth.accounts[0],to:eth.accounts[1],value:1,gasPrice:82000000000},\\"${PASSWORD}\\")"

"./mine-\$VALID_NODE" \$((REORG_DEPTH + 2))
"./mine-\$REORG_NODE" \$REORG_DEPTH

sleep 1

echo "Connecting nodes"
for node in "\${NODES[@]}"
do
for i in {0..1}
  do
    "./\$node" "attach --exec admin.addPeer('enode://\${ENODES[i]}@127.0.0.1:\${PORTS[i]}')"
  done
done

sleep 1

echo "After alpha, beta best blocks"
./alpha attach --exec 'eth.getBlock(eth.blockNumber)'
./beta attach --exec 'eth.getBlock(eth.blockNumber)'
EOF
chmod +x "${NODES_ROOT}/harness-ctl/reorg"

# Shutdown script
cat > "${NODES_ROOT}/harness-ctl/quit" <<EOF
#!/usr/bin/env bash
tmux send-keys -t $SESSION:1 C-c
tmux send-keys -t $SESSION:2 C-c
tmux kill-session
EOF
chmod +x "${NODES_ROOT}/harness-ctl/quit"

################################################################################
# Start harness
################################################################################

echo "Starting harness"
tmux new-session -d -s $SESSION "${SHELL}"
tmux rename-window -t $SESSION:0 'harness-ctl'
tmux send-keys -t $SESSION:0 "set +o history" C-m
tmux send-keys -t $SESSION:0 "cd ${NODES_ROOT}/harness-ctl" C-m

################################################################################
# Eth nodes
################################################################################

echo "Starting simnet alpha node"
"${HARNESS_DIR}/create-node.sh" "$SESSION:1" "alpha" "$ALPHA_NODE_PORT" \
	"$CHAIN_ADDRESS" "$PASSWORD" "$CHAIN_ADDRESS_JSON" \
	"$CHAIN_ADDRESS_JSON_FILE_NAME" "$ALPHA_ADDRESS_JSON" "$ALPHA_ADDRESS_JSON_FILE_NAME" \
	"$ALPHA_NODE_KEY" "snap" "$ALPHA_AUTHRPC_PORT"

echo "Starting simnet beta node"
"${HARNESS_DIR}/create-node.sh" "$SESSION:2" "beta" "$BETA_NODE_PORT" \
	"$CHAIN_ADDRESS" "$PASSWORD" "$CHAIN_ADDRESS_JSON" \
	"$CHAIN_ADDRESS_JSON_FILE_NAME" "$BETA_ADDRESS_JSON" "$BETA_ADDRESS_JSON_FILE_NAME" \
	"$BETA_NODE_KEY" "snap" "$BETA_AUTHRPC_PORT"

echo "Starting simnet gamma node"
"${HARNESS_DIR}/create-node.sh" "$SESSION:3" "gamma" "$GAMMA_NODE_PORT" \
	"_" "_" "_" "_" "$GAMMA_ADDRESS_JSON" "$GAMMA_ADDRESS_JSON_FILE_NAME" \
	"$GAMMA_NODE_KEY" "light" "$GAMMA_AUTHRPC_PORT"

echo "Starting simnet delta node"
"${HARNESS_DIR}/create-node.sh" "$SESSION:4" "delta" "$DELTA_NODE_PORT" \
	"_" "_" "_" "_" "$DELTA_ADDRESS_JSON" "$DELTA_ADDRESS_JSON_FILE_NAME" \
	"$DELTA_NODE_KEY" "light" "$DELTA_AUTHRPC_PORT"

sleep 1

# NOTE: Connecting a node will add for both. Also, light nodes take longer to
# set up. They will show 0 peers for some amount of time even after adding here.
echo "Connecting nodes"
"${NODES_ROOT}/harness-ctl/alpha" "attach --exec admin.addPeer('enode://${BETA_ENODE}@127.0.0.1:$BETA_NODE_PORT')"
"${NODES_ROOT}/harness-ctl/alpha" "attach --exec admin.addPeer('enode://${GAMMA_ENODE}@127.0.0.1:$GAMMA_NODE_PORT')"
"${NODES_ROOT}/harness-ctl/alpha" "attach --exec admin.addPeer('enode://${DELTA_ENODE}@127.0.0.1:$DELTA_NODE_PORT')"
"${NODES_ROOT}/harness-ctl/beta" "attach --exec admin.addPeer('enode://${GAMMA_ENODE}@127.0.0.1:$GAMMA_NODE_PORT')"
"${NODES_ROOT}/harness-ctl/beta" "attach --exec admin.addPeer('enode://${DELTA_ENODE}@127.0.0.1:$DELTA_NODE_PORT')"
"${NODES_ROOT}/harness-ctl/gamma" "attach --exec admin.addPeer('enode://${DELTA_ENODE}@127.0.0.1:$DELTA_NODE_PORT')"

echo "Mining some blocks"
# NOTE: These first couple of blocks will cause a reorg on one node or the
# other. The reason is unknown. It seems this initial mining and reorg is
# necessary for nodes to start communicating.
"${NODES_ROOT}/harness-ctl/mine-beta" "2"
"${NODES_ROOT}/harness-ctl/mine-alpha" "2"

SEND_AMT=5000000000000000000000
echo "Sending 5000 eth to delta and gamma and testing."
"${NODES_ROOT}/harness-ctl/alpha" "attach --preload ${NODES_ROOT}/harness-ctl/send.js --exec send(\"${ALPHA_ADDRESS}\",\"${GAMMA_ADDRESS}\",${SEND_AMT})"
"${NODES_ROOT}/harness-ctl/alpha" "attach --preload ${NODES_ROOT}/harness-ctl/send.js --exec send(\"${ALPHA_ADDRESS}\",\"${DELTA_ADDRESS}\",${SEND_AMT})"
"${NODES_ROOT}/harness-ctl/alpha" "attach --preload ${NODES_ROOT}/harness-ctl/send.js --exec send(\"${ALPHA_ADDRESS}\",\"${TESTING_ADDRESS}\",${SEND_AMT})"

echo "Deploying ETHSwapV0 contract."
ETH_SWAP_CONTRACT_HASH=$("${NODES_ROOT}/harness-ctl/alpha" "attach --preload ${NODES_ROOT}/harness-ctl/deploy.js --exec deploy(\"${ALPHA_ADDRESS}\",\"${ETH_SWAP_V0}\")" | sed 's/"//g')

echo "Deploying TestToken contract."
TEST_TOKEN_CONTRACT_HASH=$("${NODES_ROOT}/harness-ctl/alpha" "attach --preload ${NODES_ROOT}/harness-ctl/deploy.js --exec deploy(\"${ALPHA_ADDRESS}\",\"${TEST_TOKEN}\")" | sed 's/"//g')

# Initial sync for light nodes takes quite a while. Wait for them to show
# blocks on the network.
while true
do
  N=$("${NODES_ROOT}/harness-ctl/gamma" "attach --exec eth.blockNumber")
  if [ "$N" -gt 0 ]; then
    break
  fi
  echo "Waiting for light nodes to sync."
  # Although not necessary here, mine while waiting so that transactions are
  # mined if not mined yet.
  "${NODES_ROOT}/harness-ctl/mine-beta" "5"
done

mine_pending_txs() {
  while true
  do
    TXSLEN=$("${NODES_ROOT}/harness-ctl/alpha" "attach --exec eth.pendingTransactions.length")
    if [ "$TXSLEN" -eq 0 ]; then
      break
    fi
    echo "Waiting for transactions to be mined."
    "${NODES_ROOT}/harness-ctl/mine-alpha" "5"
  done
}

mine_pending_txs

ETH_SWAP_CONTRACT_ADDR=$("${NODES_ROOT}/harness-ctl/alpha" "attach --preload ${NODES_ROOT}/harness-ctl/contractAddress.js --exec contractAddress(\"${ETH_SWAP_CONTRACT_HASH}\")" | sed 's/"//g')
echo "ETH SWAP contract address is ${ETH_SWAP_CONTRACT_ADDR}. Saving to ${NODES_ROOT}/eth_swap_contract_address.txt"
cat > "${NODES_ROOT}/eth_swap_contract_address.txt" <<EOF
${ETH_SWAP_CONTRACT_ADDR}
EOF

TEST_TOKEN_CONTRACT_ADDR=$("${NODES_ROOT}/harness-ctl/alpha" "attach --preload ${NODES_ROOT}/harness-ctl/contractAddress.js --exec contractAddress(\"${TEST_TOKEN_CONTRACT_HASH}\")" | sed 's/"//g')
echo "Test Token contract address is ${TEST_TOKEN_CONTRACT_ADDR}. Saving to ${NODES_ROOT}/test_token_contract_address.txt"
cat > "${NODES_ROOT}/test_token_contract_address.txt" <<EOF
${TEST_TOKEN_CONTRACT_ADDR}
EOF

cat > "${NODES_ROOT}/harness-ctl/loadTestToken.js" <<EOF
    // This ABI comes from running 'solc --abi TestToken.sol'
    const testTokenABI = [{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"airdrop","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"}]
    testTokenABI.forEach((el) => {
        if (el.stateMutability === "view") {
            // the constant field was deprecated and the output from solc no
            // longer contains it, but the geth console version of web3 still
            // seems to require it.
            el.constant = true;
        }
    })
    var contract = web3.eth.contract(testTokenABI)
    var testToken = contract.at('${TEST_TOKEN_CONTRACT_ADDR}')
    web3.eth.defaultAccount = web3.eth.accounts.length > 1 ? web3.eth.accounts[1] : web3.eth.accounts[0]
    personal.unlockAccount(web3.eth.defaultAccount, '${PASSWORD}')

    function transfer (addr, val) {
      addr = addr.startsWith('0x') ? addr : '0x'+addr
      return testToken.transfer(addr, val*1e18)
    }
EOF

cat > "${NODES_ROOT}/harness-ctl/alphaWithToken.sh" <<EOF
  # The testToken variable will provide access to the deployed test token contract.
  ./alpha attach --preload loadTestToken.js
EOF
chmod +x "${NODES_ROOT}/harness-ctl/alphaWithToken.sh"

cat > "${NODES_ROOT}/harness-ctl/sendTokens" <<EOF
#!/usr/bin/env bash
./alpha attach --preload loadTestToken.js --exec "transfer(\"\$1\",\$2)"
EOF
chmod +x "${NODES_ROOT}/harness-ctl/sendTokens"

# ERC20Swap contract depends on the address of the test token contract, so this
# is deployed last.
echo "Deploying ERC20SwapV0 contract."
ERC20_SWAP_CONTRACT_HASH=$("${NODES_ROOT}/harness-ctl/alpha" "attach --preload ${NODES_ROOT}/harness-ctl/deploy.js --exec deployERC20Swap(\"${ALPHA_ADDRESS}\",\"${ERC20_SWAP_V0}\",\"${TEST_TOKEN_CONTRACT_ADDR}\")" | sed 's/"//g')

mine_pending_txs

ERC20_SWAP_CONTRACT_ADDR=$("${NODES_ROOT}/harness-ctl/alpha" "attach --preload ${NODES_ROOT}/harness-ctl/contractAddress.js --exec contractAddress(\"${ERC20_SWAP_CONTRACT_HASH}\")" | sed 's/"//g')
echo "ERC20 SWAP contract address is ${ERC20_SWAP_CONTRACT_ADDR}. Saving to ${NODES_ROOT}/erc20_swap_contract_address.txt"
cat > "${NODES_ROOT}/erc20_swap_contract_address.txt" <<EOF
${ERC20_SWAP_CONTRACT_ADDR}
EOF

cd "${NODES_ROOT}/harness-ctl"
TOKEN_SEND_AMT=5000
echo "Sending 5000 dextt.eth to testing."
"./sendTokens" "${SIMNET_TOKEN_ADDRESS}" "${TOKEN_SEND_AMT}"

mine_pending_txs

# Reenable history and attach to the control session.
tmux select-window -t $SESSION:0
tmux send-keys -t $SESSION:0 "set -o history" C-m
tmux attach-session -t $SESSION
