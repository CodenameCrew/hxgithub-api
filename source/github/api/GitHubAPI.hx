package github.api;

import github.api.structures.*;
import haxe.Exception;
import haxe.Http;
import haxe.Json;

//@:nullSafety(Strict)
class GitHubAPI {
	private static var __cachedRateLimit(default, set):RateLimit;  // avoiding downloading everytime  - Nex
	private static var __lastUpdate:Float = 0;
	private static inline function set___cachedRateLimit(value:RateLimit) {
		__lastUpdate = Date.now().getTime();
		return __cachedRateLimit = value;
	}

	/**
	 * Checks if the GitHub's API is useable without getting rate limited (IP based) and already decreases (locally) the remaining uses.
	 * @param uses How many uses to decrease from the remaining uses.
	 * @return Whether the API can be used or not.
	 */
	public static function checkAndUseApi(uses:Int = 1):Bool {
		if (__cachedRateLimit == null || Date.now().getTime() > __lastUpdate + 120000)  // updates anyways every two minutes  - Nex
			__cachedRateLimit = getRateLimit();

		if (__cachedRateLimit != null && __cachedRateLimit.rate.remaining >= uses) {
			for (info in [__cachedRateLimit.rate, __cachedRateLimit.resources.core]) {
				info.remaining -= uses;
				info.used += uses;
			}

			return canUseApi(false);
		}
		return false;
	}

	/**
	 * Checks if the GitHub's API is useable without getting rate limited (IP based).
	 * @return Whether the API can be used or not.
	 */
	public static inline function canUseApi(download:Bool = true):Bool {
		if (download) __cachedRateLimit = getRateLimit();
		return __cachedRateLimit != null && __cachedRateLimit.rate.remaining > 0;
	}

	/**
	 * Gets the user IP's rate limit from the GitHub API.
	 * @return Rate Limits
	 */
	public static inline function getRateLimit(?onError:Exception->Void):RateLimit
		return _getAndParse('https://api.github.com/rate_limit', onError, false);

	/**
	 * Gets all the releases from a specific GitHub repository using the GitHub API.
	 * @param user The user/organization that owns the repository
	 * @param repository The repository name
	 * @param onError Error Callback
	 * @return Releases
	 */
	public static inline function getReleases(user:String, repository:String, ?onError:Exception->Void, checkRateLimit:Bool = true):Array<Release> {
		var array = _getAndParse('https://api.github.com/repos/${user}/${repository}/releases', onError, checkRateLimit);
		return array == null ? [] : array;
	}

	/**
	 * Gets the contributors list from a specific GitHub repository using the GitHub API.
	 * @param user The user/organization that owns the repository
	 * @param repository The repository name
	 * @param onError Error Callback
	 * @return Contributors List
	 */
	public static inline function getContributors(user:String, repository:String, ?onError:Exception->Void, checkRateLimit:Bool = true):Array<Contributor> {
		var array = _getAndParse('https://api.github.com/repos/${user}/${repository}/contributors', onError, checkRateLimit);
		return array == null ? [] : array;
	}

	/**
	 * Gets a specific GitHub organization using the GitHub API.
	 * @param org The organization to get
	 * @param onError Error Callback
	 * @return Organization
	 */
	public static inline function getOrganization(org:String, ?onError:Exception->Void, checkRateLimit:Bool = true):Organization
		return _getAndParse('https://api.github.com/orgs/$org', onError, checkRateLimit);

	/**
	 * Gets the members list from a specific GitHub organization using the GitHub API.
	 * NOTE: Members use Contributors' structure!
	 * @param org The organization to get the members from
	 * @param onError Error Callback
	 * @return Members List
	 */
	public static inline function getOrganizationMembers(org:String, ?onError:Exception->Void, checkRateLimit:Bool = true):Array<Contributor> {
		var array = _getAndParse('https://api.github.com/orgs/$org/members', onError, checkRateLimit);
		return array == null ? [] : array;
	}

	/**
	 * Gets a specific GitHub user/organization using the GitHub API.
	 * NOTE: If organization, it will be returned with the structure of a normal user; use `getOrganization` if you specifically want an organization!
	 * @param user The user/organization to get
	 * @param onError Error Callback
	 * @return User/Organization
	 */
	public static inline function getUser(user:String, ?onError:Exception->Void, checkRateLimit:Bool = true):User
		return _getAndParse('https://api.github.com/users/$user', onError, checkRateLimit);

	/**
	 * Filters all releases gotten by `getReleases`
	 * @param releases Releases
	 * @param keepPrereleases Whenever to keep Pre-Releases.
	 * @param keepDrafts Whenever to keep Drafts.
	 * @return Filtered releases.
	 */
	public static inline function filterReleases(releases:Array<Release>, keepPrereleases:Bool = true, keepDrafts:Bool = false)
		return [for(release in releases) if (release != null && (!release.prerelease || (release.prerelease && keepPrereleases)) && (!release.draft || (release.draft && keepDrafts))) release];

	private static function _getAndParse(url:String, ?onError:Exception->Void, checkRateLimit:Bool = true):Dynamic {
		try {
			if (checkRateLimit && !checkAndUseApi())
				throw new Exception("[GitHubException] You've got rate limited!");

			var data = Json.parse(_requestText(url));
			if (Reflect.hasField(data, "documentation_url"))
				throw __parseGitHubException(data);

			return data;
		} catch(e) {
			if (onError != null)
				onError(e);
		}
		return null;
	}

	private static inline function __parseGitHubException(obj:Dynamic):APIException {
		var msg:String = "(No message)";
		var url:String = "(No API url)";
		if (Reflect.hasField(obj, "message")) msg = Reflect.field(obj, "message");
		if (Reflect.hasField(obj, "documentation_url")) url = Reflect.field(obj, "documentation_url");
		return new APIException(msg, url);
	}

	private static inline function _requestText(url:String):String {
		var r:String = null;
		var h = new Http(url);
		h.setHeader("User-Agent", "request");

		h.onStatus = (s) -> if (s == 301 || s == 302 || s == 307 || s == 308) r = _requestText(h.responseHeaders.get("Location"));
		h.onData = (d) -> if (r == null) r = d;
		h.onError = (e) -> throw e;

		h.request(false);
		return r;
	}
}