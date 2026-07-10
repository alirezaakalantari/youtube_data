--init.sql
CREATE TABLE channels (
    channel_id TEXT, 
    channel_username TEXT, 
    channel_userid TEXT, 
    channel_avatar_thumbnail TEXT, 
    channel_is_official SMALLINT, 
    channel_name TEXT, 
    channel_bio_links TEXT, 
    channel_total_visits BIGINT, 
    channel_video_count BIGINT, 
    channel_start_date DATE, 
    channel_start_date_timestamp BIGINT, 
    channel_followers_count BIGINT, 
    channel_following_count BIGINT, 
    channel_country TEXT, 
    channel_platform TEXT, 
    channel_created_at TIMESTAMP, 
    channel_update_count BIGINT
);



COPY channels (channel_id, channel_username, channel_userid, channel_avatar_thumbnail, channel_is_official, channel_name, channel_bio_links, channel_total_visits, channel_video_count, channel_start_date, channel_start_date_timestamp, channel_followers_count, channel_following_count, channel_country, channel_platform, channel_created_at, channel_update_count)
FROM '/root/channels/channels_export.csv'
DELIMITER ',' 
CSV HEADER;