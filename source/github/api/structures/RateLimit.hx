package github.api.structures;

typedef RateLimit = {
	var resources:RateLimitResources;
	var rate:RateLimitInfos;
}

typedef RateLimitResources = {
	var core:RateLimitInfos;
	var ?graphql:RateLimitInfos;
	var search:RateLimitInfos;
	var ?code_search:RateLimitInfos;
	var ?source_import:RateLimitInfos;
	var ?integration_manifest:RateLimitInfos;
	var ?code_scanning_upload:RateLimitInfos;
	var ?actions_runner_registration:RateLimitInfos;
	var ?scim:RateLimitInfos;
	var ?dependency_snapshots:RateLimitInfos;
	var ?code_scanning_autofix:RateLimitInfos;
}

typedef RateLimitInfos = {
	var limit:Int;
	var remaining:Int;
	var reset:Int;
	var used:Int;
	var ?resource:String;
}