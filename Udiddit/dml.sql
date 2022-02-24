-- DML queries
/*************************** Migrating users   ***************************/
INSERT INTO "users"("username")
    	SELECT DISTINCT "username"
			FROM bad_posts
			UNION
			SELECT DISTINCT "username"
			FROM bad_comments
			UNION
			SELECT  DISTINCT regexp_split_to_table(upvotes, ',') upvoter_username
			FROM bad_posts
			UNION
			SELECT  DISTINCT regexp_split_to_table(downvotes, ',') downvoter_username
			FROM bad_posts;

/*************************** Migrating topics  ***************************/

INSERT INTO "topics"("topic")
			SELECT DISTINCT topic
			FROM bad_posts;

/*************************** Migrating posts  ***************************/

INSERT INTO "posts"("title", "url", "text_content", "topic_id", "user_id")
			SELECT LEFT(bp.title,100), bp.url, bp.text_content, t.id, u.id
			FROM bad_posts AS bp
			JOIN topics AS t
			ON bp.topic = t.topic
			JOIN users AS u
			ON bp.username = u.username;

/*************************** Migrating comments  ***************************/

INSERT INTO "comments"("text_content","post_id", "user_id" )
		SELECT bc.text_content, p.id, u.id
		FROM bad_comments AS bc
		JOIN bad_posts AS bp
		ON bc.post_id = bp.id
		JOIN posts AS p
		ON p.title = bp.post_title
		JOIN users AS u
		ON bc.username = u.username?

/*************************** Migrating votes  ***************************/

INSERT INTO "votes"("post_vote", "user_id", "post_id")
WITH "upvoters" AS(
				SELECT "title" post_title, 
						   regexp_split_to_table(upvotes, ',') upvoter_username,
			 			   1 AS vote_value
				FROM bad_posts),
			
	  "downvoters" AS(
		 		SELECT "title" post_title,  
		 				   regexp_split_to_table(downvotes, ',') downvoter_username,
		 				   -1 AS vote_value
		 		FROM bad_posts)
		 
SELECT up.vote_value vote_value,
	   u.id user_id,
	   po.id post_id		 
FROM upvoters AS up
JOIN users AS u
ON u.username = up.upvoter_username
JOIN posts AS po
ON po.title = up.post_title
UNION 
SELECT dn.vote_value vote_value, 
	   u.id user_id,
	   po.id AS post_id			 
FROM downvoters AS dn
JOIN users AS u
ON u.username = dn.downvoter_username
JOIN posts AS po
ON po.title = dn.post_title;
