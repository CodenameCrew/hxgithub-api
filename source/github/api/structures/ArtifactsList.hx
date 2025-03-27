package github.api.structures;

typedef ArtifactsList = {
	var total_count:Int;
	var artifacts:Array<Artifact>;
}

typedef Artifact = {
	var id:Int;
	var node_id:String;
	var name:String;
	var size_in_bytes:Int;
	var url:String;
	var archive_download_url:String;
	var expired:Bool;
	var created_at:String;
	var expires_at:String;
	var updated_at:String;
	var ?digest:String;
	var ?workflow_run:WorkflowRun;
}

typedef WorkflowRun = {
	var id:Int;
	var repository_id:Int;
	var head_repository_id:Int;
	var head_branch:String;
	var head_sha:String;
}