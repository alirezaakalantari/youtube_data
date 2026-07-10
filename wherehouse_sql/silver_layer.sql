CREATE TABLE  silver.event (
    username String,
    userid String,
    avatar_thumbnail String,
    is_official UInt8,
    name String,
    bio_link String , 
    total_video_visit UInt64,
    video_count UInt64,
    start_date Date,
    start_date_timestamp UInt64,
    followers_count UInt64,
    following_count UInt64,
    country String,
    platform String,
    account_created_at DateTime,
    account_update_count UInt64 ,
    ---
    video_id UInt32,
    video_title String,
    video_tags Array(String),
    video_uid String,
    video_visit_count UInt32,
    video_duration UInt32,
    video_posted_date Date,
    video_sdate_rss Date,
    video_comments Nullable(UInt32),
    video_frame Nullable(String),
    video_like_count Nullable(UInt32),
    video_description String,
    video_created_at DateTime,
    video_update_count UInt32,
    -- Metadata Fields
    created_at Nullable(DateTime) ,
    update_count Nullable(UInt32)
)ENGINE MergeTree
ORDER BY video_id
;
CREATE MATERIALIZED VIEW silver.mv_event TO silver.event POPULATE AS
    SELECT
    p.username ,
    p.userid ,
    p.avatar_thumbnail ,
    p.is_official ,
    p.name ,
    p.bio_links , 
    p.total_video_visit ,
    p.video_count ,
    p.start_date ,
    p.start_date_timestamp ,
    p.followers_count ,
    p.following_count ,
    p.country ,
    p.platform ,
    p.created_at ,
    p.update_count ,
    ---
    m.video_id ,
    m.video_title ,
    m.video_tags ,
    m.video_uid ,
    m.video_visit_count ,
    m.video_duration ,
    m.video_posted_date ,
    m.video_sdate_rss ,
    m.video_comments ,
    m.video_frame ,
    m.video_like_count ,
    m.video_description ,
    m.video_created_at ,
    m.video_update_count


FROM raw.MONGODB_STORAGE m
INNER JOIN raw.postgres_storage p
ON p.userid = m.video_owner_id ;

CREATE MATERIALIZED VIEW silver.mv_event TO silver.event POPULATE AS
    SELECT
    p.username ,
    p.userid ,
    p.avatar_thumbnail ,
    p.is_official ,
    p.name ,
    p.bio_links ,
    p.total_video_visit ,
    p.video_count ,
    p.start_date ,
    p.start_date_timestamp ,
    p.followers_count ,
    p.following_count ,
    p.country ,
    p.platform ,
    p.created_at ,
    p.update_count ,
    ---
    m.video_id ,
    m.video_title ,
    m.video_tags ,
    m.video_uid ,
    m.video_visit_count ,
    m.video_duration ,
    m.video_posted_date ,
    m.video_sdate_rss ,
    m.video_comments ,
    m.video_frame ,
    m.video_like_count ,
    m.video_description ,
    m.video_created_at ,
    m.video_update_count


FROM raw.postgres_storage p
INNER JOIN raw.mongodb_storage m
ON p.userid = m.video_owner_id ;
