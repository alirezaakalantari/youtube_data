--FIRST TABLE
CREATE TABLE GOLDEN.Channel_Growth (
    username String ,
    name AggregateFunction(any , String),
    date DATE ,
    followers_count AggregateFunction(any , UInt64),
    video_count AggregateFunction(any , UInt64),
    video_visit_count AggregateFunction(sum , UInt32)


)ENGINE = AggregatingMergeTree()
ORDER BY (username , date) ;

CREATE MATERIALIZED VIEW GOLDEN.mv_Channel_Growth TO GOLDEN.Channel_Growth POPULATE POPULATE AS
    SELECT
        username ,
        anyState(event.name) ,
        event.video_posted_date,
        anyState(event.followers_count),
        anyState(event.video_count),
        sumState(event.video_visit_count)

    FROM silver.event AS event
    GROUP BY event.username , event.video_posted_date  ;
--second TABLE
-- I decided to determinate 100 as the limit rate for demonstrating a list of the highest youtube accounts
CREATE  TABLE GOLDEN.TOP_PERFORM (
    username String,
    name AggregateFunction(any , String) ,
    followers AggregateFunction(any , UInt64) ,
    video_visit AggregateFunction(sum , UInt32),
    video_count AggregateFunction(any , UInt64)

)ENGINE = AggregatingMergeTree()
PRIMARY KEY username
;
CREATE MATERIALIZED VIEW GOLDEN.mv_TOP_PERFORM TO GOLDEN.TOP_PERFORM POPULATE AS
    SELECT
        username ,
        anyState(event.name) ,
        anyState(event.followers_count) AS followers,
        sumState(event.video_visit_count) AS video_visit,
        anyState(event.video_count) AS video_count

    FROM silver.event AS event
    GROUP BY (username)
    ORDER BY (followers ,video_visit, video_count ) DESC
    LIMIT 100;
--3rd Table
--video engagement metrics
--AS far as there is no need for aggregate or merge any component so we can just write an ordinary VIEW
CREATE VIEW GOLDEN.video_engagement AS
    SELECT
        event.name AS "account_name",
        event.video_visit_count  ,
        event.video_like_count ,
        event.video_comments
    FROM silver.event AS event
    ORDER BY (event.video_visit_count , event.video_like_count);


--4th TABLE
-- in this way we can categorize contents by the tags
-- so at first we flatten the video_tages (arrey(string)) and then group the table with tag
-- if consider that the video title is not the name of the video and it's the content of it
CREATE TABLE GOLDEN.content (
    tag String ,
    video_title String ,
    visit_counts AggregateFunction(sum , UInt32 )

)ENGINE AggregatingMergeTree ()
PRIMARY KEY tag
 ;
CREATE MATERIALIZED VIEW GOLDEN.mv_content TO GOLDEN.content POPULATE AS
    SELECT
        arrayJoin(event.video_tags) AS tag,
        event.video_title ,
        sumState(event.video_visit_count)
    FROM silver.event AS event
    GROUP BY event.video_title , event.video_tags ;


--5th Table
-- aggregate the table by country
CREATE TABLE GOLDEN.geographic_distribution (
    country String ,
    followers_count AggregateFunction(sum , UInt32 ) ,
    video_visit AggregateFunction(sum , UInt32 )
)ENGINE AggregatingMergeTree
PRIMARY KEY country ;

CREATE MATERIALIZED VIEW GOLDEN.mv_geographic_distribution TO GOLDEN.geographic_distribution POPULATE AS
    SELECT
        event.country ,
        sumState(event.followers_count) ,
        sumState(event.video_visit_count)
    FROM silver.event AS event
    GROUP BY event.country  ;

