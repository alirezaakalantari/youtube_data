CREATE TABLE raw.MONGODB_STORAGE  (
    video_id UInt32,
    video_owner_username String,
    video_owner_id String,
    video_title String,
    video_tags Array(String),
    video_uid String,
    video_visit_count UInt32,
    video_owner_name String,
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
) ENGINE = ReplacingMergeTree(video_created_at)
ORDER BY video_id;

CREATE TABLE raw.postgres_storage  (
    _id String,
    username String,
    userid String,
    avatar_thumbnail String,
    is_official UInt8,
    name String,
    bio_links String , 
    total_video_visit UInt64,
    video_count UInt64,
    start_date Date,
    start_date_timestamp UInt64,
    followers_count UInt64,
    following_count UInt64,
    country String,
    platform String,
    created_at DateTime,
    update_count UInt64

) ENGINE = ReplacingMergeTree(created_at)
ORDER BY _id;