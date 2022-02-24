-- Initialize Tables
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS topics CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS comments CASCADE;
DROP TABLE IF EXISTS votes CASCADE;

/******************* Creating users Table ******************************/
CREATE TABLE "users" (
	"id" SERIAL PRIMARY KEY,
	"username" VARCHAR(25) UNIQUE NOT NULL,
	"last_logon" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT "non_empty_username" CHECK(LENGTH(TRIM("username")) > 0)
);

/******************* Creating topics Table ******************************/

CREATE TABLE "topics"(
	"id" SERIAL PRIMARY KEY,
	"topic" VARCHAR(30) NOT NULL,
	"topic_description" VARCHAR(500) DEFAULT NULL,
	"user_id" INTEGER NOT NULL,
	CONSTRAINT "non_empty_topic_name" CHECK(LENGTH(TRIM("topic")) > 0),
	CONSTRAINT "topics_users_FK" FOREIGN KEY ("user_id") REFERENCES "users"("id")
);
-- Creating An index for searching topics by topic name
CREATE INDEX "topic_by_name" ON "topics"("topic");
/******************* Creating posts Table ******************************/
CREATE TABLE "posts"(
	"id" SERIAL PRIMARY KEY,
	"title" VARCHAR(100) NOT NULL,
	"url" VARCHAR DEFAULT NULL,
	"text_content" TEXT DEFAULT NULL,
	"topic_id" INTEGER NOT NULL,
	"user_id"	INTEGER,
	"created_on" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT "non_empty_title"  CHECK(LENGTH(TRIM("title")) > 0),
	FOREIGN KEY("topic_id") REFERENCES "topics"("id") ON DELETE CASCADE,
	FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE SET NULL,
	CONSTRAINT "url_OR_text" CHECK(("url" IS NOT NULL AND "text_content" IS NULL)
			OR("url" IS NULL AND "text_content" IS NOT NULL))
);

-- Create an Index for finding users by user_id in posts
CREATE INDEX "find_user_ids_in_posts" ON "posts" ("user_id");
-- Index to find posts with URL.
CREATE INDEX "find_posts_with_URL" ON "posts" ("URL");
/******************* Creating comments Table ******************************/

CREATE TABLE "comments"(
	"id" SERIAL PRIMARY KEY,
	"parent_id" INTEGER DEFAULT NULL,
	"user_id" INTEGER,
	"post_id" BIGINT NOT NULL,
	"created_on" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	"text_content" TEXT NOT NULL,
	CONSTRAINT "Non_empty_text_content" CHECK(LENGTH(TRIM("text_content")) > 0),
	FOREIGN KEY("parent_id") REFERENCES "comments"("id") ON DELETE CASCADE,
	FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE SET NULL,
	FOREIGN KEY("post_id") REFERENCES "posts"("id") ON DELETE CASCADE
);

-- Creating an Index for searching comments without parrent bad_posts
CREATE INDEX "finding_comments_no_parent_on_a_post" ON "comments"("parent_id",
"post_id", "text_content") WHERE "parent_id" = NULL;
        
/******************* Creating votes Table ******************************/
CREATE TABLE "votes"(
	"id" SERIAL PRIMARY KEY,
	"post_vote" SMALLINT,
	"user_id" INTEGER,
	"post_id" BIGINT NOT NULL,
	FOREIGN KEY("user_id") REFERENCES "users"("id") ON DELETE SET NULL,
	FOREIGN KEY("post_id") REFERENCES "posts"("id") ON DELETE CASCADE,
	CONSTRAINT "post_vote_value" CHECK("post_vote" = 1 OR "post_vote" = -1),
	CONSTRAINT "unique_vote" UNIQUE("user_id", "post_id")
);

-- Index to find score of post.
CREATE INDEX "find_score_of_post" ON "votes" ("post_vote", "post_id"); 
