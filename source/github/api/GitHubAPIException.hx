package github.api;

import haxe.Exception;

class GitHubAPIException extends Exception {
	public var apiMessage:String;
	public var documentationUrl:String;

	public function new(apiMessage:String, documentationUrl:String) {
		super('[GitHubException] ${apiMessage} (Check ${documentationUrl})');
		this.apiMessage = apiMessage;
		this.documentationUrl = documentationUrl;
	}
}