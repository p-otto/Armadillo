package de.hpi.armadillo.exampleprocess;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;

import de.hpi.armadillo.OrchestrationContract;
import org.apache.commons.lang3.StringUtils;
import org.camunda.bpm.engine.delegate.DelegateExecution;
import org.camunda.bpm.engine.delegate.JavaDelegate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.protocol.http.HttpService;

import static org.web3j.tx.Contract.GAS_LIMIT;
import static org.web3j.tx.ManagedTransaction.GAS_PRICE;

public class EthereumDelegate implements JavaDelegate {
	
	private static final Logger LOGGER = LoggerFactory.getLogger(EthereumDelegate.class);
	
	
	public void execute(DelegateExecution delegateExecution) throws Exception {
		
		String ethereumAddress = (String) delegateExecution.getVariable("ethereumAddress");
		String contractAddress = (String) delegateExecution.getVariable("contractAddress");
		if (StringUtils.isEmpty(ethereumAddress)) {
			ethereumAddress = "http://127.0.0.1:9545";
		}
		
		String privateKey = (String) delegateExecution.getVariable("privateKey");
		
		LOGGER.info("Ethereum address:\t\t" + ethereumAddress);
		LOGGER.info("Contract address:\t\t" + contractAddress);
		LOGGER.info("Private key:\t\t" + privateKey);
		
		Web3j web3j = Web3j.build(new HttpService(ethereumAddress));
		
		Credentials credentials = Credentials.create(privateKey);
		
		OrchestrationContract orchestrationContract = OrchestrationContract.load(
				contractAddress,
				web3j,
				credentials,
				GAS_PRICE, // TODO gas price and limit
				GAS_LIMIT
		);
		
		TransactionReceipt receipt = orchestrationContract.triggerOrder().send();
		
		LOGGER.info("Receipt:\t\t" + receipt.toString());
	}
}
