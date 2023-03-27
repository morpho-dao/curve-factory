/* Autogenerated file. Do not edit manually. */

/* tslint:disable */

/* eslint-disable */
import type { PromiseOrValue } from "../../../common";
import type {
  MockBoostDelegationProxy,
  MockBoostDelegationProxyInterface,
} from "../../../testing/MockBoostDelegationProxy.vy/MockBoostDelegationProxy";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";

const _abi = [
  {
    stateMutability: "nonpayable",
    type: "constructor",
    inputs: [
      {
        name: "voting_escrow",
        type: "address",
      },
      {
        name: "_delegation",
        type: "address",
      },
    ],
    outputs: [],
  },
  {
    stateMutability: "view",
    type: "function",
    name: "adjusted_balance_of",
    inputs: [
      {
        name: "_addr",
        type: "address",
      },
    ],
    outputs: [
      {
        name: "",
        type: "uint256",
      },
    ],
  },
  {
    stateMutability: "nonpayable",
    type: "function",
    name: "set_delegation",
    inputs: [
      {
        name: "_delegation",
        type: "address",
      },
    ],
    outputs: [],
  },
  {
    stateMutability: "view",
    type: "function",
    name: "delegation",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
      },
    ],
  },
  {
    stateMutability: "view",
    type: "function",
    name: "voting_escrow",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
      },
    ],
  },
] as const;

const _bytecode =
  "0x604061013a61014039602061013a60c03960c05160a01c610135576020602061013a0160c03960c05160a01c61013557610160516000556101405160015561011d56600436101561000d576100d0565b600035601c52600051346100d65763bbf7408a8114156100805760043560a01c6100d6576000546100755760206101c060246370a08231610140526004356101605261015c6001545afa156100d657601f3d11156100d6576000506101c05160005260206000f35b604560005260206000f35b63f4b446a381141561009e5760043560a01c6100d657600435600055005b63df5cf7238114156100b65760005460005260206000f35b63dfe050318114156100ce5760015460005260206000f35b505b60006000fd5b600080fd5b61004261011d0361004260003961004261011d036000f35b600080fd";

type MockBoostDelegationProxyConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: MockBoostDelegationProxyConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class MockBoostDelegationProxy__factory extends ContractFactory {
  constructor(...args: MockBoostDelegationProxyConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    voting_escrow: PromiseOrValue<string>,
    _delegation: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<MockBoostDelegationProxy> {
    return super.deploy(
      voting_escrow,
      _delegation,
      overrides || {}
    ) as Promise<MockBoostDelegationProxy>;
  }
  override getDeployTransaction(
    voting_escrow: PromiseOrValue<string>,
    _delegation: PromiseOrValue<string>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(
      voting_escrow,
      _delegation,
      overrides || {}
    );
  }
  override attach(address: string): MockBoostDelegationProxy {
    return super.attach(address) as MockBoostDelegationProxy;
  }
  override connect(signer: Signer): MockBoostDelegationProxy__factory {
    return super.connect(signer) as MockBoostDelegationProxy__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): MockBoostDelegationProxyInterface {
    return new utils.Interface(_abi) as MockBoostDelegationProxyInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): MockBoostDelegationProxy {
    return new Contract(
      address,
      _abi,
      signerOrProvider
    ) as MockBoostDelegationProxy;
  }
}