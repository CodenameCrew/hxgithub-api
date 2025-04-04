package github.api.structures;

typedef Asset = {
	var url:String;
	var id:Int;
	var node_id:String;
	var name:String;
	var label:String;
	var uploader:User;
	var content_type:String;
	var state:String;
	var size:UInt;
	var download_count:Int;
	var created_at:String;
	var updated_at:String;
	var browser_download_url:String;
}