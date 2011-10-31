function to_agree(commentable_type, commentable_id, id) {
	new Ajax.Request('/commentable/' + commentable_type + '/' + commentable_id + '/comments/' + id + '/agree',
		{ method : 'post'} );
}

function to_disagree(commentable_type, commentable_id, id) {
	new Ajax.Request('/commentable/' + commentable_type + '/' + commentable_id + '/comments/' + id + '/disagree',
		{ method : 'post'} );
}
