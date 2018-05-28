package de.hpi.armadillo;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import org.web3j.abi.EventEncoder;
import org.web3j.abi.TypeReference;
import org.web3j.abi.datatypes.Event;
import org.web3j.abi.datatypes.Function;
import org.web3j.abi.datatypes.Type;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameter;
import org.web3j.protocol.core.RemoteCall;
import org.web3j.protocol.core.methods.request.EthFilter;
import org.web3j.protocol.core.methods.response.Log;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.tx.Contract;
import org.web3j.tx.TransactionManager;
import rx.Observable;
import rx.functions.Func1;

/**
 * <p>Auto generated code.
 * <p><strong>Do not modify!</strong>
 * <p>Please use the <a href="https://docs.web3j.io/command_line.html">web3j command line tools</a>,
 * or the org.web3j.codegen.SolidityFunctionWrapperGenerator in the 
 * <a href="https://github.com/web3j/web3j/tree/master/codegen">codegen module</a> to update.
 *
 * <p>Generated with web3j version 3.4.0.
 */
public class OrchestrationContract extends Contract {
    private static final String BINARY = "6080604052348015600f57600080fd5b5060b28061001e6000396000f300608060405260043610603f576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806338e61a8d146044575b600080fd5b348015604f57600080fd5b5060566058565b005b7fcc7e2208aa463e96fdcbc4e2bee9be739e8397ddfe62470098ce6b9c050ce52760405160405180910390a15600a165627a7a72305820498b773ed150c6a01d36f663d92e9a66b80ce39480c15db3647e6b4d705c03280029";

    public static final String FUNC_TRIGGERORDER = "triggerOrder";

    public static final Event ORDER_EVENT = new Event("Order", 
            Arrays.<TypeReference<?>>asList(),
            Arrays.<TypeReference<?>>asList());
    ;

    protected OrchestrationContract(String contractAddress, Web3j web3j, Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    protected OrchestrationContract(String contractAddress, Web3j web3j, TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        super(BINARY, contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    public RemoteCall<TransactionReceipt> triggerOrder() {
        final Function function = new Function(
                FUNC_TRIGGERORDER, 
                Arrays.<Type>asList(), 
                Collections.<TypeReference<?>>emptyList());
        return executeRemoteCallTransaction(function);
    }

    public static RemoteCall<OrchestrationContract> deploy(Web3j web3j, Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        return deployRemoteCall(OrchestrationContract.class, web3j, credentials, gasPrice, gasLimit, BINARY, "");
    }

    public static RemoteCall<OrchestrationContract> deploy(Web3j web3j, TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        return deployRemoteCall(OrchestrationContract.class, web3j, transactionManager, gasPrice, gasLimit, BINARY, "");
    }

    public List<OrderEventResponse> getOrderEvents(TransactionReceipt transactionReceipt) {
        List<Contract.EventValuesWithLog> valueList = extractEventParametersWithLog(ORDER_EVENT, transactionReceipt);
        ArrayList<OrderEventResponse> responses = new ArrayList<OrderEventResponse>(valueList.size());
        for (Contract.EventValuesWithLog eventValues : valueList) {
            OrderEventResponse typedResponse = new OrderEventResponse();
            typedResponse.log = eventValues.getLog();
            responses.add(typedResponse);
        }
        return responses;
    }

    public Observable<OrderEventResponse> orderEventObservable(EthFilter filter) {
        return web3j.ethLogObservable(filter).map(new Func1<Log, OrderEventResponse>() {
            @Override
            public OrderEventResponse call(Log log) {
                Contract.EventValuesWithLog eventValues = extractEventParametersWithLog(ORDER_EVENT, log);
                OrderEventResponse typedResponse = new OrderEventResponse();
                typedResponse.log = log;
                return typedResponse;
            }
        });
    }

    public Observable<OrderEventResponse> orderEventObservable(DefaultBlockParameter startBlock, DefaultBlockParameter endBlock) {
        EthFilter filter = new EthFilter(startBlock, endBlock, getContractAddress());
        filter.addSingleTopic(EventEncoder.encode(ORDER_EVENT));
        return orderEventObservable(filter);
    }

    public static OrchestrationContract load(String contractAddress, Web3j web3j, Credentials credentials, BigInteger gasPrice, BigInteger gasLimit) {
        return new OrchestrationContract(contractAddress, web3j, credentials, gasPrice, gasLimit);
    }

    public static OrchestrationContract load(String contractAddress, Web3j web3j, TransactionManager transactionManager, BigInteger gasPrice, BigInteger gasLimit) {
        return new OrchestrationContract(contractAddress, web3j, transactionManager, gasPrice, gasLimit);
    }

    public static class OrderEventResponse {
        public Log log;
    }
}
