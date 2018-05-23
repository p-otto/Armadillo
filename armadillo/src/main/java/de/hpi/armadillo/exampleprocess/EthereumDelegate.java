package de.hpi.armadillo.exampleprocess;

import java.util.concurrent.ExecutionException;

import org.camunda.bpm.engine.delegate.DelegateExecution;
import org.camunda.bpm.engine.delegate.JavaDelegate;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.methods.response.Web3ClientVersion;
import org.web3j.protocol.http.HttpService;

public class EthereumDelegate implements JavaDelegate {
	
	// private static final Logger LOGGER = Logger.getLogger(EthereumDelegate.class.getName());
	
	
	public void execute(DelegateExecution delegateExecution) throws ExecutionException, InterruptedException {

		// String ethereumAdress = (String)delegateExecution.getVariable("ethereumAddress");
		// if (ethereumAdress == null || ethereumAdress.isEmpty()) {
		// 	ethereumAdress = "http://127.0.0.1:9545/";
		// }
		String ethereumAdress = "http://127.0.0.1:9545/";

		//LOGGER.info("Ethereum address: " + delegateExecution.getVariable("ethereumAddress"));
		
		Web3j web3 = Web3j.build(new HttpService(ethereumAdress));

		Web3ClientVersion web3ClientVersion = web3.web3ClientVersion().sendAsync().get();
		String clientVersion = web3ClientVersion.getWeb3ClientVersion();
		// LOGGER.info("Client version: " + clientVersion);
		System.out.println("Client version: " + clientVersion);
	}
}
